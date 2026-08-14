import 'dart:convert';

import 'package:life_timeline/features/backup/domain/automatic_backup_models.dart';
import 'package:life_timeline/features/backup/domain/automatic_backup_ports.dart';
import 'package:life_timeline/features/backup/domain/backup_models.dart';
import 'package:life_timeline/features/security/domain/security_ports.dart';

final class SecureAutomaticBackupSettingsStore
    implements AutomaticBackupSettingsStore {
  const SecureAutomaticBackupSettingsStore(this._store);

  static const _settingsKey = 'automatic_backup_settings_v1';
  static const _runStateKey = 'automatic_backup_run_state_v1';

  final SecureKeyStore _store;

  @override
  Future<AutomaticBackupSettings> loadSettings() async {
    final encoded = await _store.read(_settingsKey);
    if (encoded == null) return const AutomaticBackupSettings();
    try {
      return AutomaticBackupSettings.fromJson(
        Map<String, Object?>.from(jsonDecode(encoded) as Map),
      );
    } on Object {
      throw const BackupFailure('automatic_backup_settings_unreadable');
    }
  }

  @override
  Future<AutomaticBackupRunState> loadRunState() async {
    final encoded = await _store.read(_runStateKey);
    if (encoded == null) return const AutomaticBackupRunState();
    try {
      return AutomaticBackupRunState.fromJson(
        Map<String, Object?>.from(jsonDecode(encoded) as Map),
      );
    } on Object {
      throw const BackupFailure('automatic_backup_state_unreadable');
    }
  }

  @override
  Future<void> saveRunState(AutomaticBackupRunState state) =>
      _store.write(_runStateKey, jsonEncode(state.toJson()));

  @override
  Future<void> saveSettings(AutomaticBackupSettings settings) =>
      _store.write(_settingsKey, jsonEncode(settings.toJson()));
}

final class DeviceOnlyAutomaticBackupCredentialStore
    implements AutomaticBackupCredentialStore {
  const DeviceOnlyAutomaticBackupCredentialStore(this._store);

  static const _credentialKey = 'automatic_backup_recovery_password_v1';

  final SecureKeyStore _store;

  @override
  Future<void> delete() => _store.delete(_credentialKey);

  @override
  Future<String?> read() => _store.read(_credentialKey);

  @override
  Future<void> save(String recoveryPassword) async {
    if (recoveryPassword.length < 8) {
      throw const BackupFailure('recovery_password_too_short');
    }
    await _store.write(_credentialKey, recoveryPassword);
  }
}
