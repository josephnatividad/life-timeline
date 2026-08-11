import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/stories/application/local_story_export_service.dart';
import 'package:life_timeline/features/stories/domain/story_models.dart';
import 'package:life_timeline/features/stories/infrastructure/local_story_file_services.dart';
import 'package:life_timeline/features/stories/infrastructure/repaint_boundary_story_renderer.dart';
import 'package:life_timeline/features/stories/presentation/widgets/story_render_canvas.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';

void main() {
  testWidgets('all five templates render with long text and missing media', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(500, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final template in StoryTemplateId.values) {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Center(
            child: StoryRenderCanvas(
              composition: _composition(template, missingMedia: true),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull, reason: template.name);
    }
  });

  testWidgets('renderer produces an exact 1080 by 1920 PNG', (tester) async {
    tester.view
      ..physicalSize = const Size(500, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final key = GlobalKey();
    final composition = _composition(StoryTemplateId.minimal);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Center(
          child: StoryRenderCanvas(boundaryKey: key, composition: composition),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final png = await tester.runAsync(
      () => RepaintBoundaryStoryRenderer(
        key,
      ).render(composition, const StoryRenderConfig()),
    );
    expect(_pngDimensions(png!), (width: 1080, height: 1920));
  });

  test('export invokes share and cleans its temporary file', () async {
    final renderer = _FakeRenderer();
    final files = _FakeTemporaryFiles();
    final share = _FakeShareService();
    final result = await LocalStoryExportService(renderer, files, share)
        .renderAndShare(
          _composition(StoryTemplateId.minimal),
          const StoryRenderConfig(),
        );

    expect(renderer.calls, 1);
    expect(share.calls, 1);
    expect(files.deleted, isTrue);
    expect(result.outcome, StoryShareOutcome.shared);
    expect(result.temporaryFileCleaned, isTrue);
    expect(result.width, 1080);
    expect(result.height, 1920);
  });

  test('temporary cleanup still runs when system sharing throws', () async {
    final files = _FakeTemporaryFiles();
    final service = LocalStoryExportService(
      _FakeRenderer(),
      files,
      _FakeShareService(throwOnShare: true),
    );

    await expectLater(
      service.renderAndShare(
        _composition(StoryTemplateId.minimal),
        const StoryRenderConfig(),
      ),
      throwsStateError,
    );
    expect(files.deleted, isTrue);
  });

  test('real temporary store deletes only its own Story files', () async {
    final root = await Directory.systemTemp.createTemp('story-store-test-');
    addTearDown(() async {
      if (await root.exists()) await root.delete(recursive: true);
    });
    final store = PathProviderStoryTemporaryFileStore(
      temporaryDirectoryProvider: () async => root,
    );
    final file = await store.writePng(Uint8List.fromList([1, 2, 3]));
    expect(await File(file.path).exists(), isTrue);

    await store.delete(file);
    expect(await File(file.path).exists(), isFalse);
    await expectLater(
      store.delete(TemporaryStoryFile(path: '${root.path}/outside.png')),
      throwsStateError,
    );
  });

  test('stale cleanup is bounded to old app-created PNGs', () async {
    final root = await Directory.systemTemp.createTemp('story-cleanup-test-');
    addTearDown(() async {
      if (await root.exists()) await root.delete(recursive: true);
    });
    final store = PathProviderStoryTemporaryFileStore(
      temporaryDirectoryProvider: () async => root,
    );
    final file = await store.writePng(Uint8List.fromList([1]));
    await File(file.path).setLastModified(DateTime.utc(2026, 1, 1));
    final unrelated = File('${File(file.path).parent.path}/keep.txt');
    await unrelated.writeAsString('keep');

    await store.cleanupStaleFiles(DateTime.utc(2026, 1, 3));

    expect(await File(file.path).exists(), isFalse);
    expect(await unrelated.exists(), isTrue);
  });
}

StoryComposition _composition(
  StoryTemplateId template, {
  bool missingMedia = false,
}) => StoryComposition(
  sourceId: 'source-1',
  sourceType: template == StoryTemplateId.thenNow
      ? StorySourceType.thenNow
      : StorySourceType.event,
  templateId: template,
  themeVariant: StoryThemeVariant.paper,
  branding: const StoryBrandingConfig(),
  sourceRecordIds: const ['event-1'],
  fields: [
    StoryField(
      id: template == StoryTemplateId.thenNow ? 'then.title' : 'event.title',
      label: 'Title',
      value:
          'A deliberately very long Story title that must stay inside the exported canvas without overflowing any edge',
      kind: StoryFieldKind.title,
      privacyClassification: PrivacyClassification.shareSafe,
    ),
    StoryField(
      id: template == StoryTemplateId.thenNow ? 'then.year' : 'event.year',
      label: 'Year',
      value: 'Around 2019',
      kind: StoryFieldKind.year,
      privacyClassification: PrivacyClassification.shareSafe,
    ),
    if (template == StoryTemplateId.thenNow) ...[
      StoryField(
        id: 'now.title',
        label: 'Now title',
        value: 'Current chapter',
        kind: StoryFieldKind.title,
        privacyClassification: PrivacyClassification.shareSafe,
      ),
      StoryField(
        id: 'now.year',
        label: 'Now year',
        value: '2026',
        kind: StoryFieldKind.year,
        privacyClassification: PrivacyClassification.shareSafe,
      ),
    ],
  ],
  media: missingMedia
      ? [
          StoryMedia(
            id: template == StoryTemplateId.thenNow
                ? 'then.missing'
                : 'missing',
            label: 'Missing photo',
            kind: StoryMediaKind.image,
            localPath: 'Z:/file-that-does-not-exist.jpg',
            privacyClassification: PrivacyClassification.shareSafe,
          ),
        ]
      : const [],
  excludedFields: const [],
);

final class _FakeRenderer implements StoryImageRenderer {
  var calls = 0;

  @override
  Future<Uint8List> render(
    StoryComposition composition,
    StoryRenderConfig config,
  ) async {
    calls++;
    return Uint8List.fromList([137, 80, 78, 71]);
  }
}

final class _FakeTemporaryFiles implements StoryTemporaryFileStore {
  var deleted = false;

  @override
  Future<void> cleanupStaleFiles(DateTime now) async {}

  @override
  Future<void> delete(TemporaryStoryFile file) async => deleted = true;

  @override
  Future<TemporaryStoryFile> writePng(Uint8List pngBytes) async =>
      const TemporaryStoryFile(path: 'temporary-story.png');
}

final class _FakeShareService implements StoryShareService {
  _FakeShareService({this.throwOnShare = false});

  final bool throwOnShare;
  var calls = 0;

  @override
  Future<StoryShareOutcome> sharePng(
    TemporaryStoryFile file, {
    required String shareTitle,
  }) async {
    calls++;
    if (throwOnShare) throw StateError('Share failed');
    return StoryShareOutcome.shared;
  }
}

({int width, int height}) _pngDimensions(Uint8List bytes) {
  expect(bytes.length, greaterThan(24));
  expect(bytes.sublist(1, 4), [80, 78, 71]);
  final data = ByteData.sublistView(bytes);
  return (
    width: data.getUint32(16, Endian.big),
    height: data.getUint32(20, Endian.big),
  );
}
