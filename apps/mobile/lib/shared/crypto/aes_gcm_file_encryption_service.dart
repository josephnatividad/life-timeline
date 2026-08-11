import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:life_timeline/shared/crypto/crypto_models.dart';

final class AesGcmFileEncryptionService implements EncryptionService {
  const AesGcmFileEncryptionService(
    this._keyDeriver, {
    this.magic = 'LTBACK01',
  });

  static const _macLength = 16;
  static const _maxHeaderLength = 16 * 1024;

  final PasswordKeyDeriver _keyDeriver;
  final String magic;

  List<int> get _magic {
    final value = ascii.encode(magic);
    if (value.length != 8) throw const CryptoFailure('invalid_magic');
    return value;
  }

  @override
  Future<EncryptedContainerHeader> inspect(String encryptedPath) async {
    final parsed = await _readHeader(File(encryptedPath));
    return parsed.header;
  }

  @override
  Future<EncryptedContainerHeader> encryptFile({
    required String inputPath,
    required String outputPath,
    required String password,
    required DateTime createdAt,
    required int databaseSchemaVersion,
    required int attachmentCount,
    KdfParameters kdf = const KdfParameters(),
  }) async {
    if (password.isEmpty) {
      throw const CryptoFailure('empty_password');
    }
    final input = File(inputPath);
    final payloadLength = await input.length();
    final salt = _keyDeriver.randomBytes(16);
    final algorithm = AesGcm.with256bits();
    final nonce = algorithm.newNonce();
    final header = EncryptedContainerHeader(
      formatVersion: 1,
      createdAt: createdAt.toUtc(),
      databaseSchemaVersion: databaseSchemaVersion,
      attachmentCount: attachmentCount,
      payloadLength: payloadLength,
      kdf: kdf,
      salt: salt,
      nonce: nonce,
    );
    header.validate();
    final headerBytes = utf8.encode(jsonEncode(header.toJson()));
    if (headerBytes.length > _maxHeaderLength) {
      throw const CryptoFailure('invalid_header');
    }
    final keyBytes = await _keyDeriver.derive(
      password: password,
      salt: salt,
      parameters: kdf,
    );
    final output = File(outputPath);
    await output.parent.create(recursive: true);
    final sink = output.openWrite();
    Mac? mac;
    try {
      sink.add(_magic);
      sink.add(_uint32(headerBytes.length));
      sink.add(headerBytes);
      final encrypted = algorithm.encryptStream(
        input.openRead(),
        secretKey: SecretKey(keyBytes),
        nonce: nonce,
        aad: headerBytes,
        onMac: (value) => mac = value,
      );
      await sink.addStream(encrypted);
      final authenticationTag = mac;
      if (authenticationTag == null ||
          authenticationTag.bytes.length != _macLength) {
        throw const CryptoFailure('encryption_failed');
      }
      sink.add(authenticationTag.bytes);
      await sink.flush();
    } on CryptoFailure {
      rethrow;
    } on Object {
      throw const CryptoFailure('encryption_failed');
    } finally {
      await sink.close();
      _clear(keyBytes);
    }
    return header;
  }

  @override
  Future<void> decryptFile({
    required String inputPath,
    required String outputPath,
    required String password,
  }) async {
    if (password.isEmpty) {
      throw const CryptoFailure('authentication_failed');
    }
    final input = File(inputPath);
    final parsed = await _readHeader(input);
    final fileLength = await input.length();
    final expectedLength =
        parsed.ciphertextOffset + parsed.header.payloadLength + _macLength;
    if (fileLength != expectedLength) {
      throw const CryptoFailure('invalid_container_length');
    }
    final random = await input.open();
    late List<int> macBytes;
    try {
      await random.setPosition(fileLength - _macLength);
      macBytes = await random.read(_macLength);
    } finally {
      await random.close();
    }
    final keyBytes = await _keyDeriver.derive(
      password: password,
      salt: parsed.header.salt,
      parameters: parsed.header.kdf,
    );
    final output = File(outputPath);
    await output.parent.create(recursive: true);
    final sink = output.openWrite();
    CryptoFailure? failure;
    try {
      final decrypted = AesGcm.with256bits().decryptStream(
        input.openRead(
          parsed.ciphertextOffset,
          parsed.ciphertextOffset + parsed.header.payloadLength,
        ),
        secretKey: SecretKey(keyBytes),
        nonce: parsed.header.nonce,
        mac: Mac(macBytes),
        aad: parsed.headerBytes,
      );
      await sink.addStream(decrypted);
      await sink.flush();
    } on SecretBoxAuthenticationError {
      failure = const CryptoFailure('authentication_failed');
    } on Object {
      failure = const CryptoFailure('decryption_failed');
    } finally {
      try {
        await sink.close();
      } on FileSystemException {
        if (failure == null) {
          rethrow;
        }
        // A stream authentication error may already have closed the sink.
      }
      _clear(keyBytes);
    }
    if (failure != null) {
      if (await output.exists()) {
        await output.delete();
      }
      throw failure;
    }
  }

  @override
  Future<String> sha256File(String path) async {
    final sink = Sha256().newHashSink();
    await for (final chunk in File(path).openRead()) {
      sink.add(chunk);
    }
    sink.close();
    final hash = await sink.hash();
    return base64UrlEncode(hash.bytes);
  }

  Future<_ParsedHeader> _readHeader(File input) async {
    final random = await input.open();
    try {
      final magic = await random.read(_magic.length);
      if (!_keyDeriver.secureEquals(magic, _magic)) {
        throw const CryptoFailure('invalid_magic');
      }
      final lengthBytes = await random.read(4);
      if (lengthBytes.length != 4) {
        throw const CryptoFailure('invalid_header');
      }
      final headerLength = ByteData.sublistView(
        Uint8List.fromList(lengthBytes),
      ).getUint32(0);
      if (headerLength <= 0 || headerLength > _maxHeaderLength) {
        throw const CryptoFailure('invalid_header');
      }
      final headerBytes = await random.read(headerLength);
      if (headerBytes.length != headerLength) {
        throw const CryptoFailure('invalid_header');
      }
      final decoded = jsonDecode(utf8.decode(headerBytes));
      if (decoded is! Map) {
        throw const CryptoFailure('invalid_header');
      }
      final header = EncryptedContainerHeader.fromJson(
        Map<String, Object?>.from(decoded),
      );
      return _ParsedHeader(
        header: header,
        headerBytes: headerBytes,
        ciphertextOffset: _magic.length + 4 + headerLength,
      );
    } on CryptoFailure {
      rethrow;
    } on Object {
      throw const CryptoFailure('invalid_header');
    } finally {
      await random.close();
    }
  }

  Uint8List _uint32(int value) =>
      (ByteData(4)..setUint32(0, value)).buffer.asUint8List();

  void _clear(List<int> bytes) {
    for (var index = 0; index < bytes.length; index++) {
      bytes[index] = 0;
    }
  }
}

final class _ParsedHeader {
  const _ParsedHeader({
    required this.header,
    required this.headerBytes,
    required this.ciphertextOffset,
  });

  final int ciphertextOffset;
  final EncryptedContainerHeader header;
  final List<int> headerBytes;
}
