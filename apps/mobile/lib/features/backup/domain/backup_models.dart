import 'package:life_timeline/shared/crypto/crypto_models.dart';

enum BackupDestinationType { localFile, googleDrive }

enum BackupDestinationAvailability {
  ready,
  needsAuthorization,
  unavailable,
  misconfigured,
}

final class BackupDestinationStatus {
  const BackupDestinationStatus({
    required this.availability,
    this.accountLabel,
    this.detailCode,
  });

  final String? accountLabel;
  final BackupDestinationAvailability availability;
  final String? detailCode;

  bool get isReady => availability == BackupDestinationAvailability.ready;
}

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
    this.importantItemsWithSingleCopy = 0,
    this.archiveItemsWithSingleCopy = 0,
    this.itemsWithNoVerifiedCopy = 0,
  });

  final int? backupSize;
  final int archiveItemsWithSingleCopy;
  final BackupDestinationType? destinationType;
  final DateTime? lastBackupAt;
  final int importantItemsWithSingleCopy;
  final int itemsWithNoVerifiedCopy;
  final bool pendingChangesSinceBackup;
  final bool recoveryConfigured;
  final bool verified;

  BackupHealth copyWith({
    DateTime? lastBackupAt,
    BackupDestinationType? destinationType,
    bool? verified,
    int? backupSize,
    bool? pendingChangesSinceBackup,
    bool? recoveryConfigured,
    int? importantItemsWithSingleCopy,
    int? archiveItemsWithSingleCopy,
    int? itemsWithNoVerifiedCopy,
  }) => BackupHealth(
    lastBackupAt: lastBackupAt ?? this.lastBackupAt,
    destinationType: destinationType ?? this.destinationType,
    verified: verified ?? this.verified,
    backupSize: backupSize ?? this.backupSize,
    pendingChangesSinceBackup:
        pendingChangesSinceBackup ?? this.pendingChangesSinceBackup,
    recoveryConfigured: recoveryConfigured ?? this.recoveryConfigured,
    importantItemsWithSingleCopy:
        importantItemsWithSingleCopy ?? this.importantItemsWithSingleCopy,
    archiveItemsWithSingleCopy:
        archiveItemsWithSingleCopy ?? this.archiveItemsWithSingleCopy,
    itemsWithNoVerifiedCopy:
        itemsWithNoVerifiedCopy ?? this.itemsWithNoVerifiedCopy,
  );
}

enum BackupEntryType { database, attachment, thumbnail, preservedOriginal }

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

/// A complete LTBACK01 file that has been encrypted and verified locally.
final class VerifiedBackupArtifact {
  const VerifiedBackupArtifact({
    required this.backupId,
    required this.path,
    required this.stagingDirectory,
    required this.createdAt,
    required this.byteSize,
    required this.sha256,
    required this.formatVersion,
    required this.databaseSchemaVersion,
    required this.attachmentCount,
  });

  final int attachmentCount;
  final String backupId;
  final int byteSize;
  final DateTime createdAt;
  final int databaseSchemaVersion;
  final int formatVersion;
  final String path;
  final String sha256;
  final String stagingDirectory;
}

final class BackupUploadResult {
  const BackupUploadResult({
    required this.providerReference,
    required this.verified,
    required this.byteSize,
    required this.sha256,
  });

  final int byteSize;
  final String providerReference;
  final String sha256;
  final bool verified;
}

final class RemoteBackupInfo {
  const RemoteBackupInfo({
    required this.providerReference,
    required this.backupId,
    required this.createdAt,
    required this.formatVersion,
    required this.databaseSchemaVersion,
    required this.byteSize,
    required this.sha256,
  });

  final String backupId;
  final int byteSize;
  final DateTime createdAt;
  final int databaseSchemaVersion;
  final int formatVersion;
  final String providerReference;
  final String sha256;
}

final class BackupDownloadResult {
  const BackupDownloadResult({
    required this.path,
    required this.byteSize,
    required this.sha256,
    required this.verified,
  });

  final int byteSize;
  final String path;
  final String sha256;
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
