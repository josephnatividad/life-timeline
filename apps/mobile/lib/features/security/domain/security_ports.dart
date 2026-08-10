import 'package:life_timeline/features/security/domain/security_models.dart';

abstract interface class SecureKeyStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
  Future<void> clear();
}

/// Establishes a fresh-install boundary before device-bound state is read.
///
/// Some platform keystores can outlive the application container. A new
/// install must not inherit stale lock state that could block local recovery.
abstract interface class InstallSecretBoundary {
  Future<void> prepare();
}

abstract interface class SecuritySettingsStore {
  Future<SecuritySettings> load();
  Future<void> save(SecuritySettings settings);
}

abstract interface class BiometricAuthenticator {
  Future<bool> isAvailable();
  Future<BiometricResult> authenticate();
}

abstract interface class AppUnlockService {
  Future<bool> hasPin();
  Future<void> setPin(String pin);
  Future<PinAttemptResult> verifyPin(String pin);
  Future<BiometricResult> unlockWithBiometrics();
  Future<bool> biometricsAvailable();
}
