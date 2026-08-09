import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_timeline/app/navigation/app_routes.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/timeline/application/timeline_providers.dart';
import 'package:life_timeline/features/timeline/domain/temporal_display.dart';

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
        error: (error, stackTrace) => const Center(
          child: AppErrorState(
            title: 'Archive unavailable',
            message: 'Archived records could not be opened.',
          ),
        ),
        data: (values) => values.isEmpty
            ? const Center(
                child: AppEmptyState(
                  title: 'No archived memories',
                  message: 'Memories you archive will remain preserved here.',
                  icon: AppIcons.database,
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.xl),
                itemCount: values.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final memory = values[index];
                  return MemoryCard(
                    title: memory.event.title,
                    metadata: TemporalDisplay.label(memory.event.temporalValue),
                    subtitle: memory.event.eventType,
                    trailing: AppButton(
                      label: 'Restore',
                      variant: AppButtonVariant.tertiary,
                      onPressed: () => ref
                          .read(setMemoryArchiveStateUseCaseProvider)
                          .restore(memory.event.metadata.id),
                    ),
                    onTap: () => context.pushNamed(
                      AppRoute.memoryDetail.name,
                      pathParameters: {'memoryId': memory.event.metadata.id},
                    ),
                  );
                },
              ),
      ),
    );
  }
}
