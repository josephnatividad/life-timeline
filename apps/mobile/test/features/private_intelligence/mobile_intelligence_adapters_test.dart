import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/features/private_intelligence/application/intelligence_ports.dart';
import 'package:life_timeline/features/private_intelligence/infrastructure/mobile_intelligence_adapters.dart';
import 'package:path/path.dart' as p;

void main() {
  test(
    'candidate images are relative to the managed attachment root',
    () async {
      final temporary = await Directory.systemTemp.createTemp(
        'timeline_candidate_attachment_test',
      );
      addTearDown(() => temporary.delete(recursive: true));
      final preparedFile = File(p.join(temporary.path, 'prepared.jpg'));
      await preparedFile.writeAsBytes([1, 2, 3], flush: true);
      final store = AppPrivateCandidateAttachmentStore(
        supportDirectoryProvider: () async => temporary,
      );

      final managed = await store.store(
        PreparedImage(
          path: preparedFile.path,
          mimeType: 'image/jpeg',
          byteSize: 3,
        ),
        'attachment-1',
      );

      expect(managed.relativePath, p.join('intelligence', 'attachment-1.jpg'));
      expect(
        managed.absolutePath,
        p.join(
          temporary.path,
          'attachments',
          'intelligence',
          'attachment-1.jpg',
        ),
      );
      expect(await File(managed.absolutePath).readAsBytes(), [1, 2, 3]);
    },
  );
}
