import 'package:life_timeline/features/stories/domain/milestone_models.dart';
import 'package:life_timeline/features/stories/domain/story_models.dart';
import 'package:life_timeline/shared/domain/formatting/temporal_label.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';
import 'package:life_timeline/shared/domain/model/temporal_value.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';
import 'package:life_timeline/shared/domain/repositories/timeline_repository.dart';

abstract interface class StoryAttachmentPathResolver {
  Future<String?> resolve(Attachment attachment);
}

abstract interface class StorySourceFactory {
  Future<StorySource?> fromEvent(String eventId);
  Future<StorySource?> fromEntity(String entityId);
  Future<StorySource?> fromMilestone(MilestoneCandidate milestone);
  StorySource thenAndNow(StorySource first, StorySource second);
}

final class LocalStorySourceFactory implements StorySourceFactory {
  const LocalStorySourceFactory(this._timeline, this._pathResolver);

  final StoryAttachmentPathResolver _pathResolver;
  final TimelineRepository _timeline;

  @override
  Future<StorySource?> fromEvent(String eventId) async {
    final memory = await _timeline.memoryById(eventId);
    if (memory == null ||
        memory.event.metadata.lifecycle != RecordLifecycle.confirmed) {
      return null;
    }
    final event = memory.event;
    final classification = event.metadata.privacyClassification;
    final relatedEntity =
        memory.relatedEntityRelationship?.metadata.lifecycle ==
            RecordLifecycle.confirmed
        ? memory.relatedEntity
        : null;
    final fields = <StoryField>[
      StoryField(
        id: 'event.title',
        label: 'Memory title',
        value: event.title,
        kind: StoryFieldKind.title,
        privacyClassification: classification,
        suggestedByDefault: classification == PrivacyClassification.shareSafe,
      ),
      if (event.temporalValue.start != null)
        StoryField(
          id: 'event.year',
          label: 'Year',
          value: '${event.temporalValue.start!.year}',
          kind: StoryFieldKind.year,
          privacyClassification: _strictest(
            classification,
            PrivacyClassification.shareSafe,
          ),
          suggestedByDefault: classification == PrivacyClassification.shareSafe,
        ),
      if (event.temporalValue.precision != TemporalPrecision.unknown)
        StoryField(
          id: 'event.date',
          label: 'Detailed date',
          value: TemporalLabel.format(event.temporalValue),
          kind: StoryFieldKind.date,
          privacyClassification: _strictest(
            classification,
            PrivacyClassification.personal,
          ),
        ),
      if (event.eventType?.trim().isNotEmpty ?? false)
        StoryField(
          id: 'event.type',
          label: 'Memory type',
          value: event.eventType!.trim(),
          kind: StoryFieldKind.category,
          privacyClassification: classification,
          suggestedByDefault: classification == PrivacyClassification.shareSafe,
        ),
      if (memory.category case final category?)
        StoryField(
          id: 'event.category',
          label: 'Category',
          value: category.name,
          kind: StoryFieldKind.category,
          privacyClassification: _strictest(
            classification,
            category.metadata.privacyClassification,
          ),
          suggestedByDefault:
              classification == PrivacyClassification.shareSafe &&
              category.metadata.privacyClassification ==
                  PrivacyClassification.shareSafe,
        ),
      if (relatedEntity case final entity?)
        StoryField(
          id: 'event.entity',
          label: 'Related thing or place',
          value: entity.name,
          kind: StoryFieldKind.location,
          privacyClassification: _strictest(
            classification,
            _strictest(
              entity.metadata.privacyClassification,
              memory
                      .relatedEntityRelationship
                      ?.metadata
                      .privacyClassification ??
                  PrivacyClassification.shareSafe,
            ),
          ),
          suggestedByDefault:
              classification == PrivacyClassification.shareSafe &&
              entity.metadata.privacyClassification ==
                  PrivacyClassification.shareSafe &&
              (memory
                          .relatedEntityRelationship
                          ?.metadata
                          .privacyClassification ??
                      PrivacyClassification.shareSafe) ==
                  PrivacyClassification.shareSafe,
        ),
      if (event.description?.trim().isNotEmpty ?? false)
        StoryField(
          id: 'event.description',
          label: 'Memory details',
          value: event.description!.trim(),
          kind: StoryFieldKind.detail,
          privacyClassification: _strictest(
            classification,
            PrivacyClassification.personal,
          ),
        ),
    ];
    return StorySource(
      id: 'event:$eventId',
      sourceType: StorySourceType.event,
      title: event.title,
      sourceRecordIds: [eventId],
      fields: fields,
      media: await _mediaForEvent(event, classification),
      temporalPrecision: event.temporalValue.precision,
    );
  }

  @override
  Future<StorySource?> fromEntity(String entityId) async {
    final entity = await _timeline.entityById(entityId);
    if (entity == null ||
        entity.metadata.lifecycle != RecordLifecycle.confirmed) {
      return null;
    }
    final relationships = await _timeline.relationshipsFor(
      TimelineRecordReference(type: TimelineRecordType.entity, id: entityId),
    );
    final eventLinks =
        <({Event event, PrivacyClassification relationshipPrivacy})>[];
    for (final relationship in relationships) {
      if (relationship.metadata.lifecycle != RecordLifecycle.confirmed ||
          relationship.metadata.privacyClassification ==
              PrivacyClassification.neverShare) {
        continue;
      }
      final eventId = _otherId(
        relationship,
        TimelineRecordType.event,
        entityId,
      );
      if (eventId == null) continue;
      final event = await _timeline.eventById(eventId);
      if (event?.metadata.lifecycle == RecordLifecycle.confirmed) {
        eventLinks.add((
          event: event!,
          relationshipPrivacy: relationship.metadata.privacyClassification,
        ));
      }
    }
    eventLinks.sort((left, right) => _eventChronology(left.event, right.event));
    final events = eventLinks.map((link) => link.event).toList();
    final classification = entity.metadata.privacyClassification;
    final historyClassification = eventLinks.fold(
      classification,
      (strictest, link) => _strictest(
        strictest,
        _strictest(
          link.event.metadata.privacyClassification,
          link.relationshipPrivacy,
        ),
      ),
    );
    final fields = <StoryField>[
      StoryField(
        id: 'entity.title',
        label: 'Entity name',
        value: entity.name,
        kind: StoryFieldKind.title,
        privacyClassification: classification,
        suggestedByDefault: classification == PrivacyClassification.shareSafe,
      ),
      StoryField(
        id: 'entity.type',
        label: 'Entity type',
        value: entity.entityType,
        kind: StoryFieldKind.category,
        privacyClassification: classification,
        suggestedByDefault: classification == PrivacyClassification.shareSafe,
      ),
      if (events.isNotEmpty)
        StoryField(
          id: 'entity.memoryCount',
          label: 'Confirmed memories',
          value: '${events.length}',
          kind: StoryFieldKind.statistic,
          privacyClassification: historyClassification,
          suggestedByDefault:
              historyClassification == PrivacyClassification.shareSafe,
        ),
      if (events.firstOrNull?.temporalValue.start case final first?)
        StoryField(
          id: 'entity.firstYear',
          label: 'First recorded year',
          value: '${first.year}',
          kind: StoryFieldKind.year,
          privacyClassification: historyClassification,
          suggestedByDefault:
              historyClassification == PrivacyClassification.shareSafe,
        ),
      if (entity.notes?.trim().isNotEmpty ?? false)
        StoryField(
          id: 'entity.notes',
          label: 'Private notes',
          value: entity.notes!.trim(),
          kind: StoryFieldKind.detail,
          privacyClassification: _strictest(
            classification,
            PrivacyClassification.personal,
          ),
        ),
    ];
    final media = <StoryMedia>[];
    for (final link in eventLinks) {
      media.addAll(
        await _mediaForEvent(
          link.event,
          _strictest(classification, link.relationshipPrivacy),
        ),
      );
      if (media.isNotEmpty) break;
    }
    return StorySource(
      id: 'entity:$entityId',
      sourceType: StorySourceType.entity,
      title: entity.name,
      sourceRecordIds: [entityId, ...events.map((event) => event.metadata.id)],
      fields: fields,
      media: media,
      temporalPrecision: events.firstOrNull?.temporalValue.precision,
    );
  }

  @override
  Future<StorySource?> fromMilestone(MilestoneCandidate milestone) async {
    final eventSource = await fromEvent(milestone.sourceRecordIds.first);
    if (eventSource == null) return null;
    final fields = <StoryField>[
      StoryField(
        id: 'milestone.title',
        label: 'Milestone',
        value: milestone.headline,
        kind: StoryFieldKind.title,
        privacyClassification: milestone.privacyClassification,
        suggestedByDefault:
            milestone.privacyClassification == PrivacyClassification.shareSafe,
      ),
      StoryField(
        id: 'milestone.detail',
        label: 'Milestone detail',
        value: milestone.detail,
        kind: StoryFieldKind.statistic,
        privacyClassification: milestone.privacyClassification,
        suggestedByDefault:
            milestone.privacyClassification == PrivacyClassification.shareSafe,
      ),
    ];
    return StorySource(
      id: 'milestone:${milestone.id}',
      sourceType: StorySourceType.milestone,
      title: milestone.headline,
      sourceRecordIds: milestone.sourceRecordIds,
      fields: fields,
      media: eventSource.media,
      temporalPrecision: eventSource.temporalPrecision,
    );
  }

  @override
  StorySource thenAndNow(StorySource first, StorySource second) {
    if (first.id == second.id) {
      throw ArgumentError('Then & Now requires two different records.');
    }
    if (first.sourceType == StorySourceType.thenNow ||
        second.sourceType == StorySourceType.thenNow) {
      throw ArgumentError('A Then & Now pair cannot contain another pair.');
    }
    return StorySource(
      id: 'then-now:${first.id}:${second.id}',
      sourceType: StorySourceType.thenNow,
      title: 'Then & Now',
      sourceRecordIds: {
        ...first.sourceRecordIds,
        ...second.sourceRecordIds,
      }.toList(),
      fields: [
        ..._pairFields('then', 'Then', first),
        ..._pairFields('now', 'Now', second),
      ],
      media: [
        for (final media in first.media.take(1))
          StoryMedia(
            id: 'then.${media.id}',
            label: 'Then photo',
            kind: media.kind,
            localPath: media.localPath,
            privacyClassification: media.privacyClassification,
            suggestedByDefault: media.suggestedByDefault,
          ),
        for (final media in second.media.take(1))
          StoryMedia(
            id: 'now.${media.id}',
            label: 'Now photo',
            kind: media.kind,
            localPath: media.localPath,
            privacyClassification: media.privacyClassification,
            suggestedByDefault: media.suggestedByDefault,
          ),
      ],
    );
  }

  List<StoryField> _pairFields(
    String prefix,
    String label,
    StorySource source,
  ) {
    final title = source.fields
        .where((field) => field.kind == StoryFieldKind.title)
        .firstOrNull;
    final year = source.fields
        .where((field) => field.kind == StoryFieldKind.year)
        .firstOrNull;
    return [
      if (title != null)
        StoryField(
          id: '$prefix.title',
          label: '$label title',
          value: title.value,
          kind: StoryFieldKind.title,
          privacyClassification: title.privacyClassification,
          suggestedByDefault: title.suggestedByDefault,
        ),
      if (year != null)
        StoryField(
          id: '$prefix.year',
          label: '$label year',
          value: year.value,
          kind: StoryFieldKind.year,
          privacyClassification: year.privacyClassification,
          suggestedByDefault: year.suggestedByDefault,
        ),
    ];
  }

  Future<List<StoryMedia>> _mediaForEvent(
    Event event,
    PrivacyClassification sourceClassification,
  ) async {
    final relationships = await _timeline.relationshipsFor(
      TimelineRecordReference(
        type: TimelineRecordType.event,
        id: event.metadata.id,
      ),
    );
    final media = <StoryMedia>[];
    for (final relationship in relationships) {
      if (relationship.metadata.lifecycle != RecordLifecycle.confirmed) {
        continue;
      }
      final evidenceId = _otherId(
        relationship,
        TimelineRecordType.evidence,
        event.metadata.id,
      );
      if (evidenceId == null) continue;
      final evidence = await _timeline.evidenceById(evidenceId);
      if (evidence == null ||
          evidence.metadata.lifecycle != RecordLifecycle.confirmed) {
        continue;
      }
      for (final attachment in await _timeline.attachmentsForEvidence(
        evidenceId,
      )) {
        if (!attachment.mimeType.toLowerCase().startsWith('image/')) continue;
        final localPath = await _pathResolver.resolve(attachment);
        if (localPath == null) continue;
        final classification = _strictest(
          sourceClassification,
          _strictest(
            relationship.metadata.privacyClassification,
            _strictest(
              evidence.metadata.privacyClassification,
              attachment.metadata.privacyClassification,
            ),
          ),
        );
        media.add(
          StoryMedia(
            id: 'attachment:${attachment.metadata.id}',
            label: 'Selected photo',
            kind: StoryMediaKind.image,
            localPath: localPath,
            privacyClassification: classification,
            suggestedByDefault:
                classification == PrivacyClassification.shareSafe,
          ),
        );
      }
    }
    return media;
  }

  String? _otherId(
    Relationship relationship,
    TimelineRecordType desiredType,
    String knownId,
  ) {
    if (relationship.source.id == knownId &&
        relationship.target.type == desiredType) {
      return relationship.target.id;
    }
    if (relationship.target.id == knownId &&
        relationship.source.type == desiredType) {
      return relationship.source.id;
    }
    return null;
  }

  int _eventChronology(Event left, Event right) {
    final leftPoint = left.temporalValue.start;
    final rightPoint = right.temporalValue.start;
    if (leftPoint == null) return rightPoint == null ? 0 : 1;
    if (rightPoint == null) return -1;
    return _pointValue(leftPoint).compareTo(_pointValue(rightPoint));
  }

  int _pointValue(TemporalPoint point) =>
      point.year * 10000 + (point.month ?? 1) * 100 + (point.day ?? 1);

  PrivacyClassification _strictest(
    PrivacyClassification left,
    PrivacyClassification right,
  ) => left.index >= right.index ? left : right;
}
