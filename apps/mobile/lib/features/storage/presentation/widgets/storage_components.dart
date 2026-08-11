import 'package:flutter/material.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/backup/domain/backup_models.dart';
import 'package:life_timeline/features/storage/domain/storage_models.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

final class StorageSummarySurface extends StatelessWidget {
  const StorageSummarySurface({
    required this.health,
    required this.breakdown,
    super.key,
  });

  final StorageBreakdown breakdown;
  final StorageHealth health;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      container: true,
      label: 'Life Timeline uses ${formatStorageBytes(health.appStorageBytes)}',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          border: Border.all(color: colors.outlineVariant),
          borderRadius: BorderRadius.circular(AppRadius.largeCard),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppIcon(
                icon: AppIcons.database,
                size: AppIconSize.feature,
                semanticLabel: 'Storage',
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Life Timeline uses',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                formatStorageBytes(health.appStorageBytes),
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                health.recommendedAction,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
              ),
              if (health.freeDeviceBytes case final free?) ...[
                const SizedBox(height: AppSpacing.sm),
                Text('${formatStorageBytes(free)} available on this device'),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

final class StorageBreakdownList extends StatelessWidget {
  const StorageBreakdownList({required this.value, super.key});

  final StorageBreakdown value;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _StorageRow(
        icon: AppIcons.image,
        label: 'Photos',
        bytes: value.photosBytes,
      ),
      _StorageRow(
        icon: AppIcons.stories,
        label: 'Documents',
        bytes: value.documentsBytes,
      ),
      _StorageRow(
        icon: AppIcons.preview,
        label: 'Thumbnails',
        bytes: value.thumbnailsBytes,
      ),
      _StorageRow(
        icon: AppIcons.database,
        label: 'Database',
        bytes: value.databaseBytes,
      ),
      _StorageRow(
        icon: AppIcons.loading,
        label: 'Cache',
        bytes: value.cacheBytes,
      ),
      _StorageRow(
        icon: AppIcons.archive,
        label: 'Other managed files',
        bytes: value.otherManagedBytes,
      ),
    ],
  );
}

final class BackupProtectionSurface extends StatelessWidget {
  const BackupProtectionSurface({required this.health, super.key});

  final BackupHealth health;

  @override
  Widget build(BuildContext context) {
    final status = backupHealthLabel(health, DateTime.now().toUtc());
    final tone = status == 'Protected'
        ? AppBadgeTone.neutral
        : AppBadgeTone.primary;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const AppIcon(icon: AppIcons.privacy),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Backup & protection',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: AppBadge(label: status, tone: tone),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              health.lastBackupAt == null
                  ? 'No verified backup has been recorded.'
                  : 'Last verified ${MaterialLocalizations.of(context).formatMediumDate(health.lastBackupAt!.toLocal())}',
            ),
            if (health.importantItemsWithSingleCopy > 0) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${health.importantItemsWithSingleCopy} ${health.importantItemsWithSingleCopy == 1 ? 'item has' : 'items have'} only one verified copy.',
              ),
            ],
            if (health.archiveItemsWithSingleCopy > 0) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${health.archiveItemsWithSingleCopy} archived ${health.archiveItemsWithSingleCopy == 1 ? 'original exists' : 'originals exist'} in one verified location.',
              ),
            ],
            if (health.itemsWithNoVerifiedCopy > 0) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${health.itemsWithNoVerifiedCopy} ${health.itemsWithNoVerifiedCopy == 1 ? 'item needs' : 'items need'} reconnection.',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

final class StorageOperationProgressView extends StatelessWidget {
  const StorageOperationProgressView({
    required this.progress,
    required this.label,
    super.key,
  });

  final String label;
  final ArchiveProgress? progress;

  @override
  Widget build(BuildContext context) {
    final phase = progress?.phase;
    final value = phase == null
        ? null
        : (phase.index + 1) / ArchivePhase.values.length;
    return Semantics(
      liveRegion: true,
      label: '$label, ${phase == null ? 'starting' : archivePhaseLabel(phase)}',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(label, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                phase == null ? 'Starting locally…' : archivePhaseLabel(phase),
              ),
              const SizedBox(height: AppSpacing.md),
              LinearProgressIndicator(value: value),
            ],
          ),
        ),
      ),
    );
  }
}

final class StorageAttachmentTile extends StatelessWidget {
  const StorageAttachmentTile({
    required this.stored,
    this.selected,
    this.onSelected,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String? actionLabel;
  final VoidCallback? onAction;
  final ValueChanged<bool?>? onSelected;
  final bool? selected;
  final StoredAttachment stored;

  @override
  Widget build(BuildContext context) {
    final attachment = stored.attachment;
    final title = attachment.displayName?.trim().isNotEmpty ?? false
        ? attachment.displayName!.trim()
        : _friendlyType(attachment.mimeType);
    return Semantics(
      container: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (selected != null)
              Checkbox(
                value: selected,
                onChanged: onSelected,
                semanticLabel: 'Select $title',
              )
            else
              const Padding(
                padding: EdgeInsets.only(top: AppSpacing.sm),
                child: AppIcon(icon: AppIcons.archive),
              ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    '${formatStorageBytes(attachment.byteSize)} · ${storageStateLabel(attachment.storageState)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (stored.archiveReference case final archive?) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Archive: ${archive.logicalKey}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  if (actionLabel != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    AppButton(
                      label: actionLabel!,
                      onPressed: onAction,
                      variant: AppButtonVariant.tertiary,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _StorageRow extends StatelessWidget {
  const _StorageRow({
    required this.icon,
    required this.label,
    required this.bytes,
  });

  final int bytes;
  final AppIconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
    child: Row(
      children: [
        AppIcon(icon: icon),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Text(label)),
        const SizedBox(width: AppSpacing.md),
        Text(
          formatStorageBytes(bytes),
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ],
    ),
  );
}

String formatStorageBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  final kib = bytes / 1024;
  if (kib < 1024) return '${kib.toStringAsFixed(kib >= 10 ? 0 : 1)} KB';
  final mib = kib / 1024;
  if (mib < 1024) return '${mib.toStringAsFixed(mib >= 10 ? 0 : 1)} MB';
  final gib = mib / 1024;
  return '${gib.toStringAsFixed(gib >= 10 ? 1 : 2)} GB';
}

String storageStateLabel(AttachmentStorageState state) => switch (state) {
  AttachmentStorageState.local => 'On this device',
  AttachmentStorageState.referenced => 'Referenced original',
  AttachmentStorageState.archived => 'Archived original',
  AttachmentStorageState.unavailable => 'Original unavailable',
};

String backupHealthLabel(BackupHealth health, DateTime now) {
  final last = health.lastBackupAt;
  if (!health.verified || last == null) return 'Needs attention';
  if (now.toUtc().difference(last) > const Duration(days: 30)) {
    return 'Not backed up recently';
  }
  if (health.pendingChangesSinceBackup ||
      health.importantItemsWithSingleCopy > 0 ||
      health.itemsWithNoVerifiedCopy > 0) {
    return 'Needs attention';
  }
  return 'Protected';
}

String archivePhaseLabel(ArchivePhase phase) => switch (phase) {
  ArchivePhase.verifyingSource => 'Verifying the original',
  ArchivePhase.preparingPreview => 'Preparing a local preview',
  ArchivePhase.encrypting => 'Encrypting locally',
  ArchivePhase.decrypting => 'Authenticating and decrypting locally',
  ArchivePhase.choosingDestination => 'Waiting for your chosen location',
  ArchivePhase.verifyingArchive => 'Verifying the archive copy',
  ArchivePhase.recordingReference => 'Recording the verified archive',
  ArchivePhase.removingLocalCopy => 'Removing the confirmed local original',
  ArchivePhase.complete => 'Complete',
};

String _friendlyType(String mimeType) {
  if (mimeType.toLowerCase().startsWith('image/')) return 'Managed photo';
  if (mimeType.toLowerCase() == 'application/pdf') return 'Managed PDF';
  return 'Managed attachment';
}
