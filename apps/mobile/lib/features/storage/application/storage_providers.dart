import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_timeline/features/backup/application/backup_providers.dart';
import 'package:life_timeline/features/backup/domain/backup_models.dart';
import 'package:life_timeline/features/security/application/security_providers.dart';
import 'package:life_timeline/features/storage/application/storage_health_services.dart';
import 'package:life_timeline/features/storage/domain/storage_models.dart';
import 'package:life_timeline/features/storage/domain/storage_ports.dart';
import 'package:life_timeline/features/storage/infrastructure/drift_storage_repository.dart';
import 'package:life_timeline/features/storage/infrastructure/file_picker_archive_storage.dart';
import 'package:life_timeline/features/storage/infrastructure/local_archive_service.dart';
import 'package:life_timeline/features/storage/infrastructure/local_image_optimization_service.dart';
import 'package:life_timeline/features/storage/infrastructure/local_storage_inventory_service.dart';
import 'package:life_timeline/shared/crypto/aes_gcm_file_encryption_service.dart';
import 'package:life_timeline/shared/database/app_database_provider.dart';

final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  return DriftStorageRepository(ref.watch(appDatabaseProvider));
});

final storagePathProvider = Provider<StoragePathProvider>((ref) {
  return const PathProviderStoragePaths();
});

final storageInventoryServiceProvider = Provider<StorageInventoryService>((
  ref,
) {
  return FileSystemStorageInventoryService(
    ref.watch(storageRepositoryProvider),
    ref.watch(storagePathProvider),
  );
});

final storageCleanupServiceProvider = Provider<StorageCleanupService>((ref) {
  return ScopedStorageCleanupService(ref.watch(storagePathProvider));
});

final archiveStorageProvider = Provider<ArchiveStorage>((ref) {
  return const FilePickerArchiveStorage();
});

final archiveServiceProvider = Provider<ArchiveService>((ref) {
  return LocalArchiveService(
    ref.watch(storageRepositoryProvider),
    ref.watch(archiveStorageProvider),
    AesGcmFileEncryptionService(
      ref.watch(passwordKeyDeriverProvider),
      magic: 'LTARCH01',
    ),
    ref.watch(storagePathProvider),
  );
});

final imageOptimizationServiceProvider = Provider<ImageOptimizationService>((
  ref,
) {
  return LocalImageOptimizationService(
    ref.watch(storageRepositoryProvider),
    ref.watch(storagePathProvider),
  );
});

final copyProtectionServiceProvider = Provider<CopyProtectionService>((ref) {
  return const DefaultCopyProtectionService();
});

final storageHealthServiceProvider = Provider<StorageHealthService>((ref) {
  return const DefaultStorageHealthService();
});

final storageOverviewProvider = FutureProvider<StorageOverview>((ref) async {
  final inventory = await ref.watch(storageInventoryServiceProvider).analyze();
  final recordedBackup = await ref.watch(backupHealthStoreProvider).load();
  final latestChange = await ref
      .watch(storageRepositoryProvider)
      .latestContentChangeAt();
  final pending =
      recordedBackup.lastBackupAt == null ||
      (latestChange?.isAfter(recordedBackup.lastBackupAt!) ?? false);
  final protection = ref
      .watch(copyProtectionServiceProvider)
      .calculate(
        inventory: inventory,
        backup: BackupProtectionSnapshot(
          verified: recordedBackup.verified,
          pendingChanges: pending,
          lastBackupAt: recordedBackup.lastBackupAt,
        ),
      );
  final effectiveBackup = recordedBackup.copyWith(
    pendingChangesSinceBackup: pending,
    importantItemsWithSingleCopy: protection.importantItemsWithSingleCopy,
    archiveItemsWithSingleCopy: protection.archiveItemsWithSingleCopy,
    itemsWithNoVerifiedCopy: protection.itemsWithNoVerifiedCopy,
  );
  final health = ref
      .watch(storageHealthServiceProvider)
      .calculate(inventory: inventory, protection: protection);
  return StorageOverview(
    inventory: inventory,
    protection: protection,
    health: health,
    backupHealth: effectiveBackup,
  );
});

final class StorageOverview {
  const StorageOverview({
    required this.inventory,
    required this.protection,
    required this.health,
    required this.backupHealth,
  });

  final BackupHealth backupHealth;
  final StorageHealth health;
  final StorageInventory inventory;
  final CopyProtectionSummary protection;
}

enum StorageOperationKind { archive, retrieve, cleanup, optimize }

final class StorageOperationState {
  const StorageOperationState({
    this.running = false,
    this.kind,
    this.progress,
    this.completedMessage,
    this.errorCode,
  });

  final String? completedMessage;
  final String? errorCode;
  final StorageOperationKind? kind;
  final ArchiveProgress? progress;
  final bool running;
}

final storageOperationControllerProvider =
    NotifierProvider<StorageOperationController, StorageOperationState>(
      StorageOperationController.new,
    );

final class StorageOperationController extends Notifier<StorageOperationState> {
  @override
  StorageOperationState build() => const StorageOperationState();

  Future<void> archiveAttachments({
    required List<String> attachmentIds,
    required String recoveryPassword,
    required bool removeLocalOriginals,
  }) async {
    if (state.running || attachmentIds.isEmpty) return;
    state = const StorageOperationState(
      running: true,
      kind: StorageOperationKind.archive,
    );
    var archived = 0;
    var removed = 0;
    try {
      for (final id in attachmentIds) {
        final result = await ref
            .read(archiveServiceProvider)
            .archive(
              attachmentId: id,
              recoveryPassword: recoveryPassword,
              removeLocalOriginal: removeLocalOriginals,
              onProgress: (progress) {
                state = StorageOperationState(
                  running: true,
                  kind: StorageOperationKind.archive,
                  progress: progress,
                );
              },
            );
        if (result == null) {
          state = const StorageOperationState();
          return;
        }
        archived++;
        if (result.localOriginalRemoved) removed++;
      }
      _refresh();
      state = StorageOperationState(
        kind: StorageOperationKind.archive,
        completedMessage: removeLocalOriginals
            ? '$archived archived, $removed local originals removed.'
            : '$archived verified archive ${archived == 1 ? 'copy' : 'copies'} created.',
      );
    } on ArchiveFailure catch (error) {
      state = StorageOperationState(
        kind: StorageOperationKind.archive,
        errorCode: error.code,
      );
    } on Object {
      state = const StorageOperationState(
        kind: StorageOperationKind.archive,
        errorCode: 'archive_failed',
      );
    }
  }

  Future<void> retrieve({
    required String attachmentId,
    required String recoveryPassword,
  }) async {
    if (state.running) return;
    state = const StorageOperationState(
      running: true,
      kind: StorageOperationKind.retrieve,
    );
    try {
      final result = await ref
          .read(archiveServiceProvider)
          .retrieve(
            attachmentId: attachmentId,
            recoveryPassword: recoveryPassword,
            onProgress: (progress) {
              state = StorageOperationState(
                running: true,
                kind: StorageOperationKind.retrieve,
                progress: progress,
              );
            },
          );
      if (result.outcome == ArchiveRetrievalOutcome.canceled) {
        state = const StorageOperationState();
        return;
      }
      if (result.outcome == ArchiveRetrievalOutcome.unavailable) {
        state = const StorageOperationState(
          kind: StorageOperationKind.retrieve,
          errorCode: 'archive_destination_unavailable',
        );
        return;
      }
      _refresh();
      state = const StorageOperationState(
        kind: StorageOperationKind.retrieve,
        completedMessage: 'Original restored to this device.',
      );
    } on ArchiveFailure catch (error) {
      state = StorageOperationState(
        kind: StorageOperationKind.retrieve,
        errorCode: error.code,
      );
    } on Object {
      state = const StorageOperationState(
        kind: StorageOperationKind.retrieve,
        errorCode: 'archive_retrieval_failed',
      );
    }
  }

  Future<void> cleanup() async {
    if (state.running) return;
    state = const StorageOperationState(
      running: true,
      kind: StorageOperationKind.cleanup,
    );
    try {
      final result = await ref
          .read(storageCleanupServiceProvider)
          .cleanStaleTemporaryFiles(DateTime.now().toUtc());
      _refresh();
      state = StorageOperationState(
        kind: StorageOperationKind.cleanup,
        completedMessage:
            '${result.removedEntries} temporary ${result.removedEntries == 1 ? 'file' : 'files'} removed.',
      );
    } on Object {
      state = const StorageOperationState(
        kind: StorageOperationKind.cleanup,
        errorCode: 'cleanup_failed',
      );
    }
  }

  Future<void> optimize({
    required String attachmentId,
    required bool preserveOriginal,
  }) async {
    if (state.running) return;
    state = const StorageOperationState(
      running: true,
      kind: StorageOperationKind.optimize,
    );
    try {
      final result = await ref
          .read(imageOptimizationServiceProvider)
          .optimize(attachmentId, preserveOriginal: preserveOriginal);
      _refresh();
      state = StorageOperationState(
        kind: StorageOperationKind.optimize,
        completedMessage: switch (result.outcome) {
          ImageOptimizationOutcome.optimized =>
            'Optimized copy created and verified.',
          ImageOptimizationOutcome.alreadyEfficient =>
            'This image is already storage-efficient.',
          ImageOptimizationOutcome.unsupported =>
            'This image is not eligible for safe optimization.',
          ImageOptimizationOutcome.missing =>
            'The managed image is currently unavailable.',
        },
      );
    } on Object {
      state = const StorageOperationState(
        kind: StorageOperationKind.optimize,
        errorCode: 'optimization_failed',
      );
    }
  }

  void reset() => state = const StorageOperationState();

  void _refresh() {
    ref.invalidate(storageOverviewProvider);
    ref.invalidate(backupHealthProvider);
  }
}
