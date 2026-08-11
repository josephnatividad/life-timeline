import 'dart:typed_data';

import 'package:life_timeline/shared/domain/model/record_metadata.dart';
import 'package:life_timeline/shared/domain/model/temporal_value.dart';

enum StorySourceType { event, entity, milestone, thenNow }

enum StoryTemplateId { minimal, photo, stats, journey, thenNow }

enum StoryTemplateTier { core, futurePro }

enum StoryThemeVariant { paper, indigo, midnight, warm }

enum StoryFieldKind {
  title,
  caption,
  year,
  date,
  location,
  category,
  statistic,
  detail,
}

enum StoryMediaKind { image }

enum StoryExclusionReason {
  notSelected,
  privateByDefault,
  protectedAlways,
  unsupported,
}

final class StoryField {
  StoryField({
    required this.id,
    required this.label,
    required this.value,
    required this.kind,
    required this.privacyClassification,
    this.suggestedByDefault = false,
  }) {
    if (id.trim().isEmpty || label.trim().isEmpty || value.trim().isEmpty) {
      throw ArgumentError('Story field ID, label, and value are required.');
    }
  }

  final String id;
  final StoryFieldKind kind;
  final String label;
  final PrivacyClassification privacyClassification;
  final bool suggestedByDefault;
  final String value;
}

final class StoryMedia {
  StoryMedia({
    required this.id,
    required this.label,
    required this.kind,
    required this.localPath,
    required this.privacyClassification,
    this.suggestedByDefault = false,
  }) {
    if (id.trim().isEmpty || label.trim().isEmpty || localPath.trim().isEmpty) {
      throw ArgumentError(
        'Story media ID, label, and local path are required.',
      );
    }
  }

  final String id;
  final StoryMediaKind kind;
  final String label;
  final String localPath;
  final PrivacyClassification privacyClassification;
  final bool suggestedByDefault;
}

final class StorySource {
  StorySource({
    required this.id,
    required this.sourceType,
    required this.title,
    required List<String> sourceRecordIds,
    List<StoryField> fields = const [],
    List<StoryMedia> media = const [],
    this.temporalPrecision,
  }) : fields = List.unmodifiable(fields),
       media = List.unmodifiable(media),
       sourceRecordIds = List.unmodifiable(sourceRecordIds) {
    if (id.trim().isEmpty || title.trim().isEmpty || sourceRecordIds.isEmpty) {
      throw ArgumentError('A Story source requires identity and records.');
    }
  }

  final List<StoryField> fields;
  final String id;
  final List<StoryMedia> media;
  final List<String> sourceRecordIds;
  final StorySourceType sourceType;
  final TemporalPrecision? temporalPrecision;
  final String title;
}

final class StoryPrivacySelection {
  StoryPrivacySelection({
    Set<String> includedFieldIds = const {},
    Set<String> includedMediaIds = const {},
    this.publicCaption,
    this.publicTitle,
  }) : includedFieldIds = Set.unmodifiable(includedFieldIds),
       includedMediaIds = Set.unmodifiable(includedMediaIds);

  factory StoryPrivacySelection.defaultsFor(StorySource source) =>
      StoryPrivacySelection(
        includedFieldIds: {
          for (final field in source.fields)
            if (field.suggestedByDefault &&
                field.privacyClassification == PrivacyClassification.shareSafe)
              field.id,
        },
        includedMediaIds: {
          for (final media in source.media)
            if (media.suggestedByDefault &&
                media.privacyClassification == PrivacyClassification.shareSafe)
              media.id,
        },
      );

  final Set<String> includedFieldIds;
  final Set<String> includedMediaIds;
  final String? publicCaption;
  final String? publicTitle;

  StoryPrivacySelection copyWith({
    Set<String>? includedFieldIds,
    Set<String>? includedMediaIds,
    String? publicCaption,
    String? publicTitle,
  }) => StoryPrivacySelection(
    includedFieldIds: includedFieldIds ?? this.includedFieldIds,
    includedMediaIds: includedMediaIds ?? this.includedMediaIds,
    publicCaption: publicCaption ?? this.publicCaption,
    publicTitle: publicTitle ?? this.publicTitle,
  );
}

final class StoryExcludedField {
  const StoryExcludedField({
    required this.id,
    required this.label,
    required this.privacyClassification,
    required this.reason,
  });

  final String id;
  final String label;
  final PrivacyClassification privacyClassification;
  final StoryExclusionReason reason;
}

final class StorySanitizationResult {
  StorySanitizationResult({
    required List<StoryField> includedFields,
    required List<StoryMedia> includedMedia,
    required List<StoryExcludedField> excludedFields,
  }) : excludedFields = List.unmodifiable(excludedFields),
       includedFields = List.unmodifiable(includedFields),
       includedMedia = List.unmodifiable(includedMedia);

  final List<StoryExcludedField> excludedFields;
  final List<StoryField> includedFields;
  final List<StoryMedia> includedMedia;
}

abstract interface class StoryPrivacySanitizer {
  StorySanitizationResult sanitize(
    StorySource source,
    StoryPrivacySelection selection,
  );
}

final class StoryBrandingConfig {
  const StoryBrandingConfig({
    this.attribution = 'Made with Life Timeline',
    this.showAttribution = true,
  });

  final String attribution;
  final bool showAttribution;
}

final class StoryTemplateDefinition {
  StoryTemplateDefinition({
    required this.id,
    required this.label,
    required this.description,
    required Set<StorySourceType> supportedSources,
    required this.maximumMedia,
    required this.tier,
  }) : supportedSources = Set.unmodifiable(supportedSources) {
    if (maximumMedia < 0 || label.trim().isEmpty) {
      throw ArgumentError('Story template configuration is invalid.');
    }
  }

  final String description;
  final StoryTemplateId id;
  final String label;
  final int maximumMedia;
  final Set<StorySourceType> supportedSources;
  final StoryTemplateTier tier;

  bool supports(StorySource source) =>
      supportedSources.contains(source.sourceType);
}

final class StoryComposition {
  StoryComposition({
    required this.sourceId,
    required this.sourceType,
    required this.templateId,
    required this.themeVariant,
    required this.branding,
    required List<String> sourceRecordIds,
    required List<StoryField> fields,
    required List<StoryMedia> media,
    required List<StoryExcludedField> excludedFields,
  }) : excludedFields = List.unmodifiable(excludedFields),
       fields = List.unmodifiable(fields),
       media = List.unmodifiable(media),
       sourceRecordIds = List.unmodifiable(sourceRecordIds);

  final StoryBrandingConfig branding;
  final List<StoryExcludedField> excludedFields;
  final List<StoryField> fields;
  final List<StoryMedia> media;
  final String sourceId;
  final List<String> sourceRecordIds;
  final StorySourceType sourceType;
  final StoryTemplateId templateId;
  final StoryThemeVariant themeVariant;

  StoryField? field(String id) {
    for (final field in fields) {
      if (field.id == id) return field;
    }
    return null;
  }

  StoryField? firstOfKind(StoryFieldKind kind) {
    for (final field in fields) {
      if (field.kind == kind) return field;
    }
    return null;
  }
}

abstract interface class StoryComposer {
  StoryComposition compose({
    required StorySource source,
    required StoryPrivacySelection selection,
    required StoryTemplateId templateId,
    required StoryThemeVariant themeVariant,
    required StoryBrandingConfig branding,
  });
}

final class StoryRenderConfig {
  const StoryRenderConfig({
    this.logicalWidth = 360,
    this.logicalHeight = 640,
    this.pixelRatio = 3,
  });

  final double logicalHeight;
  final double logicalWidth;
  final double pixelRatio;

  int get outputWidth => (logicalWidth * pixelRatio).round();
  int get outputHeight => (logicalHeight * pixelRatio).round();
}

abstract interface class StoryImageRenderer {
  Future<Uint8List> render(
    StoryComposition composition,
    StoryRenderConfig config,
  );
}

final class TemporaryStoryFile {
  const TemporaryStoryFile({required this.path});

  final String path;
}

abstract interface class StoryTemporaryFileStore {
  Future<TemporaryStoryFile> writePng(Uint8List pngBytes);
  Future<void> delete(TemporaryStoryFile file);
  Future<void> cleanupStaleFiles(DateTime now);
}

enum StoryShareOutcome { shared, dismissed, unavailable }

abstract interface class StoryShareService {
  Future<StoryShareOutcome> sharePng(
    TemporaryStoryFile file, {
    required String shareTitle,
  });
}

final class StoryExportResult {
  const StoryExportResult({
    required this.outcome,
    required this.width,
    required this.height,
    required this.byteSize,
    required this.temporaryFileCleaned,
  });

  final int byteSize;
  final int height;
  final StoryShareOutcome outcome;
  final bool temporaryFileCleaned;
  final int width;
}

abstract interface class StoryExportService {
  Future<StoryExportResult> renderAndShare(
    StoryComposition composition,
    StoryRenderConfig config,
  );
}

abstract interface class StoryMediaPicker {
  Future<StoryMedia?> chooseImage();
}
