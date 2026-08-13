import 'package:drift/drift.dart';
import 'package:life_timeline/features/private_intelligence/domain/intelligence_models.dart';
import 'package:life_timeline/features/reminders/domain/reminder.dart';
import 'package:life_timeline/shared/database/app_database.dart' as db;
import 'package:life_timeline/shared/database/mappers/candidate_provenance_mapper.dart';
import 'package:life_timeline/shared/database/mappers/reminder_mapper.dart';
import 'package:life_timeline/shared/database/mappers/timeline_mapper.dart';
import 'package:life_timeline/shared/database/schema_migrations.dart';
import 'package:life_timeline/shared/domain/model/field_provenance.dart';
import 'package:life_timeline/shared/domain/model/memory_candidate.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';
import 'package:life_timeline/shared/domain/repositories/timeline_repository.dart';

final class DriftMemoryCandidateRepository
    implements MemoryCandidateRepository {
  DriftMemoryCandidateRepository(this._database);

  final db.AppDatabase _database;

  @override
  Future<void> saveCandidate(MemoryCandidate candidate) async {
    await _database.transaction(() => _saveCandidateAggregate(candidate));
  }

  Future<void> _saveCandidateAggregate(MemoryCandidate candidate) async {
    await _database
        .into(_database.memoryCandidates)
        .insertOnConflictUpdate(
          CandidateProvenanceMapper.candidateToCompanion(candidate),
        );
    await (_database.delete(
      _database.candidateExtractedFields,
    )..where((row) => row.candidateId.equals(candidate.metadata.id))).go();
    await (_database.delete(
      _database.candidateEntityProposals,
    )..where((row) => row.candidateId.equals(candidate.metadata.id))).go();
    for (final field in candidate.extractedFields) {
      await _database
          .into(_database.candidateExtractedFields)
          .insert(
            db.CandidateExtractedFieldsCompanion.insert(
              id: field.id,
              candidateId: candidate.metadata.id,
              key: field.key,
              value: field.value,
              valueType: field.valueType.name,
              confidence: field.confidence,
              privacyClassification: field.privacyClassification.name,
              extractionMethod: field.extractionMethod,
              sourceExcerpt: Value(field.sourceExcerpt),
              reviewRecommended: Value(field.reviewRecommended),
            ),
          );
    }
    for (final proposal in candidate.entityProposals) {
      await _database
          .into(_database.candidateEntityProposals)
          .insert(
            db.CandidateEntityProposalsCompanion.insert(
              id: proposal.id,
              candidateId: candidate.metadata.id,
              name: proposal.name,
              entityType: proposal.entityType,
              confidence: proposal.confidence,
              brand: Value(proposal.brand),
              model: Value(proposal.model),
              serialNumber: Value(proposal.serialNumber),
              suggestedEntityId: Value(proposal.suggestedEntityId),
              matchScore: Value(proposal.matchScore),
              matchReasons: Value(proposal.matchReasons.join('|')),
            ),
          );
    }
  }

  @override
  Future<void> saveCaptureCandidate({
    required MemoryCandidate candidate,
    required Evidence evidence,
    required Attachment attachment,
    List<FieldProvenance> provenance = const [],
  }) => _database.transaction(() async {
    await _database
        .into(_database.evidenceRecords)
        .insert(TimelineMapper.evidenceToCompanion(evidence));
    await _database
        .into(_database.attachments)
        .insert(TimelineMapper.attachmentToCompanion(attachment));
    await _database
        .into(_database.attachmentLinks)
        .insert(
          TimelineMapper.attachmentLinkToCompanion(
            AttachmentLink(
              id: 'evidence-link:${evidence.metadata.id}:${attachment.metadata.id}',
              attachmentId: attachment.metadata.id,
              evidenceId: evidence.metadata.id,
              role: AttachmentRole.evidence,
              sortOrder: 0,
              importedAt: attachment.metadata.createdAt,
            ),
          ),
        );
    await _saveCandidateAggregate(candidate);
    for (final field in provenance) {
      await _database
          .into(_database.fieldProvenanceRows)
          .insert(CandidateProvenanceMapper.provenanceToCompanion(field));
    }
  });

  @override
  Future<MemoryCandidate?> candidateById(
    String id, {
    bool includeDeleted = false,
  }) async {
    final query = _database.select(_database.memoryCandidates)
      ..where(
        (row) =>
            row.id.equals(id) &
            (includeDeleted
                ? const Constant(true)
                : row.lifecycle.isNotValue('soft_deleted')),
      );
    final row = await query.getSingleOrNull();
    return row == null ? null : _hydrate(row);
  }

  @override
  Future<List<MemoryCandidate>> pendingCandidates() async {
    final query = _database.select(_database.memoryCandidates)
      ..where(
        (row) =>
            row.lifecycle.equals('candidate') &
            row.reviewStatus.isIn(['pending', 'reviewing']),
      )
      ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]);
    return Future.wait((await query.get()).map(_hydrate));
  }

  @override
  Stream<List<MemoryCandidate>> watchPendingCandidates() {
    final query = _database.select(_database.memoryCandidates)
      ..where(
        (row) =>
            row.lifecycle.equals('candidate') &
            row.reviewStatus.isIn(['pending', 'reviewing']),
      )
      ..orderBy([(row) => OrderingTerm.desc(row.createdAt)]);
    return query.watch().asyncMap((rows) => Future.wait(rows.map(_hydrate)));
  }

  @override
  Future<String?> entityIdForExactSerial(String serialNumber) async {
    final rows = await _database
        .customSelect(
          '''
      SELECT p.suggested_entity_id
      FROM candidate_entity_proposals p
      JOIN memory_candidates c ON c.id = p.candidate_id
      WHERE p.suggested_entity_id IS NOT NULL
        AND p.serial_number IS NOT NULL
        AND lower(p.serial_number) = lower(?)
        AND c.review_status = 'confirmed'
      ORDER BY c.updated_at DESC
      LIMIT 1
      ''',
          variables: [Variable.withString(serialNumber.trim())],
          readsFrom: {
            _database.candidateEntityProposals,
            _database.memoryCandidates,
          },
        )
        .get();
    return rows.isEmpty ? null : rows.first.read<String>('suggested_entity_id');
  }

  Future<MemoryCandidate> _hydrate(db.MemoryCandidate row) async {
    final fieldsQuery = _database.select(_database.candidateExtractedFields)
      ..where((value) => value.candidateId.equals(row.id));
    final proposalsQuery = _database.select(_database.candidateEntityProposals)
      ..where((value) => value.candidateId.equals(row.id));
    final fields = await fieldsQuery.get();
    final proposals = await proposalsQuery.get();
    return CandidateProvenanceMapper.candidateFromRow(row).copyWith(
      extractedFields: fields
          .map(
            (field) => ExtractedField(
              id: field.id,
              key: field.key,
              value: field.value,
              valueType: ExtractedValueType.values.byName(field.valueType),
              confidence: field.confidence,
              privacyClassification: PrivacyClassification.values.byName(
                field.privacyClassification,
              ),
              extractionMethod: field.extractionMethod,
              sourceExcerpt: field.sourceExcerpt,
              reviewRecommended: field.reviewRecommended,
            ),
          )
          .toList(),
      entityProposals: proposals
          .map(
            (proposal) => EntityProposal(
              id: proposal.id,
              name: proposal.name,
              entityType: proposal.entityType,
              confidence: proposal.confidence,
              brand: proposal.brand,
              model: proposal.model,
              serialNumber: proposal.serialNumber,
              suggestedEntityId: proposal.suggestedEntityId,
              matchScore: proposal.matchScore,
              matchReasons: proposal.matchReasons.isEmpty
                  ? const []
                  : proposal.matchReasons.split('|'),
            ),
          )
          .toList(),
    );
  }

  @override
  Future<void> confirmCandidate({
    required String candidateId,
    required Event confirmedEvent,
    required DateTime confirmedAt,
    List<FieldProvenance> provenance = const [],
    List<Entity> entities = const [],
    List<Relationship> relationships = const [],
    Reminder? reminder,
  }) => _database.transaction(() async {
    final candidateQuery = _database.select(_database.memoryCandidates)
      ..where((row) => row.id.equals(candidateId));
    final candidateRow = await candidateQuery.getSingleOrNull();
    if (candidateRow == null) {
      throw StateError('Memory candidate does not exist.');
    }
    final candidate = CandidateProvenanceMapper.candidateFromRow(candidateRow);
    if (candidate.metadata.lifecycle != RecordLifecycle.candidate) {
      throw StateError('Only pending candidates can be confirmed.');
    }
    if (confirmedAt.toUtc().isBefore(candidate.metadata.createdAt)) {
      throw ArgumentError('confirmedAt must not be before candidate creation.');
    }

    await _database
        .into(_database.events)
        .insertOnConflictUpdate(
          TimelineMapper.eventToCompanion(confirmedEvent),
        );
    for (final entity in entities) {
      await _database
          .into(_database.entities)
          .insertOnConflictUpdate(TimelineMapper.entityToCompanion(entity));
    }
    for (final relationship in relationships) {
      await _database
          .into(_database.relationships)
          .insertOnConflictUpdate(
            TimelineMapper.relationshipToCompanion(relationship),
          );
    }
    String? relatedEntityId;
    for (final relationship in relationships) {
      if (relationship.target.type == TimelineRecordType.entity) {
        relatedEntityId = relationship.target.id;
        break;
      }
    }
    if (relatedEntityId != null) {
      await (_database.update(
        _database.candidateEntityProposals,
      )..where((row) => row.candidateId.equals(candidateId))).write(
        db.CandidateEntityProposalsCompanion(
          suggestedEntityId: Value(relatedEntityId),
        ),
      );
    }
    await (_database.update(
      _database.memoryCandidates,
    )..where((row) => row.id.equals(candidateId))).write(
      db.MemoryCandidatesCompanion(
        lifecycle: const Value('confirmed'),
        updatedAt: Value(confirmedAt.toUtc()),
        deletedAt: const Value(null),
        confirmedEventId: Value(confirmedEvent.metadata.id),
        reviewStatus: const Value('confirmed'),
      ),
    );
    if (candidate.sourceEvidenceId != null) {
      await (_database.update(
        _database.evidenceRecords,
      )..where((row) => row.id.equals(candidate.sourceEvidenceId!))).write(
        db.EvidenceRecordsCompanion(
          lifecycle: const Value('confirmed'),
          updatedAt: Value(confirmedAt.toUtc()),
        ),
      );
      final evidenceAttachmentIds =
          _database.selectOnly(_database.attachmentLinks)
            ..addColumns([_database.attachmentLinks.attachmentId])
            ..where(
              _database.attachmentLinks.evidenceId.equals(
                candidate.sourceEvidenceId!,
              ),
            );
      await (_database.update(
        _database.attachments,
      )..where((row) => row.id.isInQuery(evidenceAttachmentIds))).write(
        db.AttachmentsCompanion(
          lifecycle: const Value('confirmed'),
          updatedAt: Value(confirmedAt.toUtc()),
        ),
      );
    }
    for (final field in provenance) {
      await _database
          .into(_database.fieldProvenanceRows)
          .insertOnConflictUpdate(
            CandidateProvenanceMapper.provenanceToCompanion(field),
          );
    }
    if (reminder != null) {
      await _database
          .into(_database.reminders)
          .insert(ReminderMapper.toCompanion(reminder));
    }
    // Rebuild from persisted relationships rather than only the newly-created
    // entities. This also indexes an existing entity linked during review.
    await refreshEventSearchIndex(_database, confirmedEvent.metadata.id);
  });

  @override
  Future<void> setReviewStatus(
    String id,
    CandidateReviewStatus status,
    DateTime updatedAt,
  ) async {
    await (_database.update(
      _database.memoryCandidates,
    )..where((row) => row.id.equals(id))).write(
      db.MemoryCandidatesCompanion(
        reviewStatus: Value(status.name),
        updatedAt: Value(updatedAt.toUtc()),
      ),
    );
  }

  @override
  Future<void> softDeleteCandidate(String id, DateTime deletedAt) async {
    final at = deletedAt.toUtc();
    await (_database.update(
      _database.memoryCandidates,
    )..where((row) => row.id.equals(id))).write(
      db.MemoryCandidatesCompanion(
        lifecycle: const Value('soft_deleted'),
        updatedAt: Value(at),
        deletedAt: Value(at),
      ),
    );
  }
}
