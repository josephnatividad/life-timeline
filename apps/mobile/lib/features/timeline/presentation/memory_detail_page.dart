import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_timeline/app/navigation/app_routes.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/media/presentation/memory_media_gallery.dart';
import 'package:life_timeline/features/reminders/presentation/memory_reminder_section.dart';
import 'package:life_timeline/features/stories/application/story_providers.dart';
import 'package:life_timeline/features/timeline/application/timeline_providers.dart';
import 'package:life_timeline/features/timeline/presentation/widgets/memory_summary.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

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
            icon: AppIcons.edit,
            label: 'Edit memory',
            onPressed: () => context.pushNamed(
              AppRoute.editMemory.name,
              pathParameters: {'memoryId': memoryId},
            ),
          ),
          AppIconButton(
            icon: AppIcons.more,
            label: 'Memory options',
            onPressed: () => _showActions(context, ref),
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
                      MemoryHeroMedia(memoryId: memoryId),
                      const SizedBox(height: AppSpacing.xl),
                      MemorySummary(memory: value, showSecondary: false),
                      const SizedBox(height: AppSpacing.xxl),
                      MemoryReminderSection(memory: value),
                      const SizedBox(height: AppSpacing.xxl),
                      MemoryMediaGallery(memoryId: memoryId, showHero: false),
                      MemorySummary(
                        memory: value,
                        showPrimary: false,
                        evidenceSection: _MemoryEvidenceSection(
                          memoryId: memoryId,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _showActions(BuildContext context, WidgetRef ref) async {
    final memory = ref.read(memoryDetailProvider(memoryId)).value;
    if (memory == null) return;
    await AppBottomSheet.show<void>(
      context: context,
      builder: (sheetContext) => AppBottomSheet(
        title: 'Memory options',
        description:
            'Archive keeps history preserved. Trash is for mistakes or records you no longer want.',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (memory.event.metadata.lifecycle == RecordLifecycle.confirmed)
              ListTile(
                key: const Key('create-memory-story'),
                contentPadding: EdgeInsets.zero,
                leading: const AppIcon(icon: AppIcons.stories),
                title: const Text('Create Story'),
                subtitle: const Text(
                  'Review fields before a local share image is made',
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _createStory(context, ref);
                },
              ),
            if (memory.event.metadata.lifecycle == RecordLifecycle.archived)
              ListTile(
                key: const Key('restore-memory'),
                contentPadding: EdgeInsets.zero,
                leading: const AppIcon(icon: AppIcons.restore),
                title: const Text('Restore to timeline'),
                subtitle: const Text('Make this memory active again'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _restore(context, ref);
                },
              )
            else
              ListTile(
                key: const Key('archive-memory'),
                contentPadding: EdgeInsets.zero,
                leading: const AppIcon(icon: AppIcons.archive),
                title: const Text('Archive memory'),
                subtitle: const Text('Preserve it outside the active timeline'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _archive(context, ref);
                },
              ),
            ListTile(
              key: const Key('trash-memory'),
              contentPadding: EdgeInsets.zero,
              leading: AppIcon(
                icon: AppIcons.trash,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Move to Trash',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              subtitle: const Text('You can restore it before deleting it'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _trash(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createStory(BuildContext context, WidgetRef ref) async {
    final source = await ref
        .read(storySourceFactoryProvider)
        .fromEvent(memoryId);
    if (!context.mounted) return;
    if (source == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This memory cannot create a Story.')),
      );
      return;
    }
    await context.pushNamed(AppRoute.storyEditor.name, extra: source);
  }

  Future<void> _archive(BuildContext context, WidgetRef ref) async {
    await ref.read(setMemoryArchiveStateUseCaseProvider).archive(memoryId);
    if (context.mounted) {
      final messenger = ScaffoldMessenger.of(context);
      context.goNamed(AppRoute.timeline.name);
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Memory archived.'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => ref
                .read(setMemoryArchiveStateUseCaseProvider)
                .restore(memoryId),
          ),
        ),
      );
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

  Future<void> _trash(BuildContext context, WidgetRef ref) async {
    await ref.read(deleteMemoryUseCaseProvider).moveToTrash(memoryId);
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    context.goNamed(AppRoute.timeline.name);
    messenger.showSnackBar(
      SnackBar(
        content: const Text('Memory moved to Trash.'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () =>
              ref.read(deleteMemoryUseCaseProvider).restoreFromTrash(memoryId),
        ),
      ),
    );
  }
}

final class _MemoryEvidenceSection extends ConsumerWidget {
  const _MemoryEvidenceSection({required this.memoryId});

  final String memoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final evidence = ref.watch(memoryEvidenceProvider(memoryId));
    return evidence.when(
      loading: () => const AppLoadingState(label: 'Loading evidence'),
      error: (error, stackTrace) => const AppErrorState(
        title: 'Evidence unavailable',
        message: 'Supporting records could not be opened.',
      ),
      data: (values) => values.isEmpty
          ? const AppEmptyState(
              title: 'No evidence attached',
              message: 'Receipts and supporting documents will appear here.',
              icon: AppIcons.database,
            )
          : Column(
              children: [
                for (final item in values)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const AppIcon(icon: AppIcons.database),
                    title: Text(item.evidence.title),
                    subtitle: Text(
                      '${_evidenceTypeLabel(item.evidence.evidenceType)} · ${item.attachmentCount} ${item.attachmentCount == 1 ? 'attachment' : 'attachments'}',
                    ),
                  ),
              ],
            ),
    );
  }

  String _evidenceTypeLabel(EvidenceType value) => switch (value) {
    EvidenceType.receipt => 'Receipt',
    EvidenceType.warranty => 'Warranty',
    EvidenceType.certificate => 'Certificate',
    EvidenceType.ticket => 'Ticket',
    EvidenceType.officialDocument => 'Official document',
    EvidenceType.other => 'Other evidence',
  };
}
