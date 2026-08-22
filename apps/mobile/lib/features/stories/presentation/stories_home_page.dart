import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_timeline/app/navigation/app_routes.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/stories/application/story_providers.dart';
import 'package:life_timeline/features/stories/domain/milestone_models.dart';
import 'package:life_timeline/features/stories/domain/story_models.dart';
import 'package:life_timeline/features/stories/presentation/widgets/story_editor_components.dart';
import 'package:life_timeline/features/timeline/application/timeline_providers.dart';
import 'package:life_timeline/shared/domain/formatting/temporal_label.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

final class StoriesHomePage extends ConsumerWidget {
  const StoriesHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(storyTemporaryCleanupProvider);
    final memories = ref.watch(timelineMemoryPreviewProvider(6));
    final memoryCount = ref.watch(timelineMemoryCountProvider).value;
    return AppScaffold(
      appBar: AppBar(title: const Text('Stories')),
      body: memories.when(
        loading: () =>
            const Center(child: AppLoadingState(label: 'Loading Stories')),
        error: (error, stackTrace) => Center(
          child: AppErrorState(
            title: 'Stories unavailable',
            message: 'Confirmed memories could not be read on this device.',
            actionLabel: 'Try again',
            onAction: () => ref.invalidate(timelineMemoryPreviewProvider(6)),
          ),
        ),
        data: (value) => _StoriesContent(
          memories: value,
          totalMemoryCount: memoryCount ?? value.length,
        ),
      ),
    );
  }
}

final class _StoriesContent extends ConsumerWidget {
  const _StoriesContent({
    required this.memories,
    required this.totalMemoryCount,
  });

  final List<TimelineMemory> memories;
  final int totalMemoryCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (memories.isEmpty) {
      return Center(
        child: AppEmptyState(
          title: 'Your first Story begins with a memory',
          message:
              'Add and confirm a timeline memory, then choose exactly what becomes shareable.',
          actionLabel: 'Add a memory',
          icon: AppIcons.stories,
          onAction: () => context.pushNamed(AppRoute.addMemory.name),
        ),
      );
    }
    final milestones = ref.watch(milestoneCandidatesProvider);
    final entities = <String, Entity>{};
    for (final memory in memories) {
      final entity = memory.relatedEntity;
      if (entity != null) entities[entity.metadata.id] = entity;
    }
    return ScreenContainer(
      child: ListView(
        key: const Key('stories-home-content'),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppSignatureIcon(
                kind: AppSignatureIconKind.story,
                semanticLabel: 'Story creation',
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Share a moment, not your timeline',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Stories are composed and rendered locally from fields you review.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppSection(
            title: 'Create something',
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                AppButton(
                  key: const Key('choose-story-memory'),
                  label: 'From a memory',
                  icon: AppIcons.timeline,
                  onPressed: () =>
                      context.pushNamed(AppRoute.storyMemorySources.name),
                ),
                AppButton(
                  key: const Key('create-then-now'),
                  label: 'Then & Now',
                  icon: AppIcons.stories,
                  onPressed: totalMemoryCount < 2
                      ? null
                      : () => context.pushNamed(AppRoute.thenNowSelection.name),
                  variant: AppButtonVariant.secondary,
                ),
              ],
            ),
          ),
          milestones.when(
            loading: () => const SizedBox.shrink(),
            error: (error, stackTrace) => const SizedBox.shrink(),
            data: (value) => value.isEmpty
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xxxl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const AppSectionHeader(
                          title: 'For you',
                          supportingText:
                              'Only dates and counts with enough evidence become candidates.',
                        ),
                        const SizedBox(height: AppSpacing.md),
                        for (final milestone in value.take(2)) ...[
                          StoryMilestoneCard(
                            milestone: milestone,
                            onCreateStory: () =>
                                _openMilestone(context, ref, milestone),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          AppCollectionPreview(
            title: 'Recent memories',
            count: totalMemoryCount,
            viewAllLabel: 'Choose another memory',
            onViewAll: () =>
                context.pushNamed(AppRoute.storyMemorySources.name),
            child: Column(
              children: [
                for (final memory in memories.take(3))
                  _StorySourceRow(
                    title: memory.event.title,
                    temporalLabel: TemporalLabel.format(
                      memory.event.temporalValue,
                    ),
                    semanticLabel: 'Create a Story from ${memory.event.title}',
                    onTap: () =>
                        _openEvent(context, ref, memory.event.metadata.id),
                  ),
              ],
            ),
          ),
          if (entities.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxxl),
            const AppSectionHeader(
              title: 'Things and places',
              supportingText:
                  'Compose a Story from the confirmed history of an entity.',
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final entity in entities.values.take(3))
              _StorySourceRow(
                title: entity.name,
                temporalLabel: entity.entityType,
                semanticLabel: 'Create an entity Story for ${entity.name}',
                onTap: () => _openEntity(context, ref, entity.metadata.id),
              ),
          ],
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  Future<void> _openEvent(
    BuildContext context,
    WidgetRef ref,
    String eventId,
  ) async {
    final source = await ref
        .read(storySourceFactoryProvider)
        .fromEvent(eventId);
    if (!context.mounted) return;
    await _openSource(context, source);
  }

  Future<void> _openEntity(
    BuildContext context,
    WidgetRef ref,
    String entityId,
  ) async {
    final source = await ref
        .read(storySourceFactoryProvider)
        .fromEntity(entityId);
    if (!context.mounted) return;
    await _openSource(context, source);
  }

  Future<void> _openMilestone(
    BuildContext context,
    WidgetRef ref,
    MilestoneCandidate milestone,
  ) async {
    final source = await ref
        .read(storySourceFactoryProvider)
        .fromMilestone(milestone);
    if (!context.mounted) return;
    await _openSource(context, source);
  }

  Future<void> _openSource(BuildContext context, StorySource? source) async {
    if (source == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This source is not available for a Story.'),
        ),
      );
      return;
    }
    await context.pushNamed(AppRoute.storyEditor.name, extra: source);
  }
}

final class _StorySourceRow extends StatelessWidget {
  const _StorySourceRow({
    required this.title,
    required this.temporalLabel,
    required this.semanticLabel,
    required this.onTap,
  });

  final VoidCallback onTap;
  final String semanticLabel;
  final String temporalLabel;
  final String title;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: semanticLabel,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.smallControl),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            const AppIcon(icon: AppIcons.stories),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    temporalLabel,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const AppIcon(icon: AppIcons.next),
          ],
        ),
      ),
    ),
  );
}
