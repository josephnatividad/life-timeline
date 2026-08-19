import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_timeline/app/navigation/app_routes.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/stories/application/story_providers.dart';
import 'package:life_timeline/features/timeline/application/timeline_providers.dart';
import 'package:life_timeline/shared/domain/formatting/temporal_label.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

final class StoryMemorySourcesPage extends ConsumerWidget {
  const StoryMemorySourcesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memories = ref.watch(timelineMemoriesProvider);
    return AppScaffold(
      appBar: AppBar(title: const Text('Choose a memory')),
      body: memories.when(
        loading: () =>
            const Center(child: AppLoadingState(label: 'Loading memories')),
        error: (error, stackTrace) => Center(
          child: AppErrorState(
            title: 'Memories unavailable',
            message: 'Confirmed memories could not be opened.',
            actionLabel: 'Try again',
            onAction: () => ref.invalidate(timelineMemoriesProvider),
          ),
        ),
        data: (values) => values.isEmpty
            ? const Center(
                child: AppEmptyState(
                  title: 'No memories to choose from',
                  message: 'Confirm a memory before creating a Story.',
                  icon: AppIcons.stories,
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.xl),
                itemCount: values.length,
                separatorBuilder: (context, index) => const AppDivider(),
                itemBuilder: (context, index) => _MemorySourceRow(
                  memory: values[index],
                  onTap: () => _open(context, ref, values[index]),
                ),
              ),
      ),
    );
  }

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    TimelineMemory memory,
  ) async {
    final source = await ref
        .read(storySourceFactoryProvider)
        .fromEvent(memory.event.metadata.id);
    if (!context.mounted) return;
    if (source == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This memory is not available.')),
      );
      return;
    }
    await context.pushNamed(AppRoute.storyEditor.name, extra: source);
  }
}

final class _MemorySourceRow extends StatelessWidget {
  const _MemorySourceRow({required this.memory, required this.onTap});

  final TimelineMemory memory;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const AppIcon(icon: AppIcons.timeline),
    title: Text(memory.event.title),
    subtitle: Text(TemporalLabel.format(memory.event.temporalValue)),
    trailing: const AppIcon(icon: AppIcons.next),
    onTap: onTap,
  );
}
