import 'package:drift/drift.dart';
import 'package:life_timeline/shared/database/app_database.dart' as db;
import 'package:life_timeline/shared/database/mappers/candidate_provenance_mapper.dart';
import 'package:life_timeline/shared/database/mappers/persistence_value_codec.dart';
import 'package:life_timeline/shared/database/mappers/timeline_mapper.dart';
import 'package:life_timeline/shared/domain/model/field_provenance.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';
import 'package:life_timeline/shared/domain/repositories/timeline_repository.dart';

final class DriftTimelineRepository implements TimelineRepository {
  DriftTimelineRepository(this._database);

  final db.AppDatabase _database;

  @override
  Stream<List<TimelineMemory>> watchMemories({bool archived = false}) =>
      _memoryQuery(
        whereSql: 'e.lifecycle = ?',
        variables: [Variable.withString(archived ? 'archived' : 'confirmed')],
      ).watch().map((rows) => rows.map(_memoryFromRow).toList());

  @override
  Future<TimelineMemory?> memoryById(String id) async {
    final rows = await _memoryQuery(
      whereSql: "e.id = ? AND e.lifecycle IN ('confirmed', 'archived')",
      variables: [Variable.withString(id)],
    ).get();
    return rows.isEmpty ? null : _memoryFromRow(rows.first);
  }

  @override
  Future<List<MemorySearchResult>> searchMemories(String query) async {
    final matchQuery = _ftsMatchQuery(query);
    if (matchQuery.isEmpty) {
      return const [];
    }
    final rows = await _database
        .customSelect(
          '''
        SELECT e.id AS event_id
        FROM event_search
        JOIN events e ON e.id = event_search.event_id
        WHERE event_search MATCH ?
          AND e.lifecycle = 'confirmed'
        ORDER BY bm25(event_search), e.updated_at DESC
        LIMIT 100
      ''',
          variables: [Variable.withString(matchQuery)],
          readsFrom: {_database.events},
        )
        .get();
    final normalizedQuery = query.trim().toLowerCase();
    final results = <MemorySearchResult>[];
    for (final row in rows) {
      final memory = await memoryById(row.read<String>('event_id'));
      if (memory != null) {
        results.add(
          MemorySearchResult(
            memory: memory,
            matchedField: _matchedField(memory, normalizedQuery),
          ),
        );
      }
    }
    return results;
  }

  @override
  Future<void> saveMemory(
    TimelineMemory memory, {
    List<FieldProvenance> provenance = const [],
  }) => _database.transaction(() async {
    await _database
        .into(_database.events)
        .insertOnConflictUpdate(TimelineMapper.eventToCompanion(memory.event));

    await _syncRelatedEntity(memory);
    await _syncCategory(memory);
    for (final field in provenance) {
      if (field.target.type != ProvenanceTargetType.event ||
          field.target.id != memory.event.metadata.id) {
        throw ArgumentError(
          'Memory provenance must target the event being saved.',
        );
      }
      await _database
          .into(_database.fieldProvenanceRows)
          .insertOnConflictUpdate(
            CandidateProvenanceMapper.provenanceToCompanion(field),
          );
    }
    await _refreshEventSearchIndex(memory.event.metadata.id);
  });

  @override
  Future<void> archiveEvent(String id, DateTime archivedAt) async {
    final at = archivedAt.toUtc();
    await (_database.update(_database.events)..where(
          (row) => row.id.equals(id) & row.lifecycle.equals('confirmed'),
        ))
        .write(
          db.EventsCompanion(
            lifecycle: const Value('archived'),
            updatedAt: Value(at),
            deletedAt: const Value(null),
          ),
        );
  }

  @override
  Future<void> restoreEvent(String id, DateTime restoredAt) async {
    final at = restoredAt.toUtc();
    await (_database.update(
          _database.events,
        )..where((row) => row.id.equals(id) & row.lifecycle.equals('archived')))
        .write(
          db.EventsCompanion(
            lifecycle: const Value('confirmed'),
            updatedAt: Value(at),
            deletedAt: const Value(null),
          ),
        );
  }

  @override
  Future<void> saveEntity(Entity entity) async {
    await _database
        .into(_database.entities)
        .insertOnConflictUpdate(TimelineMapper.entityToCompanion(entity));
  }

  @override
  Future<void> saveEvent(Event event) async {
    await _database.transaction(() async {
      await _database
          .into(_database.events)
          .insertOnConflictUpdate(TimelineMapper.eventToCompanion(event));
      await _refreshEventSearchIndex(event.metadata.id);
    });
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
    await _database.transaction(() async {
      await (_database.update(
        _database.events,
      )..where((row) => row.id.equals(id))).write(_deletedEvent(deletedAt));
      await _refreshEventSearchIndex(id);
    });
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

  Selectable<QueryRow> _memoryQuery({
    required String whereSql,
    required List<Variable<Object>> variables,
  }) => _database.customSelect(
    '''
      SELECT
        e.*,
        en.id AS related_entity_id,
        en.privacy_classification AS related_entity_privacy,
        en.lifecycle AS related_entity_lifecycle,
        en.created_at AS related_entity_created_at,
        en.updated_at AS related_entity_updated_at,
        en.deleted_at AS related_entity_deleted_at,
        en.name AS related_entity_name,
        en.entity_type AS related_entity_type,
        en.notes AS related_entity_notes,
        r.id AS related_relationship_id,
        r.privacy_classification AS related_relationship_privacy,
        r.lifecycle AS related_relationship_lifecycle,
        r.created_at AS related_relationship_created_at,
        r.updated_at AS related_relationship_updated_at,
        r.deleted_at AS related_relationship_deleted_at,
        c.id AS category_id,
        c.privacy_classification AS category_privacy,
        c.lifecycle AS category_lifecycle,
        c.created_at AS category_created_at,
        c.updated_at AS category_updated_at,
        c.deleted_at AS category_deleted_at,
        c.name AS category_name,
        c.parent_id AS category_parent_id
      FROM events e
      LEFT JOIN relationships r ON r.id = (
        SELECT candidate.id
        FROM relationships candidate
        WHERE candidate.relationship_type = 'related_entity'
          AND candidate.lifecycle <> 'soft_deleted'
          AND (candidate.source_event_id = e.id OR candidate.target_event_id = e.id)
        ORDER BY candidate.updated_at DESC
        LIMIT 1
      )
      LEFT JOIN entities en ON en.id = CASE
        WHEN r.source_event_id = e.id THEN r.target_entity_id
        ELSE r.source_entity_id
      END
      LEFT JOIN event_categories ec ON ec.rowid = (
        SELECT candidate.rowid
        FROM event_categories candidate
        WHERE candidate.event_id = e.id
        LIMIT 1
      )
      LEFT JOIN categories c ON c.id = ec.category_id
      WHERE $whereSql
      ORDER BY
        CASE WHEN e.start_year IS NULL THEN 1 ELSE 0 END,
        e.start_year DESC,
        COALESCE(e.start_month, 0) DESC,
        COALESCE(e.start_day, 0) DESC,
        e.updated_at DESC
    ''',
    variables: variables,
    readsFrom: {
      _database.events,
      _database.relationships,
      _database.entities,
      _database.eventCategories,
      _database.categories,
    },
  );

  TimelineMemory _memoryFromRow(QueryRow row) {
    final eventRow = _database.events.map(row.data);
    final relatedEntityId = row.readNullable<String>('related_entity_id');
    final relationshipId = row.readNullable<String>('related_relationship_id');
    final categoryId = row.readNullable<String>('category_id');
    final event = TimelineMapper.eventFromRow(eventRow);
    final entity = relatedEntityId == null
        ? null
        : Entity(
            metadata: PersistenceValueCodec.metadataFromStorage(
              id: relatedEntityId,
              privacyClassification: row.read<String>('related_entity_privacy'),
              lifecycle: row.read<String>('related_entity_lifecycle'),
              createdAt: row.read<DateTime>('related_entity_created_at'),
              updatedAt: row.read<DateTime>('related_entity_updated_at'),
              deletedAt: row.readNullable<DateTime>(
                'related_entity_deleted_at',
              ),
            ),
            name: row.read<String>('related_entity_name'),
            entityType: row.read<String>('related_entity_type'),
            notes: row.readNullable<String>('related_entity_notes'),
          );
    final relationship = relationshipId == null || entity == null
        ? null
        : Relationship(
            metadata: PersistenceValueCodec.metadataFromStorage(
              id: relationshipId,
              privacyClassification: row.read<String>(
                'related_relationship_privacy',
              ),
              lifecycle: row.read<String>('related_relationship_lifecycle'),
              createdAt: row.read<DateTime>('related_relationship_created_at'),
              updatedAt: row.read<DateTime>('related_relationship_updated_at'),
              deletedAt: row.readNullable<DateTime>(
                'related_relationship_deleted_at',
              ),
            ),
            source: TimelineRecordReference(
              type: TimelineRecordType.event,
              id: event.metadata.id,
            ),
            target: TimelineRecordReference(
              type: TimelineRecordType.entity,
              id: entity.metadata.id,
            ),
            relationshipType: 'related_entity',
          );
    final category = categoryId == null
        ? null
        : Category(
            metadata: PersistenceValueCodec.metadataFromStorage(
              id: categoryId,
              privacyClassification: row.read<String>('category_privacy'),
              lifecycle: row.read<String>('category_lifecycle'),
              createdAt: row.read<DateTime>('category_created_at'),
              updatedAt: row.read<DateTime>('category_updated_at'),
              deletedAt: row.readNullable<DateTime>('category_deleted_at'),
            ),
            name: row.read<String>('category_name'),
            parentId: row.readNullable<String>('category_parent_id'),
          );
    return TimelineMemory(
      event: event,
      relatedEntity: entity,
      relatedEntityRelationship: relationship,
      category: category,
    );
  }

  Future<void> _syncRelatedEntity(TimelineMemory memory) async {
    final eventId = memory.event.metadata.id;
    final at = memory.event.metadata.updatedAt;
    final suppliedEntity = memory.relatedEntity;
    final suppliedRelationship = memory.relatedEntityRelationship;
    String? relationshipToKeep;
    if (suppliedEntity != null && suppliedRelationship != null) {
      final normalized = PersistenceValueCodec.normalizeName(
        suppliedEntity.name,
      );
      final existingByName =
          await (_database.select(_database.entities)
                ..where(
                  (row) =>
                      row.normalizedName.equals(normalized) &
                      row.lifecycle.isNotValue('soft_deleted'),
                )
                ..limit(1))
              .getSingleOrNull();
      final entityId = existingByName?.id ?? suppliedEntity.metadata.id;
      if (existingByName == null) {
        await _database
            .into(_database.entities)
            .insertOnConflictUpdate(
              TimelineMapper.entityToCompanion(suppliedEntity),
            );
      }
      final relationship = Relationship(
        metadata: suppliedRelationship.metadata,
        source: TimelineRecordReference(
          type: TimelineRecordType.event,
          id: eventId,
        ),
        target: TimelineRecordReference(
          type: TimelineRecordType.entity,
          id: entityId,
        ),
        relationshipType: 'related_entity',
      );
      relationshipToKeep = relationship.metadata.id;
      await _database
          .into(_database.relationships)
          .insertOnConflictUpdate(
            TimelineMapper.relationshipToCompanion(relationship),
          );
    }

    final stale = _database.update(_database.relationships)
      ..where(
        (row) =>
            row.relationshipType.equals('related_entity') &
            (row.sourceEventId.equals(eventId) |
                row.targetEventId.equals(eventId)) &
            row.lifecycle.isNotValue('soft_deleted') &
            (relationshipToKeep == null
                ? const Constant(true)
                : row.id.isNotValue(relationshipToKeep)),
      );
    await stale.write(
      db.RelationshipsCompanion(
        lifecycle: const Value('soft_deleted'),
        updatedAt: Value(at),
        deletedAt: Value(at),
      ),
    );
  }

  Future<void> _syncCategory(TimelineMemory memory) async {
    final category = memory.category;
    await (_database.delete(
      _database.eventCategories,
    )..where((row) => row.eventId.equals(memory.event.metadata.id))).go();
    if (category == null) {
      return;
    }
    final normalized = PersistenceValueCodec.normalizeName(category.name);
    final existing =
        await (_database.select(_database.categories)
              ..where(
                (row) =>
                    row.normalizedName.equals(normalized) &
                    row.lifecycle.isNotValue('soft_deleted'),
              )
              ..limit(1))
            .getSingleOrNull();
    final categoryId = existing?.id ?? category.metadata.id;
    if (existing == null) {
      await _database
          .into(_database.categories)
          .insertOnConflictUpdate(TimelineMapper.categoryToCompanion(category));
    }
    await _database
        .into(_database.eventCategories)
        .insert(
          db.EventCategoriesCompanion(
            eventId: Value(memory.event.metadata.id),
            categoryId: Value(categoryId),
          ),
        );
  }

  Future<void> _refreshEventSearchIndex(String eventId) async {
    await _database.customStatement(
      'DELETE FROM event_search WHERE event_id = ?',
      [eventId],
    );
    await _database.customStatement(
      '''
        INSERT INTO event_search(
          event_id,
          title,
          description,
          event_type,
          entity_names,
          category_names
        )
        SELECT
          e.id,
          e.title,
          COALESCE(e.description, ''),
          COALESCE(e.event_type, ''),
          COALESCE((
            SELECT group_concat(en.name, ' ')
            FROM relationships r
            JOIN entities en ON (
              (r.source_event_id = e.id AND r.target_entity_id = en.id) OR
              (r.target_event_id = e.id AND r.source_entity_id = en.id)
            )
            WHERE r.lifecycle <> 'soft_deleted'
              AND en.lifecycle <> 'soft_deleted'
          ), ''),
          COALESCE((
            SELECT group_concat(c.name, ' ')
            FROM event_categories ec
            JOIN categories c ON c.id = ec.category_id
            WHERE ec.event_id = e.id
              AND c.lifecycle <> 'soft_deleted'
          ), '')
        FROM events e
        WHERE e.id = ? AND e.lifecycle <> 'soft_deleted'
      ''',
      [eventId],
    );
  }

  String _ftsMatchQuery(String query) => query
      .trim()
      .split(RegExp(r'\s+'))
      .where((term) => term.isNotEmpty)
      .map((term) => '"${term.replaceAll('"', '""')}"*')
      .join(' AND ');

  MemoryMatchField _matchedField(TimelineMemory memory, String query) {
    final terms = query.split(RegExp(r'\s+')).where((term) => term.isNotEmpty);
    bool matches(String? value) {
      final normalized = value?.toLowerCase();
      return normalized != null && terms.any(normalized.contains);
    }

    if (matches(memory.event.title)) {
      return MemoryMatchField.title;
    }
    if (matches(memory.event.description)) {
      return MemoryMatchField.description;
    }
    if (matches(memory.event.eventType)) {
      return MemoryMatchField.eventType;
    }
    if (matches(memory.relatedEntity?.name)) {
      return MemoryMatchField.entity;
    }
    return MemoryMatchField.category;
  }
}
