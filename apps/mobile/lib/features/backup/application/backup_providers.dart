import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:life_timeline/features/backup/application/automatic_backup_coordinator.dart';
import 'package:life_timeline/features/backup/application/recovery_password_service.dart';
import 'package:life_timeline/features/backup/domain/automatic_backup_models.dart';
import 'package:life_timeline/features/backup/domain/automatic_backup_ports.dart';
import 'package:life_timeline/features/backup/domain/backup_models.dart';
import 'package:life_timeline/features/backup/domain/backup_ports.dart';
import 'package:life_timeline/features/backup/infrastructure/automatic_backup_storage.dart';
import 'package:life_timeline/features/backup/infrastructure/connectivity_backup_policy_checker.dart';
import 'package:life_timeline/features/backup/infrastructure/google_drive_backup_destination.dart';
import 'package:life_timeline/features/backup/infrastructure/local_backup_service.dart';
import 'package:life_timeline/features/backup/infrastructure/platform_backup_adapters.dart';
import 'package:life_timeline/features/backup/infrastructure/secure_backup_health_store.dart';
import 'package:life_timeline/features/backup/infrastructure/workmanager_automatic_backup_scheduler.dart';
import 'package:life_timeline/features/security/application/security_providers.dart';
import 'package:life_timeline/features/security/domain/security_ports.dart';
import 'package:life_timeline/features/security/infrastructure/secure_storage_adapters.dart';
import 'package:life_timeline/shared/crypto/aes_gcm_file_encryption_service.dart';
import 'package:life_timeline/shared/crypto/crypto_models.dart';
import 'package:life_timeline/shared/database/app_database_provider.dart';
import 'package:life_timeline/shared/database/backup/drift_backup_data_source.dart';
import 'package:path/path.dart' as p;

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

final backupFileGatewayProvider = Provider<BackupFileGateway>((ref) {
  return const FilePickerBackupDestination();
});

// Kept as a compatibility alias while restore callers move to the explicit
// file-gateway name. It is not the remote BackupDestination port.
final backupDestinationProvider = backupFileGatewayProvider;

final appVersionProvider = Provider<AppVersionProvider>((ref) {
  return const PackageInfoAppVersionProvider();
});

final backupServiceProvider = Provider<LocalBackupService>((ref) {
  return LocalBackupService(
    ref.watch(backupDataSourceProvider),
    ref.watch(managedAttachmentStorageProvider),
    ref.watch(backupFileGatewayProvider),
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

final driveBackupListProvider = FutureProvider<List<RemoteBackupInfo>>((
  ref,
) async {
  final destination = ref.watch(automaticBackupDestinationProvider);
  final status = await destination.status();
  if (!status.isReady) return const [];
  return destination.listBackups();
});

final googleDriveBackupDestinationProvider =
    Provider<GoogleDriveBackupDestination>(
      (ref) => GoogleDriveBackupDestination(),
    );

final automaticBackupDestinationProvider = Provider<BackupDestination>((ref) {
  return ref.watch(googleDriveBackupDestinationProvider);
});

final automaticBackupAuthorizationProvider =
    Provider<BackupDestinationAuthorization>((ref) {
      return ref.watch(googleDriveBackupDestinationProvider);
    });

final automaticBackupDeviceStoreProvider = Provider<SecureKeyStore>((ref) {
  return const FlutterSecureKeyStore(
    FlutterSecureStorage(
      aOptions: AndroidOptions(migrateWithBackup: false),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
        synchronizable: false,
        accountName: 'life_timeline_automatic_backup_device_only',
      ),
    ),
  );
});

final automaticBackupSettingsStoreProvider =
    Provider<AutomaticBackupSettingsStore>((ref) {
      return SecureAutomaticBackupSettingsStore(
        ref.watch(automaticBackupDeviceStoreProvider),
      );
    });

final automaticBackupCredentialStoreProvider =
    Provider<AutomaticBackupCredentialStore>((ref) {
      return DeviceOnlyAutomaticBackupCredentialStore(
        ref.watch(automaticBackupDeviceStoreProvider),
      );
    });

final backupNetworkPolicyCheckerProvider = Provider<BackupNetworkPolicyChecker>(
  (ref) => ConnectivityBackupPolicyChecker(),
);

final automaticBackupSchedulerProvider = Provider<AutomaticBackupScheduler>(
  (ref) => const WorkmanagerAutomaticBackupScheduler(),
);

final automaticBackupCoordinatorProvider = Provider<AutomaticBackupCoordinator>(
  (ref) => AutomaticBackupCoordinator(
    ref.watch(automaticBackupSettingsStoreProvider),
    ref.watch(automaticBackupCredentialStoreProvider),
    ref.watch(backupDataSourceProvider),
    ref.watch(backupServiceProvider),
    ref.watch(automaticBackupDestinationProvider),
    ref.watch(backupNetworkPolicyCheckerProvider),
    ref.watch(backupHealthStoreProvider),
  ),
);

final automaticBackupControllerProvider =
    AsyncNotifierProvider<AutomaticBackupController, AutomaticBackupViewState>(
      AutomaticBackupController.new,
    );

final class AutomaticBackupViewState {
  const AutomaticBackupViewState({
    required this.settings,
    required this.runState,
    required this.destinationStatus,
  });

  final BackupDestinationStatus destinationStatus;
  final AutomaticBackupRunState runState;
  final AutomaticBackupSettings settings;

  AutomaticBackupViewState copyWith({
    AutomaticBackupSettings? settings,
    AutomaticBackupRunState? runState,
    BackupDestinationStatus? destinationStatus,
  }) => AutomaticBackupViewState(
    settings: settings ?? this.settings,
    runState: runState ?? this.runState,
    destinationStatus: destinationStatus ?? this.destinationStatus,
  );
}

class AutomaticBackupController
    extends AsyncNotifier<AutomaticBackupViewState> {
  @override
  Future<AutomaticBackupViewState> build() async {
    final store = ref.watch(automaticBackupSettingsStoreProvider);
    return AutomaticBackupViewState(
      settings: await store.loadSettings(),
      runState: await store.loadRunState(),
      destinationStatus: await ref
          .watch(automaticBackupDestinationProvider)
          .status(),
    );
  }

  Future<BackupDestinationStatus> authorize() async {
    final status = await ref
        .read(automaticBackupAuthorizationProvider)
        .authorize();
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(destinationStatus: status));
    }
    return status;
  }

  Future<void> enable(String recoveryPassword) async {
    final current = state.value;
    if (current == null) {
      throw const BackupFailure('automatic_backup_settings_unavailable');
    }
    final status = await ref.read(automaticBackupDestinationProvider).status();
    if (!status.isReady) {
      throw const BackupFailure('drive_authorization_required');
    }
    await ref
        .read(automaticBackupCredentialStoreProvider)
        .save(recoveryPassword);
    try {
      await ref
          .read(recoveryPasswordServiceProvider)
          .configure(recoveryPassword);
      await ref
          .read(securityControllerProvider.notifier)
          .setRecoveryConfigured(true);
      final settings = current.settings.copyWith(enabled: true);
      await ref
          .read(automaticBackupSettingsStoreProvider)
          .saveSettings(settings);
      await ref.read(automaticBackupSchedulerProvider).configure(settings);
      await ref.read(automaticBackupSchedulerProvider).scheduleSoon(settings);
      state = AsyncData(
        current.copyWith(settings: settings, destinationStatus: status),
      );
    } on Object {
      await ref.read(automaticBackupCredentialStoreProvider).delete();
      final disabled = current.settings.copyWith(enabled: false);
      await ref
          .read(automaticBackupSettingsStoreProvider)
          .saveSettings(disabled);
      try {
        await ref.read(automaticBackupSchedulerProvider).configure(disabled);
      } on Object {
        // The persisted disabled flag remains the execution gate.
      }
      rethrow;
    }
  }

  Future<void> disable() async {
    final current = state.value;
    if (current == null) return;
    final settings = current.settings.copyWith(enabled: false);
    await ref.read(automaticBackupSettingsStoreProvider).saveSettings(settings);
    try {
      await ref.read(automaticBackupSchedulerProvider).configure(settings);
    } on Object {
      // The persisted disabled state gates any stale platform task.
    }
    await ref.read(automaticBackupCredentialStoreProvider).delete();
    state = AsyncData(current.copyWith(settings: settings));
  }

  Future<void> disconnect() async {
    await disable();
    await ref.read(automaticBackupAuthorizationProvider).disconnect();
    final current = state.value;
    if (current != null) {
      state = AsyncData(
        current.copyWith(
          destinationStatus: const BackupDestinationStatus(
            availability: BackupDestinationAvailability.needsAuthorization,
          ),
        ),
      );
    }
  }

  Future<void> updateSettings(AutomaticBackupSettings settings) async {
    final current = state.value;
    if (current == null) return;
    await ref.read(automaticBackupSettingsStoreProvider).saveSettings(settings);
    await ref.read(automaticBackupSchedulerProvider).configure(settings);
    state = AsyncData(current.copyWith(settings: settings));
  }

  Future<AutomaticBackupRunResult> runNow() async {
    final current = state.value;
    if (current == null) return AutomaticBackupRunResult.failed;
    final result = await ref
        .read(automaticBackupCoordinatorProvider)
        .run(
          force: true,
          onState: (runState) {
            final latest = state.value;
            if (latest != null) {
              state = AsyncData(latest.copyWith(runState: runState));
            }
          },
        );
    ref.invalidate(backupHealthProvider);
    return result;
  }
}

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
  BackupRestoreService? _backupServiceForDisposal;
  String? _downloadedSourceForDisposal;
  PreparedRestore? _preparedForDisposal;

  @override
  RestoreOperationState build() {
    ref.onDispose(() {
      final backupService = _backupServiceForDisposal;
      final prepared = _preparedForDisposal;
      if (backupService != null && prepared != null) {
        unawaited(backupService.discard(prepared));
      }
      final downloaded = _downloadedSourceForDisposal;
      if (downloaded != null) {
        unawaited(_deleteDownloadedSource(downloaded));
      }
    });
    return const RestoreOperationState();
  }

  Future<bool> chooseAndInspect() async {
    state = const RestoreOperationState(
      stage: RestoreOperationStage.inspecting,
    );
    try {
      final path = await ref.read(backupDestinationProvider).chooseImportPath();
      if (path == null) {
        state = const RestoreOperationState();
        return false;
      }
      return _inspectPath(path);
    } on BackupFailure catch (error) {
      state = RestoreOperationState(errorCode: error.code);
      return false;
    } on CryptoFailure catch (error) {
      state = RestoreOperationState(errorCode: error.code);
      return false;
    } on Object {
      state = const RestoreOperationState(errorCode: 'backup_unreadable');
      return false;
    }
  }

  Future<bool> downloadAndInspect(RemoteBackupInfo backup) async {
    state = const RestoreOperationState(
      stage: RestoreOperationStage.inspecting,
    );
    try {
      final temporaryRoot = await ref
          .read(managedAttachmentStorageProvider)
          .temporaryRootPath();
      final directory = Directory(p.join(temporaryRoot, 'drive-restore'));
      await directory.create(recursive: true);
      final destinationPath = p.join(
        directory.path,
        'selected-${DateTime.now().toUtc().microsecondsSinceEpoch}.timelinebackup',
      );
      final downloaded = await ref
          .read(automaticBackupDestinationProvider)
          .download(backup, destinationPath: destinationPath);
      if (!downloaded.verified) {
        throw const BackupFailure('drive_download_verification_failed');
      }
      _downloadedSourceForDisposal = downloaded.path;
      return _inspectPath(downloaded.path);
    } on BackupFailure catch (error) {
      state = RestoreOperationState(errorCode: error.code);
      return false;
    } on Object {
      state = const RestoreOperationState(errorCode: 'drive_download_failed');
      return false;
    }
  }

  Future<bool> _inspectPath(String path) async {
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
      final backupService = ref.read(backupServiceProvider);
      final prepared = await backupService.prepare(
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
      _backupServiceForDisposal = backupService;
      _preparedForDisposal = prepared;
      final downloaded = _downloadedSourceForDisposal;
      if (downloaded != null) {
        await _deleteDownloadedSource(downloaded);
        _downloadedSourceForDisposal = null;
      }
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
      _backupServiceForDisposal = null;
      _preparedForDisposal = null;
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
    _backupServiceForDisposal = null;
    _preparedForDisposal = null;
    final downloaded = _downloadedSourceForDisposal;
    if (downloaded != null) {
      await _deleteDownloadedSource(downloaded);
      _downloadedSourceForDisposal = null;
    }
    state = const RestoreOperationState();
  }
}

Future<void> _deleteDownloadedSource(String path) async {
  final file = File(path);
  if (await file.exists()) await file.delete();
}
