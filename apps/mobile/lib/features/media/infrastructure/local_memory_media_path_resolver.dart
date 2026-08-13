import 'dart:io';

import 'package:life_timeline/features/media/domain/memory_media_paths.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

final class LocalMemoryMediaPathResolver implements MemoryMediaPathResolver {
  const LocalMemoryMediaPathResolver({this.supportDirectoryProvider});

  final Future<Directory> Function()? supportDirectoryProvider;

  @override
  Future<String?> resolve(
    Attachment attachment, {
    required bool preferThumbnail,
  }) async {
    final candidate = preferThumbnail
        ? attachment.thumbnailRelativePath ?? attachment.relativePath
        : attachment.relativePath;
    if (candidate == null || candidate.trim().isEmpty) return null;
    if (attachment.storageState == AttachmentStorageState.referenced) {
      if (!p.isAbsolute(candidate)) return null;
      final normalized = p.normalize(p.absolute(candidate));
      return await File(normalized).exists() ? normalized : null;
    }
    if (p.isAbsolute(candidate)) return null;
    final support =
        await (supportDirectoryProvider?.call() ??
            getApplicationSupportDirectory());
    final root = p.normalize(p.absolute(p.join(support.path, 'attachments')));
    final resolved = p.normalize(p.absolute(p.join(root, candidate)));
    if (!p.isWithin(root, resolved)) return null;
    return await File(resolved).exists() ? resolved : null;
  }
}
