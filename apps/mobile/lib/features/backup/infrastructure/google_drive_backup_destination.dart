import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:life_timeline/features/backup/domain/backup_models.dart';
import 'package:life_timeline/features/backup/domain/backup_ports.dart';

/// Encrypted backup transport restricted to Google Drive's hidden
/// `appDataFolder`. This is not an application account system.
final class GoogleDriveBackupDestination
    implements BackupDestination, BackupDestinationAuthorization {
  GoogleDriveBackupDestination({
    GoogleSignIn? signIn,
    this.iosClientId = const String.fromEnvironment(
      'LIFE_TIMELINE_GOOGLE_IOS_CLIENT_ID',
    ),
    this.serverClientId = const String.fromEnvironment(
      'LIFE_TIMELINE_GOOGLE_SERVER_CLIENT_ID',
    ),
  }) : _signIn = signIn ?? GoogleSignIn.instance;

  static const _backupKind = 'life_timeline_automatic_backup';
  static const _mimeType = 'application/vnd.life-timeline.backup';
  static const _fields =
      'id,name,size,sha256Checksum,createdTime,appProperties,trashed';
  static const _listFields =
      'nextPageToken,files(id,name,size,sha256Checksum,createdTime,appProperties,trashed)';
  static const _scopes = <String>[drive.DriveApi.driveAppdataScope];

  final GoogleSignIn _signIn;
  final String iosClientId;
  final String serverClientId;
  Future<void>? _initialization;

  bool get _platformSupported => Platform.isAndroid || Platform.isIOS;
  bool get _configurationMissing =>
      (Platform.isAndroid && serverClientId.isEmpty) ||
      (Platform.isIOS && iosClientId.isEmpty);

  @override
  Future<BackupDestinationStatus> authorize() async {
    if (!_platformSupported) {
      return const BackupDestinationStatus(
        availability: BackupDestinationAvailability.unavailable,
        detailCode: 'drive_platform_unavailable',
      );
    }
    if (_configurationMissing) {
      return const BackupDestinationStatus(
        availability: BackupDestinationAvailability.misconfigured,
        detailCode: 'drive_client_configuration_missing',
      );
    }
    try {
      final account = await _interactiveAccount();
      final authorization = await account.authorizationClient.authorizeScopes(
        _scopes,
      );
      final client = authorization.authClient(scopes: _scopes);
      client.close();
      return BackupDestinationStatus(
        availability: BackupDestinationAvailability.ready,
        accountLabel: account.email,
      );
    } on GoogleSignInException catch (error) {
      return _authorizationFailureStatus(error.code);
    } on Object {
      return const BackupDestinationStatus(
        availability: BackupDestinationAvailability.unavailable,
        detailCode: 'drive_unavailable',
      );
    }
  }

  @override
  Future<void> delete(RemoteBackupInfo backup) => _withApi(
    (api, account) => api.files.delete(backup.providerReference),
    failureCode: 'drive_delete_failed',
  );

  @override
  Future<void> disconnect() async {
    if (!_platformSupported) return;
    await _ensureInitialized();
    await _signIn.disconnect();
  }

  @override
  Future<BackupDownloadResult> download(
    RemoteBackupInfo backup, {
    required String destinationPath,
  }) => _withApi((api, account) async {
    final destination = File(destinationPath);
    await destination.parent.create(recursive: true);
    try {
      final response = await api.files.get(
        backup.providerReference,
        downloadOptions: drive.DownloadOptions.fullMedia,
      );
      if (response is! drive.Media) {
        throw const BackupFailure('drive_download_invalid');
      }
      final sink = destination.openWrite();
      try {
        await sink.addStream(response.stream);
      } finally {
        await sink.close();
      }
      final byteSize = await destination.length();
      final sha256 = await _sha256Base64Url(destination);
      final verified = byteSize == backup.byteSize && sha256 == backup.sha256;
      if (!verified) {
        await destination.delete();
        throw const BackupFailure('drive_download_verification_failed');
      }
      return BackupDownloadResult(
        path: destination.path,
        byteSize: byteSize,
        sha256: sha256,
        verified: true,
      );
    } on Object {
      if (await destination.exists()) await destination.delete();
      rethrow;
    }
  }, failureCode: 'drive_download_failed');

  @override
  Future<List<RemoteBackupInfo>> listBackups() =>
      _withApi((api, account) async {
        final backups = <RemoteBackupInfo>[];
        String? pageToken;
        do {
          final response = await api.files.list(
            spaces: 'appDataFolder',
            q: 'trashed = false',
            pageSize: 100,
            pageToken: pageToken,
            $fields: _listFields,
          );
          for (final file in response.files ?? const <drive.File>[]) {
            final parsed = _remoteInfo(file);
            if (parsed != null) backups.add(parsed);
          }
          pageToken = response.nextPageToken;
        } while (pageToken != null && pageToken.isNotEmpty);
        backups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return backups;
      }, failureCode: 'drive_list_failed');

  @override
  Future<BackupDestinationStatus> status() async {
    if (!_platformSupported) {
      return const BackupDestinationStatus(
        availability: BackupDestinationAvailability.unavailable,
        detailCode: 'drive_platform_unavailable',
      );
    }
    if (_configurationMissing) {
      return const BackupDestinationStatus(
        availability: BackupDestinationAvailability.misconfigured,
        detailCode: 'drive_client_configuration_missing',
      );
    }
    try {
      final account = await _silentAccount();
      if (account == null) {
        return const BackupDestinationStatus(
          availability: BackupDestinationAvailability.needsAuthorization,
        );
      }
      final authorization = await account.authorizationClient
          .authorizationForScopes(_scopes);
      if (authorization == null) {
        return const BackupDestinationStatus(
          availability: BackupDestinationAvailability.needsAuthorization,
        );
      }
      final client = authorization.authClient(scopes: _scopes);
      client.close();
      return BackupDestinationStatus(
        availability: BackupDestinationAvailability.ready,
        accountLabel: account.email,
      );
    } on Object {
      return const BackupDestinationStatus(
        availability: BackupDestinationAvailability.unavailable,
        detailCode: 'drive_unavailable',
      );
    }
  }

  @override
  Future<BackupUploadResult> upload(VerifiedBackupArtifact artifact) =>
      _withApi((api, account) async {
        final source = File(artifact.path);
        if (!await source.exists() ||
            await source.length() != artifact.byteSize) {
          throw const BackupFailure('backup_artifact_missing');
        }
        final localHex = await _sha256Hex(source);
        final metadata = drive.File(
          name: _opaqueName(artifact.createdAt),
          mimeType: _mimeType,
          parents: const ['appDataFolder'],
          appProperties: {
            'kind': _backupKind,
            'backupId': artifact.backupId,
            'createdAt': artifact.createdAt.toIso8601String(),
            'formatVersion': '${artifact.formatVersion}',
            'schemaVersion': '${artifact.databaseSchemaVersion}',
            'byteSize': '${artifact.byteSize}',
            'sha256': artifact.sha256,
          },
        );
        final created = await api.files.create(
          metadata,
          uploadMedia: drive.Media(
            source.openRead(),
            artifact.byteSize,
            contentType: _mimeType,
          ),
          uploadOptions: drive.UploadOptions.resumable,
          $fields: _fields,
        );
        final id = created.id;
        final remoteSize = int.tryParse(created.size ?? '');
        final verified =
            id != null &&
            remoteSize == artifact.byteSize &&
            created.sha256Checksum == localHex &&
            created.appProperties?['sha256'] == artifact.sha256;
        if (!verified) {
          if (id != null) {
            try {
              await api.files.delete(id);
            } on Object {
              // Best effort only: never obscure the verification failure.
            }
          }
          throw const BackupFailure('drive_upload_verification_failed');
        }
        return BackupUploadResult(
          providerReference: id,
          verified: true,
          byteSize: artifact.byteSize,
          sha256: artifact.sha256,
        );
      }, failureCode: 'drive_upload_failed');

  Future<T> _withApi<T>(
    Future<T> Function(drive.DriveApi api, GoogleSignInAccount account)
    action, {
    required String failureCode,
  }) async {
    if (!_platformSupported || _configurationMissing) {
      throw const BackupFailure('drive_unavailable');
    }
    try {
      final account = await _silentAccount();
      if (account == null) {
        throw const BackupFailure('drive_authorization_required');
      }
      final authorization = await account.authorizationClient
          .authorizationForScopes(_scopes);
      if (authorization == null) {
        throw const BackupFailure('drive_authorization_required');
      }
      final client = authorization.authClient(scopes: _scopes);
      try {
        return await action(drive.DriveApi(client), account);
      } finally {
        client.close();
      }
    } on BackupFailure {
      rethrow;
    } on GoogleSignInException {
      throw const BackupFailure('drive_authorization_required');
    } on Object {
      throw BackupFailure(failureCode);
    }
  }

  Future<void> _ensureInitialized() => _initialization ??= _signIn.initialize(
    clientId: iosClientId.isEmpty ? null : iosClientId,
    serverClientId: serverClientId.isEmpty ? null : serverClientId,
  );

  Future<GoogleSignInAccount> _interactiveAccount() async {
    await _ensureInitialized();
    return _signIn.authenticate(scopeHint: _scopes);
  }

  Future<GoogleSignInAccount?> _silentAccount() async {
    await _ensureInitialized();
    final attempt = _signIn.attemptLightweightAuthentication();
    if (attempt == null) return null;
    return attempt;
  }

  static RemoteBackupInfo? _remoteInfo(drive.File file) {
    final properties = file.appProperties;
    if (file.trashed == true ||
        properties?['kind'] != _backupKind ||
        file.id == null) {
      return null;
    }
    final createdAt = DateTime.tryParse(
      properties?['createdAt'] ?? '',
    )?.toUtc();
    final formatVersion = int.tryParse(properties?['formatVersion'] ?? '');
    final schemaVersion = int.tryParse(properties?['schemaVersion'] ?? '');
    final byteSize = int.tryParse(properties?['byteSize'] ?? '');
    final sha256 = properties?['sha256'];
    final backupId = properties?['backupId'];
    if (createdAt == null ||
        formatVersion == null ||
        schemaVersion == null ||
        byteSize == null ||
        sha256 == null ||
        backupId == null ||
        int.tryParse(file.size ?? '') != byteSize) {
      return null;
    }
    return RemoteBackupInfo(
      providerReference: file.id!,
      backupId: backupId,
      createdAt: createdAt,
      formatVersion: formatVersion,
      databaseSchemaVersion: schemaVersion,
      byteSize: byteSize,
      sha256: sha256,
    );
  }

  static String _opaqueName(DateTime createdAt) =>
      'timeline-${createdAt.toUtc().toIso8601String().replaceAll(':', '-')}.timelinebackup';

  static BackupDestinationStatus _authorizationFailureStatus(
    GoogleSignInExceptionCode code,
  ) => switch (code) {
    GoogleSignInExceptionCode.canceled => const BackupDestinationStatus(
      availability: BackupDestinationAvailability.needsAuthorization,
      detailCode: 'drive_authorization_canceled',
    ),
    GoogleSignInExceptionCode.interrupted => const BackupDestinationStatus(
      availability: BackupDestinationAvailability.needsAuthorization,
      detailCode: 'drive_authorization_interrupted',
    ),
    GoogleSignInExceptionCode.clientConfigurationError =>
      const BackupDestinationStatus(
        availability: BackupDestinationAvailability.misconfigured,
        detailCode: 'drive_client_configuration_invalid',
      ),
    GoogleSignInExceptionCode.providerConfigurationError =>
      const BackupDestinationStatus(
        availability: BackupDestinationAvailability.unavailable,
        detailCode: 'drive_provider_configuration_error',
      ),
    GoogleSignInExceptionCode.uiUnavailable => const BackupDestinationStatus(
      availability: BackupDestinationAvailability.unavailable,
      detailCode: 'drive_authorization_ui_unavailable',
    ),
    GoogleSignInExceptionCode.userMismatch => const BackupDestinationStatus(
      availability: BackupDestinationAvailability.needsAuthorization,
      detailCode: 'drive_authorization_user_mismatch',
    ),
    _ => const BackupDestinationStatus(
      availability: BackupDestinationAvailability.unavailable,
      detailCode: 'drive_authorization_failed',
    ),
  };

  static Future<String> _sha256Base64Url(File file) async {
    final hash = await _hash(file);
    return base64UrlEncode(hash.bytes);
  }

  static Future<String> _sha256Hex(File file) async {
    final hash = await _hash(file);
    return hash.bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  static Future<Hash> _hash(File file) async {
    final sink = Sha256().newHashSink();
    await for (final chunk in file.openRead()) {
      sink.add(chunk);
    }
    sink.close();
    return sink.hash();
  }
}
