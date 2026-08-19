import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_timeline/app/navigation/app_routes.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/media/presentation/memory_media_gallery.dart';
import 'package:life_timeline/features/reminders/presentation/memory_reminder_section.dart';
import 'package:life_timeline/features/stories/application/story_providers.dart';
import 'package:life_timeline/features/timeline/application/timeline_providers.dart';
import 'package:life_timeline/features/timeline/presentation/memory_evidence_page.dart';
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
                      const SizedBox(height: AppSpacing.xl),
                      _PrimaryActions(
                        onAddPhoto: () => context.pushNamed(
                          AppRoute.memoryPhotos.name,
                          pathParameters: {'memoryId': memoryId},
                        ),
                        onCreateStory:
                            value.event.metadata.lifecycle ==
                                RecordLifecycle.confirmed
                            ? () => _createStory(context, ref)
                            : null,
                      ),
                      MemoryMediaPreview(memoryId: memoryId),
                      if (value.relatedEntity case final entity?)
                        _RelatedSection(entity: entity),
                      MemoryEvidencePreview(memoryId: memoryId),
                      MemoryReminderSection(memory: value),
                      const SizedBox(height: AppSpacing.xxxl),
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
            ListTile(
              key: const Key('add-memory-reminder'),
              contentPadding: EdgeInsets.zero,
              leading: const AppIcon(icon: AppIcons.reminder),
              title: const Text('Add reminder'),
              subtitle: const Text('Choose a local date and notification'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                context.pushNamed(
                  AppRoute.addReminder.name,
                  queryParameters: {'memoryId': memoryId},
                );
              },
            ),
            ListTile(
              key: const Key('memory-technical-details'),
              contentPadding: EdgeInsets.zero,
              leading: const AppIcon(icon: AppIcons.information),
              title: const Text('Memory details'),
              subtitle: const Text('Privacy, status, and record dates'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _showMemoryDetails(context, memory);
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

  Future<void> _showMemoryDetails(
    BuildContext context,
    TimelineMemory memory,
  ) => AppBottomSheet.show<void>(
    context: context,
    builder: (sheetContext) => AppBottomSheet(
      title: 'Memory details',
      description:
          'Technical record information is kept separate from the memory itself.',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _UtilityRow(
            label: 'Privacy',
            value: _privacyLabel(memory.event.metadata.privacyClassification),
          ),
          _UtilityRow(
            label: 'Created',
            value: MaterialLocalizations.of(
              sheetContext,
            ).formatMediumDate(memory.event.metadata.createdAt.toLocal()),
          ),
          _UtilityRow(
            label: 'Last updated',
            value: MaterialLocalizations.of(
              sheetContext,
            ).formatMediumDate(memory.event.metadata.updatedAt.toLocal()),
          ),
          _UtilityRow(
            label: 'Status',
            value: memory.event.metadata.lifecycle == RecordLifecycle.archived
                ? 'Archived'
                : 'Active',
          ),
        ],
      ),
    ),
  );

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
    final archiveState = ref.read(setMemoryArchiveStateUseCaseProvider);
    await archiveState.archive(memoryId);
    if (context.mounted) {
      final messenger = ScaffoldMessenger.of(context);
      context.goNamed(AppRoute.timeline.name);
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Memory archived.'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => archiveState.restore(memoryId),
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
    final deleteMemory = ref.read(deleteMemoryUseCaseProvider);
    await deleteMemory.moveToTrash(memoryId);
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    context.goNamed(AppRoute.timeline.name);
    messenger.showSnackBar(
      SnackBar(
        content: const Text('Memory moved to Trash.'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => deleteMemory.restoreFromTrash(memoryId),
        ),
      ),
    );
  }
}

final class _PrimaryActions extends StatelessWidget {
  const _PrimaryActions({required this.onAddPhoto, this.onCreateStory});

  final VoidCallback onAddPhoto;
  final VoidCallback? onCreateStory;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AppSpacing.sm,
    runSpacing: AppSpacing.sm,
    children: [
      if (onCreateStory != null)
        AppButton(
          key: const Key('create-memory-story'),
          label: 'Create Story',
          icon: AppIcons.stories,
          onPressed: onCreateStory,
        ),
      AppButton(
        key: const Key('memory-add-photo'),
        label: 'Add photo',
        icon: AppIcons.image,
        variant: AppButtonVariant.secondary,
        onPressed: onAddPhoto,
      ),
    ],
  );
}

final class _RelatedSection extends StatelessWidget {
  const _RelatedSection({required this.entity});

  final Entity entity;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.xxxl),
    child: AppSection(
      title: 'Related',
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const AppIcon(icon: AppIcons.you),
        title: Text(entity.name),
        subtitle: Text(entity.entityType),
      ),
    ),
  );
}

final class _UtilityRow extends StatelessWidget {
  const _UtilityRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label),
    trailing: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 180),
      child: Text(
        value,
        textAlign: TextAlign.end,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    ),
  );
}

String _privacyLabel(PrivacyClassification value) => switch (value) {
  PrivacyClassification.shareSafe => 'Share safe',
  PrivacyClassification.personal => 'Personal',
  PrivacyClassification.sensitive => 'Sensitive',
  PrivacyClassification.neverShare => 'Never share',
};
