import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_timeline/app/navigation/app_routes.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/timeline/application/timeline_providers.dart';
import 'package:life_timeline/features/timeline/presentation/widgets/memory_summary.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';

final class MemoryDetailPage extends ConsumerWidget {
  const MemoryDetailPage({required this.memoryId, super.key});

  final String memoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memory = ref.watch(memoryDetailProvider(memoryId));
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Memory'),
        actions: [
          AppIconButton(
            icon: AppIcons.settings,
            label: 'Edit memory',
            onPressed: () => context.pushNamed(
              AppRoute.editMemory.name,
              pathParameters: {'memoryId': memoryId},
            ),
          ),
        ],
      ),
      body: memory.when(
        loading: () =>
            const Center(child: AppLoadingState(label: 'Loading memory')),
        error: (error, stackTrace) => Center(
          child: AppErrorState(
            title: 'Memory unavailable',
            message: 'This local memory could not be opened.',
            actionLabel: 'Try again',
            onAction: () => ref.invalidate(memoryDetailProvider(memoryId)),
          ),
        ),
        data: (value) => value == null
            ? const Center(
                child: AppErrorState(
                  title: 'Memory not found',
                  message: 'It may have been moved to Trash.',
                ),
              )
            : SingleChildScrollView(
                child: ScreenContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      MemorySummary(memory: value),
                      const SizedBox(height: AppSpacing.xl),
                      if (value.event.metadata.lifecycle ==
                          RecordLifecycle.archived)
                        AppButton(
                          key: const Key('restore-memory'),
                          label: 'Restore to timeline',
                          icon: AppIcons.success,
                          variant: AppButtonVariant.secondary,
                          expanded: true,
                          onPressed: () => _restore(context, ref),
                        )
                      else
                        AppButton(
                          key: const Key('archive-memory'),
                          label: 'Archive memory',
                          icon: AppIcons.database,
                          variant: AppButtonVariant.secondary,
                          expanded: true,
                          onPressed: () => _archive(context, ref),
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _archive(BuildContext context, WidgetRef ref) async {
    await ref.read(setMemoryArchiveStateUseCaseProvider).archive(memoryId);
    if (context.mounted) {
      context.goNamed(AppRoute.timeline.name);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Memory archived.')));
    }
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    await ref.read(setMemoryArchiveStateUseCaseProvider).restore(memoryId);
    ref.invalidate(memoryDetailProvider(memoryId));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Memory restored to your timeline.')),
      );
    }
  }
}
