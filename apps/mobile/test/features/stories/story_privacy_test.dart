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
        _field(
          'address',
          'Home address',
          'HOME-ADDRESS-SECRET',
          PrivacyClassification.neverShare,
        ),
        _field(
          'passport',
          'Passport number',
          'PASSPORT-SECRET',
          PrivacyClassification.neverShare,
        ),
        _field(
          'receipt',
          'Receipt details',
          'RECEIPT-PERSONAL',
          PrivacyClassification.sensitive,
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

  test('default photo selection follows the template media shape', () {
    final photos = List.generate(
      3,
      (index) => StoryMedia(
        id: 'photo-$index',
        label: 'Photo ${index + 1}',
        kind: StoryMediaKind.image,
        localPath: 'photo-$index.jpg',
        privacyClassification: PrivacyClassification.shareSafe,
        suggestedByDefault: true,
      ),
    );
    final ordinary = StorySource(
      id: 'event:photos',
      sourceType: StorySourceType.event,
      title: 'Photos',
      sourceRecordIds: const ['photos'],
      media: photos,
    );
    final paired = StorySource(
      id: 'then-now:photos',
      sourceType: StorySourceType.thenNow,
      title: 'Then & Now',
      sourceRecordIds: const ['then', 'now'],
      media: photos,
    );

    expect(StoryPrivacySelection.defaultsFor(ordinary).includedMediaIds, {
      'photo-0',
    });
    expect(StoryPrivacySelection.defaultsFor(paired).includedMediaIds, {
      'photo-0',
      'photo-1',
    });
  });

  test('ordinary composition never renders more than one selected photo', () {
    final photos = List.generate(
      3,
      (index) => StoryMedia(
        id: 'photo-$index',
        label: 'Photo ${index + 1}',
        kind: StoryMediaKind.image,
        localPath: 'photo-$index.jpg',
        privacyClassification: PrivacyClassification.personal,
      ),
    );
    final photoSource = StorySource(
      id: 'event:photos',
      sourceType: StorySourceType.event,
      title: 'Photos',
      sourceRecordIds: const ['photos'],
      media: photos,
    );
    final composition = const DefaultStoryComposer(sanitizer).compose(
      source: photoSource,
      selection: StoryPrivacySelection(
        includedMediaIds: {'photo-0', 'photo-1', 'photo-2'},
      ),
      templateId: StoryTemplateId.photo,
      themeVariant: StoryThemeVariant.paper,
      branding: const StoryBrandingConfig(),
    );

    expect(composition.media.map((media) => media.id), ['photo-0']);
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
    expect(protected, hasLength(4));
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

  test(
    'every template enforces the same forged-selection privacy boundary',
    () {
      for (final template in StoryTemplateId.values) {
        final templateSource = template == StoryTemplateId.thenNow
            ? StorySource(
                id: 'then-now:attack',
                sourceType: StorySourceType.thenNow,
                title: source.title,
                sourceRecordIds: source.sourceRecordIds,
                fields: source.fields,
                media: source.media,
              )
            : source;
        final composition = const DefaultStoryComposer(sanitizer).compose(
          source: templateSource,
          selection: StoryPrivacySelection(
            includedFieldIds: templateSource.fields
                .map((field) => field.id)
                .toSet(),
            includedMediaIds: templateSource.media
                .map((media) => media.id)
                .toSet(),
          ),
          templateId: template,
          themeVariant: StoryThemeVariant.paper,
          branding: const StoryBrandingConfig(),
        );
        final values = composition.fields.map((field) => field.value).toSet();
        final paths = composition.media.map((media) => media.localPath).toSet();

        expect(values, contains('Japan'), reason: template.name);
        expect(values, contains('August 11, 2026'), reason: template.name);
        expect(values, contains('SERIAL-SECRET'), reason: template.name);
        expect(values, contains('RECEIPT-PERSONAL'), reason: template.name);
        expect(
          values,
          isNot(contains('BOOKING-SECRET')),
          reason: template.name,
        );
        expect(
          values,
          isNot(contains('HOME-ADDRESS-SECRET')),
          reason: template.name,
        );
        expect(
          values,
          isNot(contains('PASSPORT-SECRET')),
          reason: template.name,
        );
        expect(paths, contains('private.jpg'), reason: template.name);
        expect(paths, isNot(contains('protected.jpg')), reason: template.name);
      }
    },
  );
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
