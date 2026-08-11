import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/features/stories/application/default_story_composer.dart';
import 'package:life_timeline/features/stories/application/default_story_privacy_sanitizer.dart';
import 'package:life_timeline/features/stories/domain/story_models.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';

void main() {
  const sanitizer = DefaultStoryPrivacySanitizer();
  late StorySource source;

  setUp(() {
    source = StorySource(
      id: 'event:event-1',
      sourceType: StorySourceType.event,
      title: 'Local source title',
      sourceRecordIds: const ['event-1'],
      fields: [
        _field('safe', 'Country', 'Japan', PrivacyClassification.shareSafe),
        _field(
          'personal',
          'Detailed date',
          'August 11, 2026',
          PrivacyClassification.personal,
        ),
        _field(
          'sensitive',
          'Serial number',
          'SERIAL-SECRET',
          PrivacyClassification.sensitive,
        ),
        _field(
          'never',
          'Booking information',
          'BOOKING-SECRET',
          PrivacyClassification.neverShare,
        ),
      ],
      media: [
        StoryMedia(
          id: 'private-photo',
          label: 'Private photo',
          kind: StoryMediaKind.image,
          localPath: 'private.jpg',
          privacyClassification: PrivacyClassification.personal,
        ),
        StoryMedia(
          id: 'protected-photo',
          label: 'Protected document image',
          kind: StoryMediaKind.image,
          localPath: 'protected.jpg',
          privacyClassification: PrivacyClassification.neverShare,
        ),
      ],
    );
  });

  test('defaults include only suggested share-safe fields', () {
    final defaults = StoryPrivacySelection.defaultsFor(source);
    final result = sanitizer.sanitize(source, defaults);

    expect(defaults.includedFieldIds, {'safe'});
    expect(result.includedFields.map((field) => field.value), ['Japan']);
    expect(result.includedMedia, isEmpty);
  });

  test('personal and sensitive fields require explicit selection', () {
    final result = sanitizer.sanitize(
      source,
      StoryPrivacySelection(
        includedFieldIds: const {'safe', 'personal', 'sensitive'},
        includedMediaIds: const {'private-photo'},
      ),
    );

    expect(
      result.includedFields.map((field) => field.id),
      containsAll(['safe', 'personal', 'sensitive']),
    );
    expect(result.includedMedia.single.id, 'private-photo');
  });

  test('never-share data survives a forged UI selection without leaking', () {
    final result = sanitizer.sanitize(
      source,
      StoryPrivacySelection(
        includedFieldIds: source.fields.map((field) => field.id).toSet(),
        includedMediaIds: source.media.map((media) => media.id).toSet(),
      ),
    );

    expect(
      result.includedFields.map((field) => field.value),
      isNot(contains('BOOKING-SECRET')),
    );
    expect(
      result.includedMedia.map((media) => media.localPath),
      isNot(contains('protected.jpg')),
    );
    final protected = result.excludedFields.where(
      (field) => field.reason == StoryExclusionReason.protectedAlways,
    );
    expect(protected, hasLength(2));
  });

  test('composition carries sanitized values and configurable branding', () {
    final composition = const DefaultStoryComposer(sanitizer).compose(
      source: source,
      selection: StoryPrivacySelection(
        includedFieldIds: {'safe', 'never'},
        publicTitle: 'My public trip',
      ),
      templateId: StoryTemplateId.minimal,
      themeVariant: StoryThemeVariant.paper,
      branding: const StoryBrandingConfig(attribution: 'Replaceable brand'),
    );

    expect(composition.field('public.title')?.value, 'My public trip');
    expect(composition.fields.map((field) => field.value), contains('Japan'));
    expect(
      composition.fields.map((field) => field.value),
      isNot(contains('BOOKING-SECRET')),
    );
    expect(composition.branding.attribution, 'Replaceable brand');
  });
}

StoryField _field(
  String id,
  String label,
  String value,
  PrivacyClassification privacy,
) => StoryField(
  id: id,
  label: label,
  value: value,
  kind: StoryFieldKind.detail,
  privacyClassification: privacy,
  suggestedByDefault: privacy == PrivacyClassification.shareSafe,
);
