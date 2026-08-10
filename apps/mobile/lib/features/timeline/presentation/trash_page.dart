import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/timeline/application/timeline_providers.dart';
import 'package:life_timeline/features/timeline/presentation/widgets/lifecycle_memory_card.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

final class TrashPage extends ConsumerStatefulWidget {
  const TrashPage({super.key});

  @override
  ConsumerState<TrashPage> createState() => _TrashPageState();
}

final class _TrashPageState extends ConsumerState<TrashPage> {
  String? _workingId;

  @override
  Widget build(BuildContext context) {
    final memories = ref.watch(trashedMemoriesProvider);
    return AppScaffold(
      appBar: AppBar(title: const Text('Trash')),
      body: memories.when(
        loading: () =>
            const Center(child: AppLoadingState(label: 'Loading Trash')),
        error: (error, stackTrace) => Center(
          child: AppErrorState(
            title: 'Trash unavailable',
            message: 'Deleted memories could not be opened locally.',
            actionLabel: 'Try again',
            onAction: () => ref.invalidate(trashedMemoriesProvider),
          ),
        ),
        data: (values) => values.isEmpty
            ? const Center(
                child: AppEmptyState(
                  title: 'Trash is empty',
                  message:
                      'Memories moved to Trash stay recoverable until you permanently delete them.',
                  icon: AppIcons.trash,
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.xl),
                itemCount: values.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final memory = values[index];
                  final busy = _workingId == memory.event.metadata.id;
                  return LifecycleMemoryCard(
                    memory: memory,
                    primaryActionIcon: AppIcons.restore,
                    primaryActionLabel: 'Restore ${memory.event.title}',
                    onPrimaryAction: busy ? null : () => _restore(memory),
                    secondaryActionIcon: AppIcons.deleteForever,
                    secondaryActionLabel:
                        'Permanently delete ${memory.event.title}',
                    onSecondaryAction: busy
                        ? null
                        : () => _confirmPermanentDelete(memory),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _restore(TimelineMemory memory) async {
    setState(() => _workingId = memory.event.metadata.id);
    await ref
        .read(deleteMemoryUseCaseProvider)
        .restoreFromTrash(memory.event.metadata.id);
    if (!mounted) return;
    setState(() => _workingId = null);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Memory restored to your timeline.')),
    );
  }

  Future<void> _confirmPermanentDelete(TimelineMemory memory) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Permanently delete this memory?'),
        content: const Text(
          'This removes the memory, its direct links and provenance. Orphaned supporting evidence and app-managed copies are also removed. Shared entities and evidence remain preserved. This cannot be undone.',
        ),
        actions: [
          AppButton(
            label: 'Cancel',
            variant: AppButtonVariant.tertiary,
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          AppButton(
            key: const Key('confirm-permanent-delete'),
            label: 'Delete permanently',
            icon: AppIcons.deleteForever,
            variant: AppButtonVariant.destructive,
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _workingId = memory.event.metadata.id);
    try {
      final cleanupComplete = await ref
          .read(deleteMemoryUseCaseProvider)
          .permanentlyDelete(memory.event.metadata.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            cleanupComplete
                ? 'Memory permanently deleted.'
                : 'Memory deleted. Some app-managed files could not be removed.',
          ),
        ),
      );
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The memory could not be deleted safely. Try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _workingId = null);
    }
  }
}
