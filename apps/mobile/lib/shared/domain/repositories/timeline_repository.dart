import 'package:life_timeline/shared/domain/model/field_provenance.dart';
import 'package:life_timeline/shared/domain/model/memory_candidate.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

abstract interface class TimelineRepository {
  Stream<List<TimelineMemory>> watchMemories({bool archived = false});
  Future<TimelineMemory?> memoryById(String id);
  Future<List<MemorySearchResult>> searchMemories(String query);
  Future<void> saveMemory(
    TimelineMemory memory, {
    List<FieldProvenance> provenance = const [],
  });
  Future<void> archiveEvent(String id, DateTime archivedAt);
  Future<void> restoreEvent(String id, DateTime restoredAt);

  Future<void> saveEntity(Entity entity);
  Future<void> saveEvent(Event event);
  Future<void> saveEvidence(
    Evidence evidence, {
    List<Attachment> attachments = const [],
  });
  Future<void> saveRelationship(Relationship relationship);
  Future<void> saveFieldProvenance(FieldProvenance provenance);
  Future<void> saveTag(Tag tag);
  Future<void> saveCategory(Category category);

  Future<Entity?> entityById(String id, {bool includeDeleted = false});
  Future<Event?> eventById(String id, {bool includeDeleted = false});
  Future<Evidence?> evidenceById(String id, {bool includeDeleted = false});
  Future<List<Attachment>> attachmentsForEvidence(String evidenceId);
  Future<List<Relationship>> relationshipsFor(TimelineRecordReference record);
  Future<List<FieldProvenance>> provenanceFor(ProvenanceTarget target);

  Future<void> assignTag(TimelineRecordReference record, String tagId);
  Future<void> assignCategory(
    TimelineRecordReference record,
    String categoryId,
  );
  Future<void> softDeleteEntity(String id, DateTime deletedAt);
  Future<void> softDeleteEvent(String id, DateTime deletedAt);
  Future<void> softDeleteEvidence(String id, DateTime deletedAt);
}

abstract interface class MemoryCandidateRepository {
  Future<void> saveCandidate(MemoryCandidate candidate);
  Future<MemoryCandidate?> candidateById(
    String id, {
    bool includeDeleted = false,
  });
  Future<List<MemoryCandidate>> pendingCandidates();

  /// Atomically creates the confirmed event and resolves the Inbox candidate.
  Future<void> confirmCandidate({
    required String candidateId,
    required Event confirmedEvent,
    required DateTime confirmedAt,
    List<FieldProvenance> provenance = const [],
  });

  Future<void> softDeleteCandidate(String id, DateTime deletedAt);
}
