import 'package:life_timeline/features/security/domain/security_models.dart';
import 'package:life_timeline/features/security/domain/security_ports.dart';
import 'package:local_auth/local_auth.dart';

final class LocalBiometricAuthenticator implements BiometricAuthenticator {
  LocalBiometricAuthenticator(this._platform);

  final LocalBiometricPlatform _platform;

  @override
  Future<bool> isAvailable() async {
    try {
      if ((await _platform.enrolledBiometrics()).isNotEmpty) {
        return true;
      }
    } on LocalAuthException {
      // Some Android implementations fail or under-report the enrolled list.
      // The biometric-only system prompt remains the final capability check.
    }
    try {
      return await _platform.supportsBiometrics();
    } on LocalAuthException {
      return false;
    }
  }

  @override
  Future<BiometricResult> authenticate() async {
    if (!await isAvailable()) {
      return BiometricResult.unavailable;
    }
    try {
      final authenticated = await _platform.authenticate();
      return authenticated ? BiometricResult.success : BiometricResult.canceled;
    } on LocalAuthException catch (error) {
      return switch (error.code) {
        LocalAuthExceptionCode.temporaryLockout ||
        LocalAuthExceptionCode.biometricLockout =>
          BiometricResult.temporarilyLocked,
        LocalAuthExceptionCode.noBiometricHardware ||
        LocalAuthExceptionCode.noBiometricsEnrolled =>
          BiometricResult.unavailable,
        _ => BiometricResult.failed,
      };
    }
  }
}

abstract interface class LocalBiometricPlatform {
  Future<List<BiometricType>> enrolledBiometrics();
  Future<bool> supportsBiometrics();
  Future<bool> authenticate();
}

final class LocalAuthBiometricPlatform implements LocalBiometricPlatform {
  LocalAuthBiometricPlatform(this._authentication);

  final LocalAuthentication _authentication;

  @override
  Future<List<BiometricType>> enrolledBiometrics() =>
      _authentication.getAvailableBiometrics();

  @override
  Future<bool> supportsBiometrics() => _authentication.canCheckBiometrics;

  @override
  Future<bool> authenticate() => _authentication.authenticate(
    localizedReason: 'Unlock your private timeline',
    biometricOnly: true,
    persistAcrossBackgrounding: true,
  );
}
