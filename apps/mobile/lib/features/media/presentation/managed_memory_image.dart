import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/media/application/media_providers.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

final class ManagedMemoryImage extends ConsumerWidget {
  const ManagedMemoryImage({
    required this.media,
    required this.semanticLabel,
    this.preferThumbnail = true,
    this.fit = BoxFit.cover,
    this.cacheWidth,
    this.backgroundColor,
    super.key,
  });

  final Color? backgroundColor;
  final int? cacheWidth;
  final BoxFit fit;
  final MemoryMedia media;
  final bool preferThumbnail;
  final String semanticLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ColoredBox(
    color: backgroundColor ?? Theme.of(context).colorScheme.surfaceContainer,
    child: FutureBuilder<String?>(
      future: ref
          .read(memoryMediaPathResolverProvider)
          .resolve(media.attachment, preferThumbnail: preferThumbnail),
      builder: (context, snapshot) {
        final path = snapshot.data;
        if (path == null) {
          return _UnavailableMedia(
            archived:
                media.attachment.storageState ==
                AttachmentStorageState.archived,
          );
        }
        return Image.file(
          File(path),
          fit: fit,
          cacheWidth: cacheWidth,
          semanticLabel: semanticLabel,
          errorBuilder: (context, error, stackTrace) =>
              const _UnavailableMedia(),
        );
      },
    ),
  );
}

final class MemoryMediaHero extends StatelessWidget {
  const MemoryMediaHero({required this.media, required this.child, super.key});

  final Widget child;
  final MemoryMedia media;

  @override
  Widget build(BuildContext context) {
    if (AppMotion.reduced(context)) return child;
    return Hero(tag: 'memory-media-${media.link.id}', child: child);
  }
}

final class _UnavailableMedia extends StatelessWidget {
  const _UnavailableMedia({this.archived = false});

  final bool archived;

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: archived
        ? 'Photo archived; original retrieval required'
        : 'Photo unavailable',
    child: LayoutBuilder(
      builder: (context, constraints) {
        final icon = AppIcon(
          icon: archived ? AppIcons.archive : AppIcons.image,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );
        final hasLabelSpace =
            constraints.maxHeight >= AppSpacing.huge + AppSpacing.xl &&
            constraints.maxWidth >= AppSpacing.huge * 2;
        return Center(
          child: hasLabelSpace
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    icon,
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      archived ? 'Archived' : 'Preview unavailable',
                      style: Theme.of(context).textTheme.labelMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              : icon,
        );
      },
    ),
  );
}
