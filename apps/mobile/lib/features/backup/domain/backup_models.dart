import 'package:life_timeline/shared/crypto/crypto_models.dart';

enum BackupDestinationType { localFile }

enum BackupPhase { preparing, encrypting, packaging, saving, verifying }

enum RestorePhase {
  reading,
  decrypting,
  verifying,
  staging,
  restoring,
  migrating,
  complete,
}

final class BackupProgress {
  const BackupProgress({required this.phase, this.detail});

  final String? detail;
  final BackupPhase phase;
}

final class RestoreProgress {
  const RestoreProgress({required this.phase, this.detail});

  final String? detail;
  final RestorePhase phase;
}

final class BackupHealth {
  const BackupHealth({
    this.lastBackupAt,
    this.destinationType,
    this.verified = false,
    this.backupSize,
    this.pendingChangesSinceBackup = true,
    this.recoveryConfigured = false,
  });

  final int? backupSize;
  final BackupDestinationType? destinationType;
  final DateTime? lastBackupAt;
  final bool pendingChangesSinceBackup;
  final bool recoveryConfigured;
  final bool verified;
}

enum BackupEntryType { database, attachment }

final class BackupFileEntry {
  const BackupFileEntry({
    required this.path,
    required this.byteSize,
    required this.sha256,
    required this.type,
    this.attachmentId,
    this.storageState,
    this.originalRelativePath,
  });

  factory BackupFileEntry.fromJson(Map<String, Object?> json) =>
      BackupFileEntry(
        path: json['path'] as String,
        byteSize: json['byteSize'] as int,
        sha256: json['sha256'] as String,
        type: BackupEntryType.values.byName(json['type'] as String),
        attachmentId: json['attachmentId'] as String?,
        storageState: json['storageState'] as String?,
        originalRelativePath: json['originalRelativePath'] as String?,
      );

  final String? attachmentId;
  final int byteSize;
  final String? originalRelativePath;
  final String path;
  final String sha256;
  final String? storageState;
  final BackupEntryType type;

  Map<String, Object?> toJson() => {
    'path': path,
    'byteSize': byteSize,
    'sha256': sha256,
    'type': type.name,
    'attachmentId': attachmentId,
    'storageState': storageState,
    'originalRelativePath': originalRelativePath,
  };
}

final class BackupManifest {
  const BackupManifest({
    required this.formatVersion,
    required this.databaseSchemaVersion,
    required this.appVersion,
    required this.createdAt,
    required this.files,
    required this.kdf,
    this.cipher = 'aes-256-gcm',
  });

  factory BackupManifest.fromJson(Map<String, Object?> json) => BackupManifest(
    formatVersion: json['formatVersion'] as int,
    databaseSchemaVersion: json['databaseSchemaVersion'] as int,
    appVersion: json['appVersion'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
    files: (json['files'] as List)
        .map(
          (entry) =>
              BackupFileEntry.fromJson(Map<String, Object?>.from(entry as Map)),
        )
        .toList(growable: false),
    kdf: KdfParameters.fromJson(Map<String, Object?>.from(json['kdf']! as Map)),
    cipher: json['cipher'] as String? ?? '',
  );

  final String appVersion;
  final String cipher;
  final DateTime createdAt;
  final int databaseSchemaVersion;
  final List<BackupFileEntry> files;
  final int formatVersion;
  final KdfParameters kdf;

  int get attachmentCount =>
      files.where((entry) => entry.type == BackupEntryType.attachment).length;

  Map<String, Object> toJson() => {
    'formatVersion': formatVersion,
    'databaseSchemaVersion': databaseSchemaVersion,
    'appVersion': appVersion,
    'createdAt': createdAt.toIso8601String(),
    'attachmentCount': attachmentCount,
    'cipher': cipher,
    'kdf': kdf.toJson(),
    'files': files.map((entry) => entry.toJson()).toList(growable: false),
  };
}

final class DatabaseSnapshot {
  const DatabaseSnapshot({required this.schemaVersion, required this.tables});

  factory DatabaseSnapshot.fromJson(Map<String, Object?> json) =>
      DatabaseSnapshot(
        schemaVersion: json['schemaVersion'] as int,
        tables: (json['tables'] as Map).map(
          (key, value) => MapEntry(
            key as String,
            (value as List)
                .map((row) => Map<String, Object?>.from(row as Map))
                .toList(growable: false),
          ),
        ),
      );

  final int schemaVersion;
  final Map<String, List<Map<String, Object?>>> tables;

  Map<String, Object> toJson() => {
    'schemaVersion': schemaVersion,
    'tables': tables,
  };
}

final class BackupResult {
  const BackupResult({
    required this.path,
    required this.createdAt,
    required this.byteSize,
    required this.verified,
  });

  final int byteSize;
  final DateTime createdAt;
  final String path;
  final bool verified;
}

final class RestorePreview {
  const RestorePreview({
    required this.createdAt,
    required this.appVersion,
    required this.databaseSchemaVersion,
    required this.attachmentCount,
    required this.containsData,
  });

  final String appVersion;
  final int attachmentCount;
  final bool containsData;
  final DateTime createdAt;
  final int databaseSchemaVersion;
}

final class PreparedRestore {
  const PreparedRestore({
    required this.id,
    required this.stagingDirectory,
    required this.manifest,
    required this.snapshot,
    required this.preview,
  });

  final String id;
  final BackupManifest manifest;
  final RestorePreview preview;
  final DatabaseSnapshot snapshot;
  final String stagingDirectory;
}

final class BackupFailure implements Exception {
  const BackupFailure(this.code);

  final String code;

  @override
  String toString() => 'BackupFailure($code)';
}
