import 'package:life_timeline/features/private_intelligence/domain/intelligence_models.dart';

final class CapturedImage {
  const CapturedImage({required this.path, required this.source});
  final String path;
  final CaptureSource source;
}

final class PreparedImage {
  const PreparedImage({
    required this.path,
    required this.mimeType,
    required this.byteSize,
  });
  final int byteSize;
  final String mimeType;
  final String path;
}

final class ManagedImage {
  const ManagedImage({
    required this.absolutePath,
    required this.relativePath,
    required this.byteSize,
    required this.checksum,
  });
  final String absolutePath;
  final int byteSize;
  final String checksum;
  final String relativePath;
}

abstract interface class ImageAcquisitionService {
  Future<CapturedImage?> acquire(CaptureSource source);
  Future<void> release(CapturedImage image);
}

abstract interface class ImagePreparationService {
  Future<PreparedImage> prepare(CapturedImage image);
  Future<void> discard(PreparedImage image);
}

abstract interface class CandidateAttachmentStore {
  Future<ManagedImage> store(PreparedImage image, String attachmentId);
  Future<void> remove(ManagedImage image);
}

typedef CaptureStageChanged = void Function(String stage);
