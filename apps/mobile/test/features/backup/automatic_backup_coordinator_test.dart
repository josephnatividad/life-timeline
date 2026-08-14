import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/features/backup/application/automatic_backup_coordinator.dart';
import 'package:life_timeline/features/backup/domain/automatic_backup_models.dart';
import 'package:life_timeline/features/backup/domain/automatic_backup_ports.dart';
import 'package:life_timeline/features/backup/domain/backup_models.dart';
import 'package:life_timeline/features/backup/domain/backup_ports.dart';

void main() {
  final now = DateTime.utc(2026, 8, 14, 12);

  test('uploads, verifies, then applies retention', () async {
    final store = _SettingsStore(const AutomaticBackupSettings(enabled: true));
    final builder = _ArtifactBuilder(_artifact(now));
    final destination = _Destination(
      backups: List.generate(
        4,
        (index) => _remote(now.subtract(Duration(days: index))),
      ),
    );
    final health = _HealthStore();
    final coordinator = AutomaticBackupCoordinator(
      store,
      _CredentialStore('correct horse'),
      _DataSource(now),
      builder,
      destination,
      const _Network(true),
      health,
      now: () => now,
    );

    final result = await coordinator.run();

    expect(result, AutomaticBackupRunResult.completed);
    expect(destination.uploads, 1);
    expect(destination.deleted, hasLength(1));
    expect(builder.discards, 1);
    expect(health.value.destinationType, BackupDestinationType.googleDrive);
    expect(health.value.verified, isTrue);
    expect(store.runState.lastResult, AutomaticBackupRunResult.completed);
  });

  test('does not delete older copies when upload verification fails', () async {
    final store = _SettingsStore(const AutomaticBackupSettings(enabled: true));
    final builder = _ArtifactBuilder(_artifact(now));
    final destination = _Destination(
      uploadVerified: false,
      backups: List.generate(4, (index) => _remote(now)),
    );
    final coordinator = AutomaticBackupCoordinator(
      store,
      _CredentialStore('correct horse'),
      _DataSource(now),
      builder,
      destination,
      const _Network(true),
      _HealthStore(),
      now: () => now,
    );

    final result = await coordinator.run();

    expect(result, AutomaticBackupRunResult.failed);
    expect(destination.deleted, isEmpty);
    expect(builder.discards, 1);
  });

  test('defers before building when selected network is unavailable', () async {
    final builder = _ArtifactBuilder(_artifact(now));
    final coordinator = AutomaticBackupCoordinator(
      _SettingsStore(const AutomaticBackupSettings(enabled: true)),
      _CredentialStore('correct horse'),
      _DataSource(now),
      builder,
      _Destination(),
      const _Network(false),
      _HealthStore(),
      now: () => now,
    );

    final result = await coordinator.run();

    expect(result, AutomaticBackupRunResult.networkDeferred);
    expect(builder.builds, 0);
  });

  test('skips unchanged timeline after a verified backup', () async {
    final builder = _ArtifactBuilder(_artifact(now));
    final health = _HealthStore(
      BackupHealth(lastBackupAt: now, verified: true),
    );
    final coordinator = AutomaticBackupCoordinator(
      _SettingsStore(const AutomaticBackupSettings(enabled: true)),
      _CredentialStore('correct horse'),
      _DataSource(now),
      builder,
      _Destination(),
      const _Network(true),
      health,
      now: () => now.add(const Duration(days: 8)),
    );

    final result = await coordinator.run();

    expect(result, AutomaticBackupRunResult.noChanges);
    expect(builder.builds, 0);
  });

  test(
    'a transient run-state read failure does not lock the coordinator',
    () async {
      final store = _SettingsStore(
        const AutomaticBackupSettings(enabled: true),
        failNextRunStateLoad: true,
      );
      final builder = _ArtifactBuilder(_artifact(now));
      final coordinator = AutomaticBackupCoordinator(
        store,
        _CredentialStore('correct horse'),
        _DataSource(now),
        builder,
        _Destination(),
        const _Network(true),
        _HealthStore(),
        now: () => now,
      );

      expect(await coordinator.run(), AutomaticBackupRunResult.failed);
      expect(await coordinator.run(), AutomaticBackupRunResult.completed);
    },
  );

  test('encrypted staging cleanup cannot mask a completed backup', () async {
    final builder = _ArtifactBuilder(_artifact(now), throwOnDiscard: true);
    final coordinator = AutomaticBackupCoordinator(
      _SettingsStore(const AutomaticBackupSettings(enabled: true)),
      _CredentialStore('correct horse'),
      _DataSource(now),
      builder,
      _Destination(),
      const _Network(true),
      _HealthStore(),
      now: () => now,
    );

    expect(await coordinator.run(), AutomaticBackupRunResult.completed);
    expect(builder.discards, 1);
  });
}

VerifiedBackupArtifact _artifact(DateTime createdAt) => VerifiedBackupArtifact(
  backupId: 'backup-id',
  path: 'artifact.timelinebackup',
  stagingDirectory: 'staging',
  createdAt: createdAt,
  byteSize: 100,
  sha256: 'sha',
  formatVersion: 1,
  databaseSchemaVersion: 8,
  attachmentCount: 0,
);

RemoteBackupInfo _remote(DateTime createdAt) => RemoteBackupInfo(
  providerReference: 'remote-${createdAt.microsecondsSinceEpoch}',
  backupId: 'backup-${createdAt.microsecondsSinceEpoch}',
  createdAt: createdAt,
  formatVersion: 1,
  databaseSchemaVersion: 8,
  byteSize: 100,
  sha256: 'sha',
);

final class _SettingsStore implements AutomaticBackupSettingsStore {
  _SettingsStore(this.settings, {this.failNextRunStateLoad = false});

  bool failNextRunStateLoad;
  AutomaticBackupRunState runState = const AutomaticBackupRunState();
  AutomaticBackupSettings settings;

  @override
  Future<AutomaticBackupRunState> loadRunState() async {
    if (failNextRunStateLoad) {
      failNextRunStateLoad = false;
      throw StateError('temporary read failure');
    }
    return runState;
  }

  @override
  Future<AutomaticBackupSettings> loadSettings() async => settings;

  @override
  Future<void> saveRunState(AutomaticBackupRunState state) async {
    runState = state;
  }

  @override
  Future<void> saveSettings(AutomaticBackupSettings value) async {
    settings = value;
  }
}

final class _CredentialStore implements AutomaticBackupCredentialStore {
  _CredentialStore(this.value);

  String? value;

  @override
  Future<void> delete() async => value = null;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> save(String recoveryPassword) async => value = recoveryPassword;
}

final class _Network implements BackupNetworkPolicyChecker {
  const _Network(this.available);

  final bool available;

  @override
  Future<bool> allows(AutomaticBackupNetworkPolicy policy) async => available;
}

final class _DataSource implements BackupDataSource {
  const _DataSource(this.latest);

  final DateTime? latest;

  @override
  int get schemaVersion => 8;

  @override
  Future<DatabaseSnapshot> exportSnapshot() => throw UnimplementedError();

  @override
  Future<bool> hasUserData() async => latest != null;

  @override
  Future<DateTime?> latestUserChangeAt() async => latest;

  @override
  Future<void> replaceWithSnapshot(DatabaseSnapshot snapshot) =>
      throw UnimplementedError();
}

final class _ArtifactBuilder implements BackupArtifactBuilder {
  _ArtifactBuilder(this.artifact, {this.throwOnDiscard = false});

  final VerifiedBackupArtifact artifact;
  final bool throwOnDiscard;
  int builds = 0;
  int discards = 0;

  @override
  Future<VerifiedBackupArtifact> build({
    required String recoveryPassword,
    required void Function(BackupProgress progress) onProgress,
  }) async {
    builds += 1;
    return artifact;
  }

  @override
  Future<void> discardArtifact(VerifiedBackupArtifact artifact) async {
    discards += 1;
    if (throwOnDiscard) throw StateError('temporary cleanup failure');
  }
}

final class _Destination implements BackupDestination {
  _Destination({this.uploadVerified = true, this.backups = const []});

  final List<RemoteBackupInfo> backups;
  final List<RemoteBackupInfo> deleted = [];
  final bool uploadVerified;
  int uploads = 0;

  @override
  Future<void> delete(RemoteBackupInfo backup) async => deleted.add(backup);

  @override
  Future<BackupDownloadResult> download(
    RemoteBackupInfo backup, {
    required String destinationPath,
  }) => throw UnimplementedError();

  @override
  Future<List<RemoteBackupInfo>> listBackups() async => backups;

  @override
  Future<BackupDestinationStatus> status() async =>
      const BackupDestinationStatus(
        availability: BackupDestinationAvailability.ready,
      );

  @override
  Future<BackupUploadResult> upload(VerifiedBackupArtifact artifact) async {
    uploads += 1;
    return BackupUploadResult(
      providerReference: 'remote',
      verified: uploadVerified,
      byteSize: artifact.byteSize,
      sha256: artifact.sha256,
    );
  }
}

final class _HealthStore implements BackupHealthStore {
  _HealthStore([this.value = const BackupHealth()]);

  BackupHealth value;

  @override
  Future<BackupHealth> load() async => value;

  @override
  Future<void> save(BackupHealth health) async => value = health;
}
