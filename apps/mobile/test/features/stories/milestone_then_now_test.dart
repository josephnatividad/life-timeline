import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/features/media/domain/memory_media_repository.dart';
import 'package:life_timeline/features/stories/application/deterministic_milestone_engine.dart';
import 'package:life_timeline/features/stories/application/story_source_factory.dart';
import 'package:life_timeline/features/stories/domain/milestone_models.dart';
import 'package:life_timeline/features/stories/domain/story_models.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';
import 'package:life_timeline/shared/domain/model/temporal_value.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';
import 'package:life_timeline/shared/domain/repositories/timeline_repository.dart';

void main() {
  const engine = DeterministicMilestoneEngine();
  final now = DateTime.utc(2026, 8, 11);

  test('exact 1, 5, 10, and 20 year anniversaries may say today', () {
    final memories = [
      for (final years in const [1, 5, 10, 20])
        _memory(
          'event-$years',
          TemporalValue.exactDate(
            year: now.year - years,
            month: now.month,
            day: now.day,
          ),
        ),
    ];

    final milestones = engine.detect(memories, now: now);

    expect(milestones, hasLength(4));
    expect(milestones.every((item) => item.isExactToday), isTrue);
    expect(
      milestones.map((item) => item.headline),
      contains('10 years ago today'),
    );
  });

  test('approximate and year-only dates use approximate wording', () {
    final milestones = engine.detect([
      _memory(
        'approximate',
        TemporalValue.approximate(TemporalPoint(year: 2016)),
      ),
      _memory('year-only', TemporalValue.year(2021)),
    ], now: now);

    expect(
      milestones.map((item) => item.headline),
      contains('About 10 years ago'),
    );
    expect(
      milestones.map((item) => item.headline),
      contains('About 5 years ago'),
    );
    expect(
      milestones.every((item) => !item.headline.contains('today')),
      isTrue,
    );
  });

  test('insufficient or unsupported temporal data creates no anniversary', () {
    final milestones = engine.detect([
      _memory('unknown', TemporalValue.unknown()),
      _memory(
        'wrong-day',
        TemporalValue.exactDate(year: 2016, month: 8, day: 10),
      ),
      _memory(
        'range',
        TemporalValue.range(
          start: TemporalPoint(year: 2015),
          end: TemporalPoint(year: 2017),
        ),
      ),
    ], now: now);

    expect(
      milestones.where((item) => item.type == MilestoneType.anniversary),
      isEmpty,
    );
  });

  test('100th confirmed memory and device ordinals are deterministic', () {
    final memories = [
      for (var index = 0; index < 100; index++)
        _memory(
          'event-$index',
          TemporalValue.year(1900 + index),
          entity: index < 10
              ? _entity('phone-$index', 'Phone $index', 'phone')
              : null,
          eventType: index < 10 ? 'Purchased' : 'Milestone',
        ),
    ];

    final milestones = engine.detect(memories, now: now);

    expect(
      milestones.where((item) => item.type == MilestoneType.hundredthMemory),
      hasLength(1),
    );
    expect(
      milestones.where((item) => item.type == MilestoneType.deviceOrdinal),
      hasLength(2),
    );
  });

  test('10,000-memory milestone scan remains bounded for local use', () {
    final memories = [
      for (var index = 0; index < 10000; index++)
        _memory(
          'scale-event-$index',
          TemporalValue.year(1900 + (index % 126)),
          entity: index < 100
              ? _entity('device-$index', 'Device $index', 'phone')
              : null,
          eventType: index < 100 ? 'Purchased' : 'Milestone',
        ),
    ];
    final stopwatch = Stopwatch()..start();

    final milestones = engine.detect(memories, now: now);
    stopwatch.stop();

    expect(
      milestones,
      contains(
        isA<MilestoneCandidate>().having(
          (item) => item.type,
          'type',
          MilestoneType.hundredthMemory,
        ),
      ),
    );
    expect(stopwatch.elapsed, lessThan(const Duration(seconds: 5)));
  });

  test('Then & Now rejects the same source and supports missing media', () {
    final factory = LocalStorySourceFactory(
      _UnusedTimelineRepository(),
      _UnusedMemoryMediaRepository(),
      const _UnusedPathResolver(),
    );
    final first = _source('first', 'First phone');
    final second = _source('second', 'Current phone');

    expect(() => factory.thenAndNow(first, first), throwsArgumentError);

    final pair = factory.thenAndNow(first, second);
    expect(pair.sourceType, StorySourceType.thenNow);
    expect(pair.media, isEmpty);
    expect(
      pair.fields.map((field) => field.id),
      containsAll(['then.title', 'now.title']),
    );
  });
}

TimelineMemory _memory(
  String id,
  TemporalValue temporal, {
  Entity? entity,
  String? eventType,
}) => TimelineMemory(
  event: Event(
    metadata: _metadata(id),
    title: 'Memory $id',
    temporalValue: temporal,
    eventType: eventType,
  ),
  relatedEntity: entity,
);

Entity _entity(String id, String name, String type) =>
    Entity(metadata: _metadata(id), name: name, entityType: type);

RecordMetadata _metadata(String id) => RecordMetadata(
  id: id,
  privacyClassification: PrivacyClassification.shareSafe,
  lifecycle: RecordLifecycle.confirmed,
  createdAt: DateTime.utc(2020),
  updatedAt: DateTime.utc(2020),
);

StorySource _source(String id, String title) => StorySource(
  id: id,
  sourceType: StorySourceType.event,
  title: title,
  sourceRecordIds: [id],
  fields: [
    StoryField(
      id: '$id.title',
      label: 'Title',
      value: title,
      kind: StoryFieldKind.title,
      privacyClassification: PrivacyClassification.shareSafe,
      suggestedByDefault: true,
    ),
  ],
);

final class _UnusedPathResolver implements StoryAttachmentPathResolver {
  const _UnusedPathResolver();

  @override
  Future<String?> resolve(Attachment attachment) async => null;
}

final class _UnusedTimelineRepository implements TimelineRepository {
  Never _unused() => throw UnimplementedError();

  @override
  dynamic noSuchMethod(Invocation invocation) => _unused();
}

final class _UnusedMemoryMediaRepository implements MemoryMediaRepository {
  Never _unused() => throw UnimplementedError();

  @override
  dynamic noSuchMethod(Invocation invocation) => _unused();
}
