import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_timeline/app/navigation/app_routes.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/timeline/application/timeline_providers.dart';
import 'package:life_timeline/features/timeline/presentation/widgets/lifecycle_memory_card.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

final class ArchivePage extends ConsumerWidget {
  const ArchivePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memories = ref.watch(archivedMemoriesProvider);
    return AppScaffold(
      appBar: AppBar(title: const Text('Archived memories')),
      body: memories.when(
        loading: () => const Center(
          child: AppLoadingState(label: 'Loading archived memories'),
        ),
        error: (error, stackTrace) => Center(
          child: AppErrorState(
            title: 'Archive unavailable',
            message: 'Archived records could not be opened.',
            actionLabel: 'Try again',
            onAction: () => ref.invalidate(archivedMemoriesProvider),
          ),
        ),
        data: (values) => values.isEmpty
            ? const Center(
                child: AppEmptyState(
                  title: 'No archived memories',
                  message:
                      'Memories you archive remain preserved and available here.',
                  icon: AppIcons.archive,
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.xl),
                itemCount: values.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final memory = values[index];
                  return LifecycleMemoryCard(
                    memory: memory,
                    onOpen: () => context.pushNamed(
                      AppRoute.memoryDetail.name,
                      pathParameters: {'memoryId': memory.event.metadata.id},
                    ),
                    primaryActionIcon: AppIcons.restore,
                    primaryActionLabel: 'Restore ${memory.event.title}',
                    onPrimaryAction: () => _restore(context, ref, memory),
                    secondaryActionIcon: AppIcons.trash,
                    secondaryActionLabel: 'Move ${memory.event.title} to Trash',
                    onSecondaryAction: () => _trash(context, ref, memory),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _restore(
    BuildContext context,
    WidgetRef ref,
    TimelineMemory memory,
  ) async {
    await ref
        .read(setMemoryArchiveStateUseCaseProvider)
        .restore(memory.event.metadata.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Memory restored to your timeline.')),
    );
  }

  Future<void> _trash(
    BuildContext context,
    WidgetRef ref,
    TimelineMemory memory,
  ) async {
    await ref
        .read(deleteMemoryUseCaseProvider)
        .moveToTrash(memory.event.metadata.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Memory moved to Trash.'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            await ref
                .read(deleteMemoryUseCaseProvider)
                .restoreFromTrash(memory.event.metadata.id);
            await ref
                .read(setMemoryArchiveStateUseCaseProvider)
                .archive(memory.event.metadata.id);
          },
        ),
      ),
    );
  }
}
