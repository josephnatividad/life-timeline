import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:life_timeline/features/storage/domain/storage_models.dart';
import 'package:life_timeline/features/storage/domain/storage_ports.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

final class PathProviderStoragePaths implements StoragePathProvider {
  const PathProviderStoragePaths();

  @override
  Future<String> applicationDocumentsPath() async =>
      (await getApplicationDocumentsDirectory()).path;

  @override
  Future<String> applicationSupportPath() async =>
      (await getApplicationSupportDirectory()).path;

  @override
  Future<String> attachmentRootPath() async =>
      p.join(await applicationSupportPath(), 'attachments');

  @override
  Future<String> temporaryPath() async => (await getTemporaryDirectory()).path;
}

final class FileSystemStorageInventoryService
    implements StorageInventoryService {
  const FileSystemStorageInventoryService(this._repository, this._paths);

  static const _staleAge = Duration(hours: 24);

  final StoragePathProvider _paths;
  final StorageRepository _repository;

  @override
  Future<StorageInventory> analyze() async {
    final attachments = await _repository.attachments();
    final attachmentRoot = p.canonicalize(await _paths.attachmentRootPath());
    final supportRoot = p.canonicalize(await _paths.applicationSupportPath());
    final documentsRoot = p.canonicalize(
      await _paths.applicationDocumentsPath(),
    );
    final tempRoot = p.canonicalize(await _paths.temporaryPath());
    final measurements = <ManagedFileMeasurement>[];
    final accountedAttachmentPaths = <String>{};
    final uniqueAttachmentSizes = <String, int>{};
    final uniqueAttachmentKinds = <String, _ManagedKind>{};

    for (final stored in attachments) {
      final attachment = stored.attachment;
      await _measureAttachmentPath(
        attachmentRoot,
        attachment,
        stored.roles,
        attachment.relativePath,
        false,
        measurements,
        accountedAttachmentPaths,
        uniqueAttachmentSizes,
        uniqueAttachmentKinds,
      );
      await _measureAttachmentPath(
        attachmentRoot,
        attachment,
        stored.roles,
        attachment.preservedOriginalRelativePath,
        true,
        measurements,
        accountedAttachmentPaths,
        uniqueAttachmentSizes,
        uniqueAttachmentKinds,
      );
      final thumbnail = attachment.thumbnailRelativePath;
      if (thumbnail != null) {
        final resolved = _resolveManaged(attachmentRoot, thumbnail);
        accountedAttachmentPaths.add(resolved);
        final size = await _existingFileSize(resolved);
        if (size != null) {
          uniqueAttachmentSizes[resolved] = size;
          uniqueAttachmentKinds[resolved] = _ManagedKind.thumbnail;
        }
      }
    }

    var photosBytes = 0;
    var documentsBytes = 0;
    var thumbnailsBytes = 0;
    var attachmentOtherBytes = 0;
    for (final entry in uniqueAttachmentSizes.entries) {
      switch (uniqueAttachmentKinds[entry.key]!) {
        case _ManagedKind.photo:
          photosBytes += entry.value;
        case _ManagedKind.document:
          documentsBytes += entry.value;
        case _ManagedKind.thumbnail:
          thumbnailsBytes += entry.value;
        case _ManagedKind.other:
          attachmentOtherBytes += entry.value;
      }
    }

    final databaseBytes = await _databaseBytes(documentsRoot);
    final cache = await _cacheMeasurements(tempRoot, DateTime.now().toUtc());
    final supportBytes = await _directoryBytes(
      Directory(supportRoot),
      excluding: accountedAttachmentPaths,
    );
    final duplicates = _duplicates(measurements);
    final missingManaged = measurements
        .where((measurement) => !measurement.exists)
        .length;

    return StorageInventory(
      breakdown: StorageBreakdown(
        photosBytes: photosBytes,
        documentsBytes: documentsBytes,
        thumbnailsBytes: thumbnailsBytes,
        databaseBytes: databaseBytes,
        cacheBytes: cache.totalBytes,
        otherManagedBytes: supportBytes + attachmentOtherBytes,
      ),
      attachments: attachments,
      managedFiles: measurements,
      duplicateGroups: duplicates,
      archivedContentBytes: attachments.fold(
        0,
        (total, stored) =>
            total + (stored.archiveReference?.originalByteSize ?? 0),
      ),
      archivedContentCount: attachments
          .where((stored) => stored.archiveReference != null)
          .length,
      referencedContentCount: attachments
          .where(
            (stored) =>
                stored.attachment.storageState ==
                AttachmentStorageState.referenced,
          )
          .length,
      unavailableContentCount: attachments
          .where(
            (stored) =>
                stored.attachment.storageState ==
                AttachmentStorageState.unavailable,
          )
          .length,
      missingManagedFileCount: missingManaged,
      reclaimableCacheBytes: cache.reclaimableBytes,
    );
  }

  Future<void> _measureAttachmentPath(
    String root,
    Attachment attachment,
    Set<AttachmentRole> roles,
    String? relativePath,
    bool preservedOriginal,
    List<ManagedFileMeasurement> measurements,
    Set<String> accounted,
    Map<String, int> uniqueSizes,
    Map<String, _ManagedKind> uniqueKinds,
  ) async {
    if (relativePath == null || p.isAbsolute(relativePath)) return;
    final resolved = _resolveManaged(root, relativePath);
    accounted.add(resolved);
    final size = await _existingFileSize(resolved);
    final exists = size != null;
    final checksum = exists ? await _sha256(resolved) : null;
    measurements.add(
      ManagedFileMeasurement(
        attachmentId: attachment.metadata.id,
        relativePath: relativePath,
        exists: exists,
        byteSize: size ?? 0,
        sha256: checksum,
        preservedOriginal: preservedOriginal,
      ),
    );
    if (size != null) {
      uniqueSizes[resolved] = size;
      uniqueKinds[resolved] = _kindFor(attachment.mimeType, roles);
    }
  }

  List<StorageDuplicateGroup> _duplicates(
    List<ManagedFileMeasurement> measurements,
  ) {
    final grouped = <String, List<ManagedFileMeasurement>>{};
    for (final measurement in measurements) {
      final hash = measurement.sha256;
      if (!measurement.exists || hash == null) continue;
      grouped
          .putIfAbsent('$hash:${measurement.byteSize}', () => [])
          .add(measurement);
    }
    return [
      for (final group in grouped.values)
        if (group.length > 1)
          StorageDuplicateGroup(
            sha256: group.first.sha256!,
            byteSize: group.first.byteSize,
            attachmentIds: {
              for (final measurement in group) measurement.attachmentId,
            }.toList(),
            distinctRelativePaths: {
              for (final measurement in group) measurement.relativePath,
            }.toList(),
          ),
    ];
  }

  Future<int> _databaseBytes(String documentsRoot) async {
    var total = 0;
    for (final suffix in const ['', '-wal', '-shm']) {
      total +=
          await _existingFileSize(
            p.join(documentsRoot, 'life_timeline.sqlite$suffix'),
          ) ??
          0;
    }
    return total;
  }

  Future<_CacheMeasurement> _cacheMeasurements(
    String tempRoot,
    DateTime now,
  ) async {
    var total = 0;
    var reclaimable = 0;
    for (final rule in _cleanupRules(tempRoot)) {
      final directory = Directory(rule.directoryPath);
      if (!await directory.exists()) continue;
      await for (final entity in directory.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is! File || !rule.matches(entity.path)) continue;
        final stat = await entity.stat();
        total += stat.size;
        if (now.difference(stat.modified.toUtc()) > _staleAge) {
          reclaimable += stat.size;
        }
      }
    }
    return _CacheMeasurement(total, reclaimable);
  }

  Future<int> _directoryBytes(
    Directory directory, {
    Set<String> excluding = const {},
  }) async {
    if (!await directory.exists()) return 0;
    var total = 0;
    await for (final entity in directory.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File) continue;
      final normalized = p.canonicalize(entity.path);
      if (!excluding.contains(normalized)) total += await entity.length();
    }
    return total;
  }

  String _resolveManaged(String root, String relativePath) {
    if (relativePath.isEmpty || p.isAbsolute(relativePath)) {
      throw StateError('Managed attachment paths must be relative.');
    }
    final resolved = p.canonicalize(p.join(root, relativePath));
    if (!p.isWithin(root, resolved)) {
      throw StateError('Managed attachment path escaped its storage root.');
    }
    return resolved;
  }

  Future<int?> _existingFileSize(String path) async {
    final file = File(path);
    return await file.exists() ? file.length() : null;
  }

  Future<String> _sha256(String path) async {
    final sink = Sha256().newHashSink();
    await for (final chunk in File(path).openRead()) {
      sink.add(chunk);
    }
    sink.close();
    return base64UrlEncode((await sink.hash()).bytes);
  }

  _ManagedKind _kindFor(String mimeType, Set<AttachmentRole> roles) {
    final normalized = mimeType.toLowerCase();
    if (normalized.startsWith('image/')) {
      if (roles.contains(AttachmentRole.heroMedia) ||
          roles.contains(AttachmentRole.memoryMedia)) {
        return _ManagedKind.photo;
      }
      if (roles.contains(AttachmentRole.evidence)) {
        return _ManagedKind.document;
      }
      return _ManagedKind.photo;
    }
    if (normalized == 'application/pdf' ||
        normalized.startsWith('text/') ||
        normalized.contains('document')) {
      return _ManagedKind.document;
    }
    return _ManagedKind.other;
  }
}

final class ScopedStorageCleanupService implements StorageCleanupService {
  const ScopedStorageCleanupService(this._paths);

  static const _staleAge = Duration(hours: 24);
  final StoragePathProvider _paths;

  @override
  Future<StorageCleanupResult> cleanStaleTemporaryFiles(DateTime now) async {
    final tempRoot = p.canonicalize(await _paths.temporaryPath());
    var removedBytes = 0;
    var removedEntries = 0;
    for (final rule in _cleanupRules(tempRoot)) {
      final directory = Directory(rule.directoryPath);
      if (!await directory.exists()) continue;
      await for (final entity in directory.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is! File || !rule.matches(entity.path)) continue;
        final stat = await entity.stat();
        if (now.toUtc().difference(stat.modified.toUtc()) <= _staleAge) {
          continue;
        }
        removedBytes += stat.size;
        await entity.delete();
        removedEntries++;
      }
      await _removeEmptyChildren(directory);
    }
    return StorageCleanupResult(
      removedBytes: removedBytes,
      removedEntries: removedEntries,
    );
  }

  Future<void> _removeEmptyChildren(Directory root) async {
    final directories = <Directory>[];
    await for (final entity in root.list(recursive: true, followLinks: false)) {
      if (entity is Directory) directories.add(entity);
    }
    directories.sort(
      (left, right) => right.path.length.compareTo(left.path.length),
    );
    for (final directory in directories) {
      if (await directory.list(followLinks: false).isEmpty) {
        await directory.delete();
      }
    }
  }
}

List<_CleanupRule> _cleanupRules(String tempRoot) => [
  _CleanupRule(
    p.join(tempRoot, 'life_timeline_story_exports'),
    (path) =>
        p.basename(path).startsWith('story-export-') &&
        p.extension(path).toLowerCase() == '.png',
  ),
  _CleanupRule(p.join(tempRoot, 'timeline_backup_staging'), (path) => true),
  _CleanupRule(
    p.join(tempRoot, 'private_intelligence'),
    (path) => p.basename(path).startsWith('ocr_'),
  ),
  _CleanupRule(
    p.join(tempRoot, 'timeline_storage_processing'),
    (path) => p.basename(path).startsWith('storage-'),
  ),
];

enum _ManagedKind { photo, document, thumbnail, other }

final class _CacheMeasurement {
  const _CacheMeasurement(this.totalBytes, this.reclaimableBytes);

  final int reclaimableBytes;
  final int totalBytes;
}

final class _CleanupRule {
  const _CleanupRule(this.directoryPath, this.matches);

  final String directoryPath;
  final bool Function(String path) matches;
}
