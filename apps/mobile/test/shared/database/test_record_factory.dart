import 'package:life_timeline/shared/domain/model/field_provenance.dart';
import 'package:life_timeline/shared/domain/model/memory_candidate.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';
import 'package:life_timeline/shared/domain/model/temporal_value.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

abstract final class TestRecordFactory {
  static final createdAt = DateTime.utc(2025, 1, 1, 10);

  static RecordMetadata metadata(
    String id, {
    RecordLifecycle lifecycle = RecordLifecycle.confirmed,
    PrivacyClassification privacy = PrivacyClassification.personal,
  }) => RecordMetadata(
    id: id,
    privacyClassification: privacy,
    lifecycle: lifecycle,
    createdAt: createdAt,
    updatedAt: createdAt,
  );

  static Entity entity({String id = 'entity-1'}) => Entity(
    metadata: metadata(id),
    name: 'Ada Lovelace',
    entityType: 'person',
  );

  static Event event({String id = 'event-1'}) => Event(
    metadata: metadata(id),
    title: 'Started a new chapter',
    temporalValue: TemporalValue.approximate(TemporalPoint(year: 2018)),
  );

  static Evidence evidence({String id = 'evidence-1'}) => Evidence(
    metadata: metadata(id, privacy: PrivacyClassification.sensitive),
    evidenceType: EvidenceType.photo,
    title: 'Reference photo',
  );

  static Attachment attachment({String id = 'attachment-1'}) => Attachment(
    metadata: metadata(id, privacy: PrivacyClassification.sensitive),
    evidenceId: 'evidence-1',
    storageState: AttachmentStorageState.local,
    importMode: AttachmentImportMode.preserveOriginal,
    mimeType: 'image/jpeg',
    byteSize: 2048,
    relativePath: 'evidence-1/photo.jpg',
    thumbnailRelativePath: 'thumbnails/evidence-1/photo.jpg',
    checksum: 'sha256:test',
  );

  static Relationship relationship({String targetId = 'event-1'}) =>
      Relationship(
        metadata: metadata('relationship-1'),
        source: TimelineRecordReference(
          type: TimelineRecordType.entity,
          id: 'entity-1',
        ),
        target: TimelineRecordReference(
          type: TimelineRecordType.event,
          id: targetId,
        ),
        relationshipType: 'participated_in',
      );

  static FieldProvenance provenance() => FieldProvenance(
    id: 'provenance-1',
    target: ProvenanceTarget(type: ProvenanceTargetType.event, id: 'event-1'),
    fieldName: 'title',
    sourceId: 'user-entry-1',
    sourceType: ProvenanceSourceType.user,
    extractionMethod: ExtractionMethod.manual,
    confidence: 1,
    userConfirmed: true,
    privacyClassification: PrivacyClassification.personal,
    createdAt: createdAt,
    updatedAt: createdAt,
  );

  static MemoryCandidate candidate() => MemoryCandidate(
    metadata: metadata('candidate-1', lifecycle: RecordLifecycle.candidate),
    title: 'Possible timeline event',
    temporalValue: TemporalValue.month(year: 2020, month: 6),
    sourceEvidenceId: 'evidence-1',
  );
}
