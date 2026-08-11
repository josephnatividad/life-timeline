import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:life_timeline/features/storage/domain/storage_models.dart';
import 'package:life_timeline/features/storage/domain/storage_ports.dart';

final class FilePickerArchiveStorage implements ArchiveStorage {
  const FilePickerArchiveStorage([
    this._androidChannel = const MethodChannel(
      'life_timeline/backup_destination',
    ),
  ]);

  final MethodChannel _androidChannel;

  @override
  Future<ArchiveDestinationReceipt?> saveArchive({
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
          throw const ArchiveFailure('archive_verification_failed');
        }
        throw const ArchiveFailure('archive_destination_unavailable');
      }
      if (result == null) return null;
      return ArchiveDestinationReceipt(
        logicalKey: suggestedName,
        verified: result['verified'] == true,
      );
    }

    final source = File(sourcePath);
    final destination = await FilePicker.platform.saveFile(
      dialogTitle: 'Save encrypted timeline archive',
      fileName: suggestedName,
      type: FileType.custom,
      allowedExtensions: const ['timelinearchive'],
      bytes: Platform.isIOS ? await source.readAsBytes() : null,
    );
    if (destination == null) return null;
    if (Platform.isIOS) {
      return ArchiveDestinationReceipt(
        logicalKey: suggestedName,
        verified: true,
      );
    }
    await source.copy(destination);
    return ArchiveDestinationReceipt(
      logicalKey: suggestedName,
      verified: await _matchesHash(destination, expectedSha256),
    );
  }

  @override
  Future<String?> chooseArchiveForRetrieval(ArchiveReference reference) async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Reconnect ${reference.logicalKey}',
      type: FileType.custom,
      allowedExtensions: const ['timelinearchive'],
      allowMultiple: false,
      withData: false,
    );
    return result?.files.single.path;
  }

  Future<bool> _matchesHash(String path, String expectedSha256) async {
    final file = File(path);
    if (!await file.exists()) return false;
    final sink = Sha256().newHashSink();
    await for (final chunk in file.openRead()) {
      sink.add(chunk);
    }
    sink.close();
    return base64UrlEncode((await sink.hash()).bytes) == expectedSha256;
  }
}
