import 'package:life_timeline/features/stories/application/story_template_catalog.dart';
import 'package:life_timeline/features/stories/domain/story_models.dart';

final class DefaultStoryComposer implements StoryComposer {
  const DefaultStoryComposer(this._sanitizer);

  final StoryPrivacySanitizer _sanitizer;

  @override
  StoryComposition compose({
    required StorySource source,
    required StoryPrivacySelection selection,
    required StoryTemplateId templateId,
    required StoryThemeVariant themeVariant,
    required StoryBrandingConfig branding,
  }) {
    final template = StoryTemplateCatalog.byId(templateId);
    if (!template.supports(source)) {
      throw ArgumentError('${template.label} does not support this source.');
    }
    final sanitized = _sanitizer.sanitize(source, selection);
    return StoryComposition(
      sourceId: source.id,
      sourceType: source.sourceType,
      templateId: templateId,
      themeVariant: themeVariant,
      branding: branding,
      sourceRecordIds: source.sourceRecordIds,
      fields: sanitized.includedFields,
      media: sanitized.includedMedia.take(template.maximumMedia).toList(),
      excludedFields: sanitized.excludedFields,
    );
  }
}
