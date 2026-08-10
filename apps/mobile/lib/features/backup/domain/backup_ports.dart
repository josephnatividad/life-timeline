import 'package:life_timeline/features/backup/domain/backup_models.dart';
import 'package:life_timeline/shared/crypto/crypto_models.dart';

abstract interface class BackupDataSource {
  int get schemaVersion;
  Future<DatabaseSnapshot> exportSnapshot();
  Future<void> replaceWithSnapshot(DatabaseSnapshot snapshot);
  Future<bool> hasUserData();
}

abstract interface class ManagedAttachmentStorage {
  Future<String> rootPath();
  Future<String> temporaryRootPath();
}

abstract interface class BackupDestination {
  Future<BackupDestinationReceipt?> saveExport({
    required String sourcePath,
    required String suggestedName,
    required String expectedSha256,
  });
  Future<String?> chooseImportPath();
}

final class BackupDestinationReceipt {
  const BackupDestinationReceipt({
    required this.displayPath,
    required this.verified,
  });

  final String displayPath;
  final bool verified;
}

abstract interface class AppVersionProvider {
  Future<String> version();
}

abstract interface class BackupHealthStore {
  Future<BackupHealth> load();
  Future<void> save(BackupHealth health);
}

abstract interface class BackupBuilder {
  Future<BackupResult?> create({
    required String recoveryPassword,
    required void Function(BackupProgress progress) onProgress,
  });
}

abstract interface class BackupRestoreService {
  Future<EncryptedContainerHeader> inspect(String path);

  Future<PreparedRestore> prepare({
    required String path,
    required String recoveryPassword,
    required void Function(RestoreProgress progress) onProgress,
  });

  Future<void> commit(
    PreparedRestore prepared, {
    required bool replaceExisting,
    required void Function(RestoreProgress progress) onProgress,
  });

  Future<void> discard(PreparedRestore prepared);
}
