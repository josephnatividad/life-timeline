import 'package:life_timeline/features/storage/domain/storage_models.dart';
import 'package:life_timeline/features/storage/domain/storage_ports.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

final class DefaultCopyProtectionService implements CopyProtectionService {
  const DefaultCopyProtectionService();

  @override
  CopyProtectionSummary calculate({
    required StorageInventory inventory,
    required BackupProtectionSnapshot backup,
  }) {
    final availablePaths = {
      for (final file in inventory.managedFiles)
        if (file.exists) file.relativePath,
    };
    return CopyProtectionSummary(
      items: [
        for (final stored in inventory.attachments)
          _protection(stored, availablePaths, backup),
      ],
    );
  }

  AttachmentProtection _protection(
    StoredAttachment stored,
    Set<String> availablePaths,
    BackupProtectionSnapshot backup,
  ) {
    final attachment = stored.attachment;
    final localPath = attachment.relativePath;
    final hasLocal =
        localPath != null &&
        !localPath.startsWith('/') &&
        availablePaths.contains(localPath);
    final hasArchive = stored.archiveReference != null;
    final hasBackup = _backupContainsOriginal(stored, backup);
    final count = [
      hasLocal,
      hasArchive,
      hasBackup,
    ].where((value) => value).length;
    return AttachmentProtection(
      attachmentId: attachment.metadata.id,
      level: switch (count) {
        0 => ProtectionLevel.noVerifiedCopy,
        1 => ProtectionLevel.singleCopy,
        _ => ProtectionLevel.protected,
      },
      verifiedCopyCount: count,
      hasLocalCopy: hasLocal,
      hasArchiveCopy: hasArchive,
      hasBackupCopy: hasBackup,
    );
  }

  bool _backupContainsOriginal(
    StoredAttachment stored,
    BackupProtectionSnapshot backup,
  ) {
    final backedUpAt = backup.lastBackupAt;
    if (!backup.verified || backedUpAt == null) return false;
    final attachment = stored.attachment;
    if (attachment.storageState == AttachmentStorageState.referenced ||
        attachment.storageState == AttachmentStorageState.unavailable ||
        attachment.metadata.createdAt.isAfter(backedUpAt)) {
      return false;
    }
    if (attachment.storageState == AttachmentStorageState.local) {
      if (!attachment.metadata.updatedAt.isAfter(backedUpAt)) return true;
      final archivedAt = stored.archiveReference?.archivedAt;
      return archivedAt != null &&
          archivedAt.isAfter(backedUpAt) &&
          !attachment.metadata.createdAt.isAfter(backedUpAt);
    }
    final archivedAt = stored.archiveReference?.archivedAt;
    return archivedAt != null && archivedAt.isAfter(backedUpAt);
  }
}

final class DefaultStorageHealthService implements StorageHealthService {
  const DefaultStorageHealthService();

  @override
  StorageHealth calculate({
    required StorageInventory inventory,
    required CopyProtectionSummary protection,
  }) {
    final warning = protection.itemsWithNoVerifiedCopy > 0
        ? StorageWarningLevel.critical
        : protection.importantItemsWithSingleCopy > 0 ||
              inventory.missingManagedFileCount > 0
        ? StorageWarningLevel.attention
        : StorageWarningLevel.healthy;
    final action = switch (warning) {
      StorageWarningLevel.critical =>
        'Reconnect unavailable originals before removing any local files.',
      StorageWarningLevel.attention =>
        'Create a verified backup before archiving more originals.',
      StorageWarningLevel.healthy =>
        inventory.reclaimableCacheBytes > 0
            ? 'Temporary files can be cleaned safely.'
            : 'No urgent storage action is needed.',
    };
    return StorageHealth(
      appStorageBytes: inventory.breakdown.totalAppOwnedBytes,
      freeDeviceBytes: inventory.freeDeviceBytes,
      reclaimableCacheBytes: inventory.reclaimableCacheBytes,
      duplicateBytes: inventory.duplicateBytes,
      archivedBytes: inventory.archivedContentBytes,
      warningLevel: warning,
      recommendedAction: action,
    );
  }
}
