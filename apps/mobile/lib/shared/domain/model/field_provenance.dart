import 'package:life_timeline/shared/domain/model/record_metadata.dart';

enum ProvenanceTargetType {
  entity,
  event,
  evidence,
  relationship,
  attachment,
  memoryCandidate,
}

enum ProvenanceSourceType { user, attachment, import, system, rule, localModel }

enum ExtractionMethod {
  manual,
  imported,
  metadata,
  deterministic,
  ocr,
  onDeviceModel,
  unknown,
}

final class ProvenanceTarget {
  ProvenanceTarget({required this.type, required this.id}) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Must not be empty.');
    }
  }

  final String id;
  final ProvenanceTargetType type;
}

final class FieldProvenance {
  FieldProvenance({
    required this.id,
    required this.target,
    required this.fieldName,
    required this.sourceId,
    required this.sourceType,
    required this.extractionMethod,
    required this.userConfirmed,
    required this.privacyClassification,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.confidence,
  }) : createdAt = createdAt.toUtc(),
       updatedAt = updatedAt.toUtc() {
    if (id.trim().isEmpty ||
        fieldName.trim().isEmpty ||
        sourceId.trim().isEmpty) {
      throw ArgumentError('ID, field name, and source ID must not be empty.');
    }
    if (confidence != null && (confidence! < 0 || confidence! > 1)) {
      throw ArgumentError.value(
        confidence,
        'confidence',
        'Must be between 0 and 1.',
      );
    }
    if (this.updatedAt.isBefore(this.createdAt)) {
      throw ArgumentError('updatedAt must not be before createdAt.');
    }
  }

  final double? confidence;
  final DateTime createdAt;
  final ExtractionMethod extractionMethod;
  final String fieldName;
  final String id;
  final PrivacyClassification privacyClassification;
  final String sourceId;
  final ProvenanceSourceType sourceType;
  final ProvenanceTarget target;
  final DateTime updatedAt;
  final bool userConfirmed;
}
