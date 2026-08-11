import 'package:life_timeline/features/stories/domain/milestone_models.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';
import 'package:life_timeline/shared/domain/model/temporal_value.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

final class DeterministicMilestoneEngine implements MilestoneEngine {
  const DeterministicMilestoneEngine();

  static const _milestoneYears = {1, 5, 10, 20};

  @override
  List<MilestoneCandidate> detect(
    List<TimelineMemory> confirmedMemories, {
    required DateTime now,
  }) {
    final memories = confirmedMemories
        .where(
          (memory) =>
              memory.event.metadata.lifecycle == RecordLifecycle.confirmed,
        )
        .toList();
    final candidates = <MilestoneCandidate>[
      ..._anniversaries(memories, now.toUtc()),
      ..._memoryCountMilestones(memories),
      ..._deviceOrdinalMilestones(memories),
      ..._ownershipDurationMilestones(memories),
    ];
    candidates.sort((left, right) => left.id.compareTo(right.id));
    return candidates;
  }

  Iterable<MilestoneCandidate> _anniversaries(
    List<TimelineMemory> memories,
    DateTime now,
  ) sync* {
    for (final memory in memories) {
      final temporal = memory.event.temporalValue;
      final point = temporal.start;
      if (point == null) continue;
      final years = now.year - point.year;
      if (!_milestoneYears.contains(years)) continue;

      final exactToday =
          temporal.precision == TemporalPrecision.exactDate &&
          point.month == now.month &&
          point.day == now.day;
      final supportsApproximate = switch (temporal.precision) {
        TemporalPrecision.month => point.month == now.month,
        TemporalPrecision.year || TemporalPrecision.approximate => true,
        _ => false,
      };
      if (!exactToday && !supportsApproximate) continue;

      yield MilestoneCandidate(
        id: 'anniversary:$years:${memory.event.metadata.id}',
        type: MilestoneType.anniversary,
        headline: exactToday
            ? '$years ${years == 1 ? 'year' : 'years'} ago today'
            : 'About $years ${years == 1 ? 'year' : 'years'} ago',
        detail: memory.event.title,
        sourceRecordIds: [memory.event.metadata.id],
        privacyClassification: memory.event.metadata.privacyClassification,
        isExactToday: exactToday,
      );
    }
  }

  Iterable<MilestoneCandidate> _memoryCountMilestones(
    List<TimelineMemory> memories,
  ) sync* {
    if (memories.length < 100) return;
    final ordered = [...memories]..sort(_chronology);
    final hundredth = ordered[99];
    yield MilestoneCandidate(
      id: 'confirmed-memory:100:${hundredth.event.metadata.id}',
      type: MilestoneType.hundredthMemory,
      headline: '100 confirmed memories',
      detail: 'A century of moments preserved in your timeline.',
      sourceRecordIds: [hundredth.event.metadata.id],
      privacyClassification: PrivacyClassification.personal,
    );
  }

  Iterable<MilestoneCandidate> _deviceOrdinalMilestones(
    List<TimelineMemory> memories,
  ) sync* {
    final acquisitions = memories.where((memory) {
      final entity = memory.relatedEntity;
      return entity != null &&
          _isDevice(entity.entityType) &&
          _isAcquisition(memory.event.eventType);
    }).toList()..sort(_chronology);
    final distinct = <TimelineMemory>[];
    final seen = <String>{};
    for (final memory in acquisitions) {
      if (seen.add(memory.relatedEntity!.metadata.id)) distinct.add(memory);
    }
    for (final ordinal in const [5, 10]) {
      if (distinct.length < ordinal) continue;
      final memory = distinct[ordinal - 1];
      final entity = memory.relatedEntity!;
      yield MilestoneCandidate(
        id: 'device-ordinal:$ordinal:${entity.metadata.id}',
        type: MilestoneType.deviceOrdinal,
        headline: 'Your ${_ordinal(ordinal)} recorded device',
        detail: entity.name,
        sourceRecordIds: [memory.event.metadata.id, entity.metadata.id],
        privacyClassification: _strictest(
          memory.event.metadata.privacyClassification,
          _strictest(
            entity.metadata.privacyClassification,
            memory.relatedEntityRelationship?.metadata.privacyClassification ??
                PrivacyClassification.shareSafe,
          ),
        ),
      );
    }
  }

  Iterable<MilestoneCandidate> _ownershipDurationMilestones(
    List<TimelineMemory> memories,
  ) sync* {
    final byEntity = <String, List<TimelineMemory>>{};
    for (final memory in memories) {
      final entity = memory.relatedEntity;
      if (entity == null || !_isDevice(entity.entityType)) continue;
      byEntity.putIfAbsent(entity.metadata.id, () => []).add(memory);
    }
    ({TimelineMemory start, TimelineMemory end, int years})? longest;
    for (final history in byEntity.values) {
      final starts = history.where(
        (memory) => _isAcquisition(memory.event.eventType),
      );
      final ends = history.where(
        (memory) => _isDisposal(memory.event.eventType),
      );
      if (starts.isEmpty || ends.isEmpty) continue;
      final start = starts.reduce(
        (left, right) => _chronology(left, right) <= 0 ? left : right,
      );
      final end = ends.reduce(
        (left, right) => _chronology(left, right) >= 0 ? left : right,
      );
      final startYear = start.event.temporalValue.start?.year;
      final endYear = end.event.temporalValue.start?.year;
      if (startYear == null || endYear == null || endYear <= startYear) {
        continue;
      }
      final years = endYear - startYear;
      if (years < 5 || (longest != null && years <= longest.years)) continue;
      longest = (start: start, end: end, years: years);
    }
    if (longest case final value?) {
      final entity = value.start.relatedEntity!;
      yield MilestoneCandidate(
        id: 'ownership:${entity.metadata.id}:${value.years}',
        type: MilestoneType.ownershipDuration,
        headline: 'A notable ownership chapter',
        detail: 'You recorded about ${value.years} years with ${entity.name}.',
        sourceRecordIds: [
          value.start.event.metadata.id,
          value.end.event.metadata.id,
          entity.metadata.id,
        ],
        privacyClassification: _strictest(
          _strictest(
            value.start.event.metadata.privacyClassification,
            value.end.event.metadata.privacyClassification,
          ),
          _strictest(
            entity.metadata.privacyClassification,
            _strictest(
              value
                      .start
                      .relatedEntityRelationship
                      ?.metadata
                      .privacyClassification ??
                  PrivacyClassification.shareSafe,
              value
                      .end
                      .relatedEntityRelationship
                      ?.metadata
                      .privacyClassification ??
                  PrivacyClassification.shareSafe,
            ),
          ),
        ),
      );
    }
  }

  int _chronology(TimelineMemory left, TimelineMemory right) {
    final leftPoint = left.event.temporalValue.start;
    final rightPoint = right.event.temporalValue.start;
    if (leftPoint == null) return rightPoint == null ? 0 : 1;
    if (rightPoint == null) return -1;
    return _pointValue(leftPoint).compareTo(_pointValue(rightPoint));
  }

  int _pointValue(TemporalPoint point) =>
      point.year * 10000 + (point.month ?? 1) * 100 + (point.day ?? 1);

  bool _isAcquisition(String? value) => const {
    'bought',
    'purchase',
    'purchased',
    'acquired',
    'got',
  }.contains(value?.trim().toLowerCase());

  bool _isDisposal(String? value) => const {
    'sold',
    'disposed',
    'replaced',
    'retired',
  }.contains(value?.trim().toLowerCase());

  bool _isDevice(String value) => const {
    'phone',
    'smartphone',
    'mobile phone',
    'computer',
    'laptop',
    'tablet',
    'device',
  }.contains(value.trim().toLowerCase());

  String _ordinal(int value) => switch (value) {
    5 => '5th',
    10 => '10th',
    _ => '$value',
  };

  PrivacyClassification _strictest(
    PrivacyClassification left,
    PrivacyClassification right,
  ) => left.index >= right.index ? left : right;
}
