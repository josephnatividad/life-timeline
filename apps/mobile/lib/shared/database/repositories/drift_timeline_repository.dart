import 'package:drift/drift.dart';
import 'package:life_timeline/shared/database/app_database.dart' as db;
import 'package:life_timeline/shared/database/mappers/candidate_provenance_mapper.dart';
import 'package:life_timeline/shared/database/mappers/timeline_mapper.dart';
import 'package:life_timeline/shared/domain/model/field_provenance.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';
import 'package:life_timeline/shared/domain/repositories/timeline_repository.dart';

final class DriftTimelineRepository implements TimelineRepository {
  DriftTimelineRepository(this._database);

  final db.AppDatabase _database;

  @override
  Future<void> saveEntity(Entity entity) async {
    await _database
        .into(_database.entities)
        .insertOnConflictUpdate(TimelineMapper.entityToCompanion(entity));
  }

  @override
  Future<void> saveEvent(Event event) async {
    await _database
        .into(_database.events)
        .insertOnConflictUpdate(TimelineMapper.eventToCompanion(event));
  }

  @override
  Future<void> saveEvidence(
    Evidence evidence, {
    List<Attachment> attachments = const [],
  }) => _database.transaction(() async {
    await _database
        .into(_database.evidenceRecords)
        .insertOnConflictUpdate(TimelineMapper.evidenceToCompanion(evidence));
    for (final attachment in attachments) {
      if (attachment.evidenceId != evidence.metadata.id) {
        throw ArgumentError(
          'Every attachment must belong to the saved evidence record.',
        );
      }
      await _database
          .into(_database.attachments)
          .insertOnConflictUpdate(
            TimelineMapper.attachmentToCompanion(attachment),
          );
    }
  });

  @override
  Future<void> saveRelationship(Relationship relationship) async {
    await _database
        .into(_database.relationships)
        .insertOnConflictUpdate(
          TimelineMapper.relationshipToCompanion(relationship),
        );
  }

  @override
  Future<void> saveFieldProvenance(FieldProvenance provenance) async {
    await _database
        .into(_database.fieldProvenanceRows)
        .insertOnConflictUpdate(
          CandidateProvenanceMapper.provenanceToCompanion(provenance),
        );
  }

  @override
  Future<void> saveTag(Tag tag) async {
    await _database
        .into(_database.tags)
        .insertOnConflictUpdate(TimelineMapper.tagToCompanion(tag));
  }

  @override
  Future<void> saveCategory(Category category) async {
    await _database
        .into(_database.categories)
        .insertOnConflictUpdate(TimelineMapper.categoryToCompanion(category));
  }

  @override
  Future<Entity?> entityById(String id, {bool includeDeleted = false}) async {
    final query = _database.select(_database.entities)
      ..where(
        (row) =>
            row.id.equals(id) &
            _notDeleted(row.lifecycle, includeDeleted: includeDeleted),
      );
    final row = await query.getSingleOrNull();
    return row == null ? null : TimelineMapper.entityFromRow(row);
  }

  @override
  Future<Event?> eventById(String id, {bool includeDeleted = false}) async {
    final query = _database.select(_database.events)
      ..where(
        (row) =>
            row.id.equals(id) &
            _notDeleted(row.lifecycle, includeDeleted: includeDeleted),
      );
    final row = await query.getSingleOrNull();
    return row == null ? null : TimelineMapper.eventFromRow(row);
  }

  @override
  Future<Evidence?> evidenceById(
    String id, {
    bool includeDeleted = false,
  }) async {
    final query = _database.select(_database.evidenceRecords)
      ..where(
        (row) =>
            row.id.equals(id) &
            _notDeleted(row.lifecycle, includeDeleted: includeDeleted),
      );
    final row = await query.getSingleOrNull();
    return row == null ? null : TimelineMapper.evidenceFromRow(row);
  }

  @override
  Future<List<Attachment>> attachmentsForEvidence(String evidenceId) async {
    final query = _database.select(_database.attachments)
      ..where(
        (row) =>
            row.evidenceId.equals(evidenceId) &
            row.lifecycle.isNotValue('soft_deleted'),
      )
      ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]);
    return (await query.get()).map(TimelineMapper.attachmentFromRow).toList();
  }

  @override
  Future<List<Relationship>> relationshipsFor(
    TimelineRecordReference record,
  ) async {
    final query = _database.select(_database.relationships)
      ..where(
        (row) =>
            (_relationshipEndpoint(row, record, source: true) |
                _relationshipEndpoint(row, record, source: false)) &
            row.lifecycle.isNotValue('soft_deleted'),
      )
      ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]);
    return (await query.get()).map(TimelineMapper.relationshipFromRow).toList();
  }

  @override
  Future<List<FieldProvenance>> provenanceFor(ProvenanceTarget target) async {
    final query = _database.select(_database.fieldProvenanceRows)
      ..where((row) => _provenanceTarget(row, target))
      ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]);
    return (await query.get())
        .map(CandidateProvenanceMapper.provenanceFromRow)
        .toList();
  }

  @override
  Future<void> assignTag(TimelineRecordReference record, String tagId) async {
    switch (record.type) {
      case TimelineRecordType.entity:
        await _database
            .into(_database.entityTags)
            .insert(
              db.EntityTagsCompanion(
                entityId: Value(record.id),
                tagId: Value(tagId),
              ),
              mode: InsertMode.insertOrIgnore,
            );
      case TimelineRecordType.event:
        await _database
            .into(_database.eventTags)
            .insert(
              db.EventTagsCompanion(
                eventId: Value(record.id),
                tagId: Value(tagId),
              ),
              mode: InsertMode.insertOrIgnore,
            );
      case TimelineRecordType.evidence:
        await _database
            .into(_database.evidenceTags)
            .insert(
              db.EvidenceTagsCompanion(
                evidenceId: Value(record.id),
                tagId: Value(tagId),
              ),
              mode: InsertMode.insertOrIgnore,
            );
    }
  }

  @override
  Future<void> assignCategory(
    TimelineRecordReference record,
    String categoryId,
  ) async {
    switch (record.type) {
      case TimelineRecordType.entity:
        await _database
            .into(_database.entityCategories)
            .insert(
              db.EntityCategoriesCompanion(
                entityId: Value(record.id),
                categoryId: Value(categoryId),
              ),
              mode: InsertMode.insertOrIgnore,
            );
      case TimelineRecordType.event:
        await _database
            .into(_database.eventCategories)
            .insert(
              db.EventCategoriesCompanion(
                eventId: Value(record.id),
                categoryId: Value(categoryId),
              ),
              mode: InsertMode.insertOrIgnore,
            );
      case TimelineRecordType.evidence:
        await _database
            .into(_database.evidenceCategories)
            .insert(
              db.EvidenceCategoriesCompanion(
                evidenceId: Value(record.id),
                categoryId: Value(categoryId),
              ),
              mode: InsertMode.insertOrIgnore,
            );
    }
  }

  @override
  Future<void> softDeleteEntity(String id, DateTime deletedAt) async {
    await (_database.update(
      _database.entities,
    )..where((row) => row.id.equals(id))).write(_deletedEntity(deletedAt));
  }

  @override
  Future<void> softDeleteEvent(String id, DateTime deletedAt) async {
    await (_database.update(
      _database.events,
    )..where((row) => row.id.equals(id))).write(_deletedEvent(deletedAt));
  }

  @override
  Future<void> softDeleteEvidence(String id, DateTime deletedAt) async {
    await (_database.update(
      _database.evidenceRecords,
    )..where((row) => row.id.equals(id))).write(_deletedEvidence(deletedAt));
  }

  Expression<bool> _relationshipEndpoint(
    db.$RelationshipsTable row,
    TimelineRecordReference record, {
    required bool source,
  }) => switch ((record.type, source)) {
    (TimelineRecordType.entity, true) => row.sourceEntityId.equals(record.id),
    (TimelineRecordType.entity, false) => row.targetEntityId.equals(record.id),
    (TimelineRecordType.event, true) => row.sourceEventId.equals(record.id),
    (TimelineRecordType.event, false) => row.targetEventId.equals(record.id),
    (TimelineRecordType.evidence, true) => row.sourceEvidenceId.equals(
      record.id,
    ),
    (TimelineRecordType.evidence, false) => row.targetEvidenceId.equals(
      record.id,
    ),
  };

  Expression<bool> _provenanceTarget(
    db.$FieldProvenanceRowsTable row,
    ProvenanceTarget target,
  ) => switch (target.type) {
    ProvenanceTargetType.entity => row.entityId.equals(target.id),
    ProvenanceTargetType.event => row.eventId.equals(target.id),
    ProvenanceTargetType.evidence => row.evidenceId.equals(target.id),
    ProvenanceTargetType.relationship => row.relationshipId.equals(target.id),
    ProvenanceTargetType.attachment => row.attachmentId.equals(target.id),
    ProvenanceTargetType.memoryCandidate => row.memoryCandidateId.equals(
      target.id,
    ),
  };

  Expression<bool> _notDeleted(
    GeneratedColumn<String> lifecycle, {
    required bool includeDeleted,
  }) => includeDeleted
      ? const Constant(true)
      : lifecycle.isNotValue('soft_deleted');

  db.EntitiesCompanion _deletedEntity(DateTime deletedAt) =>
      db.EntitiesCompanion(
        lifecycle: const Value('soft_deleted'),
        updatedAt: Value(deletedAt.toUtc()),
        deletedAt: Value(deletedAt.toUtc()),
      );

  db.EventsCompanion _deletedEvent(DateTime deletedAt) => db.EventsCompanion(
    lifecycle: const Value('soft_deleted'),
    updatedAt: Value(deletedAt.toUtc()),
    deletedAt: Value(deletedAt.toUtc()),
  );

  db.EvidenceRecordsCompanion _deletedEvidence(DateTime deletedAt) =>
      db.EvidenceRecordsCompanion(
        lifecycle: const Value('soft_deleted'),
        updatedAt: Value(deletedAt.toUtc()),
        deletedAt: Value(deletedAt.toUtc()),
      );
}
