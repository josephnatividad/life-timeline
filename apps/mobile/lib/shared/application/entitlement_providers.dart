import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_timeline/shared/domain/services/entitlement_service.dart';

final entitlementServiceProvider = Provider<EntitlementService>(
  (ref) => const LocalEntitlementService(),
);

final class LocalEntitlementService implements EntitlementService {
  const LocalEntitlementService({this.proEnabled = false});

  final bool proEnabled;

  @override
  Future<bool> hasAccess(ProFeature feature) async => proEnabled;
}
