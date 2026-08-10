import 'dart:io';

import 'package:life_timeline/features/timeline/application/memory_use_cases.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

final class PathProviderAttachmentCleanup implements ManagedAttachmentCleanup {
  const PathProviderAttachmentCleanup({this.supportDirectoryProvider});

  final Future<Directory> Function()? supportDirectoryProvider;

  @override
  Future<void> deleteManagedFiles(Iterable<String> relativePaths) async {
    final support =
        await (supportDirectoryProvider?.call() ??
            getApplicationSupportDirectory());
    final root = p.canonicalize(p.join(support.path, 'attachments'));
    for (final relativePath in relativePaths.toSet()) {
      if (relativePath.isEmpty || p.isAbsolute(relativePath)) {
        throw StateError('Managed attachment path must be relative.');
      }
      final resolved = p.canonicalize(p.join(root, relativePath));
      if (!p.isWithin(root, resolved)) {
        throw StateError('Managed attachment path escaped its storage root.');
      }
      final file = File(resolved);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }
}
