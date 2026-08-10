import 'dart:convert';

final class KdfParameters {
  const KdfParameters({
    this.algorithm = 'argon2id',
    this.memoryKiB = 19456,
    this.iterations = 2,
    this.parallelism = 1,
    this.hashLength = 32,
  });

  factory KdfParameters.fromJson(Map<String, Object?> json) {
    final value = KdfParameters(
      algorithm: json['algorithm'] as String? ?? '',
      memoryKiB: json['memoryKiB'] as int? ?? 0,
      iterations: json['iterations'] as int? ?? 0,
      parallelism: json['parallelism'] as int? ?? 0,
      hashLength: json['hashLength'] as int? ?? 0,
    );
    value.validate();
    return value;
  }

  final String algorithm;
  final int hashLength;
  final int iterations;
  final int memoryKiB;
  final int parallelism;

  Map<String, Object> toJson() => {
    'algorithm': algorithm,
    'memoryKiB': memoryKiB,
    'iterations': iterations,
    'parallelism': parallelism,
    'hashLength': hashLength,
  };

  void validate() {
    if (algorithm != 'argon2id' ||
        memoryKiB < 1024 ||
        memoryKiB > 262144 ||
        iterations < 1 ||
        iterations > 10 ||
        parallelism < 1 ||
        parallelism > 8 ||
        hashLength != 32) {
      throw const CryptoFailure('unsupported_kdf');
    }
  }
}

final class EncryptedContainerHeader {
  const EncryptedContainerHeader({
    required this.formatVersion,
    required this.createdAt,
    required this.databaseSchemaVersion,
    required this.attachmentCount,
    required this.payloadLength,
    required this.kdf,
    required this.salt,
    required this.nonce,
    this.cipher = 'aes-256-gcm',
  });

  factory EncryptedContainerHeader.fromJson(Map<String, Object?> json) {
    final value = EncryptedContainerHeader(
      formatVersion: json['formatVersion'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
      databaseSchemaVersion: json['databaseSchemaVersion'] as int? ?? 0,
      attachmentCount: json['attachmentCount'] as int? ?? -1,
      payloadLength: json['payloadLength'] as int? ?? -1,
      kdf: KdfParameters.fromJson(
        Map<String, Object?>.from(json['kdf']! as Map),
      ),
      salt: base64Url.decode(json['salt'] as String),
      nonce: base64Url.decode(json['nonce'] as String),
      cipher: json['cipher'] as String? ?? '',
    );
    value.validate();
    return value;
  }

  final int attachmentCount;
  final String cipher;
  final DateTime createdAt;
  final int databaseSchemaVersion;
  final int formatVersion;
  final KdfParameters kdf;
  final List<int> nonce;
  final int payloadLength;
  final List<int> salt;

  Map<String, Object> toJson() => {
    'formatVersion': formatVersion,
    'createdAt': createdAt.toIso8601String(),
    'databaseSchemaVersion': databaseSchemaVersion,
    'attachmentCount': attachmentCount,
    'payloadLength': payloadLength,
    'cipher': cipher,
    'kdf': kdf.toJson(),
    'salt': base64UrlEncode(salt),
    'nonce': base64UrlEncode(nonce),
  };

  void validate() {
    if (formatVersion != 1 ||
        cipher != 'aes-256-gcm' ||
        databaseSchemaVersion < 1 ||
        attachmentCount < 0 ||
        payloadLength < 0 ||
        payloadLength > 1 << 40 ||
        salt.length != 16 ||
        nonce.length != 12) {
      throw const CryptoFailure('invalid_header');
    }
    kdf.validate();
  }
}

final class CryptoFailure implements Exception {
  const CryptoFailure(this.code);

  final String code;

  @override
  String toString() => 'CryptoFailure($code)';
}

abstract interface class PasswordKeyDeriver {
  List<int> randomBytes(int length);

  Future<List<int>> derive({
    required String password,
    required List<int> salt,
    required KdfParameters parameters,
  });

  bool secureEquals(List<int> left, List<int> right);
}

abstract interface class EncryptionService {
  Future<EncryptedContainerHeader> inspect(String encryptedPath);

  Future<EncryptedContainerHeader> encryptFile({
    required String inputPath,
    required String outputPath,
    required String password,
    required DateTime createdAt,
    required int databaseSchemaVersion,
    required int attachmentCount,
    KdfParameters kdf = const KdfParameters(),
  });

  Future<void> decryptFile({
    required String inputPath,
    required String outputPath,
    required String password,
  });

  Future<String> sha256File(String path);
}
