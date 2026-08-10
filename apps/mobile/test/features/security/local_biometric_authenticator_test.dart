import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/features/security/domain/security_models.dart';
import 'package:life_timeline/features/security/infrastructure/local_biometric_authenticator.dart';
import 'package:local_auth/local_auth.dart';

void main() {
  test(
    'hardware support allows the native prompt when enrollment is under-reported',
    () async {
      final platform = FakeLocalBiometricPlatform(
        hardwareSupported: true,
        enrolled: const [],
      );
      final authenticator = LocalBiometricAuthenticator(platform);

      expect(await authenticator.isAvailable(), isTrue);
    },
  );

  test('successful biometric-only prompt enables authentication', () async {
    final platform = FakeLocalBiometricPlatform(
      hardwareSupported: true,
      enrolled: const [BiometricType.fingerprint],
      authenticationResult: true,
    );
    final authenticator = LocalBiometricAuthenticator(platform);

    expect(await authenticator.authenticate(), BiometricResult.success);
    expect(platform.authenticationAttempts, 1);
  });

  test('devices without biometric hardware remain unavailable', () async {
    final platform = FakeLocalBiometricPlatform(
      hardwareSupported: false,
      enrolled: const [],
    );
    final authenticator = LocalBiometricAuthenticator(platform);

    expect(await authenticator.isAvailable(), isFalse);
    expect(await authenticator.authenticate(), BiometricResult.unavailable);
    expect(platform.authenticationAttempts, 0);
  });
}

final class FakeLocalBiometricPlatform implements LocalBiometricPlatform {
  FakeLocalBiometricPlatform({
    required this.hardwareSupported,
    required this.enrolled,
    this.authenticationResult = false,
  });

  final bool authenticationResult;
  final List<BiometricType> enrolled;
  final bool hardwareSupported;
  int authenticationAttempts = 0;

  @override
  Future<bool> authenticate() async {
    authenticationAttempts++;
    return authenticationResult;
  }

  @override
  Future<List<BiometricType>> enrolledBiometrics() async => enrolled;

  @override
  Future<bool> supportsBiometrics() async => hardwareSupported;
}
