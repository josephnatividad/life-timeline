import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/features/storage/domain/storage_models.dart';
import 'package:life_timeline/features/storage/infrastructure/drift_storage_repository.dart';
import 'package:life_timeline/shared/database/app_database.dart'
    hide ArchiveReference, Attachment;
import 'package:life_timeline/shared/database/mappers/timeline_mapper.dart';
import 'package:life_timeline/shared/database/repositories/drift_timeline_repository.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

import '../../shared/database/test_record_factory.dart';

void main() {
  late AppDatabase database;
  late DriftStorageRepository storage;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    storage = DriftStorageRepository(database);
    await DriftTimelineRepository(
      database,
    ).saveEvidence(TestRecordFactory.evidence());
    await database
        .into(database.attachments)
        .insert(
          TimelineMapper.attachmentToCompanion(
            Attachment(
              metadata: TestRecordFactory.metadata('attachment-1'),
              evidenceId: 'evidence-1',
              storageState: AttachmentStorageState.local,
              importMode: AttachmentImportMode.preserveOriginal,
              mimeType: 'image/jpeg',
              byteSize: 20,
              checksum: 'original-sha',
              relativePath: 'photos/original.jpg',
            ),
          ),
        );
  });

  tearDown(() => database.close());

  test('archive metadata and attachment lifecycle round trip', () async {
    final archivedAt = DateTime.utc(2026, 8, 12, 9);
    final reference = ArchiveReference(
      id: 'archive-1',
      attachmentId: 'attachment-1',
      destinationType: ArchiveDestinationType.userSelectedFile,
      logicalKey: 'chosen.timelinearchive',
      originalByteSize: 20,
      originalSha256: 'original-sha',
      archiveByteSize: 42,
      archiveSha256: 'archive-sha',
      encryptionAlgorithm: 'aes-256-gcm+argon2id',
      formatVersion: 1,
      archivedAt: archivedAt,
      verifiedAt: archivedAt,
    );

    await storage.saveVerifiedArchive(
      reference,
      thumbnailRelativePath: 'thumbnails/attachment-1.jpg',
    );
    final stored = await storage.attachmentById('attachment-1');
    expect(stored?.archiveReference?.logicalKey, 'chosen.timelinearchive');
    expect(
      stored?.attachment.thumbnailRelativePath,
      'thumbnails/attachment-1.jpg',
    );
    expect(await storage.latestContentChangeAt(), archivedAt);

    await storage.markArchiveRemovalStarted('attachment-1', archivedAt);
    await storage.completeArchiveRemoval('attachment-1', archivedAt);
    final archived = await storage.attachmentById('attachment-1');
    expect(archived?.attachment.storageState, AttachmentStorageState.archived);
    expect(archived?.attachment.relativePath, isNull);

    await storage.restoreArchivedAttachment(
      attachmentId: 'attachment-1',
      relativePath: 'retrieved/attachment-1/original.jpg',
      byteSize: 20,
      checksum: 'original-sha',
      at: archivedAt.add(const Duration(minutes: 1)),
    );
    final restored = await storage.attachmentById('attachment-1');
    expect(restored?.attachment.storageState, AttachmentStorageState.local);
    expect(
      restored?.attachment.relativePath,
      'retrieved/attachment-1/original.jpg',
    );
  });

  test('archive references enforce attachment foreign keys', () async {
    final now = DateTime.utc(2026, 8, 12);

    expect(
      database
          .into(database.archiveReferences)
          .insert(
            ArchiveReferencesCompanion.insert(
              id: 'orphan',
              attachmentId: 'missing',
              destinationType: 'userSelectedFile',
              logicalKey: 'missing.timelinearchive',
              originalByteSize: 1,
              originalSha256: 'one',
              archiveByteSize: 2,
              archiveSha256: 'two',
              encryptionAlgorithm: 'test',
              formatVersion: 1,
              archivedAt: now,
              verifiedAt: now,
            ),
          ),
      throwsA(isA<Exception>()),
    );
  });
}
