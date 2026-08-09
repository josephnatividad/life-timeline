import 'package:drift/drift.dart';
import 'package:life_timeline/shared/database/app_database.dart' as db;
import 'package:life_timeline/shared/database/mappers/persistence_value_codec.dart';
import 'package:life_timeline/shared/domain/model/field_provenance.dart'
    as domain;
import 'package:life_timeline/shared/domain/model/memory_candidate.dart'
    as domain;

abstract final class CandidateProvenanceMapper {
  static db.MemoryCandidatesCompanion candidateToCompanion(
    domain.MemoryCandidate value,
  ) {
    final temporal = PersistenceValueCodec.temporalToStorage(
      value.temporalValue,
    );
    return db.MemoryCandidatesCompanion(
      id: Value(value.metadata.id),
      privacyClassification: Value(
        PersistenceValueCodec.privacyToStorage(
          value.metadata.privacyClassification,
        ),
      ),
      lifecycle: Value(
        PersistenceValueCodec.lifecycleToStorage(value.metadata.lifecycle),
      ),
      createdAt: Value(value.metadata.createdAt),
      updatedAt: Value(value.metadata.updatedAt),
      deletedAt: Value(value.metadata.deletedAt),
      temporalPrecision: Value(temporal.precision),
      startYear: Value(temporal.startYear),
      startMonth: Value(temporal.startMonth),
      startDay: Value(temporal.startDay),
      endYear: Value(temporal.endYear),
      endMonth: Value(temporal.endMonth),
      endDay: Value(temporal.endDay),
      title: Value(value.title),
      description: Value(value.description),
      sourceEvidenceId: Value(value.sourceEvidenceId),
      confirmedEventId: Value(value.confirmedEventId),
    );
  }

  static domain.MemoryCandidate candidateFromRow(db.MemoryCandidate row) =>
      domain.MemoryCandidate(
        metadata: PersistenceValueCodec.metadataFromStorage(
          id: row.id,
          privacyClassification: row.privacyClassification,
          lifecycle: row.lifecycle,
          createdAt: row.createdAt,
          updatedAt: row.updatedAt,
          deletedAt: row.deletedAt,
        ),
        title: row.title,
        temporalValue: PersistenceValueCodec.temporalFromStorage(
          precision: row.temporalPrecision,
          startYear: row.startYear,
          startMonth: row.startMonth,
          startDay: row.startDay,
          endYear: row.endYear,
          endMonth: row.endMonth,
          endDay: row.endDay,
        ),
        description: row.description,
        sourceEvidenceId: row.sourceEvidenceId,
        confirmedEventId: row.confirmedEventId,
      );

  static db.FieldProvenanceRowsCompanion provenanceToCompanion(
    domain.FieldProvenance value,
  ) {
    String? entityId;
    String? eventId;
    String? evidenceId;
    String? relationshipId;
    String? attachmentId;
    String? memoryCandidateId;
    switch (value.target.type) {
      case domain.ProvenanceTargetType.entity:
        entityId = value.target.id;
      case domain.ProvenanceTargetType.event:
        eventId = value.target.id;
      case domain.ProvenanceTargetType.evidence:
        evidenceId = value.target.id;
      case domain.ProvenanceTargetType.relationship:
        relationshipId = value.target.id;
      case domain.ProvenanceTargetType.attachment:
        attachmentId = value.target.id;
      case domain.ProvenanceTargetType.memoryCandidate:
        memoryCandidateId = value.target.id;
    }
    return db.FieldProvenanceRowsCompanion(
      id: Value(value.id),
      entityId: Value(entityId),
      eventId: Value(eventId),
      evidenceId: Value(evidenceId),
      relationshipId: Value(relationshipId),
      attachmentId: Value(attachmentId),
      memoryCandidateId: Value(memoryCandidateId),
      fieldName: Value(value.fieldName),
      sourceId: Value(value.sourceId),
      sourceType: Value(
        PersistenceValueCodec.sourceTypeToStorage(value.sourceType),
      ),
      extractionMethod: Value(
        PersistenceValueCodec.extractionMethodToStorage(value.extractionMethod),
      ),
      confidence: Value(value.confidence),
      userConfirmed: Value(value.userConfirmed),
      privacyClassification: Value(
        PersistenceValueCodec.privacyToStorage(value.privacyClassification),
      ),
      createdAt: Value(value.createdAt),
      updatedAt: Value(value.updatedAt),
    );
  }

  static domain.FieldProvenance provenanceFromRow(db.FieldProvenanceRow row) =>
      domain.FieldProvenance(
        id: row.id,
        target: _target(row),
        fieldName: row.fieldName,
        sourceId: row.sourceId,
        sourceType: PersistenceValueCodec.sourceTypeFromStorage(row.sourceType),
        extractionMethod: PersistenceValueCodec.extractionMethodFromStorage(
          row.extractionMethod,
        ),
        confidence: row.confidence,
        userConfirmed: row.userConfirmed,
        privacyClassification: PersistenceValueCodec.privacyFromStorage(
          row.privacyClassification,
        ),
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  static domain.ProvenanceTarget _target(db.FieldProvenanceRow row) {
    final values = <(domain.ProvenanceTargetType, String?)>[
      (domain.ProvenanceTargetType.entity, row.entityId),
      (domain.ProvenanceTargetType.event, row.eventId),
      (domain.ProvenanceTargetType.evidence, row.evidenceId),
      (domain.ProvenanceTargetType.relationship, row.relationshipId),
      (domain.ProvenanceTargetType.attachment, row.attachmentId),
      (domain.ProvenanceTargetType.memoryCandidate, row.memoryCandidateId),
    ];
    for (final (type, id) in values) {
      if (id != null) {
        return domain.ProvenanceTarget(type: type, id: id);
      }
    }
    throw const FormatException('Provenance target is missing.');
  }
}
