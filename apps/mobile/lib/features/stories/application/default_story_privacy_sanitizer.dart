import 'package:life_timeline/features/stories/domain/story_models.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';

final class DefaultStoryPrivacySanitizer implements StoryPrivacySanitizer {
  const DefaultStoryPrivacySanitizer();

  @override
  StorySanitizationResult sanitize(
    StorySource source,
    StoryPrivacySelection selection,
  ) {
    final includedFields = <StoryField>[];
    final includedMedia = <StoryMedia>[];
    final excluded = <StoryExcludedField>[];

    for (final field in source.fields) {
      final reason = _exclusionReason(
        field.privacyClassification,
        selection.includedFieldIds.contains(field.id),
      );
      if (reason == null) {
        includedFields.add(field);
      } else {
        excluded.add(
          StoryExcludedField(
            id: field.id,
            label: field.label,
            privacyClassification: field.privacyClassification,
            reason: reason,
          ),
        );
      }
    }

    for (final media in source.media) {
      final reason = _exclusionReason(
        media.privacyClassification,
        selection.includedMediaIds.contains(media.id),
      );
      if (reason == null) {
        includedMedia.add(media);
      } else {
        excluded.add(
          StoryExcludedField(
            id: media.id,
            label: media.label,
            privacyClassification: media.privacyClassification,
            reason: reason,
          ),
        );
      }
    }

    final publicTitle = selection.publicTitle?.trim();
    if (publicTitle != null && publicTitle.isNotEmpty) {
      includedFields.insert(
        0,
        StoryField(
          id: 'public.title',
          label: 'Public title',
          value: _bounded(publicTitle, 120),
          kind: StoryFieldKind.title,
          privacyClassification: PrivacyClassification.shareSafe,
          suggestedByDefault: true,
        ),
      );
    }
    final publicCaption = selection.publicCaption?.trim();
    if (publicCaption != null && publicCaption.isNotEmpty) {
      includedFields.add(
        StoryField(
          id: 'public.caption',
          label: 'Public caption',
          value: _bounded(publicCaption, 240),
          kind: StoryFieldKind.caption,
          privacyClassification: PrivacyClassification.shareSafe,
          suggestedByDefault: true,
        ),
      );
    }

    return StorySanitizationResult(
      includedFields: includedFields,
      includedMedia: includedMedia,
      excludedFields: excluded,
    );
  }

  StoryExclusionReason? _exclusionReason(
    PrivacyClassification classification,
    bool selected,
  ) {
    if (classification == PrivacyClassification.neverShare) {
      return StoryExclusionReason.protectedAlways;
    }
    if (selected) return null;
    if (classification == PrivacyClassification.personal ||
        classification == PrivacyClassification.sensitive) {
      return StoryExclusionReason.privateByDefault;
    }
    return StoryExclusionReason.notSelected;
  }

  String _bounded(String value, int maximumCharacters) =>
      value.length <= maximumCharacters
      ? value
      : value.substring(0, maximumCharacters).trimRight();
}
