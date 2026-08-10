import 'dart:convert';

import 'package:life_timeline/features/security/domain/security_models.dart';
import 'package:life_timeline/features/security/domain/security_ports.dart';
import 'package:life_timeline/shared/crypto/crypto_models.dart';

final class LocalAppUnlockService implements AppUnlockService {
  const LocalAppUnlockService(
    this._store,
    this._keyDeriver,
    this._biometrics, {
    DateTime Function()? now,
    KdfParameters pinKdf = const KdfParameters(memoryKiB: 19456, iterations: 2),
  }) : _now = now ?? DateTime.now,
       // ignore: prefer_initializing_formals
       _pinKdf = pinKdf;

  static const _pinKey = 'security.pin.verifier.v1';
  static const _retryKey = 'security.pin.retry.v1';

  final BiometricAuthenticator _biometrics;
  final PasswordKeyDeriver _keyDeriver;
  final DateTime Function() _now;
  final KdfParameters _pinKdf;
  final SecureKeyStore _store;

  @override
  Future<bool> hasPin() async => await _store.read(_pinKey) != null;

  @override
  Future<void> setPin(String pin) async {
    if (!RegExp(r'^\d{4,12}$').hasMatch(pin)) {
      throw const SecurityFailure('invalid_pin_format');
    }
    final salt = _keyDeriver.randomBytes(16);
    final digest = await _keyDeriver.derive(
      password: pin,
      salt: salt,
      parameters: _pinKdf,
    );
    try {
      await _store.write(
        _pinKey,
        jsonEncode({
          'version': 1,
          'salt': base64UrlEncode(salt),
          'digest': base64UrlEncode(digest),
          'kdf': _pinKdf.toJson(),
        }),
      );
      await _store.delete(_retryKey);
    } finally {
      _clear(digest);
    }
  }

  @override
  Future<PinAttemptResult> verifyPin(String pin) async {
    final encoded = await _store.read(_pinKey);
    if (encoded == null) {
      return const PinAttemptResult(PinAttemptStatus.notConfigured);
    }
    final now = _now().toUtc();
    final retry = await _loadRetry();
    if (retry.nextAllowedAt != null && now.isBefore(retry.nextAllowedAt!)) {
      return PinAttemptResult(
        PinAttemptStatus.throttled,
        retryAfter: retry.nextAllowedAt!.difference(now),
      );
    }
    try {
      final json = Map<String, Object?>.from(jsonDecode(encoded) as Map);
      final salt = base64Url.decode(json['salt'] as String);
      final expected = base64Url.decode(json['digest'] as String);
      final parameters = KdfParameters.fromJson(
        Map<String, Object?>.from(json['kdf']! as Map),
      );
      final actual = await _keyDeriver.derive(
        password: pin,
        salt: salt,
        parameters: parameters,
      );
      try {
        if (_keyDeriver.secureEquals(actual, expected)) {
          await _store.delete(_retryKey);
          return const PinAttemptResult(PinAttemptStatus.success);
        }
      } finally {
        _clear(actual);
        _clear(expected);
      }
    } on SecurityFailure {
      rethrow;
    } on Object {
      throw const SecurityFailure('pin_verifier_unreadable');
    }
    final failures = retry.failures + 1;
    final delay = _delayFor(failures);
    await _store.write(
      _retryKey,
      jsonEncode({
        'failures': failures,
        'nextAllowedAt': delay == Duration.zero
            ? null
            : now.add(delay).toIso8601String(),
      }),
    );
    return PinAttemptResult(
      delay == Duration.zero
          ? PinAttemptStatus.invalid
          : PinAttemptStatus.throttled,
      retryAfter: delay,
    );
  }

  @override
  Future<bool> biometricsAvailable() => _biometrics.isAvailable();

  @override
  Future<BiometricResult> unlockWithBiometrics() => _biometrics.authenticate();

  Future<_RetryState> _loadRetry() async {
    final encoded = await _store.read(_retryKey);
    if (encoded == null) {
      return const _RetryState();
    }
    try {
      final json = Map<String, Object?>.from(jsonDecode(encoded) as Map);
      return _RetryState(
        failures: json['failures'] as int? ?? 0,
        nextAllowedAt: json['nextAllowedAt'] == null
            ? null
            : DateTime.parse(json['nextAllowedAt'] as String).toUtc(),
      );
    } on Object {
      await _store.delete(_retryKey);
      return const _RetryState();
    }
  }

  Duration _delayFor(int failures) => switch (failures) {
    <= 2 => Duration.zero,
    3 => const Duration(seconds: 5),
    4 => const Duration(seconds: 15),
    5 => const Duration(minutes: 1),
    _ => const Duration(minutes: 5),
  };

  void _clear(List<int> bytes) {
    for (var index = 0; index < bytes.length; index++) {
      bytes[index] = 0;
    }
  }
}

final class _RetryState {
  const _RetryState({this.failures = 0, this.nextAllowedAt});

  final int failures;
  final DateTime? nextAllowedAt;
}
