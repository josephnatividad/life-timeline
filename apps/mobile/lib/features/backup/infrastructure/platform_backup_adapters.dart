import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:life_timeline/features/backup/domain/backup_models.dart';
import 'package:life_timeline/features/backup/domain/backup_ports.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

final class FilePickerBackupDestination implements BackupDestination {
  const FilePickerBackupDestination([
    this._androidChannel = const MethodChannel(_androidChannelName),
  ]);

  static const _androidChannelName = 'life_timeline/backup_destination';

  final MethodChannel _androidChannel;

  @override
  Future<BackupDestinationReceipt?> saveExport({
    required String sourcePath,
    required String suggestedName,
    required String expectedSha256,
  }) async {
    if (Platform.isAndroid) {
      final Map<String, Object?>? result;
      try {
        result = await _androidChannel
            .invokeMapMethod<String, Object?>('saveBackup', {
              'sourcePath': sourcePath,
              'suggestedName': suggestedName,
              'expectedSha256': expectedSha256,
            });
      } on PlatformException catch (error) {
        if (error.code == 'backup_destination_verification_failed') {
          throw const BackupFailure('backup_destination_verification_failed');
        }
        throw const BackupFailure('backup_destination_write_failed');
      }
      if (result == null) {
        return null;
      }
      return BackupDestinationReceipt(
        displayPath: result['displayPath'] as String? ?? suggestedName,
        verified: result['verified'] == true,
      );
    }

    final source = File(sourcePath);
    final destination = await FilePicker.platform.saveFile(
      dialogTitle: 'Save encrypted timeline backup',
      fileName: suggestedName,
      type: FileType.custom,
      allowedExtensions: const ['timelinebackup'],
      bytes: Platform.isIOS ? await source.readAsBytes() : null,
    );
    if (destination == null) {
      return null;
    }
    if (Platform.isIOS) {
      // The native document picker only completes after it has accepted all
      // bytes. The encrypted staging file was verified before this call.
      return BackupDestinationReceipt(displayPath: destination, verified: true);
    }
    await source.copy(destination);
    return BackupDestinationReceipt(
      displayPath: destination,
      verified: await _matchesHash(destination, expectedSha256),
    );
  }

  @override
  Future<String?> chooseImportPath() async {
    if (Platform.isAndroid) {
      try {
        return await _androidChannel.invokeMethod<String>('openBackup');
      } on PlatformException {
        throw const BackupFailure('backup_file_selection_failed');
      }
    }
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Choose an encrypted timeline backup',
      type: FileType.custom,
      allowedExtensions: const ['timelinebackup'],
      allowMultiple: false,
      withData: false,
    );
    if (result == null) return null;
    final path = result.files.single.path;
    if (path == null || path.isEmpty) {
      throw const BackupFailure('backup_file_selection_failed');
    }
    return path;
  }

  Future<bool> _matchesHash(String path, String expectedSha256) async {
    final file = File(path);
    if (!await file.exists()) {
      return false;
    }
    final sink = Sha256().newHashSink();
    await for (final chunk in file.openRead()) {
      sink.add(chunk);
    }
    sink.close();
    final hash = await sink.hash();
    return base64UrlEncode(hash.bytes) == expectedSha256;
  }
}

final class PathProviderManagedAttachmentStorage
    implements ManagedAttachmentStorage {
  const PathProviderManagedAttachmentStorage();

  @override
  Future<String> rootPath() async {
    final support = await getApplicationSupportDirectory();
    final root = Directory(p.join(support.path, 'attachments'));
    await root.create(recursive: true);
    return root.path;
  }

  @override
  Future<String> temporaryRootPath() async {
    final temporary = await getTemporaryDirectory();
    final root = Directory(p.join(temporary.path, 'timeline_backup_staging'));
    await root.create(recursive: true);
    return root.path;
  }
}

final class PackageInfoAppVersionProvider implements AppVersionProvider {
  const PackageInfoAppVersionProvider();

  @override
  Future<String> version() async {
    final package = await PackageInfo.fromPlatform();
    return '${package.version}+${package.buildNumber}';
  }
}
