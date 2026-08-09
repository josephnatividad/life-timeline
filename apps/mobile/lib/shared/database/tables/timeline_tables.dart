// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';
import 'package:life_timeline/shared/database/tables/record_columns.dart';

@TableIndex(name: 'entities_lifecycle_idx', columns: {#lifecycle})
@TableIndex(name: 'entities_normalized_name_idx', columns: {#normalizedName})
class Entities extends Table with RecordColumns {
  TextColumn get name => text()();
  TextColumn get normalizedName => text()();
  TextColumn get entityType => text()();
  TextColumn get notes => text().nullable()();

  @override
  List<String> get customConstraints => const [
    "CHECK ((lifecycle = 'soft_deleted') = (deleted_at IS NOT NULL))",
    'CHECK (updated_at >= created_at)',
  ];
}

@TableIndex(name: 'events_lifecycle_idx', columns: {#lifecycle})
@TableIndex(
  name: 'events_temporal_start_idx',
  columns: {#startYear, #startMonth, #startDay},
)
class Events extends Table with RecordColumns, TemporalColumns {
  TextColumn get title => text()();
  TextColumn get normalizedTitle => text()();
  TextColumn get description => text().nullable()();
  TextColumn get eventType => text().nullable()();

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
  ];
}

@TableIndex(name: 'evidence_lifecycle_idx', columns: {#lifecycle})
@TableIndex(name: 'evidence_type_idx', columns: {#evidenceType})
class EvidenceRecords extends Table with RecordColumns {
  TextColumn get title => text()();
  TextColumn get normalizedTitle => text()();
  TextColumn get evidenceType => text()();
  TextColumn get summary => text().nullable()();

  @override
  String get tableName => 'evidence';

  @override
  List<String> get customConstraints => const [
    "CHECK ((lifecycle = 'soft_deleted') = (deleted_at IS NOT NULL))",
    'CHECK (updated_at >= created_at)',
  ];
}

@TableIndex(name: 'attachments_evidence_idx', columns: {#evidenceId})
@TableIndex(name: 'attachments_storage_state_idx', columns: {#storageState})
@TableIndex(name: 'attachments_checksum_idx', columns: {#checksum})
class Attachments extends Table with RecordColumns {
  TextColumn get evidenceId =>
      text().references(EvidenceRecords, #id, onDelete: KeyAction.restrict)();
  TextColumn get displayName => text().nullable()();
  TextColumn get relativePath => text().nullable()();
  TextColumn get thumbnailRelativePath => text().nullable()();
  TextColumn get mimeType => text()();
  IntColumn get byteSize => integer().check(byteSize.isBiggerOrEqualValue(0))();
  TextColumn get checksum => text().nullable()();
  TextColumn get storageState => text().check(
    storageState.isIn(const ['local', 'referenced', 'archived', 'unavailable']),
  )();
  TextColumn get importMode => text().check(
    importMode.isIn(const [
      'reference_original',
      'optimized_copy',
      'preserve_original',
    ]),
  )();

  @override
  List<String> get customConstraints => const [
    "CHECK ((lifecycle = 'soft_deleted') = (deleted_at IS NOT NULL))",
    'CHECK (updated_at >= created_at)',
  ];
}

@TableIndex(name: 'relationships_source_entity_idx', columns: {#sourceEntityId})
@TableIndex(name: 'relationships_source_event_idx', columns: {#sourceEventId})
@TableIndex(
  name: 'relationships_source_evidence_idx',
  columns: {#sourceEvidenceId},
)
@TableIndex(name: 'relationships_target_entity_idx', columns: {#targetEntityId})
@TableIndex(name: 'relationships_target_event_idx', columns: {#targetEventId})
@TableIndex(
  name: 'relationships_target_evidence_idx',
  columns: {#targetEvidenceId},
)
class Relationships extends Table with RecordColumns {
  @ReferenceName('sourceEntityRelationships')
  TextColumn get sourceEntityId => text().nullable().references(
    Entities,
    #id,
    onDelete: KeyAction.restrict,
  )();
  @ReferenceName('sourceEventRelationships')
  TextColumn get sourceEventId =>
      text().nullable().references(Events, #id, onDelete: KeyAction.restrict)();
  @ReferenceName('sourceEvidenceRelationships')
  TextColumn get sourceEvidenceId => text().nullable().references(
    EvidenceRecords,
    #id,
    onDelete: KeyAction.restrict,
  )();
  @ReferenceName('targetEntityRelationships')
  TextColumn get targetEntityId => text().nullable().references(
    Entities,
    #id,
    onDelete: KeyAction.restrict,
  )();
  @ReferenceName('targetEventRelationships')
  TextColumn get targetEventId =>
      text().nullable().references(Events, #id, onDelete: KeyAction.restrict)();
  @ReferenceName('targetEvidenceRelationships')
  TextColumn get targetEvidenceId => text().nullable().references(
    EvidenceRecords,
    #id,
    onDelete: KeyAction.restrict,
  )();
  TextColumn get relationshipType => text()();
  TextColumn get notes => text().nullable()();

  @override
  List<String> get customConstraints => const [
    "CHECK ((lifecycle = 'soft_deleted') = (deleted_at IS NOT NULL))",
    'CHECK (updated_at >= created_at)',
    '''CHECK (
      (CASE WHEN source_entity_id IS NULL THEN 0 ELSE 1 END + CASE WHEN source_event_id IS NULL THEN 0 ELSE 1 END + CASE WHEN source_evidence_id IS NULL THEN 0 ELSE 1 END) = 1
    )''',
    '''CHECK (
      (CASE WHEN target_entity_id IS NULL THEN 0 ELSE 1 END + CASE WHEN target_event_id IS NULL THEN 0 ELSE 1 END + CASE WHEN target_evidence_id IS NULL THEN 0 ELSE 1 END) = 1
    )''',
    '''CHECK (NOT (
      source_entity_id IS target_entity_id AND source_event_id IS target_event_id AND source_evidence_id IS target_evidence_id
    ))''',
  ];
}
