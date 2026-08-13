import 'dart:io';

import 'package:drift/drift.dart' show Variable, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/features/backup/domain/backup_models.dart';
import 'package:life_timeline/features/backup/domain/backup_ports.dart';
import 'package:life_timeline/features/backup/infrastructure/local_backup_service.dart';
import 'package:life_timeline/features/media/infrastructure/drift_memory_media_repository.dart';
import 'package:life_timeline/shared/crypto/aes_gcm_file_encryption_service.dart';
import 'package:life_timeline/shared/crypto/crypto_models.dart';
import 'package:life_timeline/shared/crypto/cryptography_password_key_deriver.dart';
import 'package:life_timeline/shared/database/app_database.dart'
    hide Attachment, AttachmentLink, Category, Event, MemoryCandidate;
import 'package:life_timeline/shared/database/backup/drift_backup_data_source.dart';
import 'package:life_timeline/shared/database/repositories/drift_memory_candidate_repository.dart';
import 'package:life_timeline/shared/database/repositories/drift_timeline_repository.dart';
import 'package:life_timeline/shared/domain/model/field_provenance.dart';
import 'package:life_timeline/shared/domain/model/memory_candidate.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';
import 'package:life_timeline/shared/domain/model/temporal_value.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';
import 'package:path/path.dart' as p;

void main() {
  const password = 'a memorable recovery phrase';
  const testKdf = KdfParameters(memoryKiB: 1024, iterations: 1);
  late Directory temporary;
  late AppDatabase sourceDatabase;
  late AppDatabase targetDatabase;
  late Directory sourceAttachments;
  late Directory targetAttachments;
  late String backupPath;

  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);
  tearDownAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = false);

  setUp(() async {
    temporary = await Directory.systemTemp.createTemp('timeline_backup_test');
    sourceDatabase = AppDatabase.forTesting(NativeDatabase.memory());
    targetDatabase = AppDatabase.forTesting(NativeDatabase.memory());
    sourceAttachments = Directory(p.join(temporary.path, 'source_attachments'));
    targetAttachments = Directory(p.join(temporary.path, 'target_attachments'));
    await sourceAttachments.create(recursive: true);
    await targetAttachments.create(recursive: true);
    backupPath = p.join(temporary.path, 'export.timelinebackup');
  });

  tearDown(() async {
    await sourceDatabase.close();
    await targetDatabase.close();
    if (await temporary.exists()) {
      await temporary.delete(recursive: true);
    }
  });

  test('manifest and database plus managed attachment round trip', () async {
    await _seedTimeline(sourceDatabase, sourceAttachments);
    await _seedCandidateProvenance(sourceDatabase);
    final sourceService = _service(
      sourceDatabase,
      sourceAttachments,
      backupPath,
      testKdf,
    );

    final result = await sourceService.create(
      recoveryPassword: password,
      onProgress: (_) {},
    );
    expect(result?.verified, isTrue);

    final targetService = _service(
      targetDatabase,
      targetAttachments,
      backupPath,
      testKdf,
    );
    await _seedExistingTarget(targetDatabase);
    final repository = DriftTimelineRepository(targetDatabase);
    final prepared = await targetService.prepare(
      path: backupPath,
      recoveryPassword: password,
      onProgress: (_) {},
    );
    expect(prepared.manifest.formatVersion, 1);
    expect(prepared.manifest.databaseSchemaVersion, 8);
    expect(prepared.manifest.appVersion, '0.1.0+test');
    expect(prepared.manifest.attachmentCount, 2);

    await targetService.commit(
      prepared,
      replaceExisting: true,
      onProgress: (_) {},
    );

    expect(await repository.memoryById('existing'), isNull);
    expect((await repository.memoryById('event-1'))?.event.title, 'Graduated');
    final attachments = await repository.attachmentsForEvidence('evidence-1');
    expect(attachments, hasLength(3));
    final local = attachments.singleWhere(
      (item) => item.storageState == AttachmentStorageState.local,
    );
    expect(local.metadata.id, 'attachment-local');
    expect(
      await File(
        p.join(targetAttachments.path, local.relativePath),
      ).readAsString(),
      'certificate bytes',
    );
    expect(
      await File(
        p.join(targetAttachments.path, local.thumbnailRelativePath),
      ).readAsString(),
      'certificate preview',
    );
    final referenced = attachments.singleWhere(
      (item) => item.storageState == AttachmentStorageState.referenced,
    );
    expect(referenced.relativePath, isNull);
    final archived = attachments.singleWhere(
      (item) => item.storageState == AttachmentStorageState.archived,
    );
    expect(archived.relativePath, isNull);
    expect(
      await File(
        p.join(targetAttachments.path, archived.thumbnailRelativePath),
      ).readAsString(),
      'archived preview',
    );
    final archiveReference = await targetDatabase
        .select(targetDatabase.archiveReferences)
        .getSingle();
    expect(archiveReference.attachmentId, 'attachment-archived');
    expect(archiveReference.logicalKey, 'safe-location.timelinearchive');
    final restoredCandidate = await DriftMemoryCandidateRepository(
      targetDatabase,
    ).candidateById('candidate-1');
    expect(restoredCandidate?.title, 'Possible graduation date');
    final restoredProvenance = await repository.provenanceFor(
      ProvenanceTarget(
        type: ProvenanceTargetType.memoryCandidate,
        id: 'candidate-1',
      ),
    );
    expect(restoredProvenance.single.fieldName, 'temporalValue');
    final restoredMedia = await DriftMemoryMediaRepository(
      targetDatabase,
    ).forEvent('event-1');
    expect(restoredMedia, hasLength(1));
    expect(restoredMedia.single.isHero, isTrue);
    expect(restoredMedia.single.link.caption, 'Graduation day');
    expect(
      await File(
        p.join(
          targetAttachments.path,
          restoredMedia.single.attachment.relativePath,
        ),
      ).readAsString(),
      'graduation display',
    );
    expect(
      await File(
        p.join(
          targetAttachments.path,
          restoredMedia.single.attachment.preservedOriginalRelativePath,
        ),
      ).readAsString(),
      'graduation original',
    );
  });

  test('wrong password leaves an existing timeline unchanged', () async {
    await _seedTimeline(sourceDatabase, sourceAttachments);
    await _seedExistingTarget(targetDatabase);
    final service = _service(
      sourceDatabase,
      sourceAttachments,
      backupPath,
      testKdf,
    );
    await service.create(recoveryPassword: password, onProgress: (_) {});
    final targetService = _service(
      targetDatabase,
      targetAttachments,
      backupPath,
      testKdf,
    );

    expect(
      () => targetService.prepare(
        path: backupPath,
        recoveryPassword: 'incorrect password',
        onProgress: (_) {},
      ),
      throwsA(isA<CryptoFailure>()),
    );
    expect(
      (await DriftTimelineRepository(
        targetDatabase,
      ).memoryById('existing'))?.event.title,
      'Existing timeline',
    );
  });

  test('transaction failure does not corrupt an existing timeline', () async {
    await _seedTimeline(sourceDatabase, sourceAttachments);
    await _seedExistingTarget(targetDatabase);
    final sourceService = _service(
      sourceDatabase,
      sourceAttachments,
      backupPath,
      testKdf,
    );
    await sourceService.create(recoveryPassword: password, onProgress: (_) {});
    final targetService = _service(
      targetDatabase,
      targetAttachments,
      backupPath,
      testKdf,
    );
    final prepared = await targetService.prepare(
      path: backupPath,
      recoveryPassword: password,
      onProgress: (_) {},
    );
    final tables = {
      for (final entry in prepared.snapshot.tables.entries)
        entry.key: entry.value
            .map((row) => Map<String, Object?>.from(row))
            .toList(),
    };
    tables['events']!.add(Map<String, Object?>.from(tables['events']!.first));
    final invalid = PreparedRestore(
      id: '${prepared.id}_invalid',
      stagingDirectory: prepared.stagingDirectory,
      manifest: prepared.manifest,
      snapshot: DatabaseSnapshot(schemaVersion: 1, tables: tables),
      preview: prepared.preview,
    );

    expect(
      () => targetService.commit(
        invalid,
        replaceExisting: true,
        onProgress: (_) {},
      ),
      throwsA(anything),
    );
    expect(
      (await DriftTimelineRepository(
        targetDatabase,
      ).memoryById('existing'))?.event.title,
      'Existing timeline',
    );
  });

  test('newer database backup is refused before restore', () async {
    final payload = File(p.join(temporary.path, 'payload.zip'))
      ..writeAsBytesSync([1, 2, 3]);
    final encryption = const AesGcmFileEncryptionService(
      CryptographyPasswordKeyDeriver(),
    );
    await encryption.encryptFile(
      inputPath: payload.path,
      outputPath: backupPath,
      password: password,
      createdAt: DateTime.utc(2026, 8, 10),
      databaseSchemaVersion: 99,
      attachmentCount: 0,
      kdf: testKdf,
    );
    final targetService = _service(
      targetDatabase,
      targetAttachments,
      backupPath,
      testKdf,
    );

    expect(
      () => targetService.prepare(
        path: backupPath,
        recoveryPassword: password,
        onProgress: (_) {},
      ),
      throwsA(
        isA<BackupFailure>().having(
          (failure) => failure.code,
          'code',
          'newer_backup_not_supported',
        ),
      ),
    );
  });

  test(
    'clean install restores a schema v1 backup and rebuilds search',
    () async {
      await _seedTimeline(sourceDatabase, sourceAttachments);
      final encryption = const AesGcmFileEncryptionService(
        CryptographyPasswordKeyDeriver(),
      );
      final sourceService = LocalBackupService(
        LegacyV1BackupDataSource(DriftBackupDataSource(sourceDatabase)),
        TestAttachmentStorage(sourceAttachments),
        TestBackupDestination(backupPath),
        encryption,
        const TestAppVersionProvider(),
        now: () => DateTime.utc(2026, 8, 10, 12),
        kdf: testKdf,
      );
      await sourceService.create(
        recoveryPassword: password,
        onProgress: (_) {},
      );

      final targetService = _service(
        targetDatabase,
        targetAttachments,
        backupPath,
        testKdf,
      );
      final prepared = await targetService.prepare(
        path: backupPath,
        recoveryPassword: password,
        onProgress: (_) {},
      );
      expect(prepared.snapshot.schemaVersion, 1);
      await targetService.commit(
        prepared,
        replaceExisting: false,
        onProgress: (_) {},
      );

      final result = await targetDatabase
          .customSelect(
            'SELECT event_id FROM event_search WHERE event_search MATCH ?',
            variables: [const Variable<String>('Graduated')],
          )
          .getSingle();
      expect(result.read<String>('event_id'), 'event-1');
    },
  );

  test('authenticated but corrupted archive is refused safely', () async {
    final invalidArchive = File(p.join(temporary.path, 'not-a-zip'));
    await invalidArchive.writeAsBytes([1, 2, 3, 4], flush: true);
    const encryption = AesGcmFileEncryptionService(
      CryptographyPasswordKeyDeriver(),
    );
    await encryption.encryptFile(
      inputPath: invalidArchive.path,
      outputPath: backupPath,
      password: password,
      createdAt: DateTime.utc(2026, 8, 10),
      databaseSchemaVersion: 1,
      attachmentCount: 0,
      kdf: testKdf,
    );
    final service = _service(
      targetDatabase,
      targetAttachments,
      backupPath,
      testKdf,
    );

    await expectLater(
      service.prepare(
        path: backupPath,
        recoveryPassword: password,
        onProgress: (_) {},
      ),
      throwsA(
        isA<BackupFailure>().having(
          (failure) => failure.code,
          'code',
          'archive_corrupted',
        ),
      ),
    );
  });
}

LocalBackupService _service(
  AppDatabase database,
  Directory attachments,
  String backupPath,
  KdfParameters kdf,
) => LocalBackupService(
  DriftBackupDataSource(database),
  TestAttachmentStorage(attachments),
  TestBackupDestination(backupPath),
  const AesGcmFileEncryptionService(CryptographyPasswordKeyDeriver()),
  const TestAppVersionProvider(),
  now: () => DateTime.utc(2026, 8, 10, 12),
  kdf: kdf,
);

Future<void> _seedTimeline(
  AppDatabase database,
  Directory attachmentRoot,
) async {
  final repository = DriftTimelineRepository(database);
  final at = DateTime.utc(2026, 8, 10);
  RecordMetadata metadata(String id) => RecordMetadata(
    id: id,
    privacyClassification: PrivacyClassification.personal,
    lifecycle: RecordLifecycle.confirmed,
    createdAt: at,
    updatedAt: at,
  );
  await repository.saveMemory(
    TimelineMemory(
      event: Event(
        metadata: metadata('event-1'),
        title: 'Graduated',
        temporalValue: TemporalValue.year(2020),
        eventType: 'Education',
      ),
      category: Category(metadata: metadata('category-1'), name: 'Education'),
    ),
  );
  final localPath = p.join('documents', 'certificate.txt');
  final localFile = File(p.join(attachmentRoot.path, localPath));
  await localFile.parent.create(recursive: true);
  await localFile.writeAsString('certificate bytes', flush: true);
  final thumbnailPath = p.join('thumbnails', 'certificate-preview.txt');
  final thumbnailFile = File(p.join(attachmentRoot.path, thumbnailPath));
  await thumbnailFile.parent.create(recursive: true);
  await thumbnailFile.writeAsString('certificate preview', flush: true);
  final archivedThumbnailPath = p.join('thumbnails', 'archived-preview.txt');
  final archivedThumbnail = File(
    p.join(attachmentRoot.path, archivedThumbnailPath),
  );
  await archivedThumbnail.writeAsString('archived preview', flush: true);
  await repository.saveEvidence(
    Evidence(
      metadata: metadata('evidence-1'),
      evidenceType: EvidenceType.certificate,
      title: 'Degree certificate',
    ),
    attachments: [
      Attachment(
        metadata: metadata('attachment-local'),
        storageState: AttachmentStorageState.local,
        importMode: AttachmentImportMode.preserveOriginal,
        mimeType: 'text/plain',
        byteSize: await localFile.length(),
        relativePath: localPath,
        thumbnailRelativePath: thumbnailPath,
      ),
      Attachment(
        metadata: metadata('attachment-referenced'),
        storageState: AttachmentStorageState.referenced,
        importMode: AttachmentImportMode.referenceOriginal,
        mimeType: 'application/pdf',
        byteSize: 10,
        relativePath: p.join(Directory.systemTemp.path, 'external.pdf'),
      ),
      Attachment(
        metadata: metadata('attachment-archived'),
        storageState: AttachmentStorageState.archived,
        importMode: AttachmentImportMode.preserveOriginal,
        mimeType: 'image/jpeg',
        byteSize: 20,
        thumbnailRelativePath: archivedThumbnailPath,
      ),
    ],
  );
  final mediaDisplayPath = p.join('media', 'display', 'graduation.jpg');
  final mediaDisplay = File(p.join(attachmentRoot.path, mediaDisplayPath));
  await mediaDisplay.parent.create(recursive: true);
  await mediaDisplay.writeAsString('graduation display', flush: true);
  final mediaOriginalPath = p.join('media', 'originals', 'graduation.jpg');
  final mediaOriginal = File(p.join(attachmentRoot.path, mediaOriginalPath));
  await mediaOriginal.parent.create(recursive: true);
  await mediaOriginal.writeAsString('graduation original', flush: true);
  final mediaThumbnailPath = p.join('media', 'thumbnails', 'graduation.jpg');
  final mediaThumbnail = File(p.join(attachmentRoot.path, mediaThumbnailPath));
  await mediaThumbnail.parent.create(recursive: true);
  await mediaThumbnail.writeAsString('graduation thumbnail', flush: true);
  final mediaAttachment = Attachment(
    metadata: metadata('attachment-memory-photo'),
    storageState: AttachmentStorageState.local,
    importMode: AttachmentImportMode.preserveOriginal,
    mimeType: 'image/jpeg',
    byteSize: await mediaDisplay.length(),
    relativePath: mediaDisplayPath,
    thumbnailRelativePath: mediaThumbnailPath,
    preservedOriginalRelativePath: mediaOriginalPath,
    preservedOriginalByteSize: await mediaOriginal.length(),
  );
  await DriftMemoryMediaRepository(database).add(
    attachment: mediaAttachment,
    link: AttachmentLink(
      id: 'media-link-graduation',
      attachmentId: mediaAttachment.metadata.id,
      eventId: 'event-1',
      role: AttachmentRole.heroMedia,
      caption: 'Graduation day',
      sortOrder: 0,
      importedAt: at,
    ),
  );
  await database
      .into(database.archiveReferences)
      .insert(
        ArchiveReferencesCompanion.insert(
          id: 'archive-reference-1',
          attachmentId: 'attachment-archived',
          destinationType: 'userSelectedFile',
          logicalKey: 'safe-location.timelinearchive',
          originalByteSize: 20,
          originalSha256: 'original-hash',
          archiveByteSize: 42,
          archiveSha256: 'archive-hash',
          encryptionAlgorithm: 'aes-256-gcm+argon2id',
          formatVersion: 1,
          archivedAt: at,
          verifiedAt: at,
        ),
      );
}

Future<void> _seedExistingTarget(AppDatabase database) async {
  final at = DateTime.utc(2026, 8, 9);
  await DriftTimelineRepository(database).saveEvent(
    Event(
      metadata: RecordMetadata(
        id: 'existing',
        privacyClassification: PrivacyClassification.personal,
        lifecycle: RecordLifecycle.confirmed,
        createdAt: at,
        updatedAt: at,
      ),
      title: 'Existing timeline',
      temporalValue: TemporalValue.year(2019),
      eventType: 'Personal',
    ),
  );
}

Future<void> _seedCandidateProvenance(AppDatabase database) async {
  final at = DateTime.utc(2026, 8, 10);
  await DriftMemoryCandidateRepository(database).saveCandidate(
    MemoryCandidate(
      metadata: RecordMetadata(
        id: 'candidate-1',
        privacyClassification: PrivacyClassification.personal,
        lifecycle: RecordLifecycle.candidate,
        createdAt: at,
        updatedAt: at,
      ),
      title: 'Possible graduation date',
      temporalValue: TemporalValue.year(2020),
    ),
  );
  await DriftTimelineRepository(database).saveFieldProvenance(
    FieldProvenance(
      id: 'provenance-candidate-1',
      target: ProvenanceTarget(
        type: ProvenanceTargetType.memoryCandidate,
        id: 'candidate-1',
      ),
      fieldName: 'temporalValue',
      sourceId: 'manual-review',
      sourceType: ProvenanceSourceType.user,
      extractionMethod: ExtractionMethod.manual,
      confidence: 1,
      userConfirmed: false,
      privacyClassification: PrivacyClassification.personal,
      createdAt: at,
      updatedAt: at,
    ),
  );
}

final class TestAttachmentStorage implements ManagedAttachmentStorage {
  const TestAttachmentStorage(this.root);

  final Directory root;

  @override
  Future<String> rootPath() async => root.path;

  @override
  Future<String> temporaryRootPath() async {
    final directory = Directory(p.join(root.parent.path, 'staging'));
    await directory.create(recursive: true);
    return directory.path;
  }
}

final class TestBackupDestination implements BackupDestination {
  const TestBackupDestination(this.path);

  final String path;

  @override
  Future<BackupDestinationReceipt?> saveExport({
    required String sourcePath,
    required String suggestedName,
    required String expectedSha256,
  }) async {
    await File(sourcePath).copy(path);
    return BackupDestinationReceipt(displayPath: path, verified: true);
  }

  @override
  Future<String?> chooseImportPath() async => path;
}

final class TestAppVersionProvider implements AppVersionProvider {
  const TestAppVersionProvider();

  @override
  Future<String> version() async => '0.1.0+test';
}

final class LegacyV1BackupDataSource implements BackupDataSource {
  const LegacyV1BackupDataSource(this.delegate);

  final BackupDataSource delegate;

  @override
  int get schemaVersion => 1;

  @override
  Future<DatabaseSnapshot> exportSnapshot() async {
    final current = await delegate.exportSnapshot();
    return DatabaseSnapshot(schemaVersion: 1, tables: current.tables);
  }

  @override
  Future<bool> hasUserData() => delegate.hasUserData();

  @override
  Future<void> replaceWithSnapshot(DatabaseSnapshot snapshot) =>
      delegate.replaceWithSnapshot(snapshot);
}
