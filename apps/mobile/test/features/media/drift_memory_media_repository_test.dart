import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/features/media/infrastructure/drift_memory_media_repository.dart';
import 'package:life_timeline/shared/database/app_database.dart'
    hide Attachment, AttachmentLink, Event;
import 'package:life_timeline/shared/database/mappers/timeline_mapper.dart';
import 'package:life_timeline/shared/database/repositories/drift_timeline_repository.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';
import 'package:life_timeline/shared/domain/model/temporal_value.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

void main() {
  late AppDatabase database;
  late DriftMemoryMediaRepository repository;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftMemoryMediaRepository(database);
    for (final id in const ['event-a', 'event-b']) {
      await database
          .into(database.events)
          .insert(
            TimelineMapper.eventToCompanion(
              Event(
                metadata: _metadata(id),
                title: id,
                temporalValue: TemporalValue.year(2026),
              ),
            ),
          );
    }
  });

  tearDown(() => database.close());

  test(
    'hero assignment is singular and clearing does not delete media',
    () async {
      await repository.add(
        attachment: _attachment('asset-1'),
        link: _link('link-1', 'asset-1', sortOrder: 0),
      );
      await repository.add(
        attachment: _attachment('asset-2'),
        link: _link('link-2', 'asset-2', sortOrder: 1),
      );

      await repository.setHero(eventId: 'event-a', linkId: 'link-2');
      var media = await repository.forEvent('event-a');
      expect(media.singleWhere((item) => item.isHero).link.id, 'link-2');
      expect(media, hasLength(2));

      await repository.clearHero(eventId: 'event-a', linkId: 'link-2');
      media = await repository.forEvent('event-a');
      expect(media.where((item) => item.isHero), isEmpty);
      expect(media, hasLength(2));
    },
  );

  test('explicit ordering is stable and changes only link rows', () async {
    for (var index = 0; index < 3; index++) {
      await repository.add(
        attachment: _attachment('asset-$index'),
        link: _link('link-$index', 'asset-$index', sortOrder: index),
      );
    }
    final checksums = {
      for (final row in await database.select(database.attachments).get())
        row.id: row.checksum,
    };

    await repository.reorder(
      eventId: 'event-a',
      orderedLinkIds: const ['link-2', 'link-0', 'link-1'],
    );

    expect((await repository.forEvent('event-a')).map((item) => item.link.id), [
      'link-2',
      'link-0',
      'link-1',
    ]);
    expect({
      for (final row in await database.select(database.attachments).get())
        row.id: row.checksum,
    }, checksums);
  });

  test(
    'shared asset survives unlink and deletes only after final reference',
    () async {
      final attachment = _attachment('shared');
      await repository.add(
        attachment: attachment,
        link: _link('link-a', 'shared', sortOrder: 0),
      );
      await repository.add(
        attachment: attachment,
        link: _link('link-b', 'shared', eventId: 'event-b', sortOrder: 0),
      );

      final shared = await repository.deleteUnreferenced(
        eventId: 'event-a',
        linkId: 'link-a',
      );
      expect(shared.assetDeleted, isFalse);
      expect(await repository.forEvent('event-b'), hasLength(1));
      expect(
        await (database.select(
          database.attachments,
        )..where((row) => row.id.equals('shared'))).getSingleOrNull(),
        isNotNull,
      );

      final finalReference = await repository.deleteUnreferenced(
        eventId: 'event-b',
        linkId: 'link-b',
      );
      expect(finalReference.assetDeleted, isTrue);
      expect(
        finalReference.managedRelativePaths,
        containsAll(['media/shared.jpg', 'thumbs/shared.jpg']),
      );
      await repository.completeManagedDeletion(finalReference.attachmentId!);
      expect(await database.select(database.attachments).get(), isEmpty);
    },
  );

  test('role invariants reject evidence semantics on an event link', () {
    expect(
      () => AttachmentLink(
        id: 'invalid',
        attachmentId: 'asset',
        eventId: 'event-a',
        role: AttachmentRole.evidence,
        sortOrder: 0,
        importedAt: DateTime.utc(2026),
      ),
      throwsArgumentError,
    );
  });

  test('confirmed media captions participate in local FTS search', () async {
    await repository.add(
      attachment: _attachment('captioned'),
      link: _link('caption-link', 'captioned', sortOrder: 0),
    );
    await repository.updateCaption(
      linkId: 'caption-link',
      caption: 'Blue mountain sunrise',
    );

    final results = await DriftTimelineRepository(
      database,
    ).searchMemories('mountain');
    expect(results.single.memory.event.metadata.id, 'event-a');
    expect(results.single.matchedField, MemoryMatchField.mediaCaption);
  });
}

RecordMetadata _metadata(String id) => RecordMetadata(
  id: id,
  privacyClassification: PrivacyClassification.personal,
  lifecycle: RecordLifecycle.confirmed,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

Attachment _attachment(String id) => Attachment(
  metadata: _metadata(id),
  storageState: AttachmentStorageState.local,
  importMode: AttachmentImportMode.preserveOriginal,
  mimeType: 'image/jpeg',
  byteSize: 10,
  checksum: 'checksum-$id',
  relativePath: 'media/$id.jpg',
  thumbnailRelativePath: 'thumbs/$id.jpg',
);

AttachmentLink _link(
  String id,
  String attachmentId, {
  String eventId = 'event-a',
  required int sortOrder,
}) => AttachmentLink(
  id: id,
  attachmentId: attachmentId,
  eventId: eventId,
  role: sortOrder == 0 && eventId == 'event-a'
      ? AttachmentRole.heroMedia
      : AttachmentRole.memoryMedia,
  sortOrder: sortOrder,
  importedAt: DateTime.utc(2026),
);
