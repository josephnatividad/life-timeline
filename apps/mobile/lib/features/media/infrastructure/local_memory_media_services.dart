import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:cryptography/cryptography.dart';
import 'package:image/image.dart' as image;
import 'package:image_picker/image_picker.dart';
import 'package:life_timeline/features/media/domain/memory_media_import.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

final class ImagePickerMemoryMediaPicker implements MemoryMediaPicker {
  ImagePickerMemoryMediaPicker([ImagePicker? picker])
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<List<SelectedMemoryImage>> pick(MemoryMediaSource source) async {
    if (source == MemoryMediaSource.camera) {
      final image = await _picker.pickImage(
        source: ImageSource.camera,
        requestFullMetadata: false,
      );
      return image == null ? const [] : [_selected(image)];
    }
    final images = await _picker.pickMultiImage(requestFullMetadata: false);
    return images.map(_selected).toList(growable: false);
  }

  SelectedMemoryImage _selected(XFile file) => SelectedMemoryImage(
    path: file.path,
    displayName: file.name,
    mimeType: file.mimeType,
  );
}

final class LocalMemoryImageProcessor implements MemoryImageProcessor {
  const LocalMemoryImageProcessor({
    this.supportDirectoryProvider,
    this.maximumDisplayDimension = 2560,
    this.thumbnailDimension = 512,
  });

  final int maximumDisplayDimension;
  final Future<Directory> Function()? supportDirectoryProvider;
  final int thumbnailDimension;

  @override
  Future<ProcessedMemoryImage> process({
    required SelectedMemoryImage selected,
    required String attachmentId,
    required bool preserveOriginal,
  }) async {
    final support =
        await (supportDirectoryProvider?.call() ??
            getApplicationSupportDirectory());
    final root = Directory(p.join(support.path, 'attachments'));
    final extension = _safeExtension(selected.path, selected.mimeType);
    final originalRelative = p.join(
      'media',
      'originals',
      '$attachmentId$extension',
    );
    final displayRelative = p.join('media', 'display', '$attachmentId.jpg');
    final thumbnailRelative = p.join(
      'media',
      'thumbnails',
      '$attachmentId.jpg',
    );
    final originalPath = p.join(root.path, originalRelative);
    final displayPath = p.join(root.path, displayRelative);
    final thumbnailPath = p.join(root.path, thumbnailRelative);
    await Directory(p.dirname(originalPath)).create(recursive: true);
    await Directory(p.dirname(displayPath)).create(recursive: true);
    await Directory(p.dirname(thumbnailPath)).create(recursive: true);

    final result = await Isolate.run(
      () => _processImageFiles(
        selected.path,
        originalPath,
        displayPath,
        thumbnailPath,
        maximumDisplayDimension,
        thumbnailDimension,
      ),
    );
    final originalBytes = await File(originalPath).readAsBytes();
    final originalHash = base64UrlEncode(
      (await Sha256().hash(originalBytes)).bytes,
    );

    if (!result.decoded) {
      // HEIC/HEIF decoding is platform-dependent. Keep a durable managed copy
      // without a lossy or destructive conversion when the safe Dart decoder
      // cannot read it. The UI reports preview availability explicitly.
      return ProcessedMemoryImage(
        attachment: _attachment(
          id: attachmentId,
          selected: selected,
          relativePath: originalRelative,
          thumbnailRelativePath: null,
          preservedOriginalRelativePath: null,
          preservedOriginalByteSize: null,
          preservedOriginalChecksum: null,
          mimeType: _mimeType(selected, extension),
          byteSize: originalBytes.length,
          checksum: originalHash,
          importMode: AttachmentImportMode.preserveOriginal,
        ),
        managedRelativePaths: [originalRelative],
      );
    }

    final displayBytes = await File(displayPath).readAsBytes();
    final displayHash = base64UrlEncode(
      (await Sha256().hash(displayBytes)).bytes,
    );
    if (!preserveOriginal) await File(originalPath).delete();
    return ProcessedMemoryImage(
      attachment: _attachment(
        id: attachmentId,
        selected: selected,
        relativePath: displayRelative,
        thumbnailRelativePath: thumbnailRelative,
        preservedOriginalRelativePath: preserveOriginal
            ? originalRelative
            : null,
        preservedOriginalByteSize: preserveOriginal
            ? originalBytes.length
            : null,
        preservedOriginalChecksum: preserveOriginal ? originalHash : null,
        mimeType: 'image/jpeg',
        byteSize: displayBytes.length,
        checksum: displayHash,
        importMode: preserveOriginal
            ? AttachmentImportMode.preserveOriginal
            : AttachmentImportMode.optimizedCopy,
        pixelWidth: result.width,
        pixelHeight: result.height,
      ),
      managedRelativePaths: [
        displayRelative,
        thumbnailRelative,
        if (preserveOriginal) originalRelative,
      ],
    );
  }

  Attachment _attachment({
    required String id,
    required SelectedMemoryImage selected,
    required String relativePath,
    required String? thumbnailRelativePath,
    required String? preservedOriginalRelativePath,
    required int? preservedOriginalByteSize,
    required String? preservedOriginalChecksum,
    required String mimeType,
    required int byteSize,
    required String checksum,
    required AttachmentImportMode importMode,
    int? pixelWidth,
    int? pixelHeight,
  }) {
    final now = DateTime.now().toUtc();
    return Attachment(
      metadata: RecordMetadata(
        id: id,
        privacyClassification: PrivacyClassification.personal,
        lifecycle: RecordLifecycle.confirmed,
        createdAt: now,
        updatedAt: now,
      ),
      storageState: AttachmentStorageState.local,
      importMode: importMode,
      mimeType: mimeType,
      byteSize: byteSize,
      checksum: checksum,
      displayName: selected.displayName,
      relativePath: relativePath,
      thumbnailRelativePath: thumbnailRelativePath,
      preservedOriginalRelativePath: preservedOriginalRelativePath,
      preservedOriginalByteSize: preservedOriginalByteSize,
      preservedOriginalChecksum: preservedOriginalChecksum,
      pixelWidth: pixelWidth,
      pixelHeight: pixelHeight,
    );
  }

  @override
  Future<void> deleteManagedFiles(Iterable<String> relativePaths) async {
    final support =
        await (supportDirectoryProvider?.call() ??
            getApplicationSupportDirectory());
    final root = p.canonicalize(p.join(support.path, 'attachments'));
    for (final relative in relativePaths.toSet()) {
      if (relative.isEmpty || p.isAbsolute(relative)) {
        throw StateError('Managed media path must be relative.');
      }
      final resolved = p.canonicalize(p.join(root, relative));
      if (!p.isWithin(root, resolved)) {
        throw StateError('Managed media path escaped its storage root.');
      }
      final file = File(resolved);
      if (await file.exists()) await file.delete();
    }
  }

  String _safeExtension(String path, String? mimeType) {
    final extension = p.extension(path).toLowerCase();
    if (const {
      '.jpg',
      '.jpeg',
      '.png',
      '.webp',
      '.heic',
      '.heif',
    }.contains(extension)) {
      return extension;
    }
    return switch (mimeType?.toLowerCase()) {
      'image/png' => '.png',
      'image/webp' => '.webp',
      'image/heic' => '.heic',
      'image/heif' => '.heif',
      _ => '.jpg',
    };
  }

  String _mimeType(SelectedMemoryImage selected, String extension) =>
      selected.mimeType ??
      switch (extension) {
        '.png' => 'image/png',
        '.webp' => 'image/webp',
        '.heic' => 'image/heic',
        '.heif' => 'image/heif',
        _ => 'image/jpeg',
      };
}

final class _ImageProcessingResult {
  const _ImageProcessingResult({
    required this.decoded,
    this.width,
    this.height,
  });

  final bool decoded;
  final int? height;
  final int? width;
}

_ImageProcessingResult _processImageFiles(
  String sourcePath,
  String originalPath,
  String displayPath,
  String thumbnailPath,
  int maximumDisplayDimension,
  int thumbnailDimension,
) {
  final bytes = File(sourcePath).readAsBytesSync();
  File(originalPath).writeAsBytesSync(bytes, flush: true);
  final decoded = image.decodeImage(bytes);
  if (decoded == null) {
    return const _ImageProcessingResult(decoded: false);
  }
  final normalized = image.bakeOrientation(decoded);
  final display =
      normalized.width > maximumDisplayDimension ||
          normalized.height > maximumDisplayDimension
      ? image.copyResize(
          normalized,
          width: normalized.width >= normalized.height
              ? maximumDisplayDimension
              : null,
          height: normalized.height > normalized.width
              ? maximumDisplayDimension
              : null,
          interpolation: image.Interpolation.average,
        )
      : normalized;
  final thumbnail = image.copyResize(
    normalized,
    width: normalized.width >= normalized.height ? thumbnailDimension : null,
    height: normalized.height > normalized.width ? thumbnailDimension : null,
    interpolation: image.Interpolation.average,
  );
  File(
    displayPath,
  ).writeAsBytesSync(image.encodeJpg(display, quality: 88), flush: true);
  File(
    thumbnailPath,
  ).writeAsBytesSync(image.encodeJpg(thumbnail, quality: 82), flush: true);
  return _ImageProcessingResult(
    decoded: true,
    width: normalized.width,
    height: normalized.height,
  );
}
