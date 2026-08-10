// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';
import 'package:life_timeline/shared/database/tables/record_columns.dart';
import 'package:life_timeline/shared/database/tables/schema_constraints.dart';
import 'package:life_timeline/shared/database/tables/timeline_tables.dart';

@TableIndex(name: 'memory_candidates_lifecycle_idx', columns: {#lifecycle})
@TableIndex(
  name: 'memory_candidates_source_evidence_idx',
  columns: {#sourceEvidenceId},
)
@TableIndex(
  name: 'memory_candidates_temporal_start_idx',
  columns: {#startYear, #startMonth, #startDay},
)
class MemoryCandidates extends Table with RecordColumns, TemporalColumns {
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get sourceEvidenceId => text().nullable().references(
    EvidenceRecords,
    #id,
    onDelete: KeyAction.restrict,
  )();
  @ReferenceName('confirmedCandidates')
  TextColumn get confirmedEventId =>
      text().nullable().references(Events, #id, onDelete: KeyAction.restrict)();
  TextColumn get documentType =>
      text().withDefault(const Constant('unknown'))();
  TextColumn get reviewStatus =>
      text().withDefault(const Constant('pending'))();
  RealColumn get overallConfidence => real().nullable().check(
    overallConfidence.isNull() |
        (overallConfidence.isBiggerOrEqualValue(0) &
            overallConfidence.isSmallerOrEqualValue(1)),
  )();
  @ReferenceName('possibleDuplicateCandidates')
  TextColumn get possibleDuplicateEventId =>
      text().nullable().references(Events, #id, onDelete: KeyAction.setNull)();

  @override
  List<String> get customConstraints => const [
    "CHECK ((lifecycle = 'soft_deleted') = (deleted_at IS NOT NULL))",
    'CHECK (updated_at >= created_at)',
    '''CHECK (
      (temporal_precision = 'exact_date' AND start_year IS NOT NULL AND start_month IS NOT NULL AND start_day IS NOT NULL AND end_year IS NULL AND end_month IS NULL AND end_day IS NULL) OR
      (temporal_precision = 'month' AND start_year IS NOT NULL AND start_month IS NOT NULL AND start_day IS NULL AND end_year IS NULL AND end_month IS NULL AND end_day IS NULL) OR
      (temporal_precision = 'year' AND start_year IS NOT NULL AND start_month IS NULL AND start_day IS NULL AND end_year IS NULL AND end_month IS NULL AND end_day IS NULL) OR
      (temporal_precision IN ('approximate', 'before', 'after') AND start_year IS NOT NULL AND end_year IS NULL AND end_month IS NULL AND end_day IS NULL) OR
      (temporal_precision = 'range' AND start_year IS NOT NULL AND end_year IS NOT NULL) OR
      (temporal_precision = 'unknown' AND start_year IS NULL AND start_month IS NULL AND start_day IS NULL AND end_year IS NULL AND end_month IS NULL AND end_day IS NULL)
    )''',
    '''CHECK (
      (start_month IS NULL OR start_month BETWEEN 1 AND 12) AND
      (end_month IS NULL OR end_month BETWEEN 1 AND 12) AND
      (start_day IS NULL OR (start_month IS NOT NULL AND start_day BETWEEN 1 AND 31)) AND
      (end_day IS NULL OR (end_month IS NOT NULL AND end_day BETWEEN 1 AND 31))
    )''',
    "CHECK (lifecycle <> 'confirmed' OR confirmed_event_id IS NOT NULL)",
  ];
}

@TableIndex(name: 'candidate_fields_candidate_idx', columns: {#candidateId})
@TableIndex(name: 'candidate_fields_key_idx', columns: {#key})
class CandidateExtractedFields extends Table {
  TextColumn get id => text()();
  TextColumn get candidateId =>
      text().references(MemoryCandidates, #id, onDelete: KeyAction.cascade)();
  TextColumn get key => text()();
  TextColumn get value => text()();
  TextColumn get valueType => text()();
  RealColumn get confidence => real().check(
    confidence.isBiggerOrEqualValue(0) & confidence.isSmallerOrEqualValue(1),
  )();
  TextColumn get privacyClassification => text()();
  TextColumn get extractionMethod => text()();
  TextColumn get sourceExcerpt => text().nullable()();
  BoolColumn get reviewRecommended =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@TableIndex(name: 'candidate_entities_candidate_idx', columns: {#candidateId})
@TableIndex(
  name: 'candidate_entities_suggested_idx',
  columns: {#suggestedEntityId},
)
@TableIndex(name: 'candidate_entities_serial_idx', columns: {#serialNumber})
class CandidateEntityProposals extends Table {
  TextColumn get id => text()();
  TextColumn get candidateId =>
      text().references(MemoryCandidates, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  TextColumn get entityType => text()();
  RealColumn get confidence => real()();
  TextColumn get brand => text().nullable()();
  TextColumn get model => text().nullable()();
  TextColumn get serialNumber => text().nullable()();
  TextColumn get suggestedEntityId => text().nullable().references(
    Entities,
    #id,
    onDelete: KeyAction.setNull,
  )();
  RealColumn get matchScore => real().nullable()();
  TextColumn get matchReasons => text().withDefault(const Constant(''))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class FeatureUsage extends Table {
  TextColumn get feature => text()();
  IntColumn get usageCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {feature};
}

@TableIndex(name: 'provenance_entity_idx', columns: {#entityId})
@TableIndex(name: 'provenance_event_idx', columns: {#eventId})
@TableIndex(name: 'provenance_evidence_idx', columns: {#evidenceId})
@TableIndex(name: 'provenance_relationship_idx', columns: {#relationshipId})
@TableIndex(name: 'provenance_attachment_idx', columns: {#attachmentId})
@TableIndex(name: 'provenance_candidate_idx', columns: {#memoryCandidateId})
class FieldProvenanceRows extends Table {
  TextColumn get id => text()();
  TextColumn get entityId => text().nullable().references(
    Entities,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get eventId =>
      text().nullable().references(Events, #id, onDelete: KeyAction.cascade)();
  TextColumn get evidenceId => text().nullable().references(
    EvidenceRecords,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get relationshipId => text().nullable().references(
    Relationships,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get attachmentId => text().nullable().references(
    Attachments,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get memoryCandidateId => text().nullable().references(
    MemoryCandidates,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get fieldName => text()();
  TextColumn get sourceId => text()();
  TextColumn get sourceType => text().check(
    sourceType.isIn(const [
      'user',
      'attachment',
      'import',
      'system',
      'rule',
      'local_model',
    ]),
  )();
  TextColumn get extractionMethod => text().check(
    extractionMethod.isIn(const [
      'manual',
      'imported',
      'metadata',
      'deterministic',
      'ocr',
      'on_device_model',
      'unknown',
    ]),
  )();
  RealColumn get confidence => real().nullable().check(
    confidence.isNull() |
        (confidence.isBiggerOrEqualValue(0) &
            confidence.isSmallerOrEqualValue(1)),
  )();
  BoolColumn get userConfirmed => boolean()();
  TextColumn get privacyClassification =>
      text().check(privacyClassification.isIn(SchemaValues.privacy))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  String get tableName => 'field_provenance';

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => const [
    'CHECK (updated_at >= created_at)',
    '''CHECK (
      (CASE WHEN entity_id IS NULL THEN 0 ELSE 1 END +
       CASE WHEN event_id IS NULL THEN 0 ELSE 1 END +
       CASE WHEN evidence_id IS NULL THEN 0 ELSE 1 END +
       CASE WHEN relationship_id IS NULL THEN 0 ELSE 1 END +
       CASE WHEN attachment_id IS NULL THEN 0 ELSE 1 END +
       CASE WHEN memory_candidate_id IS NULL THEN 0 ELSE 1 END) = 1
    )''',
  ];
}
