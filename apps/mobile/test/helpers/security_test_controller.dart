import 'package:life_timeline/features/security/application/security_providers.dart';
import 'package:life_timeline/features/security/domain/security_models.dart';

final class UnlockedSecurityController extends SecurityController {
  @override
  Future<SecuritySessionState> build() async => const SecuritySessionState(
    settings: SecuritySettings(),
    locked: false,
    biometricAvailable: false,
  );
}
