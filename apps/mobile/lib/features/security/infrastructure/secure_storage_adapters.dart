import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:life_timeline/features/security/domain/security_models.dart';
import 'package:life_timeline/features/security/domain/security_ports.dart';

final class FlutterSecureKeyStore implements SecureKeyStore {
  const FlutterSecureKeyStore(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<void> clear() => _storage.deleteAll();
}

final class SecureStorageSecuritySettingsStore
    implements SecuritySettingsStore {
  const SecureStorageSecuritySettingsStore(this._store, this._installBoundary);

  static const _settingsKey = 'security.settings.v1';

  final SecureKeyStore _store;
  final InstallSecretBoundary _installBoundary;

  @override
  Future<SecuritySettings> load() async {
    await _installBoundary.prepare();
    final encoded = await _store.read(_settingsKey);
    if (encoded == null) {
      return const SecuritySettings();
    }
    try {
      return SecuritySettings.fromJson(
        Map<String, Object?>.from(jsonDecode(encoded) as Map),
      );
    } on Object {
      throw const SecurityFailure('settings_unreadable');
    }
  }

  @override
  Future<void> save(SecuritySettings settings) async {
    await _installBoundary.prepare();
    await _store.write(_settingsKey, jsonEncode(settings.toJson()));
  }
}
