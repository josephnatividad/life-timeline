import 'dart:convert';

import 'package:life_timeline/features/security/domain/security_ports.dart';
import 'package:life_timeline/shared/crypto/crypto_models.dart';

final class RecoveryPasswordService {
  const RecoveryPasswordService(this._store, this._keyDeriver);

  static const _key = 'backup.recovery.verifier.v1';
  static const _kdf = KdfParameters();

  final PasswordKeyDeriver _keyDeriver;
  final SecureKeyStore _store;

  Future<bool> isConfigured() async => await _store.read(_key) != null;

  Future<void> configure(String password) async {
    if (password.length < 8) {
      throw const CryptoFailure('recovery_password_too_short');
    }
    final salt = _keyDeriver.randomBytes(16);
    final digest = await _keyDeriver.derive(
      password: password,
      salt: salt,
      parameters: _kdf,
    );
    try {
      await _store.write(
        _key,
        jsonEncode({
          'version': 1,
          'salt': base64UrlEncode(salt),
          'digest': base64UrlEncode(digest),
          'kdf': _kdf.toJson(),
        }),
      );
    } finally {
      _clear(digest);
    }
  }

  Future<bool> verify(String password) async {
    final encoded = await _store.read(_key);
    if (encoded == null) {
      return false;
    }
    try {
      final json = Map<String, Object?>.from(jsonDecode(encoded) as Map);
      final salt = base64Url.decode(json['salt'] as String);
      final expected = base64Url.decode(json['digest'] as String);
      final kdf = KdfParameters.fromJson(
        Map<String, Object?>.from(json['kdf']! as Map),
      );
      final actual = await _keyDeriver.derive(
        password: password,
        salt: salt,
        parameters: kdf,
      );
      try {
        return _keyDeriver.secureEquals(actual, expected);
      } finally {
        _clear(actual);
        _clear(expected);
      }
    } on Object {
      return false;
    }
  }

  void _clear(List<int> bytes) {
    for (var index = 0; index < bytes.length; index++) {
      bytes[index] = 0;
    }
  }
}
