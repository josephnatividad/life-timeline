import 'dart:convert';

import 'package:life_timeline/features/backup/domain/backup_models.dart';
import 'package:life_timeline/features/backup/domain/backup_ports.dart';
import 'package:life_timeline/features/security/domain/security_ports.dart';

final class SecureBackupHealthStore implements BackupHealthStore {
  const SecureBackupHealthStore(this._store);

  static const _key = 'backup.health.v1';

  final SecureKeyStore _store;

  @override
  Future<BackupHealth> load() async {
    final encoded = await _store.read(_key);
    if (encoded == null) {
      return const BackupHealth();
    }
    try {
      final json = Map<String, Object?>.from(jsonDecode(encoded) as Map);
      return BackupHealth(
        lastBackupAt: json['lastBackupAt'] == null
            ? null
            : DateTime.parse(json['lastBackupAt'] as String).toUtc(),
        destinationType: json['destinationType'] == null
            ? null
            : BackupDestinationType.values.byName(
                json['destinationType'] as String,
              ),
        verified: json['verified'] as bool? ?? false,
        backupSize: json['backupSize'] as int?,
        pendingChangesSinceBackup:
            json['pendingChangesSinceBackup'] as bool? ?? true,
        recoveryConfigured: json['recoveryConfigured'] as bool? ?? false,
        importantItemsWithSingleCopy:
            json['importantItemsWithSingleCopy'] as int? ?? 0,
        archiveItemsWithSingleCopy:
            json['archiveItemsWithSingleCopy'] as int? ?? 0,
        itemsWithNoVerifiedCopy: json['itemsWithNoVerifiedCopy'] as int? ?? 0,
      );
    } on Object {
      return const BackupHealth();
    }
  }

  @override
  Future<void> save(BackupHealth health) => _store.write(
    _key,
    jsonEncode({
      'lastBackupAt': health.lastBackupAt?.toIso8601String(),
      'destinationType': health.destinationType?.name,
      'verified': health.verified,
      'backupSize': health.backupSize,
      'pendingChangesSinceBackup': health.pendingChangesSinceBackup,
      'recoveryConfigured': health.recoveryConfigured,
      'importantItemsWithSingleCopy': health.importantItemsWithSingleCopy,
      'archiveItemsWithSingleCopy': health.archiveItemsWithSingleCopy,
      'itemsWithNoVerifiedCopy': health.itemsWithNoVerifiedCopy,
    }),
  );
}
