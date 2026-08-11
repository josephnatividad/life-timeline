import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/storage/application/storage_providers.dart';
import 'package:life_timeline/features/storage/domain/storage_models.dart';
import 'package:life_timeline/features/storage/presentation/widgets/storage_components.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

final class StorageManagerPage extends ConsumerStatefulWidget {
  const StorageManagerPage({super.key});

  @override
  ConsumerState<StorageManagerPage> createState() => _StorageManagerPageState();
}

final class _StorageManagerPageState extends ConsumerState<StorageManagerPage> {
  final _selected = <String>{};

  @override
  Widget build(BuildContext context) {
    ref.listen(storageOperationControllerProvider, (previous, next) {
      if (next.completedMessage case final message?) {
        if (next.kind == StorageOperationKind.archive) _selected.clear();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
        ref.read(storageOperationControllerProvider.notifier).reset();
      } else if (next.errorCode case final code?) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_operationErrorMessage(code))));
        ref.read(storageOperationControllerProvider.notifier).reset();
      }
    });
    final overview = ref.watch(storageOverviewProvider);
    final operation = ref.watch(storageOperationControllerProvider);
    return AppScaffold(
      appBar: AppBar(title: const Text('Storage')),
      body: overview.when(
        loading: () => const Center(
          child: AppLoadingState(label: 'Measuring local storage'),
        ),
        error: (error, stackTrace) => Center(
          child: AppErrorState(
            title: 'Storage details unavailable',
            message:
                'Life Timeline could not measure its app-owned files safely.',
            actionLabel: 'Try again',
            onAction: () => ref.invalidate(storageOverviewProvider),
          ),
        ),
        data: (value) => _StorageContent(
          overview: value,
          operation: operation,
          selected: _selected,
          onSelected: (id, selected) {
            setState(() => selected ? _selected.add(id) : _selected.remove(id));
          },
          onArchive: () => _archive(value),
          onRetrieve: (id) => _retrieve(id),
          onCleanup: () =>
              ref.read(storageOperationControllerProvider.notifier).cleanup(),
          onOptimize: (id) => _optimize(id),
        ),
      ),
    );
  }

  Future<void> _archive(StorageOverview overview) async {
    final selectedProtection = overview.protection.items.where(
      (item) => _selected.contains(item.attachmentId),
    );
    final singleCopyCount = selectedProtection
        .where((item) => item.verifiedCopyCount <= 1)
        .length;
    final request = await AppBottomSheet.show<_ArchiveRequest>(
      context: context,
      isDismissible: false,
      builder: (context) => _ArchiveConfirmationSheet(
        selectedCount: _selected.length,
        singleCopyCount: singleCopyCount,
      ),
    );
    if (request == null || !mounted) return;
    await ref
        .read(storageOperationControllerProvider.notifier)
        .archiveAttachments(
          attachmentIds: _selected.toList(growable: false),
          recoveryPassword: request.password,
          removeLocalOriginals: request.removeLocalOriginals,
        );
  }

  Future<void> _retrieve(String attachmentId) async {
    final password = await AppBottomSheet.show<String>(
      context: context,
      isDismissible: false,
      builder: (context) => const _RecoveryPasswordSheet(
        title: 'Retrieve original',
        explanation:
            'Choose the encrypted archive file next. Decryption and verification stay on this device.',
      ),
    );
    if (password == null || !mounted) return;
    await ref
        .read(storageOperationControllerProvider.notifier)
        .retrieve(attachmentId: attachmentId, recoveryPassword: password);
  }

  Future<void> _optimize(String attachmentId) async {
    final preserve = await AppBottomSheet.show<bool>(
      context: context,
      builder: (context) => const _OptimizationConfirmationSheet(),
    );
    if (preserve == null || !mounted) return;
    await ref
        .read(storageOperationControllerProvider.notifier)
        .optimize(attachmentId: attachmentId, preserveOriginal: preserve);
  }
}

final class _StorageContent extends StatelessWidget {
  const _StorageContent({
    required this.overview,
    required this.operation,
    required this.selected,
    required this.onSelected,
    required this.onArchive,
    required this.onRetrieve,
    required this.onCleanup,
    required this.onOptimize,
  });

  final VoidCallback onArchive;
  final VoidCallback onCleanup;
  final Future<void> Function(String id) onOptimize;
  final Future<void> Function(String id) onRetrieve;
  final void Function(String id, bool selected) onSelected;
  final StorageOperationState operation;
  final StorageOverview overview;
  final Set<String> selected;

  @override
  Widget build(BuildContext context) {
    final inventory = overview.inventory;
    final archiveCandidates = inventory.attachments.where((stored) {
      final attachment = stored.attachment;
      return attachment.storageState == AttachmentStorageState.local &&
          attachment.relativePath != null &&
          stored.archiveReference == null &&
          inventory.managedFiles.any(
            (file) =>
                file.attachmentId == attachment.metadata.id &&
                !file.preservedOriginal &&
                file.exists,
          );
    }).toList();
    final archived = inventory.attachments
        .where(
          (stored) =>
              stored.archiveReference != null &&
              stored.attachment.storageState == AttachmentStorageState.archived,
        )
        .toList();
    final optimizable = inventory.attachments.where((stored) {
      final attachment = stored.attachment;
      return attachment.storageState == AttachmentStorageState.local &&
          attachment.importMode != AttachmentImportMode.optimizedCopy &&
          attachment.mimeType.toLowerCase() == 'image/jpeg' &&
          attachment.byteSize >= 1024 * 1024;
    }).toList();
    return ListView(
      key: const Key('storage-manager-content'),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      children: [
        ScreenContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (operation.running) ...[
                StorageOperationProgressView(
                  progress: operation.progress,
                  label: _operationLabel(operation.kind),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
              StorageSummarySurface(
                health: overview.health,
                breakdown: inventory.breakdown,
              ),
              const SizedBox(height: AppSpacing.xxxl),
              const AppSectionHeader(
                title: 'What uses space',
                supportingText: 'Measured from app-owned files on this device.',
              ),
              const SizedBox(height: AppSpacing.sm),
              StorageBreakdownList(value: inventory.breakdown),
              const SizedBox(height: AppSpacing.xxxl),
              BackupProtectionSurface(health: overview.backupHealth),
              const SizedBox(height: AppSpacing.xxxl),
              _OptimizationSection(
                inventory: inventory,
                optimizable: optimizable,
                operationRunning: operation.running,
                onCleanup: onCleanup,
                onOptimize: onOptimize,
              ),
              const SizedBox(height: AppSpacing.xxxl),
              const AppSectionHeader(
                title: 'Archive selected originals',
                supportingText:
                    'Archive is for saving device space. It is not a second backup.',
              ),
              const SizedBox(height: AppSpacing.sm),
              if (archiveCandidates.isEmpty)
                const AppEmptyState(
                  title: 'No archive candidates',
                  message:
                      'Only available app-managed originals can be archived.',
                  icon: AppIcons.archive,
                )
              else ...[
                for (final stored in archiveCandidates)
                  StorageAttachmentTile(
                    key: Key(
                      'archive-candidate-${stored.attachment.metadata.id}',
                    ),
                    stored: stored,
                    selected: selected.contains(stored.attachment.metadata.id),
                    onSelected: operation.running
                        ? null
                        : (value) => onSelected(
                            stored.attachment.metadata.id,
                            value ?? false,
                          ),
                  ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  key: const Key('archive-selected-button'),
                  label: selected.isEmpty
                      ? 'Select originals to archive'
                      : 'Archive ${selected.length} selected',
                  icon: AppIcons.archive,
                  expanded: true,
                  onPressed: selected.isEmpty || operation.running
                      ? null
                      : onArchive,
                ),
              ],
              const SizedBox(height: AppSpacing.xxxl),
              const AppSectionHeader(
                title: 'Archived originals',
                supportingText:
                    'Previews and timeline metadata stay local. Reconnect the encrypted original when needed.',
              ),
              const SizedBox(height: AppSpacing.sm),
              if (archived.isEmpty)
                const Text('No originals are currently archived off-device.')
              else
                for (final stored in archived)
                  StorageAttachmentTile(
                    key: Key(
                      'archived-attachment-${stored.attachment.metadata.id}',
                    ),
                    stored: stored,
                    actionLabel: 'Retrieve',
                    onAction: operation.running
                        ? null
                        : () => onRetrieve(stored.attachment.metadata.id),
                  ),
              if (inventory.referencedContentCount > 0 ||
                  inventory.unavailableContentCount > 0 ||
                  inventory.missingManagedFileCount > 0) ...[
                const SizedBox(height: AppSpacing.xxxl),
                const AppSectionHeader(title: 'Needs attention'),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${inventory.referencedContentCount} referenced · '
                  '${inventory.unavailableContentCount} unavailable · '
                  '${inventory.missingManagedFileCount} missing managed files',
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

final class _OptimizationSection extends StatelessWidget {
  const _OptimizationSection({
    required this.inventory,
    required this.optimizable,
    required this.operationRunning,
    required this.onCleanup,
    required this.onOptimize,
  });

  final StorageInventory inventory;
  final VoidCallback onCleanup;
  final Future<void> Function(String id) onOptimize;
  final List<StoredAttachment> optimizable;
  final bool operationRunning;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const AppSectionHeader(
        title: 'Safe opportunities',
        supportingText:
            'Nothing here removes evidence or an original without confirmation.',
      ),
      const SizedBox(height: AppSpacing.sm),
      if (inventory.reclaimableCacheBytes == 0 &&
          inventory.duplicateGroups.isEmpty &&
          optimizable.isEmpty)
        const Text('No safe storage opportunities were found.')
      else ...[
        if (inventory.reclaimableCacheBytes > 0)
          ListTile(
            key: const Key('cleanup-cache-row'),
            contentPadding: EdgeInsets.zero,
            leading: const AppIcon(icon: AppIcons.trash),
            title: const Text('Clean stale temporary files'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${formatStorageBytes(inventory.reclaimableCacheBytes)} can be reclaimed from verified app-owned cache.',
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: 'Clean',
                  onPressed: operationRunning ? null : onCleanup,
                  variant: AppButtonVariant.tertiary,
                ),
              ],
            ),
          ),
        if (inventory.duplicateGroups.isNotEmpty)
          ListTile(
            key: const Key('duplicate-review-row'),
            contentPadding: EdgeInsets.zero,
            leading: const AppIcon(icon: AppIcons.information),
            title: Text(
              '${inventory.duplicateGroups.length} exact duplicate ${inventory.duplicateGroups.length == 1 ? 'group' : 'groups'}',
            ),
            subtitle: Text(
              '${formatStorageBytes(inventory.duplicateBytes)} potential savings. Detection is review-only; no files were removed.',
            ),
          ),
        for (final stored in optimizable.take(3))
          ListTile(
            key: Key('optimize-${stored.attachment.metadata.id}'),
            contentPadding: EdgeInsets.zero,
            leading: const AppIcon(icon: AppIcons.image),
            title: Text(stored.attachment.displayName ?? 'Large JPEG photo'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${formatStorageBytes(stored.attachment.byteSize)} · optional verified optimized copy',
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: 'Optimize',
                  onPressed: operationRunning
                      ? null
                      : () => onOptimize(stored.attachment.metadata.id),
                  variant: AppButtonVariant.tertiary,
                ),
              ],
            ),
          ),
      ],
    ],
  );
}

final class _ArchiveConfirmationSheet extends StatefulWidget {
  const _ArchiveConfirmationSheet({
    required this.selectedCount,
    required this.singleCopyCount,
  });

  final int selectedCount;
  final int singleCopyCount;

  @override
  State<_ArchiveConfirmationSheet> createState() =>
      _ArchiveConfirmationSheetState();
}

final class _ArchiveConfirmationSheetState
    extends State<_ArchiveConfirmationSheet> {
  final _password = TextEditingController();
  var _removeLocal = false;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppBottomSheet(
    title:
        'Archive ${widget.selectedCount} ${widget.selectedCount == 1 ? 'original' : 'originals'}',
    description:
        'Each original is encrypted locally, saved through the system picker, and verified before any local removal.',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.singleCopyCount > 0) ...[
          _WarningSurface(
            message:
                '${widget.singleCopyCount == 1 ? 'This item has' : '${widget.singleCopyCount} items have'} no independent verified backup. Removing locally will leave one copy of the original file.',
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        AppTextField(
          key: const Key('archive-password-field'),
          label: 'Recovery password',
          controller: _password,
          obscureText: true,
          helperText: 'Required again when retrieving the encrypted original.',
          leadingIcon: AppIcons.lock,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.md),
        SwitchListTile(
          key: const Key('remove-local-original-switch'),
          contentPadding: EdgeInsets.zero,
          title: const Text('Remove local original after verification'),
          subtitle: const Text(
            'The timeline and a small preview stay on this device.',
          ),
          value: _removeLocal,
          onChanged: (value) => setState(() => _removeLocal = value),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          key: const Key('confirm-archive-button'),
          label: 'Choose archive location',
          icon: AppIcons.archive,
          expanded: true,
          onPressed: _password.text.length < 8
              ? null
              : () => Navigator.of(context).pop(
                  _ArchiveRequest(
                    password: _password.text,
                    removeLocalOriginals: _removeLocal,
                  ),
                ),
        ),
      ],
    ),
  );
}

final class _RecoveryPasswordSheet extends StatefulWidget {
  const _RecoveryPasswordSheet({
    required this.title,
    required this.explanation,
  });

  final String explanation;
  final String title;

  @override
  State<_RecoveryPasswordSheet> createState() => _RecoveryPasswordSheetState();
}

final class _RecoveryPasswordSheetState extends State<_RecoveryPasswordSheet> {
  final _password = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppBottomSheet(
    title: widget.title,
    description: widget.explanation,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          key: const Key('retrieve-password-field'),
          label: 'Recovery password',
          controller: _password,
          obscureText: true,
          leadingIcon: AppIcons.lock,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          key: const Key('choose-archive-file-button'),
          label: 'Choose encrypted archive',
          icon: AppIcons.restore,
          expanded: true,
          onPressed: _password.text.length < 8
              ? null
              : () => Navigator.of(context).pop(_password.text),
        ),
      ],
    ),
  );
}

final class _OptimizationConfirmationSheet extends StatefulWidget {
  const _OptimizationConfirmationSheet();

  @override
  State<_OptimizationConfirmationSheet> createState() =>
      _OptimizationConfirmationSheetState();
}

final class _OptimizationConfirmationSheetState
    extends State<_OptimizationConfirmationSheet> {
  var _preserveOriginal = true;

  @override
  Widget build(BuildContext context) => AppBottomSheet(
    title: 'Optimize managed photo',
    description:
        'A high-quality copy is created and verified without changing aspect ratio.',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          key: const Key('preserve-original-switch'),
          contentPadding: EdgeInsets.zero,
          title: const Text('Preserve original'),
          subtitle: Text(
            _preserveOriginal
                ? 'Uses more space, but keeps maximum fidelity.'
                : 'The original is removed only after the optimized copy is saved and verified.',
          ),
          value: _preserveOriginal,
          onChanged: (value) => setState(() => _preserveOriginal = value),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          key: const Key('confirm-optimize-button'),
          label: 'Create optimized copy',
          icon: AppIcons.image,
          expanded: true,
          onPressed: () => Navigator.of(context).pop(_preserveOriginal),
        ),
      ],
    ),
  );
}

final class _WarningSurface extends StatelessWidget {
  const _WarningSurface({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(AppRadius.card),
    ),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIcon(
            icon: AppIcons.error,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(message)),
        ],
      ),
    ),
  );
}

final class _ArchiveRequest {
  const _ArchiveRequest({
    required this.password,
    required this.removeLocalOriginals,
  });

  final String password;
  final bool removeLocalOriginals;
}

String _operationLabel(StorageOperationKind? kind) => switch (kind) {
  StorageOperationKind.archive => 'Archiving selected originals',
  StorageOperationKind.retrieve => 'Retrieving the original',
  StorageOperationKind.cleanup => 'Cleaning temporary files',
  StorageOperationKind.optimize => 'Optimizing managed photo',
  null => 'Working locally',
};

String _operationErrorMessage(String code) => switch (code) {
  'archive_destination_unavailable' =>
    'Original file is currently unavailable. Your timeline record and preview are still safe.',
  'archive_checksum_mismatch' || 'retrieved_checksum_mismatch' =>
    'Retrieval stopped because the selected archive did not pass verification.',
  'archive_authentication_failed' =>
    'The password was not accepted or the archive is damaged.',
  'managed_file_missing' =>
    'The local original could not be found. Nothing was removed.',
  'source_checksum_mismatch' =>
    'The local original changed since it was recorded. Nothing was archived or removed.',
  'archive_verification_failed' =>
    'The archive copy could not be verified. The local original was not removed.',
  'recovery_password_too_short' =>
    'Enter a recovery password with at least eight characters.',
  'cleanup_failed' => 'Temporary files could not be cleaned safely.',
  'optimization_failed' =>
    'The optimized copy could not be verified. The original was not changed.',
  _ =>
    'The local operation could not be completed. Your original was not removed.',
};
