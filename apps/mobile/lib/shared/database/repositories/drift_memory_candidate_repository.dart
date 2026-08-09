import 'package:drift/drift.dart';
import 'package:life_timeline/shared/database/app_database.dart' as db;
import 'package:life_timeline/shared/database/mappers/candidate_provenance_mapper.dart';
import 'package:life_timeline/shared/database/mappers/timeline_mapper.dart';
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
    await _database
        .into(_database.memoryCandidates)
        .insertOnConflictUpdate(
          CandidateProvenanceMapper.candidateToCompanion(candidate),
        );
  }

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
    return row == null ? null : CandidateProvenanceMapper.candidateFromRow(row);
  }

  @override
  Future<List<MemoryCandidate>> pendingCandidates() async {
    final query = _database.select(_database.memoryCandidates)
      ..where((row) => row.lifecycle.equals('candidate'))
      ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]);
    return (await query.get())
        .map(CandidateProvenanceMapper.candidateFromRow)
        .toList();
  }

  @override
  Future<void> confirmCandidate({
    required String candidateId,
    required Event confirmedEvent,
    required DateTime confirmedAt,
    List<FieldProvenance> provenance = const [],
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
    await (_database.update(
      _database.memoryCandidates,
    )..where((row) => row.id.equals(candidateId))).write(
      db.MemoryCandidatesCompanion(
        lifecycle: const Value('confirmed'),
        updatedAt: Value(confirmedAt.toUtc()),
        deletedAt: const Value(null),
        confirmedEventId: Value(confirmedEvent.metadata.id),
      ),
    );
    for (final field in provenance) {
      await _database
          .into(_database.fieldProvenanceRows)
          .insertOnConflictUpdate(
            CandidateProvenanceMapper.provenanceToCompanion(field),
          );
    }
  });

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
