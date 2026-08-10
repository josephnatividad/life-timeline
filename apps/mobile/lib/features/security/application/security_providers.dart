import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:life_timeline/features/security/application/local_app_unlock_service.dart';
import 'package:life_timeline/features/security/domain/security_models.dart';
import 'package:life_timeline/features/security/domain/security_ports.dart';
import 'package:life_timeline/features/security/infrastructure/file_install_secret_boundary.dart';
import 'package:life_timeline/features/security/infrastructure/local_biometric_authenticator.dart';
import 'package:life_timeline/features/security/infrastructure/secure_storage_adapters.dart';
import 'package:life_timeline/shared/crypto/crypto_models.dart';
import 'package:life_timeline/shared/crypto/cryptography_password_key_deriver.dart';
import 'package:local_auth/local_auth.dart';

final secureKeyStoreProvider = Provider<SecureKeyStore>((ref) {
  return const FlutterSecureKeyStore(
    FlutterSecureStorage(
      aOptions: AndroidOptions(migrateWithBackup: true),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.unlocked_this_device,
      ),
    ),
  );
});

final passwordKeyDeriverProvider = Provider<PasswordKeyDeriver>((ref) {
  return const CryptographyPasswordKeyDeriver();
});

final installSecretBoundaryProvider = Provider<InstallSecretBoundary>((ref) {
  return FileInstallSecretBoundary(ref.watch(secureKeyStoreProvider));
});

final biometricAuthenticatorProvider = Provider<BiometricAuthenticator>((ref) {
  return LocalBiometricAuthenticator(
    LocalAuthBiometricPlatform(LocalAuthentication()),
  );
});

final securitySettingsStoreProvider = Provider<SecuritySettingsStore>((ref) {
  return SecureStorageSecuritySettingsStore(
    ref.watch(secureKeyStoreProvider),
    ref.watch(installSecretBoundaryProvider),
  );
});

final appUnlockServiceProvider = Provider<AppUnlockService>((ref) {
  return LocalAppUnlockService(
    ref.watch(secureKeyStoreProvider),
    ref.watch(passwordKeyDeriverProvider),
    ref.watch(biometricAuthenticatorProvider),
  );
});

final securityControllerProvider =
    AsyncNotifierProvider<SecurityController, SecuritySessionState>(
      SecurityController.new,
    );

class SecurityController extends AsyncNotifier<SecuritySessionState> {
  @override
  Future<SecuritySessionState> build() async {
    final settings = await ref.watch(securitySettingsStoreProvider).load();
    final available = await ref
        .watch(appUnlockServiceProvider)
        .biometricsAvailable();
    return SecuritySessionState(
      settings: settings,
      locked: settings.appLockEnabled,
      biometricAvailable: available,
    );
  }

  Future<PinAttemptResult> unlockWithPin(String pin) async {
    final result = await ref.read(appUnlockServiceProvider).verifyPin(pin);
    final value = state.value;
    if (result.status == PinAttemptStatus.success && value != null) {
      state = AsyncData(
        value.copyWith(locked: false, clearBackgroundedAt: true),
      );
    }
    return result;
  }

  Future<BiometricResult> unlockWithBiometrics() async {
    final result = await ref
        .read(appUnlockServiceProvider)
        .unlockWithBiometrics();
    final value = state.value;
    if (result == BiometricResult.success && value != null) {
      state = AsyncData(
        value.copyWith(locked: false, clearBackgroundedAt: true),
      );
    }
    return result;
  }

  Future<void> configurePin(String pin) async {
    await ref.read(appUnlockServiceProvider).setPin(pin);
    await _updateSettings(
      (settings) => settings.copyWith(appLockEnabled: true),
    );
  }

  Future<PinAttemptResult> verifyCurrentPin(String pin) =>
      ref.read(appUnlockServiceProvider).verifyPin(pin);

  Future<bool> hasPin() => ref.read(appUnlockServiceProvider).hasPin();

  Future<void> setAppLockEnabled(bool enabled) async {
    if (enabled && !await hasPin()) {
      throw const SecurityFailure('pin_required');
    }
    await _updateSettings(
      (settings) => settings.copyWith(appLockEnabled: enabled),
    );
  }

  Future<BiometricResult> setBiometricsEnabled(bool enabled) async {
    final value = state.value;
    if (value == null) {
      return BiometricResult.unavailable;
    }
    if (enabled && !value.biometricAvailable) {
      return BiometricResult.unavailable;
    }
    if (enabled) {
      final result = await ref
          .read(appUnlockServiceProvider)
          .unlockWithBiometrics();
      if (result != BiometricResult.success) {
        return result;
      }
    }
    await _updateSettings(
      (settings) => settings.copyWith(biometricsEnabled: enabled),
    );
    return BiometricResult.success;
  }

  Future<void> setAutoLock(AutoLockPreference preference) =>
      _updateSettings((settings) => settings.copyWith(autoLock: preference));

  Future<void> setRecoveryConfigured(bool configured) => _updateSettings(
    (settings) => settings.copyWith(recoveryConfigured: configured),
  );

  void lock() {
    final value = state.value;
    if (value != null && value.settings.appLockEnabled) {
      state = AsyncData(
        value.copyWith(locked: true, clearBackgroundedAt: true),
      );
    }
  }

  void onBackgrounded([DateTime? at]) {
    final value = state.value;
    if (value == null || !value.settings.appLockEnabled) {
      return;
    }
    state = AsyncData(
      value.copyWith(backgroundedAt: (at ?? DateTime.now()).toUtc()),
    );
  }

  void onResumed([DateTime? at]) {
    final value = state.value;
    if (value == null ||
        !value.settings.appLockEnabled ||
        value.backgroundedAt == null) {
      return;
    }
    final delay = value.settings.autoLock.backgroundDelay;
    final shouldLock =
        delay != null &&
        !(at ?? DateTime.now()).toUtc().isBefore(
          value.backgroundedAt!.add(delay),
        );
    state = AsyncData(
      value.copyWith(
        locked: shouldLock || value.locked,
        clearBackgroundedAt: true,
      ),
    );
  }

  Future<void> _updateSettings(
    SecuritySettings Function(SecuritySettings settings) update,
  ) async {
    final value = state.value;
    if (value == null) {
      throw const SecurityFailure('settings_unavailable');
    }
    final updated = update(value.settings);
    await ref.read(securitySettingsStoreProvider).save(updated);
    state = AsyncData(value.copyWith(settings: updated));
  }
}
