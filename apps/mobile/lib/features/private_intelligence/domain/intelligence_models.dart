import 'package:life_timeline/shared/domain/model/record_metadata.dart';

enum CaptureSource { scan, camera, photoLibrary, manual }

enum DocumentType {
  receipt,
  warranty,
  identity,
  travel,
  product,
  genericDocument,
  unknown,
}

enum CandidateReviewStatus { pending, reviewing, confirmed, ignored, rejected }

enum ExtractedValueType { text, date, money, identifier, address, phone }

final class ExtractedField {
  ExtractedField({
    required this.id,
    required this.key,
    required this.value,
    required this.valueType,
    required this.confidence,
    required this.privacyClassification,
    required this.extractionMethod,
    this.sourceExcerpt,
    this.reviewRecommended = false,
  }) {
    if (id.trim().isEmpty || key.trim().isEmpty || value.trim().isEmpty) {
      throw ArgumentError('Extracted field ID, key, and value are required.');
    }
    if (confidence < 0 || confidence > 1) {
      throw ArgumentError.value(confidence, 'confidence', 'Must be 0...1.');
    }
  }

  final double confidence;
  final String extractionMethod;
  final String id;
  final String key;
  final PrivacyClassification privacyClassification;
  final bool reviewRecommended;
  final String? sourceExcerpt;
  final String value;
  final ExtractedValueType valueType;

  ExtractedField copyWith({String? value, bool? reviewRecommended}) =>
      ExtractedField(
        id: id,
        key: key,
        value: value ?? this.value,
        valueType: valueType,
        confidence: confidence,
        privacyClassification: privacyClassification,
        extractionMethod: extractionMethod,
        sourceExcerpt: sourceExcerpt,
        reviewRecommended: reviewRecommended ?? this.reviewRecommended,
      );
}

final class EntityProposal {
  EntityProposal({
    required this.id,
    required this.name,
    required this.entityType,
    required this.confidence,
    this.brand,
    this.model,
    this.serialNumber,
    this.suggestedEntityId,
    this.matchScore,
    this.matchReasons = const [],
  }) {
    if (id.trim().isEmpty || name.trim().isEmpty || entityType.trim().isEmpty) {
      throw ArgumentError('Entity proposal ID, name, and type are required.');
    }
    if (confidence < 0 ||
        confidence > 1 ||
        (matchScore != null && (matchScore! < 0 || matchScore! > 1))) {
      throw ArgumentError('Confidence and match score must be 0...1.');
    }
  }

  final String? brand;
  final double confidence;
  final String entityType;
  final String id;
  final List<String> matchReasons;
  final double? matchScore;
  final String? model;
  final String name;
  final String? serialNumber;
  final String? suggestedEntityId;
}

final class ClassificationResult {
  const ClassificationResult({
    required this.documentType,
    required this.confidence,
    required this.reasons,
  });

  final double confidence;
  final DocumentType documentType;
  final List<String> reasons;
}

final class ExtractionResult {
  const ExtractionResult({
    required this.title,
    required this.fields,
    required this.entityProposals,
    required this.overallConfidence,
    this.description,
  });

  final String? description;
  final List<EntityProposal> entityProposals;
  final List<ExtractedField> fields;
  final double overallConfidence;
  final String title;
}

enum ProFeature { aiCapture }

abstract interface class EntitlementService {
  Future<bool> hasAccess(ProFeature feature);
}

abstract interface class FeatureUsageRepository {
  Future<int> usageCount(ProFeature feature);
  Future<void> increment(ProFeature feature, DateTime at);
}

final class ComplimentaryUsagePolicy {
  const ComplimentaryUsagePolicy({required this.aiCaptureActions});

  final int aiCaptureActions;
}
