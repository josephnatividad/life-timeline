import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:life_timeline/features/stories/application/story_source_factory.dart';
import 'package:life_timeline/features/stories/domain/story_models.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

final class LocalStoryAttachmentPathResolver
    implements StoryAttachmentPathResolver {
  const LocalStoryAttachmentPathResolver({this.supportDirectoryProvider});

  final Future<Directory> Function()? supportDirectoryProvider;

  @override
  Future<String?> resolve(Attachment attachment) async {
    final storedPath = attachment.relativePath;
    if (storedPath == null || storedPath.trim().isEmpty) return null;
    switch (attachment.storageState) {
      case AttachmentStorageState.local:
        if (p.isAbsolute(storedPath)) return null;
        final support =
            await (supportDirectoryProvider?.call() ??
                getApplicationSupportDirectory());
        final root = p.normalize(
          p.absolute(p.join(support.path, 'attachments')),
        );
        final resolved = p.normalize(p.absolute(p.join(root, storedPath)));
        if (!p.isWithin(root, resolved)) return null;
        return await File(resolved).exists() ? resolved : null;
      case AttachmentStorageState.referenced:
        if (!p.isAbsolute(storedPath)) return null;
        final resolved = p.normalize(p.absolute(storedPath));
        return await File(resolved).exists() ? resolved : null;
      case AttachmentStorageState.archived:
      case AttachmentStorageState.unavailable:
        return null;
    }
  }
}

final class PathProviderStoryTemporaryFileStore
    implements StoryTemporaryFileStore {
  PathProviderStoryTemporaryFileStore({
    this.temporaryDirectoryProvider,
    Random? random,
  }) : _random = random ?? Random.secure();

  static const _directoryName = 'life_timeline_story_exports';
  static const _filePrefix = 'story-export-';
  static const _maximumAge = Duration(hours: 24);

  final Random _random;
  final Future<Directory> Function()? temporaryDirectoryProvider;

  @override
  Future<TemporaryStoryFile> writePng(Uint8List pngBytes) async {
    if (pngBytes.isEmpty) {
      throw ArgumentError.value(pngBytes, 'pngBytes', 'Must not be empty.');
    }
    final directory = await _exportDirectory();
    await directory.create(recursive: true);
    final token = _random.nextInt(0x7fffffff).toRadixString(16);
    final file = File(
      p.join(
        directory.path,
        '$_filePrefix${DateTime.now().toUtc().microsecondsSinceEpoch}-$token.png',
      ),
    );
    await file.writeAsBytes(pngBytes, flush: true);
    return TemporaryStoryFile(path: file.path);
  }

  @override
  Future<void> delete(TemporaryStoryFile file) async {
    final directory = await _exportDirectory();
    final root = p.normalize(p.absolute(directory.path));
    final target = p.normalize(p.absolute(file.path));
    if (!p.isWithin(root, target) ||
        !p.basename(target).startsWith(_filePrefix)) {
      throw StateError('Refusing to delete a non-Story temporary file.');
    }
    final targetFile = File(target);
    if (await targetFile.exists()) await targetFile.delete();
  }

  @override
  Future<void> cleanupStaleFiles(DateTime now) async {
    final directory = await _exportDirectory();
    if (!await directory.exists()) return;
    await for (final entity in directory.list(followLinks: false)) {
      if (entity is! File ||
          !p.basename(entity.path).startsWith(_filePrefix) ||
          p.extension(entity.path).toLowerCase() != '.png') {
        continue;
      }
      final modified = await entity.lastModified();
      if (now.toUtc().difference(modified.toUtc()) > _maximumAge) {
        await entity.delete();
      }
    }
  }

  Future<Directory> _exportDirectory() async {
    final temporary =
        await (temporaryDirectoryProvider?.call() ?? getTemporaryDirectory());
    return Directory(p.join(temporary.path, _directoryName));
  }
}
