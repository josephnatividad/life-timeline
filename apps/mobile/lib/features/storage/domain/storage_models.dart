import 'package:life_timeline/shared/domain/model/timeline_models.dart';

enum ArchiveDestinationType { userSelectedFile }

enum ArchiveSourceKind { main, preservedOriginal }

final class ArchiveReference {
  ArchiveReference({
    required this.id,
    required this.attachmentId,
    required this.destinationType,
    required this.logicalKey,
    required this.originalByteSize,
    required this.originalSha256,
    required this.archiveByteSize,
    required this.archiveSha256,
    required this.encryptionAlgorithm,
    required this.formatVersion,
    required DateTime archivedAt,
    required DateTime verifiedAt,
    this.sourceKind = ArchiveSourceKind.main,
  }) : archivedAt = archivedAt.toUtc(),
       verifiedAt = verifiedAt.toUtc() {
    if (id.trim().isEmpty ||
        attachmentId.trim().isEmpty ||
        logicalKey.trim().isEmpty ||
        originalSha256.trim().isEmpty ||
        archiveSha256.trim().isEmpty ||
        encryptionAlgorithm.trim().isEmpty ||
        originalByteSize < 0 ||
        archiveByteSize < 0 ||
        formatVersion < 1 ||
        this.verifiedAt.isBefore(this.archivedAt)) {
      throw ArgumentError('Archive reference metadata is invalid.');
    }
  }

  final int archiveByteSize;
  final String archiveSha256;
  final ArchiveSourceKind sourceKind;
  final DateTime archivedAt;
  final String attachmentId;
  final ArchiveDestinationType destinationType;
  final String encryptionAlgorithm;
  final int formatVersion;
  final String id;
  final String logicalKey;
  final int originalByteSize;
  final String originalSha256;
  final DateTime verifiedAt;
}

final class StoredAttachment {
  const StoredAttachment({
    required this.attachment,
    this.archiveReference,
    this.roles = const {},
  });

  final ArchiveReference? archiveReference;
  final Attachment attachment;
  final Set<AttachmentRole> roles;
}

final class ManagedFileMeasurement {
  const ManagedFileMeasurement({
    required this.attachmentId,
    required this.relativePath,
    required this.exists,
    required this.byteSize,
    this.sha256,
    this.preservedOriginal = false,
  });

  final String attachmentId;
  final int byteSize;
  final bool exists;
  final bool preservedOriginal;
  final String relativePath;
  final String? sha256;
}

final class StorageDuplicateGroup {
  StorageDuplicateGroup({
    required this.sha256,
    required this.byteSize,
    required List<String> attachmentIds,
    required List<String> distinctRelativePaths,
  }) : attachmentIds = List.unmodifiable(attachmentIds),
       distinctRelativePaths = List.unmodifiable(distinctRelativePaths);

  final List<String> attachmentIds;
  final int byteSize;
  final List<String> distinctRelativePaths;
  final String sha256;

  int get reclaimableBytes => distinctRelativePaths.length <= 1
      ? 0
      : byteSize * (distinctRelativePaths.length - 1);

  bool get sharesOnePhysicalFile => distinctRelativePaths.length == 1;
}

final class StorageBreakdown {
  const StorageBreakdown({
    this.photosBytes = 0,
    this.documentsBytes = 0,
    this.thumbnailsBytes = 0,
    this.databaseBytes = 0,
    this.cacheBytes = 0,
    this.otherManagedBytes = 0,
  });

  final int cacheBytes;
  final int databaseBytes;
  final int documentsBytes;
  final int otherManagedBytes;
  final int photosBytes;
  final int thumbnailsBytes;

  int get totalAppOwnedBytes =>
      photosBytes +
      documentsBytes +
      thumbnailsBytes +
      databaseBytes +
      cacheBytes +
      otherManagedBytes;
}

final class StorageInventory {
  StorageInventory({
    required this.breakdown,
    required List<StoredAttachment> attachments,
    required List<ManagedFileMeasurement> managedFiles,
    required List<StorageDuplicateGroup> duplicateGroups,
    required this.archivedContentBytes,
    required this.archivedContentCount,
    required this.referencedContentCount,
    required this.unavailableContentCount,
    required this.missingManagedFileCount,
    required this.reclaimableCacheBytes,
    this.freeDeviceBytes,
  }) : attachments = List.unmodifiable(attachments),
       managedFiles = List.unmodifiable(managedFiles),
       duplicateGroups = List.unmodifiable(duplicateGroups);

  final int archivedContentBytes;
  final int archivedContentCount;
  final List<StoredAttachment> attachments;
  final StorageBreakdown breakdown;
  final List<StorageDuplicateGroup> duplicateGroups;
  final int? freeDeviceBytes;
  final List<ManagedFileMeasurement> managedFiles;
  final int missingManagedFileCount;
  final int reclaimableCacheBytes;
  final int referencedContentCount;
  final int unavailableContentCount;

  int get duplicateBytes =>
      duplicateGroups.fold(0, (total, group) => total + group.reclaimableBytes);
}

enum ProtectionLevel { protected, singleCopy, noVerifiedCopy }

final class AttachmentProtection {
  const AttachmentProtection({
    required this.attachmentId,
    required this.level,
    required this.verifiedCopyCount,
    required this.hasLocalCopy,
    required this.hasArchiveCopy,
    required this.hasBackupCopy,
  });

  final String attachmentId;
  final bool hasArchiveCopy;
  final bool hasBackupCopy;
  final bool hasLocalCopy;
  final ProtectionLevel level;
  final int verifiedCopyCount;
}

final class CopyProtectionSummary {
  CopyProtectionSummary({required List<AttachmentProtection> items})
    : items = List.unmodifiable(items);

  final List<AttachmentProtection> items;

  int get importantItemsWithSingleCopy =>
      items.where((item) => item.verifiedCopyCount == 1).length;

  int get itemsWithNoVerifiedCopy =>
      items.where((item) => item.verifiedCopyCount == 0).length;

  int get archiveItemsWithSingleCopy => items
      .where((item) => item.hasArchiveCopy && item.verifiedCopyCount == 1)
      .length;
}

final class BackupProtectionSnapshot {
  const BackupProtectionSnapshot({
    required this.verified,
    required this.pendingChanges,
    this.lastBackupAt,
  });

  final DateTime? lastBackupAt;
  final bool pendingChanges;
  final bool verified;
}

enum StorageWarningLevel { healthy, attention, critical }

final class StorageHealth {
  const StorageHealth({
    required this.appStorageBytes,
    required this.reclaimableCacheBytes,
    required this.duplicateBytes,
    required this.archivedBytes,
    required this.warningLevel,
    required this.recommendedAction,
    this.freeDeviceBytes,
  });

  final int appStorageBytes;
  final int archivedBytes;
  final int duplicateBytes;
  final int? freeDeviceBytes;
  final String recommendedAction;
  final int reclaimableCacheBytes;
  final StorageWarningLevel warningLevel;
}

enum ArchivePhase {
  verifyingSource,
  preparingPreview,
  encrypting,
  decrypting,
  choosingDestination,
  verifyingArchive,
  recordingReference,
  removingLocalCopy,
  complete,
}

final class ArchiveProgress {
  const ArchiveProgress({required this.phase, this.detail});

  final String? detail;
  final ArchivePhase phase;
}

final class ArchiveResult {
  const ArchiveResult({
    required this.reference,
    required this.localOriginalRemoved,
    required this.thumbnailRetained,
  });

  final bool localOriginalRemoved;
  final ArchiveReference reference;
  final bool thumbnailRetained;
}

enum ArchiveRetrievalOutcome { restored, canceled, unavailable }

final class ArchiveRetrievalResult {
  const ArchiveRetrievalResult({
    required this.outcome,
    this.restoredRelativePath,
  });

  final ArchiveRetrievalOutcome outcome;
  final String? restoredRelativePath;
}

final class ArchiveFailure implements Exception {
  const ArchiveFailure(this.code);

  final String code;

  @override
  String toString() => 'ArchiveFailure($code)';
}

enum ImageOptimizationOutcome {
  optimized,
  alreadyEfficient,
  unsupported,
  missing,
}

final class ImageOptimizationResult {
  const ImageOptimizationResult({
    required this.outcome,
    required this.beforeBytes,
    required this.afterBytes,
    required this.originalPreserved,
    required this.originalRemoved,
  });

  final int afterBytes;
  final int beforeBytes;
  final ImageOptimizationOutcome outcome;
  final bool originalPreserved;
  final bool originalRemoved;

  int get savedBytes => beforeBytes > afterBytes ? beforeBytes - afterBytes : 0;
}

final class StorageCleanupResult {
  const StorageCleanupResult({
    required this.removedBytes,
    required this.removedEntries,
  });

  final int removedBytes;
  final int removedEntries;
}
