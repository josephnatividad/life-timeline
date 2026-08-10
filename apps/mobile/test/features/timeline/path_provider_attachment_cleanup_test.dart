import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/features/timeline/infrastructure/path_provider_attachment_cleanup.dart';
import 'package:path/path.dart' as p;

void main() {
  test(
    'cleanup deletes only files inside the managed attachment root',
    () async {
      final temporary = await Directory.systemTemp.createTemp(
        'timeline_attachment_cleanup_test',
      );
      addTearDown(() => temporary.delete(recursive: true));
      final managed = File(
        p.join(temporary.path, 'attachments', 'documents', 'owned.pdf'),
      );
      await managed.parent.create(recursive: true);
      await managed.writeAsBytes([1, 2, 3]);
      final cleanup = PathProviderAttachmentCleanup(
        supportDirectoryProvider: () async => temporary,
      );

      await cleanup.deleteManagedFiles(['documents/owned.pdf']);

      expect(await managed.exists(), isFalse);
      await expectLater(
        cleanup.deleteManagedFiles(['../outside.pdf']),
        throwsA(isA<StateError>()),
      );
    },
  );
}
