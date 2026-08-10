import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/features/security/application/local_app_unlock_service.dart';
import 'package:life_timeline/features/security/application/security_providers.dart';
import 'package:life_timeline/features/security/domain/security_models.dart';
import 'package:life_timeline/features/security/domain/security_ports.dart';
import 'package:life_timeline/features/security/infrastructure/file_install_secret_boundary.dart';
import 'package:life_timeline/shared/crypto/crypto_models.dart';
import 'package:life_timeline/shared/crypto/cryptography_password_key_deriver.dart';

void main() {
  const testKdf = KdfParameters(memoryKiB: 1024, iterations: 1);

  test('PIN verifier accepts the PIN without storing the raw value', () async {
    final store = InMemorySecureKeyStore();
    final service = LocalAppUnlockService(
      store,
      const CryptographyPasswordKeyDeriver(),
      const FakeBiometricAuthenticator(),
      pinKdf: testKdf,
    );

    await service.setPin('2468');

    expect(store.values.values.any((value) => value.contains('2468')), isFalse);
    expect((await service.verifyPin('2468')).status, PinAttemptStatus.success);
    expect((await service.verifyPin('1357')).status, PinAttemptStatus.invalid);
  });

  test('repeated invalid PIN attempts are throttled persistently', () async {
    final store = InMemorySecureKeyStore();
    var now = DateTime.utc(2026, 8, 10, 12);
    final service = LocalAppUnlockService(
      store,
      const CryptographyPasswordKeyDeriver(),
      const FakeBiometricAuthenticator(),
      now: () => now,
      pinKdf: testKdf,
    );
    await service.setPin('2468');

    expect((await service.verifyPin('0000')).status, PinAttemptStatus.invalid);
    expect((await service.verifyPin('0000')).status, PinAttemptStatus.invalid);
    final third = await service.verifyPin('0000');
    expect(third.status, PinAttemptStatus.throttled);
    expect(third.retryAfter, const Duration(seconds: 5));
    expect(
      (await service.verifyPin('2468')).status,
      PinAttemptStatus.throttled,
    );

    now = now.add(const Duration(seconds: 5));
    expect((await service.verifyPin('2468')).status, PinAttemptStatus.success);
  });

  test('biometric failure never removes PIN fallback', () async {
    final store = InMemorySecureKeyStore();
    final service = LocalAppUnlockService(
      store,
      const CryptographyPasswordKeyDeriver(),
      const FakeBiometricAuthenticator(
        result: BiometricResult.temporarilyLocked,
      ),
      pinKdf: testKdf,
    );
    await service.setPin('2468');

    expect(
      await service.unlockWithBiometrics(),
      BiometricResult.temporarilyLocked,
    );
    expect((await service.verifyPin('2468')).status, PinAttemptStatus.success);
  });

  test(
    'biometrics are enabled only after successful system verification',
    () async {
      final store = FakeSecuritySettingsStore(
        const SecuritySettings(appLockEnabled: true),
      );
      final unlock = FakeAppUnlockService(
        biometricAvailable: true,
        biometricResult: BiometricResult.success,
      );
      final container = ProviderContainer(
        overrides: [
          securitySettingsStoreProvider.overrideWithValue(store),
          appUnlockServiceProvider.overrideWithValue(unlock),
        ],
      );
      addTearDown(container.dispose);
      await container.read(securityControllerProvider.future);

      final result = await container
          .read(securityControllerProvider.notifier)
          .setBiometricsEnabled(true);

      expect(result, BiometricResult.success);
      expect(unlock.biometricAttempts, 1);
      expect(store.settings.biometricsEnabled, isTrue);
    },
  );

  test('failed biometric verification leaves the setting disabled', () async {
    final store = FakeSecuritySettingsStore(
      const SecuritySettings(appLockEnabled: true),
    );
    final unlock = FakeAppUnlockService(
      biometricAvailable: true,
      biometricResult: BiometricResult.canceled,
    );
    final container = ProviderContainer(
      overrides: [
        securitySettingsStoreProvider.overrideWithValue(store),
        appUnlockServiceProvider.overrideWithValue(unlock),
      ],
    );
    addTearDown(container.dispose);
    await container.read(securityControllerProvider.future);

    final result = await container
        .read(securityControllerProvider.notifier)
        .setBiometricsEnabled(true);

    expect(result, BiometricResult.canceled);
    expect(store.settings.biometricsEnabled, isFalse);
  });

  test('auto-lock applies configured background delays', () async {
    final store = FakeSecuritySettingsStore(
      const SecuritySettings(
        appLockEnabled: true,
        autoLock: AutoLockPreference.oneMinute,
      ),
    );
    final unlock = FakeAppUnlockService();
    final container = ProviderContainer(
      overrides: [
        securitySettingsStoreProvider.overrideWithValue(store),
        appUnlockServiceProvider.overrideWithValue(unlock),
      ],
    );
    addTearDown(container.dispose);
    await container.read(securityControllerProvider.future);
    final controller = container.read(securityControllerProvider.notifier);
    await controller.unlockWithPin('2468');
    expect(container.read(securityControllerProvider).value?.locked, isFalse);

    final at = DateTime.utc(2026, 8, 10, 12);
    controller.onBackgrounded(at);
    controller.onResumed(at.add(const Duration(seconds: 59)));
    expect(container.read(securityControllerProvider).value?.locked, isFalse);

    controller.onBackgrounded(at);
    controller.onResumed(at.add(const Duration(minutes: 1)));
    expect(container.read(securityControllerProvider).value?.locked, isTrue);
  });

  test(
    'fresh application container clears stale device secrets once',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'timeline_install_boundary',
      );
      addTearDown(() => directory.delete(recursive: true));
      final store = InMemorySecureKeyStore()..values['stale'] = 'lock-state';
      final first = FileInstallSecretBoundary(
        store,
        supportDirectory: () async => directory,
      );

      await first.prepare();
      expect(store.values, isEmpty);
      store.values['current'] = 'keep-me';

      final nextLaunch = FileInstallSecretBoundary(
        store,
        supportDirectory: () async => directory,
      );
      await nextLaunch.prepare();
      expect(store.values['current'], 'keep-me');
    },
  );
}

final class InMemorySecureKeyStore implements SecureKeyStore {
  final values = <String, String>{};

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> clear() async => values.clear();
}

final class FakeBiometricAuthenticator implements BiometricAuthenticator {
  const FakeBiometricAuthenticator({this.result = BiometricResult.success});

  final BiometricResult result;

  @override
  Future<BiometricResult> authenticate() async => result;

  @override
  Future<bool> isAvailable() async => true;
}

final class FakeSecuritySettingsStore implements SecuritySettingsStore {
  FakeSecuritySettingsStore(this.settings);

  SecuritySettings settings;

  @override
  Future<SecuritySettings> load() async => settings;

  @override
  Future<void> save(SecuritySettings settings) async =>
      this.settings = settings;
}

final class FakeAppUnlockService implements AppUnlockService {
  FakeAppUnlockService({
    this.biometricAvailable = false,
    this.biometricResult = BiometricResult.unavailable,
  });

  final bool biometricAvailable;
  final BiometricResult biometricResult;
  int biometricAttempts = 0;

  @override
  Future<bool> biometricsAvailable() async => biometricAvailable;

  @override
  Future<bool> hasPin() async => true;

  @override
  Future<void> setPin(String pin) async {}

  @override
  Future<BiometricResult> unlockWithBiometrics() async {
    biometricAttempts++;
    return biometricResult;
  }

  @override
  Future<PinAttemptResult> verifyPin(String pin) async =>
      const PinAttemptResult(PinAttemptStatus.success);
}
