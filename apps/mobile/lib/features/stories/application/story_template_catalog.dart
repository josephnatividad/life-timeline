import 'package:life_timeline/features/stories/domain/story_models.dart';

abstract final class StoryTemplateCatalog {
  static final List<StoryTemplateDefinition> all = List.unmodifiable([
    StoryTemplateDefinition(
      id: StoryTemplateId.minimal,
      label: 'Minimal',
      description: 'Quiet typography with a restrained timeline accent.',
      supportedSources: StorySourceType.values.toSet(),
      maximumMedia: 1,
      tier: StoryTemplateTier.core,
    ),
    StoryTemplateDefinition(
      id: StoryTemplateId.photo,
      label: 'Photo',
      description: 'One image with a calm, legible text treatment.',
      supportedSources: StorySourceType.values.toSet(),
      maximumMedia: 1,
      tier: StoryTemplateTier.core,
    ),
    StoryTemplateDefinition(
      id: StoryTemplateId.stats,
      label: 'Stats',
      description: 'A focused number or milestone with supporting context.',
      supportedSources: StorySourceType.values.toSet(),
      maximumMedia: 1,
      tier: StoryTemplateTier.futurePro,
    ),
    StoryTemplateDefinition(
      id: StoryTemplateId.journey,
      label: 'Journey',
      description: 'A temporal path for places, events, and milestones.',
      supportedSources: {
        StorySourceType.event,
        StorySourceType.entity,
        StorySourceType.milestone,
      },
      maximumMedia: 1,
      tier: StoryTemplateTier.futurePro,
    ),
    StoryTemplateDefinition(
      id: StoryTemplateId.thenNow,
      label: 'Then & Now',
      description: 'A deliberate comparison of two selected memories.',
      supportedSources: {StorySourceType.thenNow},
      maximumMedia: 2,
      tier: StoryTemplateTier.futurePro,
    ),
  ]);

  static List<StoryTemplateDefinition> forSource(StorySource source) => [
    for (final template in all)
      if (template.supports(source)) template,
  ];

  static StoryTemplateDefinition byId(StoryTemplateId id) =>
      all.firstWhere((template) => template.id == id);
}
