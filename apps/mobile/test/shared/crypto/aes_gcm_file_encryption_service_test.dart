import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/shared/crypto/aes_gcm_file_encryption_service.dart';
import 'package:life_timeline/shared/crypto/crypto_models.dart';
import 'package:life_timeline/shared/crypto/cryptography_password_key_deriver.dart';

void main() {
  const password = 'correct horse battery staple';
  const testKdf = KdfParameters(memoryKiB: 1024, iterations: 1);
  late Directory temporary;
  late AesGcmFileEncryptionService encryption;

  setUp(() async {
    temporary = await Directory.systemTemp.createTemp('timeline_crypto_test');
    encryption = const AesGcmFileEncryptionService(
      CryptographyPasswordKeyDeriver(),
    );
  });

  tearDown(() async {
    if (await temporary.exists()) {
      await temporary.delete(recursive: true);
    }
  });

  test('AES-GCM encrypted file round trips', () async {
    final clear = File('${temporary.path}/clear.bin')
      ..writeAsStringSync('private timeline payload');
    final encrypted = '${temporary.path}/backup.timelinebackup';
    final restored = '${temporary.path}/restored.bin';

    await encryption.encryptFile(
      inputPath: clear.path,
      outputPath: encrypted,
      password: password,
      createdAt: DateTime.utc(2026, 8, 10),
      databaseSchemaVersion: 2,
      attachmentCount: 0,
      kdf: testKdf,
    );
    await encryption.decryptFile(
      inputPath: encrypted,
      outputPath: restored,
      password: password,
    );

    expect(await File(restored).readAsString(), 'private timeline payload');
  });

  test(
    'wrong password and modified ciphertext both fail authentication',
    () async {
      final clear = File('${temporary.path}/clear.bin')
        ..writeAsStringSync('private timeline payload');
      final encrypted = '${temporary.path}/backup.timelinebackup';
      await encryption.encryptFile(
        inputPath: clear.path,
        outputPath: encrypted,
        password: password,
        createdAt: DateTime.utc(2026, 8, 10),
        databaseSchemaVersion: 2,
        attachmentCount: 0,
        kdf: testKdf,
      );

      expect(
        () => encryption.decryptFile(
          inputPath: encrypted,
          outputPath: '${temporary.path}/wrong.bin',
          password: 'wrong password',
        ),
        throwsA(isA<CryptoFailure>()),
      );

      final bytes = await File(encrypted).readAsBytes();
      bytes[bytes.length ~/ 2] ^= 1;
      await File(encrypted).writeAsBytes(bytes, flush: true);
      expect(
        () => encryption.decryptFile(
          inputPath: encrypted,
          outputPath: '${temporary.path}/tampered.bin',
          password: password,
        ),
        throwsA(isA<CryptoFailure>()),
      );
    },
  );

  test('fresh random salt and nonce produce different containers', () async {
    final clear = File('${temporary.path}/clear.bin')
      ..writeAsStringSync('same payload');
    final first = '${temporary.path}/first.timelinebackup';
    final second = '${temporary.path}/second.timelinebackup';
    for (final output in [first, second]) {
      await encryption.encryptFile(
        inputPath: clear.path,
        outputPath: output,
        password: password,
        createdAt: DateTime.utc(2026, 8, 10),
        databaseSchemaVersion: 2,
        attachmentCount: 0,
        kdf: testKdf,
      );
    }

    expect(
      await File(first).readAsBytes(),
      isNot(orderedEquals(await File(second).readAsBytes())),
    );
    expect(
      (await encryption.inspect(first)).salt,
      isNot(orderedEquals((await encryption.inspect(second)).salt)),
    );
  });

  test('container metadata serializes no password or usable key', () async {
    final clear = File('${temporary.path}/clear.bin')
      ..writeAsStringSync('payload');
    final output = '${temporary.path}/backup.timelinebackup';
    await encryption.encryptFile(
      inputPath: clear.path,
      outputPath: output,
      password: password,
      createdAt: DateTime.utc(2026, 8, 10),
      databaseSchemaVersion: 2,
      attachmentCount: 0,
      kdf: testKdf,
    );
    final prefix = latin1.decode(
      (await File(output).readAsBytes()).take(4096).toList(),
      allowInvalid: true,
    );

    expect(prefix, isNot(contains(password)));
    expect(prefix, isNot(contains('derivedKey')));
    expect(prefix, isNot(contains('plaintextKey')));
  });
}
