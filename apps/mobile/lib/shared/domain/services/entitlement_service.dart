enum ProFeature { aiCapture, advancedStoryTemplates }

abstract interface class EntitlementService {
  Future<bool> hasAccess(ProFeature feature);
}
