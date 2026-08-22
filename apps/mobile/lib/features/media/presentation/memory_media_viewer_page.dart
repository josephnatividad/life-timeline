import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_timeline/app/navigation/app_routes.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/media/application/media_providers.dart';
import 'package:life_timeline/features/media/presentation/managed_memory_image.dart';
import 'package:life_timeline/features/media/presentation/memory_media_caption_sheet.dart';
import 'package:life_timeline/features/timeline/application/timeline_providers.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';
import 'package:share_plus/share_plus.dart';

final class MemoryMediaViewerPage extends ConsumerStatefulWidget {
  const MemoryMediaViewerPage({
    required this.memoryId,
    required this.initialLinkId,
    super.key,
  });

  final String initialLinkId;
  final String memoryId;

  @override
  ConsumerState<MemoryMediaViewerPage> createState() =>
      _MemoryMediaViewerPageState();
}

final class _MemoryMediaViewerPageState
    extends ConsumerState<MemoryMediaViewerPage> {
  PageController? _controller;
  var _index = 0;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = ref.watch(memoryMediaProvider(widget.memoryId));
    return media.when(
      loading: () => const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: AppLoadingState(label: 'Loading photo')),
      ),
      error: (error, stackTrace) => Scaffold(
        backgroundColor: Colors.black,
        appBar: _appBar(context, const [], null),
        body: const Center(
          child: AppErrorState(
            title: 'Photo unavailable',
            message: 'The local gallery could not be opened.',
          ),
        ),
      ),
      data: (values) {
        if (values.isEmpty) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: _appBar(context, values, null),
            body: const Center(
              child: AppUnavailableState(
                title: 'Photo no longer available',
                message: 'This photo is no longer linked to the memory.',
                icon: AppIcons.image,
              ),
            ),
          );
        }
        if (_controller == null) {
          final initial = values.indexWhere(
            (item) => item.link.id == widget.initialLinkId,
          );
          _index = initial < 0 ? 0 : initial;
          _controller = PageController(initialPage: _index);
        } else if (_index >= values.length) {
          _index = values.length - 1;
        }
        final current = values[_index];
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: _appBar(context, values, current),
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: values.length,
                    onPageChanged: (value) => setState(() => _index = value),
                    itemBuilder: (context, index) => _ZoomableMedia(
                      media: values[index],
                      countLabel: 'Photo ${index + 1} of ${values.length}',
                    ),
                  ),
                ),
                _metadata(context, current, values.length),
              ],
            ),
          ),
        );
      },
    );
  }

  AppBar _appBar(
    BuildContext context,
    List<MemoryMedia> values,
    MemoryMedia? current,
  ) => AppBar(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
    title: Text(values.isEmpty ? 'Photo' : '${_index + 1} of ${values.length}'),
    actions: [
      if (current != null &&
          current.attachment.metadata.privacyClassification ==
              PrivacyClassification.shareSafe)
        AppIconButton(
          icon: AppIcons.share,
          label: 'Share this photo',
          onPressed: () => _share(current),
        ),
      if (current != null)
        AppIconButton(
          icon: AppIcons.more,
          label: 'Photo options',
          onPressed: () => _showActions(context, current),
        ),
    ],
  );

  Widget _metadata(BuildContext context, MemoryMedia current, int count) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.md,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        color: Colors.black,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              liveRegion: true,
              child: Text(
                current.link.caption ?? 'Photo ${_index + 1} of $count',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.white),
              ),
            ),
            if (current.link.capturedAt case final captured?) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                MaterialLocalizations.of(context).formatMediumDate(captured),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
            ],
            if (current.attachment.storageState ==
                AttachmentStorageState.archived) ...[
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: 'Retrieve original',
                icon: AppIcons.retrieveMedia,
                variant: AppButtonVariant.secondary,
                onPressed: () =>
                    context.pushNamed(AppRoute.storageManager.name),
              ),
            ],
          ],
        ),
      );

  Future<void> _share(MemoryMedia media) async {
    final path = await ref
        .read(memoryMediaPathResolverProvider)
        .resolve(media.attachment, preferThumbnail: false);
    if (path == null || !mounted) return;
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(path, mimeType: media.attachment.mimeType)],
        title: media.link.caption ?? 'Memory photo',
      ),
    );
  }

  Future<void> _showActions(BuildContext context, MemoryMedia media) =>
      AppBottomSheet.show<void>(
        context: context,
        builder: (sheetContext) => AppBottomSheet(
          title: 'Photo options',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const AppIcon(icon: AppIcons.edit),
                title: const Text('Edit caption'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _editCaption(media);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: AppIcon(
                  icon: media.isHero ? AppIcons.remove : AppIcons.hero,
                ),
                title: Text(
                  media.isHero ? 'Remove hero designation' : 'Set as hero',
                ),
                subtitle: const Text('This never deletes the photo'),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  final repository = ref.read(memoryMediaRepositoryProvider);
                  if (media.isHero) {
                    await repository.clearHero(
                      eventId: widget.memoryId,
                      linkId: media.link.id,
                    );
                  } else {
                    await repository.setHero(
                      eventId: widget.memoryId,
                      linkId: media.link.id,
                    );
                  }
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const AppIcon(icon: AppIcons.remove),
                title: const Text('Remove from this memory'),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await ref
                      .read(memoryMediaRepositoryProvider)
                      .removeFromMemory(
                        eventId: widget.memoryId,
                        linkId: media.link.id,
                      );
                  if (mounted && _index >= 1) setState(() => _index--);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: AppIcon(
                  icon: AppIcons.trash,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  'Delete managed photo',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                subtitle: const Text('Only if no other record references it'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _delete(media);
                },
              ),
            ],
          ),
        ),
      );

  Future<void> _editCaption(MemoryMedia media) async {
    final caption = await MemoryMediaCaptionSheet.show(
      context: context,
      initialCaption: media.link.caption,
    );
    if (caption == null) return;
    await ref
        .read(memoryMediaRepositoryProvider)
        .updateCaption(linkId: media.link.id, caption: caption);
  }

  Future<void> _delete(MemoryMedia media) async {
    final result = await ref
        .read(memoryMediaRepositoryProvider)
        .deleteUnreferenced(eventId: widget.memoryId, linkId: media.link.id);
    if (result.assetDeleted) {
      await ref
          .read(managedAttachmentCleanupProvider)
          .deleteManagedFiles(result.managedRelativePaths);
      await ref
          .read(memoryMediaRepositoryProvider)
          .completeManagedDeletion(result.attachmentId!);
    }
    if (!mounted) return;
    if (_index >= 1) setState(() => _index--);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.assetDeleted
              ? 'Managed photo deleted.'
              : 'Removed here; another record still uses it.',
        ),
      ),
    );
  }
}

final class _ZoomableMedia extends StatefulWidget {
  const _ZoomableMedia({required this.media, required this.countLabel});

  final String countLabel;
  final MemoryMedia media;

  @override
  State<_ZoomableMedia> createState() => _ZoomableMediaState();
}

final class _ZoomableMediaState extends State<_ZoomableMedia> {
  final _transformation = TransformationController();
  TapDownDetails? _doubleTap;

  @override
  void dispose() {
    _transformation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onDoubleTapDown: (details) => _doubleTap = details,
    onDoubleTap: AppMotion.reduced(context) ? null : _toggleZoom,
    child: InteractiveViewer(
      transformationController: _transformation,
      minScale: 1,
      maxScale: 4,
      child: Center(
        child: MemoryMediaHero(
          media: widget.media,
          child: ManagedMemoryImage(
            media: widget.media,
            semanticLabel:
                '${widget.countLabel}. ${widget.media.link.caption ?? ''}',
            preferThumbnail:
                widget.media.attachment.storageState ==
                AttachmentStorageState.archived,
            fit: BoxFit.contain,
            backgroundColor: Colors.black,
          ),
        ),
      ),
    ),
  );

  void _toggleZoom() {
    if (_transformation.value != Matrix4.identity()) {
      _transformation.value = Matrix4.identity();
      return;
    }
    final position = _doubleTap?.localPosition ?? Offset.zero;
    _transformation.value = Matrix4.identity()
      ..translateByDouble(-position.dx, -position.dy, 0, 1)
      ..scaleByDouble(2, 2, 2, 1);
  }
}
