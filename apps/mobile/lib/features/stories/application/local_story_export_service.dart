import 'package:life_timeline/features/stories/domain/story_models.dart';

final class LocalStoryExportService implements StoryExportService {
  const LocalStoryExportService(
    this._renderer,
    this._temporaryFiles,
    this._shareService,
  );

  final StoryImageRenderer _renderer;
  final StoryShareService _shareService;
  final StoryTemporaryFileStore _temporaryFiles;

  @override
  Future<StoryExportResult> renderAndShare(
    StoryComposition composition,
    StoryRenderConfig config,
  ) async {
    final png = await _renderer.render(composition, config);
    final temporaryFile = await _temporaryFiles.writePng(png);
    var cleaned = false;
    late StoryShareOutcome outcome;
    try {
      outcome = await _shareService.sharePng(
        temporaryFile,
        shareTitle: 'Share Story',
      );
    } finally {
      try {
        await _temporaryFiles.delete(temporaryFile);
        cleaned = true;
      } on Object {
        cleaned = false;
      }
    }
    return StoryExportResult(
      outcome: outcome,
      width: config.outputWidth,
      height: config.outputHeight,
      byteSize: png.length,
      temporaryFileCleaned: cleaned,
    );
  }
}
