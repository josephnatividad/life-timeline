import 'package:drift/drift.dart';
import 'package:life_timeline/shared/database/app_database.dart' as db;
import 'package:life_timeline/shared/database/mappers/persistence_value_codec.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart'
    as domain;

abstract final class TimelineMapper {
  static db.EntitiesCompanion entityToCompanion(domain.Entity value) =>
      db.EntitiesCompanion(
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
        name: Value(value.name),
        normalizedName: Value(PersistenceValueCodec.normalizeName(value.name)),
        entityType: Value(value.entityType),
        notes: Value(value.notes),
      );

  static domain.Entity entityFromRow(db.Entity row) => domain.Entity(
    metadata: PersistenceValueCodec.metadataFromStorage(
      id: row.id,
      privacyClassification: row.privacyClassification,
      lifecycle: row.lifecycle,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    ),
    name: row.name,
    entityType: row.entityType,
    notes: row.notes,
  );

  static db.EventsCompanion eventToCompanion(domain.Event value) {
    final temporal = PersistenceValueCodec.temporalToStorage(
      value.temporalValue,
    );
    return db.EventsCompanion(
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
      normalizedTitle: Value(PersistenceValueCodec.normalizeName(value.title)),
      description: Value(value.description),
      eventType: Value(value.eventType),
    );
  }

  static domain.Event eventFromRow(db.Event row) => domain.Event(
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
    eventType: row.eventType,
  );

  static db.EvidenceRecordsCompanion evidenceToCompanion(
    domain.Evidence value,
  ) => db.EvidenceRecordsCompanion(
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
    title: Value(value.title),
    normalizedTitle: Value(PersistenceValueCodec.normalizeName(value.title)),
    evidenceType: Value(
      PersistenceValueCodec.evidenceTypeToStorage(value.evidenceType),
    ),
    summary: Value(value.summary),
  );

  static domain.Evidence evidenceFromRow(db.EvidenceRecord row) =>
      domain.Evidence(
        metadata: PersistenceValueCodec.metadataFromStorage(
          id: row.id,
          privacyClassification: row.privacyClassification,
          lifecycle: row.lifecycle,
          createdAt: row.createdAt,
          updatedAt: row.updatedAt,
          deletedAt: row.deletedAt,
        ),
        evidenceType: PersistenceValueCodec.evidenceTypeFromStorage(
          row.evidenceType,
        ),
        title: row.title,
        summary: row.summary,
      );

  static db.AttachmentsCompanion attachmentToCompanion(
    domain.Attachment value,
  ) => db.AttachmentsCompanion(
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
    evidenceId: Value(value.evidenceId),
    displayName: Value(value.displayName),
    relativePath: Value(value.relativePath),
    thumbnailRelativePath: Value(value.thumbnailRelativePath),
    mimeType: Value(value.mimeType),
    byteSize: Value(value.byteSize),
    checksum: Value(value.checksum),
    storageState: Value(
      PersistenceValueCodec.attachmentStateToStorage(value.storageState),
    ),
    importMode: Value(
      PersistenceValueCodec.attachmentModeToStorage(value.importMode),
    ),
  );

  static domain.Attachment attachmentFromRow(db.Attachment row) =>
      domain.Attachment(
        metadata: PersistenceValueCodec.metadataFromStorage(
          id: row.id,
          privacyClassification: row.privacyClassification,
          lifecycle: row.lifecycle,
          createdAt: row.createdAt,
          updatedAt: row.updatedAt,
          deletedAt: row.deletedAt,
        ),
        evidenceId: row.evidenceId,
        storageState: PersistenceValueCodec.attachmentStateFromStorage(
          row.storageState,
        ),
        importMode: PersistenceValueCodec.attachmentModeFromStorage(
          row.importMode,
        ),
        mimeType: row.mimeType,
        byteSize: row.byteSize,
        checksum: row.checksum,
        displayName: row.displayName,
        relativePath: row.relativePath,
        thumbnailRelativePath: row.thumbnailRelativePath,
      );

  static db.RelationshipsCompanion relationshipToCompanion(
    domain.Relationship value,
  ) {
    String? sourceEntityId;
    String? sourceEventId;
    String? sourceEvidenceId;
    String? targetEntityId;
    String? targetEventId;
    String? targetEvidenceId;
    switch (value.source.type) {
      case domain.TimelineRecordType.entity:
        sourceEntityId = value.source.id;
      case domain.TimelineRecordType.event:
        sourceEventId = value.source.id;
      case domain.TimelineRecordType.evidence:
        sourceEvidenceId = value.source.id;
    }
    switch (value.target.type) {
      case domain.TimelineRecordType.entity:
        targetEntityId = value.target.id;
      case domain.TimelineRecordType.event:
        targetEventId = value.target.id;
      case domain.TimelineRecordType.evidence:
        targetEvidenceId = value.target.id;
    }
    return db.RelationshipsCompanion(
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
      sourceEntityId: Value(sourceEntityId),
      sourceEventId: Value(sourceEventId),
      sourceEvidenceId: Value(sourceEvidenceId),
      targetEntityId: Value(targetEntityId),
      targetEventId: Value(targetEventId),
      targetEvidenceId: Value(targetEvidenceId),
      relationshipType: Value(value.relationshipType),
      notes: Value(value.notes),
    );
  }

  static domain.Relationship relationshipFromRow(db.Relationship row) =>
      domain.Relationship(
        metadata: PersistenceValueCodec.metadataFromStorage(
          id: row.id,
          privacyClassification: row.privacyClassification,
          lifecycle: row.lifecycle,
          createdAt: row.createdAt,
          updatedAt: row.updatedAt,
          deletedAt: row.deletedAt,
        ),
        source: _reference(
          entityId: row.sourceEntityId,
          eventId: row.sourceEventId,
          evidenceId: row.sourceEvidenceId,
        ),
        target: _reference(
          entityId: row.targetEntityId,
          eventId: row.targetEventId,
          evidenceId: row.targetEvidenceId,
        ),
        relationshipType: row.relationshipType,
        notes: row.notes,
      );

  static db.TagsCompanion tagToCompanion(domain.Tag value) => db.TagsCompanion(
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
    name: Value(value.name),
    normalizedName: Value(PersistenceValueCodec.normalizeName(value.name)),
  );

  static db.CategoriesCompanion categoryToCompanion(domain.Category value) =>
      db.CategoriesCompanion(
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
        name: Value(value.name),
        normalizedName: Value(PersistenceValueCodec.normalizeName(value.name)),
        parentId: Value(value.parentId),
      );

  static domain.TimelineRecordReference _reference({
    required String? entityId,
    required String? eventId,
    required String? evidenceId,
  }) {
    if (entityId != null) {
      return domain.TimelineRecordReference(
        type: domain.TimelineRecordType.entity,
        id: entityId,
      );
    }
    if (eventId != null) {
      return domain.TimelineRecordReference(
        type: domain.TimelineRecordType.event,
        id: eventId,
      );
    }
    if (evidenceId != null) {
      return domain.TimelineRecordReference(
        type: domain.TimelineRecordType.evidence,
        id: evidenceId,
      );
    }
    throw const FormatException('Relationship endpoint is missing.');
  }
}
