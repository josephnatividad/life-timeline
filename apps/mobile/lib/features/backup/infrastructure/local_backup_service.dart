import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:archive/archive_io.dart';
import 'package:life_timeline/features/backup/domain/backup_models.dart';
import 'package:life_timeline/features/backup/domain/backup_ports.dart';
import 'package:life_timeline/shared/crypto/crypto_models.dart';
import 'package:path/path.dart' as p;

final class LocalBackupService
    implements BackupBuilder, BackupArtifactBuilder, BackupRestoreService {
  const LocalBackupService(
    this._dataSource,
    this._attachmentStorage,
    this._destination,
    this._encryption,
    this._appVersion, {
    DateTime Function()? now,
    KdfParameters kdf = const KdfParameters(),
  }) : _now = now ?? DateTime.now,
       // ignore: prefer_initializing_formals
       _kdf = kdf;

  static const _manifestPath = 'manifest.json';
  static const _databasePath = 'database/timeline.json';
  static const _maxArchiveEntries = 100000;
  static const _maxExpandedBytes = 100 * 1024 * 1024 * 1024;

  final AppVersionProvider _appVersion;
  final ManagedAttachmentStorage _attachmentStorage;
  final BackupDataSource _dataSource;
  final BackupFileGateway _destination;
  final EncryptionService _encryption;
  final KdfParameters _kdf;
  final DateTime Function() _now;

  @override
  Future<BackupResult?> create({
    required String recoveryPassword,
    required void Function(BackupProgress progress) onProgress,
  }) async {
    final artifact = await build(
      recoveryPassword: recoveryPassword,
      onProgress: onProgress,
    );
    try {
      onProgress(const BackupProgress(phase: BackupPhase.saving));
      final destination = await _destination.saveExport(
        sourcePath: artifact.path,
        suggestedName: _suggestedName(artifact.createdAt),
        expectedSha256: artifact.sha256,
      );
      if (destination == null) {
        return null;
      }
      if (!destination.verified) {
        throw const BackupFailure('backup_destination_verification_failed');
      }
      return BackupResult(
        path: destination.displayPath,
        createdAt: artifact.createdAt,
        byteSize: artifact.byteSize,
        verified: true,
      );
    } finally {
      await discardArtifact(artifact);
    }
  }

  @override
  Future<VerifiedBackupArtifact> build({
    required String recoveryPassword,
    required void Function(BackupProgress progress) onProgress,
  }) async {
    if (recoveryPassword.length < 8) {
      throw const BackupFailure('recovery_password_too_short');
    }
    final createdAt = _now().toUtc();
    final operation = await _createOperationDirectory('backup');
    final payload = Directory(p.join(operation.path, 'payload'));
    await payload.create(recursive: true);
    final archivePath = p.join(operation.path, 'payload.zip');
    final encryptedPath = p.join(operation.path, 'encrypted.timelinebackup');
    final verificationPath = p.join(operation.path, 'verification.zip');
    try {
      onProgress(const BackupProgress(phase: BackupPhase.preparing));
      final snapshot = _portableSnapshot(await _dataSource.exportSnapshot());
      final databaseFile = File(p.join(payload.path, _databasePath));
      await databaseFile.parent.create(recursive: true);
      await databaseFile.writeAsString(
        jsonEncode(snapshot.toJson()),
        flush: true,
      );
      final entries = <BackupFileEntry>[
        BackupFileEntry(
          path: _databasePath,
          byteSize: await databaseFile.length(),
          sha256: await _encryption.sha256File(databaseFile.path),
          type: BackupEntryType.database,
        ),
      ];
      await _copyManagedAttachments(snapshot, payload, entries);
      final manifest = BackupManifest(
        formatVersion: 1,
        databaseSchemaVersion: snapshot.schemaVersion,
        appVersion: await _appVersion.version(),
        createdAt: createdAt,
        files: entries,
        kdf: _kdf,
      );
      await File(
        p.join(payload.path, _manifestPath),
      ).writeAsString(jsonEncode(manifest.toJson()), flush: true);

      onProgress(const BackupProgress(phase: BackupPhase.packaging));
      final encoder = ZipFileEncoder();
      await encoder.zipDirectory(
        payload,
        filename: archivePath,
        followLinks: false,
      );
      final archiveHash = await _encryption.sha256File(archivePath);

      onProgress(const BackupProgress(phase: BackupPhase.encrypting));
      await _encryption.encryptFile(
        inputPath: archivePath,
        outputPath: encryptedPath,
        password: recoveryPassword,
        createdAt: createdAt,
        databaseSchemaVersion: snapshot.schemaVersion,
        attachmentCount: manifest.attachmentCount,
        kdf: _kdf,
      );

      onProgress(const BackupProgress(phase: BackupPhase.verifying));
      await _encryption.decryptFile(
        inputPath: encryptedPath,
        outputPath: verificationPath,
        password: recoveryPassword,
      );
      final verified =
          await _encryption.sha256File(verificationPath) == archiveHash;
      if (!verified) {
        throw const BackupFailure('backup_verification_failed');
      }

      final encryptedSha256 = await _encryption.sha256File(encryptedPath);
      return VerifiedBackupArtifact(
        backupId: p.basename(operation.path),
        path: encryptedPath,
        stagingDirectory: operation.path,
        createdAt: createdAt,
        byteSize: await File(encryptedPath).length(),
        sha256: encryptedSha256,
        formatVersion: 1,
        databaseSchemaVersion: snapshot.schemaVersion,
        attachmentCount: manifest.attachmentCount,
      );
    } on Object {
      await _deleteDirectory(operation);
      rethrow;
    }
  }

  @override
  Future<void> discardArtifact(VerifiedBackupArtifact artifact) =>
      _deleteDirectory(Directory(artifact.stagingDirectory));

  @override
  Future<EncryptedContainerHeader> inspect(String path) =>
      _encryption.inspect(path);

  @override
  Future<PreparedRestore> prepare({
    required String path,
    required String recoveryPassword,
    required void Function(RestoreProgress progress) onProgress,
  }) async {
    final header = await inspect(path);
    if (header.databaseSchemaVersion > _dataSource.schemaVersion) {
      throw const BackupFailure('newer_backup_not_supported');
    }
    final operation = await _createOperationDirectory('restore');
    final zipPath = p.join(operation.path, 'payload.zip');
    final payload = Directory(p.join(operation.path, 'payload'));
    try {
      onProgress(const RestoreProgress(phase: RestorePhase.decrypting));
      await _encryption.decryptFile(
        inputPath: path,
        outputPath: zipPath,
        password: recoveryPassword,
      );
      onProgress(const RestoreProgress(phase: RestorePhase.staging));
      await _extractValidatedZip(zipPath, payload.path);
      onProgress(const RestoreProgress(phase: RestorePhase.verifying));
      final manifest = await _readManifest(payload);
      _validateManifestAgainstHeader(manifest, header);
      await _verifyPayload(payload, manifest);
      final databaseFile = File(p.join(payload.path, _databasePath));
      final snapshot = DatabaseSnapshot.fromJson(
        Map<String, Object?>.from(
          jsonDecode(await databaseFile.readAsString()) as Map,
        ),
      );
      if (snapshot.schemaVersion != manifest.databaseSchemaVersion ||
          snapshot.schemaVersion > _dataSource.schemaVersion) {
        throw const BackupFailure('unsupported_database_version');
      }
      _validateAttachmentMappings(snapshot, manifest);
      final preview = RestorePreview(
        createdAt: manifest.createdAt,
        appVersion: manifest.appVersion,
        databaseSchemaVersion: manifest.databaseSchemaVersion,
        attachmentCount: manifest.attachmentCount,
        containsData: _snapshotContainsData(snapshot),
      );
      return PreparedRestore(
        id: p.basename(operation.path),
        stagingDirectory: operation.path,
        manifest: manifest,
        snapshot: snapshot,
        preview: preview,
      );
    } on Object {
      await _deleteDirectory(operation);
      rethrow;
    }
  }

  @override
  Future<void> commit(
    PreparedRestore prepared, {
    required bool replaceExisting,
    required void Function(RestoreProgress progress) onProgress,
  }) async {
    if (await _dataSource.hasUserData() && !replaceExisting) {
      throw const BackupFailure('existing_data_confirmation_required');
    }
    final staging = Directory(prepared.stagingDirectory);
    if (!await staging.exists()) {
      throw const BackupFailure('restore_staging_missing');
    }
    onProgress(const RestoreProgress(phase: RestorePhase.staging));
    final attachmentRoot = await _attachmentStorage.rootPath();
    final generationRelative = p.join('restored', prepared.id);
    final generation = Directory(p.join(attachmentRoot, generationRelative));
    if (await generation.exists()) {
      throw const BackupFailure('restore_generation_conflict');
    }
    await generation.create(recursive: true);
    try {
      final rewritten = await _stageRestoredAttachments(
        prepared,
        generation,
        generationRelative,
      );
      onProgress(const RestoreProgress(phase: RestorePhase.restoring));
      await _dataSource.replaceWithSnapshot(rewritten);
      onProgress(const RestoreProgress(phase: RestorePhase.migrating));
      onProgress(const RestoreProgress(phase: RestorePhase.complete));
      await _deleteDirectory(staging);
    } on Object {
      await _deleteDirectory(generation);
      rethrow;
    }
  }

  @override
  Future<void> discard(PreparedRestore prepared) =>
      _deleteDirectory(Directory(prepared.stagingDirectory));

  Future<void> _copyManagedAttachments(
    DatabaseSnapshot snapshot,
    Directory payload,
    List<BackupFileEntry> entries,
  ) async {
    final root = await _attachmentStorage.rootPath();
    for (final row
        in snapshot.tables['attachments'] ?? const <Map<String, Object?>>[]) {
      final state = row['storage_state'] as String?;
      final relative = row['relative_path'] as String?;
      final thumbnail = row['thumbnail_relative_path'] as String?;
      final preserved = row['preserved_original_relative_path'] as String?;
      final id = row['id'] as String;
      if (state == 'local' && relative != null) {
        await _copyManagedFile(
          root: root,
          payload: payload,
          entries: entries,
          attachmentId: id,
          relativePath: relative,
          state: state,
          type: BackupEntryType.attachment,
          archiveRoot: 'attachments',
        );
      }
      if (thumbnail != null) {
        await _copyManagedFile(
          root: root,
          payload: payload,
          entries: entries,
          attachmentId: id,
          relativePath: thumbnail,
          state: state,
          type: BackupEntryType.thumbnail,
          archiveRoot: 'thumbnails',
        );
      }
      if (preserved != null) {
        await _copyManagedFile(
          root: root,
          payload: payload,
          entries: entries,
          attachmentId: id,
          relativePath: preserved,
          state: state,
          type: BackupEntryType.preservedOriginal,
          archiveRoot: 'preserved-originals',
        );
      }
    }
  }

  Future<void> _copyManagedFile({
    required String root,
    required Directory payload,
    required List<BackupFileEntry> entries,
    required String attachmentId,
    required String relativePath,
    required String? state,
    required BackupEntryType type,
    required String archiveRoot,
  }) async {
    final sourcePath = _safeResolve(root, relativePath);
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw const BackupFailure('managed_attachment_missing');
    }
    final archiveRelative = p.posix.join(
      archiveRoot,
      _safeSegment(attachmentId),
      _safeSegment(p.basename(relativePath)),
    );
    final target = File(p.join(payload.path, p.fromUri(archiveRelative)));
    await target.parent.create(recursive: true);
    await source.copy(target.path);
    entries.add(
      BackupFileEntry(
        path: archiveRelative,
        byteSize: await target.length(),
        sha256: await _encryption.sha256File(target.path),
        type: type,
        attachmentId: attachmentId,
        storageState: state,
        originalRelativePath: relativePath,
      ),
    );
  }

  Future<BackupManifest> _readManifest(Directory payload) async {
    final file = File(p.join(payload.path, _manifestPath));
    if (!await file.exists() || await file.length() > 1024 * 1024) {
      throw const BackupFailure('manifest_missing_or_too_large');
    }
    try {
      return BackupManifest.fromJson(
        Map<String, Object?>.from(jsonDecode(await file.readAsString()) as Map),
      );
    } on BackupFailure {
      rethrow;
    } on Object {
      throw const BackupFailure('manifest_invalid');
    }
  }

  void _validateManifestAgainstHeader(
    BackupManifest manifest,
    EncryptedContainerHeader header,
  ) {
    if (manifest.formatVersion != header.formatVersion ||
        manifest.databaseSchemaVersion != header.databaseSchemaVersion ||
        manifest.createdAt != header.createdAt ||
        manifest.attachmentCount != header.attachmentCount ||
        manifest.cipher != header.cipher ||
        jsonEncode(manifest.kdf.toJson()) != jsonEncode(header.kdf.toJson())) {
      throw const BackupFailure('manifest_header_mismatch');
    }
  }

  Future<void> _verifyPayload(
    Directory payload,
    BackupManifest manifest,
  ) async {
    final seen = <String>{};
    for (final entry in manifest.files) {
      if (!seen.add(entry.path) || !_isSafeArchivePath(entry.path)) {
        throw const BackupFailure('manifest_path_invalid');
      }
      final file = File(p.join(payload.path, p.fromUri(entry.path)));
      if (!await file.exists() ||
          await file.length() != entry.byteSize ||
          await _encryption.sha256File(file.path) != entry.sha256) {
        throw const BackupFailure('checksum_failed');
      }
    }
    if (!seen.contains(_databasePath)) {
      throw const BackupFailure('database_payload_missing');
    }
    final extracted = <String>{};
    await for (final entity in payload.list(recursive: true)) {
      if (entity is File) {
        extracted.add(
          p.posix.joinAll(p.split(p.relative(entity.path, from: payload.path))),
        );
      }
    }
    if (extracted.length != seen.length + 1 ||
        !extracted.contains(_manifestPath) ||
        !extracted.containsAll(seen)) {
      throw const BackupFailure('archive_contains_unexpected_files');
    }
  }

  void _validateAttachmentMappings(
    DatabaseSnapshot snapshot,
    BackupManifest manifest,
  ) {
    final rows = <String, Map<String, Object?>>{};
    for (final row
        in snapshot.tables['attachments'] ?? const <Map<String, Object?>>[]) {
      final id = row['id'];
      if (id is! String || rows[id] != null) {
        throw const BackupFailure('attachment_snapshot_invalid');
      }
      rows[id] = row;
    }
    final mainIds = <String>{};
    final thumbnailIds = <String>{};
    final preservedIds = <String>{};
    for (final entry in manifest.files.where(
      (entry) => entry.type != BackupEntryType.database,
    )) {
      final id = entry.attachmentId;
      final row = id == null ? null : rows[id];
      if (id == null || row == null) {
        throw const BackupFailure('attachment_manifest_invalid');
      }
      final accepted = switch (entry.type) {
        BackupEntryType.attachment =>
          row['storage_state'] == 'local' && mainIds.add(id),
        BackupEntryType.thumbnail => thumbnailIds.add(id),
        BackupEntryType.preservedOriginal => preservedIds.add(id),
        BackupEntryType.database => false,
      };
      if (!accepted) throw const BackupFailure('attachment_manifest_invalid');
    }
    for (final entry in rows.entries) {
      if (entry.value['storage_state'] == 'local' &&
          !mainIds.contains(entry.key)) {
        throw const BackupFailure('managed_attachment_missing');
      }
      if (entry.value['thumbnail_relative_path'] != null &&
          !thumbnailIds.contains(entry.key)) {
        throw const BackupFailure('managed_attachment_missing');
      }
      if (entry.value['preserved_original_relative_path'] != null &&
          !preservedIds.contains(entry.key)) {
        throw const BackupFailure('managed_attachment_missing');
      }
    }
  }

  Future<void> _extractValidatedZip(String zipPath, String outputPath) async {
    final input = InputFileStream(zipPath);
    try {
      final archive = ZipDecoder().decodeStream(input, verify: true);
      if (archive.length > _maxArchiveEntries) {
        throw const BackupFailure('archive_too_large');
      }
      var expandedBytes = 0;
      final names = <String>{};
      for (final entry in archive) {
        final safeName = entry.isDirectory && entry.name.endsWith('/')
            ? entry.name.substring(0, entry.name.length - 1)
            : entry.name;
        if (!_isSafeArchivePath(safeName) ||
            entry.isSymbolicLink ||
            !names.add(safeName)) {
          throw const BackupFailure('archive_path_invalid');
        }
        expandedBytes += entry.size;
        if (expandedBytes > _maxExpandedBytes) {
          throw const BackupFailure('archive_too_large');
        }
      }
      if (!names.contains(_manifestPath) || !names.contains(_databasePath)) {
        throw const BackupFailure('archive_corrupted');
      }
      final output = Directory(outputPath);
      await output.create(recursive: true);
      for (final entry in archive) {
        final target = p.join(output.path, p.fromUri(entry.name));
        if (entry.isDirectory) {
          await Directory(target).create(recursive: true);
        } else if (entry.isFile) {
          await File(target).parent.create(recursive: true);
          final stream = OutputFileStream(target);
          entry.writeContent(stream);
          await stream.close();
        } else {
          throw const BackupFailure('archive_entry_unsupported');
        }
      }
    } on BackupFailure {
      rethrow;
    } on Object {
      throw const BackupFailure('archive_corrupted');
    } finally {
      await input.close();
    }
  }

  Future<DatabaseSnapshot> _stageRestoredAttachments(
    PreparedRestore prepared,
    Directory generation,
    String generationRelative,
  ) async {
    final payload = Directory(p.join(prepared.stagingDirectory, 'payload'));
    final restoredPaths = <String, String>{};
    final restoredThumbnails = <String, String>{};
    final restoredPreservedOriginals = <String, String>{};
    for (final entry in prepared.manifest.files.where(
      (entry) => entry.type != BackupEntryType.database,
    )) {
      final id = entry.attachmentId;
      if (id == null) {
        throw const BackupFailure('attachment_manifest_invalid');
      }
      final fileName = _safeSegment(p.basename(entry.path));
      final role = switch (entry.type) {
        BackupEntryType.attachment => 'content',
        BackupEntryType.thumbnail => 'thumbnail',
        BackupEntryType.preservedOriginal => 'preserved',
        BackupEntryType.database => throw const BackupFailure(
          'attachment_manifest_invalid',
        ),
      };
      final relative = p.join(
        generationRelative,
        _safeSegment(id),
        role,
        fileName,
      );
      final target = File(
        p.join(await _attachmentStorage.rootPath(), relative),
      );
      final staged = File(p.join(payload.path, p.fromUri(entry.path)));
      if (!await staged.exists() || await staged.length() != entry.byteSize) {
        throw const BackupFailure('attachment_restore_checksum_failed');
      }
      await target.parent.create(recursive: true);
      await staged.copy(target.path);
      if (await _encryption.sha256File(target.path) != entry.sha256) {
        throw const BackupFailure('attachment_restore_checksum_failed');
      }
      switch (entry.type) {
        case BackupEntryType.attachment:
          restoredPaths[id] = relative;
        case BackupEntryType.thumbnail:
          restoredThumbnails[id] = relative;
        case BackupEntryType.preservedOriginal:
          restoredPreservedOriginals[id] = relative;
        case BackupEntryType.database:
          throw const BackupFailure('attachment_manifest_invalid');
      }
    }
    final tables = <String, List<Map<String, Object?>>>{
      for (final table in prepared.snapshot.tables.entries)
        table.key: table.value
            .map((row) => Map<String, Object?>.from(row))
            .toList(growable: false),
    };
    for (final row in tables['attachments'] ?? const <Map<String, Object?>>[]) {
      final id = row['id'] as String?;
      final relative = id == null ? null : restoredPaths[id];
      if (relative != null) {
        row['relative_path'] = relative;
        row['storage_state'] = 'local';
      }
      row['thumbnail_relative_path'] = id == null
          ? null
          : restoredThumbnails[id];
      row['preserved_original_relative_path'] = id == null
          ? null
          : restoredPreservedOriginals[id];
    }
    return DatabaseSnapshot(
      schemaVersion: prepared.snapshot.schemaVersion,
      tables: tables,
    );
  }

  bool _snapshotContainsData(DatabaseSnapshot snapshot) =>
      (snapshot.tables['events']?.isNotEmpty ?? false) ||
      (snapshot.tables['entities']?.isNotEmpty ?? false) ||
      (snapshot.tables['evidence']?.isNotEmpty ?? false);

  DatabaseSnapshot _portableSnapshot(DatabaseSnapshot source) {
    final tables = <String, List<Map<String, Object?>>>{
      for (final table in source.tables.entries)
        table.key: table.value
            .map((row) => Map<String, Object?>.from(row))
            .toList(growable: false),
    };
    for (final attachment
        in tables['attachments'] ?? const <Map<String, Object?>>[]) {
      final state = attachment['storage_state'] as String?;
      final relative = attachment['relative_path'] as String?;
      if (state == 'local' && relative != null && p.isAbsolute(relative)) {
        throw const BackupFailure('attachment_path_invalid');
      }
      if (state == 'referenced') {
        attachment['relative_path'] = null;
      }
      if (state == 'archived') {
        // An archive destination is external and is represented only by its
        // portable archive reference. A transient retained local path is not
        // a backup payload identifier.
        attachment['relative_path'] = null;
      }
    }
    return DatabaseSnapshot(
      schemaVersion: source.schemaVersion,
      tables: tables,
    );
  }

  bool _isSafeArchivePath(String value) {
    if (value.isEmpty || value.contains('\\') || p.posix.isAbsolute(value)) {
      return false;
    }
    final normalized = p.posix.normalize(value);
    return normalized == value &&
        normalized != '.' &&
        !normalized.startsWith('../') &&
        !normalized.contains('/../');
  }

  String _safeResolve(String root, String relative) {
    if (p.isAbsolute(relative)) {
      throw const BackupFailure('attachment_path_invalid');
    }
    final resolvedRoot = p.canonicalize(root);
    final resolved = p.canonicalize(p.join(root, relative));
    if (!p.isWithin(resolvedRoot, resolved)) {
      throw const BackupFailure('attachment_path_invalid');
    }
    return resolved;
  }

  String _safeSegment(String value) {
    final sanitized = value.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    if (sanitized.isEmpty || sanitized == '.' || sanitized == '..') {
      throw const BackupFailure('unsafe_file_name');
    }
    return sanitized;
  }

  Future<Directory> _createOperationDirectory(String prefix) async {
    final root = await _attachmentStorage.temporaryRootPath();
    final entropy = Random.secure().nextInt(0x7fffffff).toRadixString(36);
    final directory = Directory(
      p.join(
        root,
        '${prefix}_${_now().toUtc().microsecondsSinceEpoch}_$entropy',
      ),
    );
    await directory.create(recursive: true);
    return directory;
  }

  String _suggestedName(DateTime createdAt) {
    final date = createdAt.toIso8601String().replaceAll(':', '-');
    return 'timeline-$date.timelinebackup';
  }

  Future<void> _deleteDirectory(Directory directory) async {
    if (await directory.exists()) {
      try {
        await directory.delete(recursive: true);
      } on FileSystemException {
        // Best-effort cleanup. The directory remains inside app-private temp.
      }
    }
  }
}
