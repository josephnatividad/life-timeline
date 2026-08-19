import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/media/application/media_providers.dart';
import 'package:life_timeline/features/media/presentation/managed_memory_image.dart';
import 'package:life_timeline/features/timeline/domain/temporal_display.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

final class TimelineEventTile extends ConsumerWidget {
  const TimelineEventTile({
    required this.memory,
    required this.onTap,
    this.isLast = false,
    super.key,
  });

  final bool isLast;
  final TimelineMemory memory;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final event = memory.event;
    final hero = ref.watch(memoryHeroMediaProvider(event.metadata.id)).value;
    return Semantics(
      button: true,
      label:
          '${TemporalDisplay.label(event.temporalValue)}. ${event.title}. ${event.eventType ?? 'Memory'}',
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: AppSpacing.huge,
                child: Column(
                  children: [
                    TimelineNode(icon: AppIcons.timeline, label: event.title),
                    if (!isLast)
                      const TimelineConnector(height: AppSpacing.xxxl),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        TemporalDisplay.label(event.temporalValue),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        event.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        [
                          if (event.eventType != null) event.eventType!,
                          if (memory.category != null) memory.category!.name,
                        ].join(' · '),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (hero != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            height: AppSpacing.massive,
                            child: AspectRatio(
                              aspectRatio: AppMediaRatio.timelineThumbnail,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.smallControl,
                                ),
                                child: MemoryMediaHero(
                                  media: hero,
                                  child: ManagedMemoryImage(
                                    media: hero,
                                    semanticLabel:
                                        hero.link.caption ?? 'Memory photo',
                                    cacheWidth: 256,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const AppIcon(icon: AppIcons.next),
            ],
          ),
        ),
      ),
    );
  }
}
