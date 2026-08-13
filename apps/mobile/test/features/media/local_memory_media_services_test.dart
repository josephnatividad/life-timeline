import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:life_timeline/features/media/domain/memory_media_import.dart';
import 'package:life_timeline/features/media/infrastructure/local_memory_media_services.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory sandbox;
  late Directory support;

  setUp(() async {
    sandbox = await Directory.systemTemp.createTemp('memory_media_test_');
    support = Directory(p.join(sandbox.path, 'support'));
    await support.create(recursive: true);
  });

  tearDown(() => sandbox.delete(recursive: true));

  test(
    'import bakes orientation, hashes, thumbnails, and preserves original',
    () async {
      final source = File(p.join(sandbox.path, 'source.png'));
      final input = image.Image(width: 800, height: 400);
      image.fill(input, color: image.ColorRgb8(60, 90, 120));
      await source.writeAsBytes(image.encodePng(input));
      final processor = LocalMemoryImageProcessor(
        supportDirectoryProvider: () async => support,
        maximumDisplayDimension: 600,
        thumbnailDimension: 160,
      );

      final result = await processor.process(
        selected: SelectedMemoryImage(
          path: source.path,
          displayName: 'Source.png',
          mimeType: 'image/png',
        ),
        attachmentId: 'asset-1',
        preserveOriginal: true,
      );

      expect(
        result.attachment.metadata.privacyClassification,
        PrivacyClassification.personal,
      );
      expect(result.attachment.pixelWidth, 800);
      expect(result.attachment.pixelHeight, 400);
      expect(result.attachment.checksum, isNotEmpty);
      expect(result.attachment.preservedOriginalChecksum, isNotEmpty);
      expect(result.attachment.preservedOriginalByteSize, greaterThan(0));
      for (final relative in result.managedRelativePaths) {
        expect(
          File(p.join(support.path, 'attachments', relative)).existsSync(),
          isTrue,
        );
      }
      final thumbnail = image.decodeImage(
        File(
          p.join(
            support.path,
            'attachments',
            result.attachment.thumbnailRelativePath!,
          ),
        ).readAsBytesSync(),
      );
      expect(thumbnail, isNotNull);
      expect(thumbnail!.width, 160);
    },
  );

  test('cleanup refuses paths outside the managed attachment root', () async {
    final processor = LocalMemoryImageProcessor(
      supportDirectoryProvider: () async => support,
    );

    await expectLater(
      processor.deleteManagedFiles(const ['../outside.jpg']),
      throwsStateError,
    );
  });
}
