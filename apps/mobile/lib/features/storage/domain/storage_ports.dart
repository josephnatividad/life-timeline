import 'package:life_timeline/features/storage/domain/storage_models.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

abstract interface class StorageRepository {
  Future<List<StoredAttachment>> attachments();
  Future<StoredAttachment?> attachmentById(String id);
  Future<DateTime?> latestContentChangeAt();

  Future<void> saveVerifiedArchive(
    ArchiveReference reference, {
    String? thumbnailRelativePath,
  });
  Future<void> markArchiveRemovalStarted(String attachmentId, DateTime at);
  Future<void> completeArchiveRemoval(
    String attachmentId,
    DateTime at, {
    required ArchiveSourceKind sourceKind,
  });
  Future<void> revertArchiveRemoval(String attachmentId, DateTime at);
  Future<void> restoreArchivedAttachment({
    required String attachmentId,
    required String relativePath,
    required int byteSize,
    required String checksum,
    required ArchiveSourceKind sourceKind,
    required DateTime at,
  });
  Future<void> updateOptimizedAttachment(Attachment attachment);
}

abstract interface class StoragePathProvider {
  Future<String> attachmentRootPath();
  Future<String> applicationSupportPath();
  Future<String> applicationDocumentsPath();
  Future<String> temporaryPath();
}

abstract interface class StorageInventoryService {
  Future<StorageInventory> analyze();
}

abstract interface class StorageCleanupService {
  Future<StorageCleanupResult> cleanStaleTemporaryFiles(DateTime now);
}

abstract interface class ImageOptimizationService {
  Future<ImageOptimizationResult> optimize(
    String attachmentId, {
    required bool preserveOriginal,
  });
}

final class ArchiveDestinationReceipt {
  const ArchiveDestinationReceipt({
    required this.logicalKey,
    required this.verified,
  });

  final String logicalKey;
  final bool verified;
}

abstract interface class ArchiveStorage {
  Future<ArchiveDestinationReceipt?> saveArchive({
    required String sourcePath,
    required String suggestedName,
    required String expectedSha256,
  });

  Future<String?> chooseArchiveForRetrieval(ArchiveReference reference);
}

abstract interface class ArchiveService {
  Future<ArchiveResult?> archive({
    required String attachmentId,
    required String recoveryPassword,
    required bool removeLocalOriginal,
    required void Function(ArchiveProgress progress) onProgress,
  });

  Future<ArchiveRetrievalResult> retrieve({
    required String attachmentId,
    required String recoveryPassword,
    required void Function(ArchiveProgress progress) onProgress,
  });
}

abstract interface class CopyProtectionService {
  CopyProtectionSummary calculate({
    required StorageInventory inventory,
    required BackupProtectionSnapshot backup,
  });
}

abstract interface class StorageHealthService {
  StorageHealth calculate({
    required StorageInventory inventory,
    required CopyProtectionSummary protection,
  });
}
