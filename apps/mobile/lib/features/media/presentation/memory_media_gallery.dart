import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_timeline/app/navigation/app_routes.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/media/application/media_providers.dart';
import 'package:life_timeline/features/media/presentation/managed_memory_image.dart';
import 'package:life_timeline/features/timeline/application/timeline_providers.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

final class MemoryMediaGallery extends ConsumerWidget {
  const MemoryMediaGallery({
    required this.memoryId,
    this.showHero = true,
    super.key,
  });

  final String memoryId;
  final bool showHero;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final media = ref.watch(memoryMediaProvider(memoryId));
    return media.when(
      loading: () => const AppLoadingState(label: 'Loading photos'),
      error: (error, stackTrace) => AppErrorState(
        title: 'Photos unavailable',
        message: 'The local gallery could not be opened.',
        actionLabel: 'Try again',
        onAction: () => ref.invalidate(memoryMediaProvider(memoryId)),
      ),
      data: (values) => _MemoryMediaContent(
        memoryId: memoryId,
        media: values,
        showHero: showHero,
      ),
    );
  }
}

final class MemoryHeroMedia extends ConsumerWidget {
  const MemoryHeroMedia({required this.memoryId, super.key});

  final String memoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final media = ref.watch(memoryMediaProvider(memoryId));
    return media.maybeWhen(
      data: (values) {
        final hero = values.where((item) => item.isHero).firstOrNull;
        if (hero == null) return const SizedBox.shrink();
        return Semantics(
          button: true,
          label: 'Open hero photo. ${hero.link.caption ?? ''}',
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.largeCard),
            onTap: () => context.pushNamed(
              AppRoute.mediaViewer.name,
              pathParameters: {'memoryId': memoryId, 'linkId': hero.link.id},
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.largeCard),
              child: AspectRatio(
                aspectRatio: AppMediaRatio.hero,
                child: MemoryMediaHero(
                  media: hero,
                  child: ManagedMemoryImage(
                    media: hero,
                    preferThumbnail:
                        hero.attachment.storageState ==
                        AttachmentStorageState.archived,
                    semanticLabel: hero.link.caption ?? 'Hero photo',
                  ),
                ),
              ),
            ),
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

final class _MemoryMediaContent extends ConsumerWidget {
  const _MemoryMediaContent({
    required this.memoryId,
    required this.media,
    required this.showHero,
  });

  final List<MemoryMedia> media;
  final String memoryId;
  final bool showHero;

  MemoryMedia? get _hero => media.where((item) => item.isHero).firstOrNull;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hero = _hero;
    final gallery = media.where((item) => !item.isHero).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showHero && hero != null) ...[
          Semantics(
            button: true,
            label: 'Open hero photo. ${hero.link.caption ?? ''}',
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.largeCard),
              onTap: () => _openViewer(context, hero),
              onLongPress: () => _actions(context, ref, hero),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.largeCard),
                child: AspectRatio(
                  aspectRatio: AppMediaRatio.hero,
                  child: MemoryMediaHero(
                    media: hero,
                    child: ManagedMemoryImage(
                      media: hero,
                      preferThumbnail:
                          hero.attachment.storageState ==
                          AttachmentStorageState.archived,
                      semanticLabel: hero.link.caption ?? 'Hero photo',
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (hero.link.caption case final caption?) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(caption, style: Theme.of(context).textTheme.bodyMedium),
          ],
          const SizedBox(height: AppSpacing.xxl),
        ],
        AppSectionHeader(
          title: 'Photos',
          supportingText: media.isEmpty
              ? 'Add a curated view of this memory.'
              : '${media.length} ${media.length == 1 ? 'photo' : 'photos'}',
          action: media.length > 1
              ? AppIconButton(
                  icon: AppIcons.reorder,
                  label: 'Reorder photos',
                  onPressed: () => context.pushNamed(
                    AppRoute.reorderMedia.name,
                    pathParameters: {'memoryId': memoryId},
                  ),
                )
              : null,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (gallery.isNotEmpty)
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 720
                  ? 4
                  : constraints.maxWidth >= 440
                  ? 3
                  : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: gallery.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: AppSpacing.sm,
                  mainAxisSpacing: AppSpacing.sm,
                  childAspectRatio: AppMediaRatio.galleryThumbnail,
                ),
                itemBuilder: (context, index) {
                  final item = gallery[index];
                  return Semantics(
                    button: true,
                    label:
                        'Photo ${index + 1} of ${gallery.length}. ${item.link.caption ?? ''}',
                    child: InkWell(
                      onTap: () => _openViewer(context, item),
                      onLongPress: () => _actions(context, ref, item),
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        child: MemoryMediaHero(
                          media: item,
                          child: ManagedMemoryImage(
                            media: item,
                            semanticLabel: item.link.caption ?? 'Memory photo',
                            cacheWidth: 512,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        if (gallery.isNotEmpty) const SizedBox(height: AppSpacing.md),
        AppButton(
          key: const Key('memory-add-photo'),
          label: 'Add photo',
          icon: AppIcons.image,
          variant: AppButtonVariant.secondary,
          onPressed: () => context.pushNamed(
            AppRoute.memoryPhotos.name,
            pathParameters: {'memoryId': memoryId},
          ),
        ),
        if (media.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Open a photo for controls. Every action is also available without gestures.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }

  void _openViewer(BuildContext context, MemoryMedia item) {
    context.pushNamed(
      AppRoute.mediaViewer.name,
      pathParameters: {'memoryId': memoryId, 'linkId': item.link.id},
    );
  }

  Future<void> _actions(
    BuildContext context,
    WidgetRef ref,
    MemoryMedia item,
  ) => AppBottomSheet.show<void>(
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
              _editCaption(context, ref, item);
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: AppIcon(
              icon: item.isHero ? AppIcons.remove : AppIcons.hero,
            ),
            title: Text(
              item.isHero ? 'Remove hero designation' : 'Set as hero',
            ),
            subtitle: const Text('The photo itself is not deleted'),
            onTap: () async {
              Navigator.of(sheetContext).pop();
              final repository = ref.read(memoryMediaRepositoryProvider);
              if (item.isHero) {
                await repository.clearHero(
                  eventId: memoryId,
                  linkId: item.link.id,
                );
              } else {
                await repository.setHero(
                  eventId: memoryId,
                  linkId: item.link.id,
                );
              }
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const AppIcon(icon: AppIcons.remove),
            title: const Text('Remove from this memory'),
            subtitle: const Text('Keep the managed photo for other references'),
            onTap: () async {
              Navigator.of(sheetContext).pop();
              await ref
                  .read(memoryMediaRepositoryProvider)
                  .removeFromMemory(eventId: memoryId, linkId: item.link.id);
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
            subtitle: const Text('Only deleted if no other record uses it'),
            onTap: () {
              Navigator.of(sheetContext).pop();
              _delete(context, ref, item);
            },
          ),
        ],
      ),
    ),
  );

  Future<void> _editCaption(
    BuildContext context,
    WidgetRef ref,
    MemoryMedia item,
  ) async {
    final controller = TextEditingController(text: item.link.caption);
    final caption = await AppBottomSheet.show<String?>(
      context: context,
      builder: (sheetContext) => AppBottomSheet(
        title: 'Photo caption',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: controller,
              label: 'Caption',
              minLines: 2,
              maxLines: 4,
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: 'Save caption',
              expanded: true,
              onPressed: () => Navigator.of(sheetContext).pop(controller.text),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (caption == null) return;
    await ref
        .read(memoryMediaRepositoryProvider)
        .updateCaption(linkId: item.link.id, caption: caption);
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    MemoryMedia item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete managed photo?'),
        content: const Text(
          'The photo will only be deleted if no other memory or evidence record references it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final result = await ref
        .read(memoryMediaRepositoryProvider)
        .deleteUnreferenced(eventId: memoryId, linkId: item.link.id);
    if (result.assetDeleted) {
      await ref
          .read(managedAttachmentCleanupProvider)
          .deleteManagedFiles(result.managedRelativePaths);
      await ref
          .read(memoryMediaRepositoryProvider)
          .completeManagedDeletion(result.attachmentId!);
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.assetDeleted
              ? 'Managed photo deleted.'
              : 'Removed from this memory. Another record still uses the photo.',
        ),
      ),
    );
  }
}
