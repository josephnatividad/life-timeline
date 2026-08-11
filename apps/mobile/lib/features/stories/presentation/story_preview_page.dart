import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/stories/application/local_story_export_service.dart';
import 'package:life_timeline/features/stories/application/story_providers.dart';
import 'package:life_timeline/features/stories/domain/story_models.dart';
import 'package:life_timeline/features/stories/infrastructure/repaint_boundary_story_renderer.dart';
import 'package:life_timeline/features/stories/presentation/widgets/story_editor_components.dart';
import 'package:life_timeline/features/stories/presentation/widgets/story_render_canvas.dart';

final class StoryPreviewPage extends ConsumerStatefulWidget {
  const StoryPreviewPage({
    required this.composition,
    this.imageRenderer,
    super.key,
  });

  final StoryComposition composition;
  final StoryImageRenderer? imageRenderer;

  @override
  ConsumerState<StoryPreviewPage> createState() => _StoryPreviewPageState();
}

final class _StoryPreviewPageState extends ConsumerState<StoryPreviewPage> {
  final _boundaryKey = GlobalKey();
  var _sharing = false;
  var _failed = false;
  StoryExportResult? _result;

  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppBar(title: const Text('Story preview')),
    body: ScreenContainer(
      child: ListView(
        key: const Key('story-preview-content'),
        children: [
          Text(
            'Ready when you are',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Review the image and included fields before opening the system share sheet.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: StoryPreviewSurface(
                boundaryKey: _boundaryKey,
                composition: widget.composition,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          StoryPrivacyReview(composition: widget.composition),
          if (_failed) ...[
            const SizedBox(height: AppSpacing.lg),
            const AppErrorState(
              title: 'Story not shared',
              message:
                  'The local PNG could not be prepared. No upload occurred.',
            ),
          ],
          if (_result case final result?) ...[
            const SizedBox(height: AppSpacing.lg),
            _StoryExportStatus(
              key: const Key('story-export-result'),
              label: _resultLabel(result),
              icon: result.outcome == StoryShareOutcome.shared
                  ? AppIcons.success
                  : AppIcons.information,
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            key: const Key('share-story'),
            label: 'Share 1080 × 1920 PNG',
            icon: AppIcons.share,
            loading: _sharing,
            expanded: true,
            onPressed: _sharing ? null : _share,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'The selected receiving app handles the PNG after you choose it.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    ),
  );

  Future<void> _share() async {
    setState(() {
      _failed = false;
      _result = null;
      _sharing = true;
    });
    try {
      await WidgetsBinding.instance.endOfFrame;
      await ref
          .read(storyTemporaryFileStoreProvider)
          .cleanupStaleFiles(DateTime.now().toUtc());
      final exporter = LocalStoryExportService(
        widget.imageRenderer ?? RepaintBoundaryStoryRenderer(_boundaryKey),
        ref.read(storyTemporaryFileStoreProvider),
        ref.read(storyShareServiceProvider),
      );
      final result = await exporter.renderAndShare(
        widget.composition,
        const StoryRenderConfig(),
      );
      if (mounted) setState(() => _result = result);
    } on Object {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  String _resultLabel(StoryExportResult result) {
    final cleanup = result.temporaryFileCleaned
        ? 'Temporary file cleared.'
        : 'Temporary cleanup will retry later.';
    return switch (result.outcome) {
      StoryShareOutcome.shared => 'Story shared. $cleanup',
      StoryShareOutcome.dismissed => 'Share canceled. $cleanup',
      StoryShareOutcome.unavailable => 'System sharing unavailable. $cleanup',
    };
  }
}

final class _StoryExportStatus extends StatelessWidget {
  const _StoryExportStatus({
    required this.label,
    required this.icon,
    super.key,
  });

  final AppIconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      label: label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.primaryContainer,
          border: Border.all(color: colors.primary),
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppIcon(icon: icon, color: colors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colors.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
