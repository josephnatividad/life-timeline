import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/features/media/infrastructure/drift_memory_media_repository.dart';
import 'package:life_timeline/features/stories/application/default_story_privacy_sanitizer.dart';
import 'package:life_timeline/features/stories/application/story_source_factory.dart';
import 'package:life_timeline/features/stories/domain/story_models.dart';
import 'package:life_timeline/shared/database/app_database.dart'
    hide Attachment, AttachmentLink, Entity, Event, Relationship;
import 'package:life_timeline/shared/database/repositories/drift_timeline_repository.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';
import 'package:life_timeline/shared/domain/model/temporal_value.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

void main() {
  late AppDatabase database;
  late DriftTimelineRepository repository;
  late DriftMemoryMediaRepository mediaRepository;
  late LocalStorySourceFactory factory;

  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftTimelineRepository(database);
    mediaRepository = DriftMemoryMediaRepository(database);
    factory = LocalStorySourceFactory(
      repository,
      mediaRepository,
      const _FixedPathResolver(),
    );

    final event = Event(
      metadata: _metadata('event-japan'),
      title: 'Visited Japan',
      description: 'Private travel notes',
      temporalValue: TemporalValue.exactDate(year: 2025, month: 4, day: 12),
      eventType: 'Travel',
    );
    final entity = Entity(
      metadata: _metadata(
        'entity-japan',
        privacy: PrivacyClassification.personal,
      ),
      name: 'Japan',
      entityType: 'country',
    );
    final entityRelationship = Relationship(
      metadata: _metadata(
        'relationship-entity',
        privacy: PrivacyClassification.sensitive,
      ),
      source: TimelineRecordReference(
        type: TimelineRecordType.event,
        id: event.metadata.id,
      ),
      target: TimelineRecordReference(
        type: TimelineRecordType.entity,
        id: entity.metadata.id,
      ),
      relationshipType: 'related_entity',
    );
    await repository.saveMemory(
      TimelineMemory(
        event: event,
        relatedEntity: entity,
        relatedEntityRelationship: entityRelationship,
      ),
    );
    final memoryPhoto = Attachment(
      metadata: _metadata(
        'attachment-memory-photo',
        privacy: PrivacyClassification.personal,
      ),
      storageState: AttachmentStorageState.local,
      importMode: AttachmentImportMode.preserveOriginal,
      mimeType: 'image/jpeg',
      byteSize: 1400,
      relativePath: 'memories/japan.jpg',
    );
    await mediaRepository.add(
      attachment: memoryPhoto,
      link: AttachmentLink(
        id: 'media-link-japan',
        attachmentId: memoryPhoto.metadata.id,
        eventId: event.metadata.id,
        role: AttachmentRole.heroMedia,
        sortOrder: 0,
        importedAt: DateTime.utc(2025),
      ),
    );
    final evidence = Evidence(
      metadata: _metadata(
        'evidence-photo',
        privacy: PrivacyClassification.sensitive,
      ),
      evidenceType: EvidenceType.other,
      title: 'Trip photo',
    );
    await repository.saveEvidence(
      evidence,
      attachments: [
        Attachment(
          metadata: _metadata(
            'attachment-photo',
            privacy: PrivacyClassification.sensitive,
          ),
          storageState: AttachmentStorageState.local,
          importMode: AttachmentImportMode.preserveOriginal,
          mimeType: 'image/jpeg',
          byteSize: 1200,
          relativePath: 'trip/photo.jpg',
        ),
      ],
    );
    await repository.saveRelationship(
      Relationship(
        metadata: _metadata(
          'relationship-evidence',
          privacy: PrivacyClassification.neverShare,
        ),
        source: TimelineRecordReference(
          type: TimelineRecordType.evidence,
          id: evidence.metadata.id,
        ),
        target: TimelineRecordReference(
          type: TimelineRecordType.event,
          id: event.metadata.id,
        ),
        relationshipType: 'supports',
      ),
    );
  });

  tearDown(() => database.close());

  test(
    'confirmed event becomes a typed source with classified media',
    () async {
      final source = await factory.fromEvent('event-japan');

      expect(source, isNotNull);
      expect(source!.sourceType, StorySourceType.event);
      expect(source.fields.map((field) => field.id), contains('event.date'));
      expect(
        source.fields
            .singleWhere((field) => field.id == 'event.date')
            .privacyClassification,
        PrivacyClassification.personal,
      );
      expect(source.media.single.localPath, 'C:/local/story-photo.jpg');
      expect(
        source.media.single.privacyClassification,
        PrivacyClassification.personal,
      );
      expect(source.media.single.id, 'memory-media:media-link-japan');
      expect(
        source.media.map((media) => media.id),
        isNot(contains('attachment:evidence-photo')),
      );
      expect(
        source.fields
            .singleWhere((field) => field.id == 'event.entity')
            .privacyClassification,
        PrivacyClassification.sensitive,
      );
    },
  );

  test(
    'default sanitization cannot leak description, entity, or photo',
    () async {
      final source = (await factory.fromEvent('event-japan'))!;
      final result = const DefaultStoryPrivacySanitizer().sanitize(
        source,
        StoryPrivacySelection.defaultsFor(source),
      );

      expect(
        result.includedFields.map((field) => field.value),
        contains('Visited Japan'),
      );
      expect(
        result.includedFields.map((field) => field.value),
        isNot(contains('Private travel notes')),
      );
      expect(
        result.includedFields.map((field) => field.value),
        isNot(contains('Japan')),
      );
      expect(result.includedMedia, isEmpty);
    },
  );

  test('entity history is assembled without persistence rows', () async {
    final source = await factory.fromEntity('entity-japan');

    expect(source, isNotNull);
    expect(source!.sourceType, StorySourceType.entity);
    expect(
      source.sourceRecordIds,
      containsAll(['entity-japan', 'event-japan']),
    );
    expect(
      source.fields.map((field) => field.id),
      contains('entity.memoryCount'),
    );
    expect(
      source.fields
          .singleWhere((field) => field.id == 'entity.memoryCount')
          .privacyClassification,
      PrivacyClassification.sensitive,
    );
  });

  test('archived events are not accepted as active Story sources', () async {
    await repository.archiveEvent('event-japan', DateTime.utc(2026));

    expect(await factory.fromEvent('event-japan'), isNull);
  });

  test(
    'archived Memory Media requests original retrieval, never a thumbnail',
    () async {
      await (database.update(
        database.attachments,
      )..where((row) => row.id.equals('attachment-memory-photo'))).write(
        const AttachmentsCompanion(
          storageState: Value('archived'),
          relativePath: Value(null),
          thumbnailRelativePath: Value('thumbs/japan.jpg'),
        ),
      );

      final source = (await factory.fromEvent('event-japan'))!;
      expect(source.media, isEmpty);
      expect(source.unavailableMedia, hasLength(1));
      expect(
        source.unavailableMedia.single.reason,
        contains('Retrieve the original'),
      );
    },
  );

  test('never-share Memory Media is not offered to Story selection', () async {
    await (database.update(
      database.attachments,
    )..where((row) => row.id.equals('attachment-memory-photo'))).write(
      const AttachmentsCompanion(privacyClassification: Value('never_share')),
    );

    final source = (await factory.fromEvent('event-japan'))!;
    expect(source.media, isEmpty);
    expect(source.unavailableMedia, isEmpty);
  });
}

RecordMetadata _metadata(
  String id, {
  PrivacyClassification privacy = PrivacyClassification.shareSafe,
}) => RecordMetadata(
  id: id,
  privacyClassification: privacy,
  lifecycle: RecordLifecycle.confirmed,
  createdAt: DateTime.utc(2025),
  updatedAt: DateTime.utc(2025),
);

final class _FixedPathResolver implements StoryAttachmentPathResolver {
  const _FixedPathResolver();

  @override
  Future<String?> resolve(Attachment attachment) async {
    if (attachment.storageState != AttachmentStorageState.local) return null;
    return 'C:/local/story-photo.jpg';
  }
}
