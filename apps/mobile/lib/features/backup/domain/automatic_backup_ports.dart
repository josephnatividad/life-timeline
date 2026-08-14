import 'package:life_timeline/features/backup/domain/automatic_backup_models.dart';

abstract interface class AutomaticBackupSettingsStore {
  Future<AutomaticBackupSettings> loadSettings();
  Future<void> saveSettings(AutomaticBackupSettings settings);
  Future<AutomaticBackupRunState> loadRunState();
  Future<void> saveRunState(AutomaticBackupRunState state);
}

/// Device-only recovery password used by unattended encrypted backups.
abstract interface class AutomaticBackupCredentialStore {
  Future<void> save(String recoveryPassword);
  Future<String?> read();
  Future<void> delete();
}

abstract interface class BackupNetworkPolicyChecker {
  Future<bool> allows(AutomaticBackupNetworkPolicy policy);
}

abstract interface class AutomaticBackupScheduler {
  Future<void> configure(AutomaticBackupSettings settings);
  Future<void> scheduleSoon(AutomaticBackupSettings settings);
}
