import 'package:life_timeline/features/backup/domain/automatic_backup_models.dart';
import 'package:life_timeline/features/backup/domain/automatic_backup_ports.dart';
import 'package:life_timeline/features/backup/domain/backup_models.dart';
import 'package:life_timeline/features/backup/domain/backup_ports.dart';
import 'package:life_timeline/shared/crypto/crypto_models.dart';

final class AutomaticBackupCoordinator {
  AutomaticBackupCoordinator(
    this._settingsStore,
    this._credentialStore,
    this._dataSource,
    this._artifactBuilder,
    this._destination,
    this._network,
    this._healthStore, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final BackupArtifactBuilder _artifactBuilder;
  final AutomaticBackupCredentialStore _credentialStore;
  final BackupDataSource _dataSource;
  final BackupDestination _destination;
  final BackupHealthStore _healthStore;
  final BackupNetworkPolicyChecker _network;
  final DateTime Function() _now;
  final AutomaticBackupSettingsStore _settingsStore;
  bool _running = false;

  Future<AutomaticBackupRunResult> run({
    bool force = false,
    void Function(AutomaticBackupRunState state)? onState,
  }) async {
    if (_running) return AutomaticBackupRunResult.notDue;
    _running = true;
    final now = _now().toUtc();
    var state = AutomaticBackupRunState(lastAttemptAt: now);
    VerifiedBackupArtifact? artifact;
    try {
      state = (await _settingsStore.loadRunState()).copyWith(
        running: true,
        stage: AutomaticBackupStage.checking,
        lastAttemptAt: now,
        clearError: true,
      );
      onState?.call(state);
      final settings = await _settingsStore.loadSettings();
      if (!settings.enabled && !force) {
        return await _finish(state, AutomaticBackupRunResult.disabled, onState);
      }
      if (!await _network.allows(settings.networkPolicy)) {
        return await _finish(
          state,
          AutomaticBackupRunResult.networkDeferred,
          onState,
        );
      }
      final health = await _healthStore.load();
      final latestChange = await _dataSource.latestUserChangeAt();
      if (!force &&
          (latestChange == null ||
              (health.lastBackupAt != null &&
                  !latestChange.isAfter(health.lastBackupAt!)))) {
        return await _finish(
          state,
          AutomaticBackupRunResult.noChanges,
          onState,
        );
      }
      final previousSuccess = state.lastSuccessAt ?? health.lastBackupAt;
      if (!force &&
          previousSuccess != null &&
          now.isBefore(previousSuccess.add(settings.interval))) {
        return await _finish(state, AutomaticBackupRunResult.notDue, onState);
      }
      final destinationStatus = await _destination.status();
      if (!destinationStatus.isReady) {
        return await _finish(
          state,
          AutomaticBackupRunResult.authorizationRequired,
          onState,
          errorCode:
              destinationStatus.detailCode ?? 'drive_authorization_required',
        );
      }
      final password = await _credentialStore.read();
      if (password == null || password.length < 8) {
        return await _finish(
          state,
          AutomaticBackupRunResult.credentialUnavailable,
          onState,
          errorCode: 'automatic_backup_credential_unavailable',
        );
      }
      state = state.copyWith(stage: AutomaticBackupStage.preparing);
      onState?.call(state);
      artifact = await _artifactBuilder.build(
        recoveryPassword: password,
        onProgress: (progress) {
          state = state.copyWith(
            stage: switch (progress.phase) {
              BackupPhase.preparing ||
              BackupPhase.packaging => AutomaticBackupStage.preparing,
              BackupPhase.encrypting => AutomaticBackupStage.encrypting,
              BackupPhase.saving => AutomaticBackupStage.uploading,
              BackupPhase.verifying => AutomaticBackupStage.verifying,
            },
          );
          onState?.call(state);
        },
      );
      state = state.copyWith(stage: AutomaticBackupStage.uploading);
      onState?.call(state);
      final uploaded = await _destination.upload(artifact);
      if (!uploaded.verified ||
          uploaded.byteSize != artifact.byteSize ||
          uploaded.sha256 != artifact.sha256) {
        throw const BackupFailure('drive_upload_verification_failed');
      }
      state = state.copyWith(stage: AutomaticBackupStage.applyingRetention);
      onState?.call(state);
      await _applyRetention(settings.retentionCount);
      await _healthStore.save(
        BackupHealth(
          lastBackupAt: artifact.createdAt,
          destinationType: BackupDestinationType.googleDrive,
          verified: true,
          backupSize: artifact.byteSize,
          pendingChangesSinceBackup: false,
          recoveryConfigured: true,
        ),
      );
      return await _finish(
        state,
        AutomaticBackupRunResult.completed,
        onState,
        successAt: artifact.createdAt,
      );
    } on BackupFailure catch (error) {
      return await _finish(
        state,
        AutomaticBackupRunResult.failed,
        onState,
        errorCode: error.code,
      );
    } on CryptoFailure catch (error) {
      return await _finish(
        state,
        AutomaticBackupRunResult.failed,
        onState,
        errorCode: error.code,
      );
    } on Object {
      return await _finish(
        state,
        AutomaticBackupRunResult.failed,
        onState,
        errorCode: 'automatic_backup_failed',
      );
    } finally {
      if (artifact != null) {
        try {
          await _artifactBuilder.discardArtifact(artifact);
        } on Object {
          // A staging cleanup failure must not change the verified remote
          // backup result. The artifact remains encrypted at rest.
        }
      }
      _running = false;
    }
  }

  Future<void> _applyRetention(int retentionCount) async {
    final backups = await _destination.listBackups();
    if (backups.length <= retentionCount) return;
    for (final backup in backups.skip(retentionCount)) {
      try {
        await _destination.delete(backup);
      } on Object {
        // Retention is best effort. A failed deletion must not invalidate the
        // new verified backup or remove additional older recovery points.
        break;
      }
    }
  }

  Future<AutomaticBackupRunResult> _finish(
    AutomaticBackupRunState state,
    AutomaticBackupRunResult result,
    void Function(AutomaticBackupRunState state)? onState, {
    String? errorCode,
    DateTime? successAt,
  }) async {
    final finished = state.copyWith(
      running: false,
      stage: result == AutomaticBackupRunResult.completed
          ? AutomaticBackupStage.complete
          : AutomaticBackupStage.idle,
      lastResult: result,
      lastSuccessAt: successAt,
      lastErrorCode: errorCode,
      clearError: errorCode == null,
    );
    await _settingsStore.saveRunState(finished);
    onState?.call(finished);
    return result;
  }
}
