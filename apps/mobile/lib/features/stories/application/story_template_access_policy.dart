import 'package:life_timeline/features/stories/domain/story_models.dart';
import 'package:life_timeline/shared/domain/services/entitlement_service.dart';

final class StoryTemplateAccessPolicy {
  const StoryTemplateAccessPolicy(
    this._entitlements, {
    this.enforceFutureProGates = false,
  });

  final bool enforceFutureProGates;
  final EntitlementService _entitlements;

  Future<bool> canUse(StoryTemplateDefinition template) async {
    if (!enforceFutureProGates || template.tier == StoryTemplateTier.core) {
      return true;
    }
    return _entitlements.hasAccess(ProFeature.advancedStoryTemplates);
  }
}
