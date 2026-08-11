import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:image/image.dart' as image;
import 'package:life_timeline/features/storage/domain/storage_models.dart';
import 'package:life_timeline/features/storage/domain/storage_ports.dart';
import 'package:life_timeline/shared/crypto/crypto_models.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';
import 'package:path/path.dart' as p;

final class LocalArchiveService implements ArchiveService {
  LocalArchiveService(
    this._repository,
    this._storage,
    this._encryption,
    this._paths, {
    DateTime Function()? now,
    Random? random,
  }) : _now = now ?? DateTime.now,
       _random = random ?? Random.secure();

  static const _formatVersion = 1;
  static const _encryptionAlgorithm = 'aes-256-gcm+argon2id';

  final EncryptionService _encryption;
  final DateTime Function() _now;
  final StoragePathProvider _paths;
  final Random _random;
  final StorageRepository _repository;
  final ArchiveStorage _storage;

  @override
  Future<ArchiveResult?> archive({
    required String attachmentId,
    required String recoveryPassword,
    required bool removeLocalOriginal,
    required void Function(ArchiveProgress progress) onProgress,
  }) async {
    if (recoveryPassword.length < 8) {
      throw const ArchiveFailure('recovery_password_too_short');
    }
    final stored = await _repository.attachmentById(attachmentId);
    final attachment = stored?.attachment;
    final relativePath = attachment?.relativePath;
    if (attachment == null ||
        attachment.storageState != AttachmentStorageState.local ||
        relativePath == null ||
        p.isAbsolute(relativePath)) {
      throw const ArchiveFailure('attachment_not_local');
    }
    onProgress(const ArchiveProgress(phase: ArchivePhase.verifyingSource));
    final root = p.canonicalize(await _paths.attachmentRootPath());
    final sourcePath = _resolveManaged(root, relativePath);
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw const ArchiveFailure('managed_file_missing');
    }
    final sourceSize = await source.length();
    final sourceHash = await _encryption.sha256File(source.path);
    if (attachment.checksum != null && attachment.checksum != sourceHash) {
      throw const ArchiveFailure('source_checksum_mismatch');
    }

    onProgress(const ArchiveProgress(phase: ArchivePhase.preparingPreview));
    final thumbnail = await _ensureThumbnail(root, attachment, source.path);
    final operation = await _operationDirectory('archive');
    final encrypted = File(p.join(operation.path, 'storage-archive.bin'));
    var archiveReferenceRecorded = false;
    try {
      onProgress(const ArchiveProgress(phase: ArchivePhase.encrypting));
      await _encryption.encryptFile(
        inputPath: source.path,
        outputPath: encrypted.path,
        password: recoveryPassword,
        createdAt: _now().toUtc(),
        databaseSchemaVersion: _formatVersion,
        attachmentCount: 1,
      );
      final archiveHash = await _encryption.sha256File(encrypted.path);
      final archiveSize = await encrypted.length();
      final suggestedName = _archiveFileName(attachment);

      onProgress(
        const ArchiveProgress(phase: ArchivePhase.choosingDestination),
      );
      final destination = await _storage.saveArchive(
        sourcePath: encrypted.path,
        suggestedName: suggestedName,
        expectedSha256: archiveHash,
      );
      if (destination == null) return null;
      onProgress(const ArchiveProgress(phase: ArchivePhase.verifyingArchive));
      if (!destination.verified) {
        throw const ArchiveFailure('archive_verification_failed');
      }
      final now = _now().toUtc();
      final reference = ArchiveReference(
        id: _id('archive'),
        attachmentId: attachmentId,
        destinationType: ArchiveDestinationType.userSelectedFile,
        logicalKey: destination.logicalKey,
        originalByteSize: sourceSize,
        originalSha256: sourceHash,
        archiveByteSize: archiveSize,
        archiveSha256: archiveHash,
        encryptionAlgorithm: _encryptionAlgorithm,
        formatVersion: _formatVersion,
        archivedAt: now,
        verifiedAt: now,
      );
      onProgress(const ArchiveProgress(phase: ArchivePhase.recordingReference));
      await _repository.saveVerifiedArchive(
        reference,
        thumbnailRelativePath: thumbnail,
      );
      archiveReferenceRecorded = true;

      var removed = false;
      if (removeLocalOriginal) {
        onProgress(
          const ArchiveProgress(phase: ArchivePhase.removingLocalCopy),
        );
        await _repository.markArchiveRemovalStarted(attachmentId, now);
        try {
          await source.delete();
        } on Object {
          await _repository.revertArchiveRemoval(attachmentId, _now().toUtc());
        }
        if (!await source.exists()) {
          await _repository.completeArchiveRemoval(
            attachmentId,
            _now().toUtc(),
          );
          removed = true;
        }
      }
      onProgress(const ArchiveProgress(phase: ArchivePhase.complete));
      return ArchiveResult(
        reference: reference,
        localOriginalRemoved: removed,
        thumbnailRetained: thumbnail != null,
      );
    } on ArchiveFailure {
      rethrow;
    } on CryptoFailure catch (error) {
      throw ArchiveFailure('archive_${error.code}');
    } on Object {
      if (!archiveReferenceRecorded) {
        throw const ArchiveFailure('archive_failed');
      }
      rethrow;
    } finally {
      await _deleteDirectory(operation);
    }
  }

  @override
  Future<ArchiveRetrievalResult> retrieve({
    required String attachmentId,
    required String recoveryPassword,
    required void Function(ArchiveProgress progress) onProgress,
  }) async {
    final stored = await _repository.attachmentById(attachmentId);
    final attachment = stored?.attachment;
    final reference = stored?.archiveReference;
    if (attachment == null || reference == null) {
      throw const ArchiveFailure('archive_reference_missing');
    }
    onProgress(const ArchiveProgress(phase: ArchivePhase.choosingDestination));
    final selected = await _storage.chooseArchiveForRetrieval(reference);
    if (selected == null) {
      return const ArchiveRetrievalResult(
        outcome: ArchiveRetrievalOutcome.canceled,
      );
    }
    final archive = File(selected);
    if (!await archive.exists()) {
      return const ArchiveRetrievalResult(
        outcome: ArchiveRetrievalOutcome.unavailable,
      );
    }
    onProgress(const ArchiveProgress(phase: ArchivePhase.verifyingArchive));
    if (await archive.length() != reference.archiveByteSize ||
        await _encryption.sha256File(archive.path) != reference.archiveSha256) {
      throw const ArchiveFailure('archive_checksum_mismatch');
    }
    final operation = await _operationDirectory('retrieve');
    final decrypted = File(p.join(operation.path, 'storage-retrieved.bin'));
    try {
      onProgress(const ArchiveProgress(phase: ArchivePhase.decrypting));
      await _encryption.decryptFile(
        inputPath: archive.path,
        outputPath: decrypted.path,
        password: recoveryPassword,
      );
      if (await decrypted.length() != reference.originalByteSize ||
          await _encryption.sha256File(decrypted.path) !=
              reference.originalSha256) {
        throw const ArchiveFailure('retrieved_checksum_mismatch');
      }
      final root = p.canonicalize(await _paths.attachmentRootPath());
      final relative = p.join(
        'retrieved',
        _safeSegment(attachmentId),
        '${_now().toUtc().microsecondsSinceEpoch}-${_safeFileName(attachment)}',
      );
      final targetPath = _resolveManaged(root, relative);
      final target = File(targetPath);
      await target.parent.create(recursive: true);
      await decrypted.copy(target.path);
      if (await _encryption.sha256File(target.path) !=
          reference.originalSha256) {
        await target.delete();
        throw const ArchiveFailure('retrieved_checksum_mismatch');
      }
      await _repository.restoreArchivedAttachment(
        attachmentId: attachmentId,
        relativePath: relative,
        byteSize: reference.originalByteSize,
        checksum: reference.originalSha256,
        at: _now().toUtc(),
      );
      onProgress(const ArchiveProgress(phase: ArchivePhase.complete));
      return ArchiveRetrievalResult(
        outcome: ArchiveRetrievalOutcome.restored,
        restoredRelativePath: relative,
      );
    } on ArchiveFailure {
      rethrow;
    } on CryptoFailure catch (error) {
      throw ArchiveFailure('archive_${error.code}');
    } finally {
      await _deleteDirectory(operation);
    }
  }

  Future<String?> _ensureThumbnail(
    String root,
    Attachment attachment,
    String sourcePath,
  ) async {
    final existing = attachment.thumbnailRelativePath;
    if (existing != null &&
        await File(_resolveManaged(root, existing)).exists()) {
      return existing;
    }
    if (!attachment.mimeType.toLowerCase().startsWith('image/')) return null;
    final relative = p.join(
      'thumbnails',
      '${_safeSegment(attachment.metadata.id)}.jpg',
    );
    final target = _resolveManaged(root, relative);
    try {
      final created = await Isolate.run(
        () => _createThumbnail(sourcePath, target),
      );
      return created ? relative : null;
    } on Object {
      return null;
    }
  }

  Future<Directory> _operationDirectory(String purpose) async {
    final temp = p.canonicalize(await _paths.temporaryPath());
    final root = Directory(p.join(temp, 'timeline_storage_processing'));
    await root.create(recursive: true);
    return root.createTemp('storage-$purpose-');
  }

  String _resolveManaged(String root, String relativePath) {
    if (relativePath.isEmpty || p.isAbsolute(relativePath)) {
      throw const ArchiveFailure('attachment_path_invalid');
    }
    final resolved = p.canonicalize(p.join(root, relativePath));
    if (!p.isWithin(root, resolved)) {
      throw const ArchiveFailure('attachment_path_invalid');
    }
    return resolved;
  }

  String _archiveFileName(Attachment attachment) =>
      '${_safeSegment(attachment.metadata.id)}-${_now().toUtc().microsecondsSinceEpoch}.timelinearchive';

  String _safeFileName(Attachment attachment) {
    final display = attachment.displayName;
    if (display != null && display.trim().isNotEmpty) {
      return _safeSegment(display);
    }
    final extension = switch (attachment.mimeType.toLowerCase()) {
      'image/jpeg' => '.jpg',
      'image/png' => '.png',
      'application/pdf' => '.pdf',
      _ => '.bin',
    };
    return 'original$extension';
  }

  String _safeSegment(String value) {
    final safe = value.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    if (safe.isEmpty || safe == '.' || safe == '..') {
      throw const ArchiveFailure('unsafe_file_name');
    }
    return safe;
  }

  String _id(String prefix) {
    final entropy = _random.nextInt(0x7fffffff).toRadixString(36);
    return '$prefix-${_now().toUtc().microsecondsSinceEpoch}-$entropy';
  }

  Future<void> _deleteDirectory(Directory directory) async {
    if (!await directory.exists()) return;
    try {
      await directory.delete(recursive: true);
    } on FileSystemException {
      // The scoped cleanup service will retry stale processing directories.
    }
  }
}

bool _createThumbnail(String sourcePath, String targetPath) {
  final decoded = image.decodeImage(File(sourcePath).readAsBytesSync());
  if (decoded == null) return false;
  var normalized = image.bakeOrientation(decoded);
  if (normalized.width > 512 || normalized.height > 512) {
    normalized = image.copyResize(
      normalized,
      width: normalized.width >= normalized.height ? 512 : null,
      height: normalized.height > normalized.width ? 512 : null,
      interpolation: image.Interpolation.average,
    );
  }
  final target = File(targetPath);
  target.parent.createSync(recursive: true);
  target.writeAsBytesSync(
    image.encodeJpg(normalized, quality: 72),
    flush: true,
  );
  return true;
}
