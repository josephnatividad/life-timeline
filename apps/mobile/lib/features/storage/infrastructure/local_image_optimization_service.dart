import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:cryptography/cryptography.dart';
import 'package:image/image.dart' as image;
import 'package:life_timeline/features/storage/domain/storage_models.dart';
import 'package:life_timeline/features/storage/domain/storage_ports.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';
import 'package:path/path.dart' as p;

final class LocalImageOptimizationService implements ImageOptimizationService {
  const LocalImageOptimizationService(
    this._repository,
    this._paths, {
    this.minimumBytes = 1024 * 1024,
    this.maximumDimension = 2400,
  });

  final int maximumDimension;
  final int minimumBytes;
  final StoragePathProvider _paths;
  final StorageRepository _repository;

  @override
  Future<ImageOptimizationResult> optimize(
    String attachmentId, {
    required bool preserveOriginal,
  }) async {
    final stored = await _repository.attachmentById(attachmentId);
    final attachment = stored?.attachment;
    final relative = attachment?.relativePath;
    if (attachment == null ||
        attachment.storageState != AttachmentStorageState.local ||
        relative == null) {
      return const ImageOptimizationResult(
        outcome: ImageOptimizationOutcome.missing,
        beforeBytes: 0,
        afterBytes: 0,
        originalPreserved: false,
        originalRemoved: false,
      );
    }
    if (attachment.importMode == AttachmentImportMode.optimizedCopy ||
        attachment.mimeType.toLowerCase() != 'image/jpeg') {
      return ImageOptimizationResult(
        outcome: ImageOptimizationOutcome.unsupported,
        beforeBytes: attachment.byteSize,
        afterBytes: attachment.byteSize,
        originalPreserved: attachment.preservedOriginalRelativePath != null,
        originalRemoved: false,
      );
    }
    final root = p.canonicalize(await _paths.attachmentRootPath());
    final sourcePath = _resolveManaged(root, relative);
    final source = File(sourcePath);
    if (!await source.exists()) {
      return const ImageOptimizationResult(
        outcome: ImageOptimizationOutcome.missing,
        beforeBytes: 0,
        afterBytes: 0,
        originalPreserved: false,
        originalRemoved: false,
      );
    }
    final beforeBytes = await source.length();
    final targetRelative = p.join(
      'optimized',
      '$attachmentId-${DateTime.now().toUtc().microsecondsSinceEpoch}.jpg',
    );
    final targetPath = _resolveManaged(root, targetRelative);
    final result = await Isolate.run(
      () =>
          _optimizeJpeg(sourcePath, targetPath, minimumBytes, maximumDimension),
    );
    if (!result.created) {
      return ImageOptimizationResult(
        outcome: ImageOptimizationOutcome.alreadyEfficient,
        beforeBytes: beforeBytes,
        afterBytes: beforeBytes,
        originalPreserved: false,
        originalRemoved: false,
      );
    }
    final target = File(targetPath);
    final afterBytes = await target.length();
    if (afterBytes >= (beforeBytes * 0.95).round()) {
      await target.delete();
      return ImageOptimizationResult(
        outcome: ImageOptimizationOutcome.alreadyEfficient,
        beforeBytes: beforeBytes,
        afterBytes: beforeBytes,
        originalPreserved: false,
        originalRemoved: false,
      );
    }
    final checksum = await _sha256(targetPath);
    final updatedAt = DateTime.now().toUtc();
    final optimized = Attachment(
      metadata: attachment.metadata.copyWith(updatedAt: updatedAt),
      storageState: AttachmentStorageState.local,
      importMode: AttachmentImportMode.optimizedCopy,
      mimeType: 'image/jpeg',
      byteSize: afterBytes,
      checksum: checksum,
      displayName: attachment.displayName,
      relativePath: targetRelative,
      thumbnailRelativePath: attachment.thumbnailRelativePath,
      // Keep the source tracked until an explicit deletion succeeds. This
      // makes interruption conservative rather than creating an orphan.
      preservedOriginalRelativePath: relative,
      preservedOriginalByteSize: beforeBytes,
      preservedOriginalChecksum: attachment.checksum,
      pixelWidth: result.width,
      pixelHeight: result.height,
    );
    try {
      await _repository.updateOptimizedAttachment(optimized);
    } on Object {
      await target.delete();
      rethrow;
    }
    var originalRemoved = false;
    if (!preserveOriginal) {
      try {
        await source.delete();
        originalRemoved = true;
        await _repository.updateOptimizedAttachment(
          Attachment(
            metadata: optimized.metadata,
            storageState: optimized.storageState,
            importMode: optimized.importMode,
            mimeType: optimized.mimeType,
            byteSize: optimized.byteSize,
            checksum: optimized.checksum,
            displayName: optimized.displayName,
            relativePath: optimized.relativePath,
            thumbnailRelativePath: optimized.thumbnailRelativePath,
            pixelWidth: optimized.pixelWidth,
            pixelHeight: optimized.pixelHeight,
          ),
        );
      } on FileSystemException {
        originalRemoved = false;
      }
    }
    return ImageOptimizationResult(
      outcome: ImageOptimizationOutcome.optimized,
      beforeBytes: beforeBytes,
      afterBytes: afterBytes,
      originalPreserved: preserveOriginal || !originalRemoved,
      originalRemoved: originalRemoved,
    );
  }

  String _resolveManaged(String root, String relativePath) {
    if (relativePath.isEmpty || p.isAbsolute(relativePath)) {
      throw StateError('Managed image path must be relative.');
    }
    final resolved = p.canonicalize(p.join(root, relativePath));
    if (!p.isWithin(root, resolved)) {
      throw StateError('Managed image path escaped its storage root.');
    }
    return resolved;
  }

  Future<String> _sha256(String path) async {
    final sink = Sha256().newHashSink();
    await for (final chunk in File(path).openRead()) {
      sink.add(chunk);
    }
    sink.close();
    return base64UrlEncode((await sink.hash()).bytes);
  }
}

({bool created, int? width, int? height}) _optimizeJpeg(
  String sourcePath,
  String targetPath,
  int minimumBytes,
  int maximumDimension,
) {
  final source = File(sourcePath);
  final bytes = source.readAsBytesSync();
  final decoded = image.decodeImage(bytes);
  if (decoded == null) return (created: false, width: null, height: null);
  var normalized = image.bakeOrientation(decoded);
  if (bytes.length < minimumBytes &&
      normalized.width <= maximumDimension &&
      normalized.height <= maximumDimension) {
    return (created: false, width: normalized.width, height: normalized.height);
  }
  if (normalized.width > maximumDimension ||
      normalized.height > maximumDimension) {
    normalized = image.copyResize(
      normalized,
      width: normalized.width >= normalized.height ? maximumDimension : null,
      height: normalized.height > normalized.width ? maximumDimension : null,
      interpolation: image.Interpolation.average,
    );
  }
  final target = File(targetPath);
  target.parent.createSync(recursive: true);
  target.writeAsBytesSync(
    image.encodeJpg(normalized, quality: 90),
    flush: true,
  );
  return (created: true, width: normalized.width, height: normalized.height);
}
