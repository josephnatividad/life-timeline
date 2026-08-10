import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_timeline/features/backup/application/recovery_password_service.dart';
import 'package:life_timeline/features/backup/domain/backup_models.dart';
import 'package:life_timeline/features/backup/domain/backup_ports.dart';
import 'package:life_timeline/features/backup/infrastructure/local_backup_service.dart';
import 'package:life_timeline/features/backup/infrastructure/platform_backup_adapters.dart';
import 'package:life_timeline/features/backup/infrastructure/secure_backup_health_store.dart';
import 'package:life_timeline/features/security/application/security_providers.dart';
import 'package:life_timeline/shared/crypto/aes_gcm_file_encryption_service.dart';
import 'package:life_timeline/shared/crypto/crypto_models.dart';
import 'package:life_timeline/shared/database/app_database_provider.dart';
import 'package:life_timeline/shared/database/backup/drift_backup_data_source.dart';

final encryptionServiceProvider = Provider<EncryptionService>((ref) {
  return AesGcmFileEncryptionService(ref.watch(passwordKeyDeriverProvider));
});

final backupDataSourceProvider = Provider<BackupDataSource>((ref) {
  return DriftBackupDataSource(ref.watch(appDatabaseProvider));
});

final managedAttachmentStorageProvider = Provider<ManagedAttachmentStorage>((
  ref,
) {
  return const PathProviderManagedAttachmentStorage();
});

final backupDestinationProvider = Provider<BackupDestination>((ref) {
  return const FilePickerBackupDestination();
});

final appVersionProvider = Provider<AppVersionProvider>((ref) {
  return const PackageInfoAppVersionProvider();
});

final backupServiceProvider = Provider<LocalBackupService>((ref) {
  return LocalBackupService(
    ref.watch(backupDataSourceProvider),
    ref.watch(managedAttachmentStorageProvider),
    ref.watch(backupDestinationProvider),
    ref.watch(encryptionServiceProvider),
    ref.watch(appVersionProvider),
  );
});

final recoveryPasswordServiceProvider = Provider<RecoveryPasswordService>((
  ref,
) {
  return RecoveryPasswordService(
    ref.watch(secureKeyStoreProvider),
    ref.watch(passwordKeyDeriverProvider),
  );
});

final backupHealthStoreProvider = Provider<BackupHealthStore>((ref) {
  return SecureBackupHealthStore(ref.watch(secureKeyStoreProvider));
});

final backupHealthProvider = FutureProvider<BackupHealth>((ref) {
  return ref.watch(backupHealthStoreProvider).load();
});

final backupControllerProvider =
    NotifierProvider<BackupController, BackupOperationState>(
      BackupController.new,
    );

final restoreControllerProvider =
    NotifierProvider<RestoreController, RestoreOperationState>(
      RestoreController.new,
    );

final class BackupOperationState {
  const BackupOperationState({
    this.progress,
    this.result,
    this.errorCode,
    this.running = false,
    this.canceled = false,
  });

  final bool canceled;
  final String? errorCode;
  final BackupProgress? progress;
  final BackupResult? result;
  final bool running;
}

final class BackupController extends Notifier<BackupOperationState> {
  @override
  BackupOperationState build() => const BackupOperationState();

  Future<void> start(String password) async {
    if (state.running) {
      return;
    }
    state = const BackupOperationState(running: true);
    try {
      final result = await ref
          .read(backupServiceProvider)
          .create(
            recoveryPassword: password,
            onProgress: (progress) {
              state = BackupOperationState(running: true, progress: progress);
            },
          );
      if (result == null) {
        state = const BackupOperationState(canceled: true);
        return;
      }
      await ref.read(recoveryPasswordServiceProvider).configure(password);
      await ref
          .read(securityControllerProvider.notifier)
          .setRecoveryConfigured(true);
      await ref
          .read(backupHealthStoreProvider)
          .save(
            BackupHealth(
              lastBackupAt: result.createdAt,
              destinationType: BackupDestinationType.localFile,
              verified: result.verified,
              backupSize: result.byteSize,
              pendingChangesSinceBackup: false,
              recoveryConfigured: true,
            ),
          );
      ref.invalidate(backupHealthProvider);
      state = BackupOperationState(result: result);
    } on BackupFailure catch (error) {
      state = BackupOperationState(errorCode: error.code);
    } on CryptoFailure catch (error) {
      state = BackupOperationState(errorCode: error.code);
    } on Object {
      state = const BackupOperationState(errorCode: 'backup_failed');
    }
  }

  void reset() => state = const BackupOperationState();
}

enum RestoreOperationStage {
  idle,
  inspecting,
  preparing,
  ready,
  committing,
  complete,
}

final class RestoreOperationState {
  const RestoreOperationState({
    this.stage = RestoreOperationStage.idle,
    this.sourcePath,
    this.header,
    this.progress,
    this.prepared,
    this.existingData = false,
    this.errorCode,
  });

  final String? errorCode;
  final bool existingData;
  final EncryptedContainerHeader? header;
  final PreparedRestore? prepared;
  final RestoreProgress? progress;
  final String? sourcePath;
  final RestoreOperationStage stage;
}

final class RestoreController extends Notifier<RestoreOperationState> {
  @override
  RestoreOperationState build() {
    ref.onDispose(() {
      final prepared = state.prepared;
      if (prepared != null && state.stage != RestoreOperationStage.complete) {
        unawaited(ref.read(backupServiceProvider).discard(prepared));
      }
    });
    return const RestoreOperationState();
  }

  Future<bool> chooseAndInspect() async {
    state = const RestoreOperationState(
      stage: RestoreOperationStage.inspecting,
    );
    final path = await ref.read(backupDestinationProvider).chooseImportPath();
    if (path == null) {
      state = const RestoreOperationState();
      return false;
    }
    try {
      final header = await ref.read(backupServiceProvider).inspect(path);
      if (header.databaseSchemaVersion >
          ref.read(backupDataSourceProvider).schemaVersion) {
        state = const RestoreOperationState(
          errorCode: 'newer_backup_not_supported',
        );
        return false;
      }
      state = RestoreOperationState(
        sourcePath: path,
        header: header,
        stage: RestoreOperationStage.idle,
      );
      return true;
    } on CryptoFailure catch (error) {
      state = RestoreOperationState(errorCode: error.code);
      return false;
    } on Object {
      state = const RestoreOperationState(errorCode: 'backup_unreadable');
      return false;
    }
  }

  Future<void> prepare(String password) async {
    final path = state.sourcePath;
    final header = state.header;
    if (path == null || header == null) {
      state = const RestoreOperationState(errorCode: 'backup_not_selected');
      return;
    }
    state = RestoreOperationState(
      sourcePath: path,
      header: header,
      stage: RestoreOperationStage.preparing,
    );
    try {
      final prepared = await ref
          .read(backupServiceProvider)
          .prepare(
            path: path,
            recoveryPassword: password,
            onProgress: (progress) {
              state = RestoreOperationState(
                sourcePath: path,
                header: header,
                progress: progress,
                stage: RestoreOperationStage.preparing,
              );
            },
          );
      final existing = await ref.read(backupDataSourceProvider).hasUserData();
      state = RestoreOperationState(
        sourcePath: path,
        header: header,
        prepared: prepared,
        existingData: existing,
        stage: RestoreOperationStage.ready,
      );
    } on CryptoFailure {
      state = RestoreOperationState(
        sourcePath: path,
        header: header,
        errorCode: 'wrong_password_or_damaged_backup',
      );
    } on BackupFailure catch (error) {
      state = RestoreOperationState(
        sourcePath: path,
        header: header,
        errorCode: error.code,
      );
    } on Object {
      state = RestoreOperationState(
        sourcePath: path,
        header: header,
        errorCode: 'restore_preparation_failed',
      );
    }
  }

  Future<void> commit({required bool replaceExisting}) async {
    final prepared = state.prepared;
    if (prepared == null) {
      state = const RestoreOperationState(errorCode: 'restore_not_prepared');
      return;
    }
    state = RestoreOperationState(
      prepared: prepared,
      existingData: state.existingData,
      stage: RestoreOperationStage.committing,
    );
    try {
      await ref
          .read(backupServiceProvider)
          .commit(
            prepared,
            replaceExisting: replaceExisting,
            onProgress: (progress) {
              state = RestoreOperationState(
                prepared: prepared,
                existingData: state.existingData,
                progress: progress,
                stage: RestoreOperationStage.committing,
              );
            },
          );
      state = RestoreOperationState(
        prepared: prepared,
        stage: RestoreOperationStage.complete,
      );
      ref.invalidate(timelineRepositoryProvider);
      ref.invalidate(memoryCandidateRepositoryProvider);
      ref.invalidate(backupHealthProvider);
    } on BackupFailure catch (error) {
      state = RestoreOperationState(
        prepared: prepared,
        existingData: state.existingData,
        errorCode: error.code,
      );
    } on Object {
      state = RestoreOperationState(
        prepared: prepared,
        existingData: state.existingData,
        errorCode: 'restore_failed',
      );
    }
  }

  Future<void> reset() async {
    final prepared = state.prepared;
    if (prepared != null && state.stage != RestoreOperationStage.complete) {
      await ref.read(backupServiceProvider).discard(prepared);
    }
    state = const RestoreOperationState();
  }
}
