import 'package:life_timeline/shared/domain/model/timeline_models.dart';

enum MemoryMediaSource { camera, photoLibrary }

final class SelectedMemoryImage {
  const SelectedMemoryImage({
    required this.path,
    required this.displayName,
    this.mimeType,
    this.capturedAt,
  });

  final DateTime? capturedAt;
  final String displayName;
  final String? mimeType;
  final String path;
}

abstract interface class MemoryMediaPicker {
  Future<List<SelectedMemoryImage>> pick(MemoryMediaSource source);
}

final class ProcessedMemoryImage {
  const ProcessedMemoryImage({
    required this.attachment,
    required this.managedRelativePaths,
  });

  final Attachment attachment;
  final List<String> managedRelativePaths;
}

abstract interface class MemoryImageProcessor {
  Future<ProcessedMemoryImage> process({
    required SelectedMemoryImage selected,
    required String attachmentId,
    required bool preserveOriginal,
  });

  Future<void> deleteManagedFiles(Iterable<String> relativePaths);
}
