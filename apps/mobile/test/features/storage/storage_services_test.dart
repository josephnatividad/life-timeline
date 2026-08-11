import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/features/storage/application/storage_health_services.dart';
import 'package:life_timeline/features/storage/domain/storage_models.dart';
import 'package:life_timeline/features/storage/domain/storage_ports.dart';
import 'package:life_timeline/features/storage/infrastructure/local_archive_service.dart';
import 'package:life_timeline/features/storage/infrastructure/local_storage_inventory_service.dart';
import 'package:life_timeline/shared/crypto/crypto_models.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';
import 'package:path/path.dart' as p;

void main() {
  group('archive engine', () {
    late Directory sandbox;
    late _TestPaths paths;
    late _MemoryStorageRepository repository;
    late _TestArchiveStorage archiveStorage;
    late _CopyingEncryptionService encryption;
    late File original;
    late LocalArchiveService service;

    setUp(() async {
      sandbox = await Directory.systemTemp.createTemp('storage_archive_test_');
      paths = await _TestPaths.create(sandbox);
      original = File(p.join(paths.attachmentRoot, 'photos', 'original.bin'));
      await original.parent.create(recursive: true);
      await original.writeAsBytes(utf8.encode('private original bytes'));
      encryption = const _CopyingEncryptionService();
      final checksum = await encryption.sha256File(original.path);
      repository = _MemoryStorageRepository(
        StoredAttachment(
          attachment: _attachment(
            relativePath: p.join('photos', 'original.bin'),
            byteSize: await original.length(),
            checksum: checksum,
          ),
        ),
      );
      archiveStorage = _TestArchiveStorage(
        File(p.join(sandbox.path, 'chosen.timelinearchive')),
      );
      service = LocalArchiveService(
        repository,
        archiveStorage,
        encryption,
        paths,
        now: () => DateTime.utc(2026, 8, 12, 10),
      );
    });

    tearDown(() async {
      if (await sandbox.exists()) await sandbox.delete(recursive: true);
    });

    test(
      'records a verified archive before optionally retaining local',
      () async {
        final phases = <ArchivePhase>[];

        final result = await service.archive(
          attachmentId: 'attachment-1',
          recoveryPassword: 'recovery phrase',
          removeLocalOriginal: false,
          onProgress: (progress) => phases.add(progress.phase),
        );

        expect(result, isNotNull);
        expect(result!.localOriginalRemoved, isFalse);
        expect(await original.exists(), isTrue);
        expect(repository.value.archiveReference, isNotNull);
        expect(repository.savedArchiveWhileLocalExisted, isTrue);
        expect(phases, contains(ArchivePhase.recordingReference));
        expect(phases.last, ArchivePhase.complete);
      },
    );

    test(
      'cancellation and verification failure never remove local data',
      () async {
        archiveStorage.cancelSave = true;
        final canceled = await service.archive(
          attachmentId: 'attachment-1',
          recoveryPassword: 'recovery phrase',
          removeLocalOriginal: true,
          onProgress: (_) {},
        );
        expect(canceled, isNull);
        expect(await original.exists(), isTrue);
        expect(repository.value.archiveReference, isNull);

        archiveStorage
          ..cancelSave = false
          ..verified = false;
        await expectLater(
          service.archive(
            attachmentId: 'attachment-1',
            recoveryPassword: 'recovery phrase',
            removeLocalOriginal: true,
            onProgress: (_) {},
          ),
          throwsA(
            isA<ArchiveFailure>().having(
              (error) => error.code,
              'code',
              'archive_verification_failed',
            ),
          ),
        );
        expect(await original.exists(), isTrue);
        expect(repository.value.archiveReference, isNull);
      },
    );

    test(
      'retry after an interrupted save succeeds without data loss',
      () async {
        archiveStorage.saveError = StateError('interrupted');
        await expectLater(
          service.archive(
            attachmentId: 'attachment-1',
            recoveryPassword: 'recovery phrase',
            removeLocalOriginal: true,
            onProgress: (_) {},
          ),
          throwsA(isA<ArchiveFailure>()),
        );
        expect(await original.exists(), isTrue);
        expect(repository.value.archiveReference, isNull);

        archiveStorage.saveError = null;
        final retried = await service.archive(
          attachmentId: 'attachment-1',
          recoveryPassword: 'recovery phrase',
          removeLocalOriginal: true,
          onProgress: (_) {},
        );
        expect(retried!.localOriginalRemoved, isTrue);
        expect(await original.exists(), isFalse);
        expect(
          repository.value.attachment.storageState,
          AttachmentStorageState.archived,
        );
        expect(repository.value.attachment.relativePath, isNull);
      },
    );

    test(
      'retrieval authenticates, verifies, and restores a managed copy',
      () async {
        await service.archive(
          attachmentId: 'attachment-1',
          recoveryPassword: 'recovery phrase',
          removeLocalOriginal: true,
          onProgress: (_) {},
        );
        archiveStorage.retrievalPath = archiveStorage.destination.path;
        final phases = <ArchivePhase>[];

        final result = await service.retrieve(
          attachmentId: 'attachment-1',
          recoveryPassword: 'recovery phrase',
          onProgress: (progress) => phases.add(progress.phase),
        );

        expect(result.outcome, ArchiveRetrievalOutcome.restored);
        expect(phases, contains(ArchivePhase.decrypting));
        final restored = File(
          p.join(
            paths.attachmentRoot,
            repository.value.attachment.relativePath,
          ),
        );
        expect(await restored.readAsString(), 'private original bytes');
        expect(
          repository.value.attachment.storageState,
          AttachmentStorageState.local,
        );
      },
    );

    test(
      'wrong password and unavailable selection preserve archived state',
      () async {
        await service.archive(
          attachmentId: 'attachment-1',
          recoveryPassword: 'recovery phrase',
          removeLocalOriginal: true,
          onProgress: (_) {},
        );
        archiveStorage.retrievalPath = archiveStorage.destination.path;

        await expectLater(
          service.retrieve(
            attachmentId: 'attachment-1',
            recoveryPassword: 'wrong password',
            onProgress: (_) {},
          ),
          throwsA(
            isA<ArchiveFailure>().having(
              (error) => error.code,
              'code',
              'archive_authentication_failed',
            ),
          ),
        );
        expect(
          repository.value.attachment.storageState,
          AttachmentStorageState.archived,
        );

        archiveStorage.retrievalPath = p.join(sandbox.path, 'missing.archive');
        final unavailable = await service.retrieve(
          attachmentId: 'attachment-1',
          recoveryPassword: 'recovery phrase',
          onProgress: (_) {},
        );
        expect(unavailable.outcome, ArchiveRetrievalOutcome.unavailable);
      },
    );
  });

  group('inventory and cleanup', () {
    late Directory sandbox;
    late _TestPaths paths;

    setUp(() async {
      sandbox = await Directory.systemTemp.createTemp(
        'storage_inventory_test_',
      );
      paths = await _TestPaths.create(sandbox);
    });

    tearDown(() async {
      if (await sandbox.exists()) await sandbox.delete(recursive: true);
    });

    test(
      'measures actual files and detects exact duplicates without deleting',
      () async {
        final first = File(p.join(paths.attachmentRoot, 'photos', 'one.jpg'));
        final second = File(p.join(paths.attachmentRoot, 'photos', 'two.jpg'));
        await first.parent.create(recursive: true);
        await first.writeAsString('same bytes');
        await second.writeAsString('same bytes');
        await File(
          p.join(paths.documents, 'life_timeline.sqlite'),
        ).writeAsBytes(List<int>.filled(31, 1));
        final stale = File(
          p.join(
            paths.temporary,
            'life_timeline_story_exports',
            'story-export-old.png',
          ),
        );
        await stale.parent.create(recursive: true);
        await stale.writeAsBytes(List<int>.filled(17, 2));
        await stale.setLastModified(DateTime.utc(2026, 8, 9));
        final repository = _ListStorageRepository([
          StoredAttachment(
            attachment: _attachment(
              id: 'one',
              relativePath: p.join('photos', 'one.jpg'),
              byteSize: await first.length(),
            ),
          ),
          StoredAttachment(
            attachment: _attachment(
              id: 'two',
              relativePath: p.join('photos', 'two.jpg'),
              byteSize: await second.length(),
            ),
          ),
        ]);

        final inventory = await FileSystemStorageInventoryService(
          repository,
          paths,
        ).analyze();

        expect(inventory.breakdown.photosBytes, await first.length() * 2);
        expect(inventory.breakdown.databaseBytes, 31);
        expect(inventory.duplicateGroups, hasLength(1));
        expect(inventory.duplicateBytes, await first.length());
        expect(inventory.reclaimableCacheBytes, 17);
        expect(await first.exists(), isTrue);
        expect(await second.exists(), isTrue);
      },
    );

    test(
      'cleanup removes only stale files in the explicit allowlist',
      () async {
        final allowed = File(
          p.join(
            paths.temporary,
            'life_timeline_story_exports',
            'story-export-old.png',
          ),
        );
        final denied = File(
          p.join(
            paths.temporary,
            'life_timeline_story_exports',
            'personal-note.txt',
          ),
        );
        final outside = File(p.join(paths.temporary, 'unrelated-private.bin'));
        await allowed.parent.create(recursive: true);
        await allowed.writeAsBytes(List<int>.filled(11, 1));
        await denied.writeAsBytes(List<int>.filled(12, 1));
        await outside.writeAsBytes(List<int>.filled(13, 1));
        final old = DateTime.utc(2026, 8, 9);
        await allowed.setLastModified(old);
        await denied.setLastModified(old);
        await outside.setLastModified(old);

        final result = await ScopedStorageCleanupService(
          paths,
        ).cleanStaleTemporaryFiles(DateTime.utc(2026, 8, 12));

        expect(result.removedEntries, 1);
        expect(result.removedBytes, 11);
        expect(await allowed.exists(), isFalse);
        expect(await denied.exists(), isTrue);
        expect(await outside.exists(), isTrue);
      },
    );
  });

  test('copy protection counts local, archive, and backup independently', () {
    final beforeBackup = DateTime.utc(2026, 8, 10);
    final archivedAfterBackup = DateTime.utc(2026, 8, 11);
    final local = _attachment(
      relativePath: 'photos/original.jpg',
      byteSize: 100,
      createdAt: DateTime.utc(2026, 8, 1),
      updatedAt: archivedAfterBackup,
    );
    final stored = StoredAttachment(
      attachment: local,
      archiveReference: _archiveReference(archivedAt: archivedAfterBackup),
    );
    final inventory = StorageInventory(
      breakdown: const StorageBreakdown(),
      attachments: [stored],
      managedFiles: const [
        ManagedFileMeasurement(
          attachmentId: 'attachment-1',
          relativePath: 'photos/original.jpg',
          exists: true,
          byteSize: 100,
        ),
      ],
      duplicateGroups: const [],
      archivedContentBytes: 100,
      archivedContentCount: 1,
      referencedContentCount: 0,
      unavailableContentCount: 0,
      missingManagedFileCount: 0,
      reclaimableCacheBytes: 0,
    );

    final result = const DefaultCopyProtectionService().calculate(
      inventory: inventory,
      backup: BackupProtectionSnapshot(
        verified: true,
        pendingChanges: true,
        lastBackupAt: beforeBackup,
      ),
    );

    expect(result.items.single.verifiedCopyCount, 3);
    expect(result.items.single.level, ProtectionLevel.protected);
  });
}

Attachment _attachment({
  String id = 'attachment-1',
  String? relativePath,
  int byteSize = 0,
  String? checksum,
  AttachmentStorageState state = AttachmentStorageState.local,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final created = createdAt ?? DateTime.utc(2026, 8, 1);
  final updated = updatedAt ?? created;
  return Attachment(
    metadata: RecordMetadata(
      id: id,
      privacyClassification: PrivacyClassification.sensitive,
      lifecycle: RecordLifecycle.confirmed,
      createdAt: created,
      updatedAt: updated,
    ),
    evidenceId: 'evidence-1',
    storageState: state,
    importMode: AttachmentImportMode.preserveOriginal,
    mimeType: 'image/jpeg',
    byteSize: byteSize,
    checksum: checksum,
    displayName: 'Original photo.jpg',
    relativePath: relativePath,
  );
}

ArchiveReference _archiveReference({DateTime? archivedAt}) {
  final at = archivedAt ?? DateTime.utc(2026, 8, 12);
  return ArchiveReference(
    id: 'archive-1',
    attachmentId: 'attachment-1',
    destinationType: ArchiveDestinationType.userSelectedFile,
    logicalKey: 'chosen.timelinearchive',
    originalByteSize: 22,
    originalSha256: 'original-hash',
    archiveByteSize: 31,
    archiveSha256: 'archive-hash',
    encryptionAlgorithm: 'test',
    formatVersion: 1,
    archivedAt: at,
    verifiedAt: at,
  );
}

final class _TestPaths implements StoragePathProvider {
  _TestPaths._({
    required this.attachmentRoot,
    required this.support,
    required this.documents,
    required this.temporary,
  });

  static Future<_TestPaths> create(Directory root) async {
    final paths = _TestPaths._(
      attachmentRoot: p.join(root.path, 'support', 'attachments'),
      support: p.join(root.path, 'support'),
      documents: p.join(root.path, 'documents'),
      temporary: p.join(root.path, 'temporary'),
    );
    for (final path in [
      paths.attachmentRoot,
      paths.support,
      paths.documents,
      paths.temporary,
    ]) {
      await Directory(path).create(recursive: true);
    }
    return paths;
  }

  final String attachmentRoot;
  final String documents;
  final String support;
  final String temporary;

  @override
  Future<String> applicationDocumentsPath() async => documents;

  @override
  Future<String> applicationSupportPath() async => support;

  @override
  Future<String> attachmentRootPath() async => attachmentRoot;

  @override
  Future<String> temporaryPath() async => temporary;
}

final class _TestArchiveStorage implements ArchiveStorage {
  _TestArchiveStorage(this.destination);

  final File destination;
  bool cancelSave = false;
  String? retrievalPath;
  Object? saveError;
  bool verified = true;

  @override
  Future<String?> chooseArchiveForRetrieval(ArchiveReference reference) async =>
      retrievalPath;

  @override
  Future<ArchiveDestinationReceipt?> saveArchive({
    required String sourcePath,
    required String suggestedName,
    required String expectedSha256,
  }) async {
    if (saveError case final error?) throw error;
    if (cancelSave) return null;
    await File(sourcePath).copy(destination.path);
    return ArchiveDestinationReceipt(
      logicalKey: p.basename(destination.path),
      verified: verified,
    );
  }
}

final class _CopyingEncryptionService implements EncryptionService {
  const _CopyingEncryptionService();

  @override
  Future<void> decryptFile({
    required String inputPath,
    required String outputPath,
    required String password,
  }) async {
    final bytes = await File(inputPath).readAsBytes();
    final marker = utf8.encode('encrypted:$password:');
    if (bytes.length < marker.length ||
        utf8.decode(bytes.take(marker.length).toList()) !=
            'encrypted:$password:') {
      throw const CryptoFailure('authentication_failed');
    }
    await File(outputPath).writeAsBytes(bytes.skip(marker.length).toList());
  }

  @override
  Future<EncryptedContainerHeader> encryptFile({
    required String inputPath,
    required String outputPath,
    required String password,
    required DateTime createdAt,
    required int databaseSchemaVersion,
    required int attachmentCount,
    KdfParameters kdf = const KdfParameters(),
  }) async {
    final payload = await File(inputPath).readAsBytes();
    await File(
      outputPath,
    ).writeAsBytes([...utf8.encode('encrypted:$password:'), ...payload]);
    return EncryptedContainerHeader(
      formatVersion: 1,
      createdAt: createdAt,
      databaseSchemaVersion: databaseSchemaVersion,
      attachmentCount: attachmentCount,
      payloadLength: payload.length,
      kdf: kdf,
      salt: List<int>.filled(16, 1),
      nonce: List<int>.filled(12, 2),
    );
  }

  @override
  Future<EncryptedContainerHeader> inspect(String encryptedPath) =>
      throw UnimplementedError();

  @override
  Future<String> sha256File(String path) async {
    final hash = await Sha256().hash(await File(path).readAsBytes());
    return base64UrlEncode(hash.bytes);
  }
}

final class _MemoryStorageRepository implements StorageRepository {
  _MemoryStorageRepository(this.value);

  bool savedArchiveWhileLocalExisted = false;
  StoredAttachment value;

  @override
  Future<StoredAttachment?> attachmentById(String id) async =>
      value.attachment.metadata.id == id ? value : null;

  @override
  Future<List<StoredAttachment>> attachments() async => [value];

  @override
  Future<void> completeArchiveRemoval(String attachmentId, DateTime at) async {
    value = StoredAttachment(
      attachment: _copyAttachment(
        value.attachment,
        state: AttachmentStorageState.archived,
        clearRelativePath: true,
        updatedAt: at,
      ),
      archiveReference: value.archiveReference,
    );
  }

  @override
  Future<DateTime?> latestContentChangeAt() async =>
      value.attachment.metadata.updatedAt;

  @override
  Future<void> markArchiveRemovalStarted(
    String attachmentId,
    DateTime at,
  ) async {
    value = StoredAttachment(
      attachment: _copyAttachment(
        value.attachment,
        state: AttachmentStorageState.archived,
        updatedAt: at,
      ),
      archiveReference: value.archiveReference,
    );
  }

  @override
  Future<void> restoreArchivedAttachment({
    required String attachmentId,
    required String relativePath,
    required int byteSize,
    required String checksum,
    required DateTime at,
  }) async {
    value = StoredAttachment(
      attachment: _copyAttachment(
        value.attachment,
        state: AttachmentStorageState.local,
        relativePath: relativePath,
        byteSize: byteSize,
        checksum: checksum,
        updatedAt: at,
      ),
      archiveReference: value.archiveReference,
    );
  }

  @override
  Future<void> revertArchiveRemoval(String attachmentId, DateTime at) async {
    value = StoredAttachment(
      attachment: _copyAttachment(
        value.attachment,
        state: AttachmentStorageState.local,
        updatedAt: at,
      ),
      archiveReference: value.archiveReference,
    );
  }

  @override
  Future<void> saveVerifiedArchive(
    ArchiveReference reference, {
    String? thumbnailRelativePath,
  }) async {
    savedArchiveWhileLocalExisted =
        value.attachment.storageState == AttachmentStorageState.local &&
        value.attachment.relativePath != null;
    value = StoredAttachment(
      attachment: _copyAttachment(
        value.attachment,
        thumbnailRelativePath: thumbnailRelativePath,
      ),
      archiveReference: reference,
    );
  }

  @override
  Future<void> updateOptimizedAttachment(Attachment attachment) async {
    value = StoredAttachment(
      attachment: attachment,
      archiveReference: value.archiveReference,
    );
  }
}

final class _ListStorageRepository implements StorageRepository {
  const _ListStorageRepository(this.values);

  final List<StoredAttachment> values;

  @override
  Future<StoredAttachment?> attachmentById(String id) async =>
      values.where((item) => item.attachment.metadata.id == id).firstOrNull;

  @override
  Future<List<StoredAttachment>> attachments() async => values;

  @override
  Future<void> completeArchiveRemoval(String attachmentId, DateTime at) =>
      throw UnimplementedError();

  @override
  Future<DateTime?> latestContentChangeAt() async => null;

  @override
  Future<void> markArchiveRemovalStarted(String attachmentId, DateTime at) =>
      throw UnimplementedError();

  @override
  Future<void> restoreArchivedAttachment({
    required String attachmentId,
    required String relativePath,
    required int byteSize,
    required String checksum,
    required DateTime at,
  }) => throw UnimplementedError();

  @override
  Future<void> revertArchiveRemoval(String attachmentId, DateTime at) =>
      throw UnimplementedError();

  @override
  Future<void> saveVerifiedArchive(
    ArchiveReference reference, {
    String? thumbnailRelativePath,
  }) => throw UnimplementedError();

  @override
  Future<void> updateOptimizedAttachment(Attachment attachment) =>
      throw UnimplementedError();
}

Attachment _copyAttachment(
  Attachment source, {
  AttachmentStorageState? state,
  String? relativePath,
  bool clearRelativePath = false,
  int? byteSize,
  String? checksum,
  String? thumbnailRelativePath,
  DateTime? updatedAt,
}) => Attachment(
  metadata: source.metadata.copyWith(updatedAt: updatedAt),
  evidenceId: source.evidenceId,
  storageState: state ?? source.storageState,
  importMode: source.importMode,
  mimeType: source.mimeType,
  byteSize: byteSize ?? source.byteSize,
  checksum: checksum ?? source.checksum,
  displayName: source.displayName,
  relativePath: clearRelativePath
      ? null
      : (relativePath ?? source.relativePath),
  thumbnailRelativePath: thumbnailRelativePath ?? source.thumbnailRelativePath,
  preservedOriginalRelativePath: source.preservedOriginalRelativePath,
  pixelWidth: source.pixelWidth,
  pixelHeight: source.pixelHeight,
);
