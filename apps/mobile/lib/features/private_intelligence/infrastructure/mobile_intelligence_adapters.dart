import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:cryptography/cryptography.dart';
import 'package:image/image.dart' as image;
import 'package:image_picker/image_picker.dart';
import 'package:life_timeline/features/private_intelligence/application/intelligence_ports.dart';
import 'package:life_timeline/features/private_intelligence/domain/document_intelligence.dart';
import 'package:life_timeline/features/private_intelligence/domain/intelligence_models.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Placeholder retained behind the project-owned recognition boundary.
///
/// Network-enabled builds intentionally ship without a native OCR SDK until a
/// telemetry-free local engine passes the documented benchmark and review.
final class UnavailableTextRecognitionEngine implements TextRecognitionEngine {
  const UnavailableTextRecognitionEngine();

  @override
  Future<OcrDocument> recognize(String imagePath) =>
      throw const TextRecognitionUnavailableException();

  @override
  Future<void> close() async {}
}

final class TextRecognitionUnavailableException implements Exception {
  const TextRecognitionUnavailableException();
}

final class ImagePickerAcquisitionService implements ImageAcquisitionService {
  ImagePickerAcquisitionService([ImagePicker? picker])
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<CapturedImage?> acquire(CaptureSource source) async {
    if (source == CaptureSource.manual) return null;
    final pickerSource = source == CaptureSource.photoLibrary
        ? ImageSource.gallery
        : ImageSource.camera;
    final selected = await _picker.pickImage(
      source: pickerSource,
      requestFullMetadata: false,
    );
    return selected == null
        ? null
        : CapturedImage(path: selected.path, source: source);
  }

  @override
  Future<void> release(CapturedImage image) async {
    if (image.source == CaptureSource.photoLibrary) return;
    final file = File(image.path);
    if (await file.exists()) await file.delete();
  }
}

final class IsolateImagePreparationService implements ImagePreparationService {
  const IsolateImagePreparationService({this.maximumDimension = 2048});

  final int maximumDimension;

  @override
  Future<PreparedImage> prepare(CapturedImage captured) async {
    final root = await getTemporaryDirectory();
    final directory = Directory(p.join(root.path, 'private_intelligence'));
    await directory.create(recursive: true);
    await _deleteStaleWorkingCopies(directory);
    final target = p.join(
      directory.path,
      'ocr_${DateTime.now().toUtc().microsecondsSinceEpoch}.jpg',
    );
    final result = await Isolate.run(
      () => _prepareImage(captured.path, target, maximumDimension),
    );
    return PreparedImage(
      path: target,
      mimeType: 'image/jpeg',
      byteSize: result,
    );
  }

  @override
  Future<void> discard(PreparedImage prepared) async {
    final file = File(prepared.path);
    if (await file.exists()) await file.delete();
  }
}

Future<void> _deleteStaleWorkingCopies(Directory directory) async {
  final cutoff = DateTime.now().toUtc().subtract(const Duration(days: 1));
  await for (final entity in directory.list()) {
    if (entity is! File || !p.basename(entity.path).startsWith('ocr_')) {
      continue;
    }
    final modified = (await entity.stat()).modified.toUtc();
    if (modified.isBefore(cutoff)) await entity.delete();
  }
}

int _prepareImage(String sourcePath, String targetPath, int maximumDimension) {
  final decoded = image.decodeImage(File(sourcePath).readAsBytesSync());
  if (decoded == null) throw const FormatException('Unsupported image file.');
  var normalized = image.bakeOrientation(decoded);
  if (normalized.width > maximumDimension ||
      normalized.height > maximumDimension) {
    normalized = image.copyResize(
      normalized,
      width: normalized.width >= normalized.height ? maximumDimension : null,
      height: normalized.height > normalized.width ? maximumDimension : null,
      interpolation: image.Interpolation.average,
    );
  }
  final bytes = image.encodeJpg(normalized, quality: 86);
  File(targetPath).writeAsBytesSync(bytes, flush: true);
  return bytes.length;
}

final class AppPrivateCandidateAttachmentStore
    implements CandidateAttachmentStore {
  const AppPrivateCandidateAttachmentStore({this.supportDirectoryProvider});

  final Future<Directory> Function()? supportDirectoryProvider;

  @override
  Future<ManagedImage> store(
    PreparedImage prepared,
    String attachmentId,
  ) async {
    final support =
        await (supportDirectoryProvider?.call() ??
            getApplicationSupportDirectory());
    final attachmentRoot = p.join(support.path, 'attachments');
    final relative = p.join('intelligence', '$attachmentId.jpg');
    final destination = File(p.join(attachmentRoot, relative));
    await destination.parent.create(recursive: true);
    await File(prepared.path).copy(destination.path);
    final bytes = await destination.readAsBytes();
    final digest = await Sha256().hash(bytes);
    return ManagedImage(
      absolutePath: destination.path,
      relativePath: relative,
      byteSize: bytes.length,
      checksum: base64UrlEncode(digest.bytes),
    );
  }

  @override
  Future<void> remove(ManagedImage image) async {
    final file = File(image.absolutePath);
    if (await file.exists()) await file.delete();
  }
}
