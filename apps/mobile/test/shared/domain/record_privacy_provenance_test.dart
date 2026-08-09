import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/shared/domain/model/field_provenance.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';

void main() {
  final createdAt = DateTime.utc(2025, 1, 1);

  test('soft-deleted records require a deletion timestamp', () {
    expect(
      () => RecordMetadata(
        id: 'entity-1',
        privacyClassification: PrivacyClassification.sensitive,
        lifecycle: RecordLifecycle.softDeleted,
        createdAt: createdAt,
        updatedAt: createdAt,
      ),
      throwsArgumentError,
    );
  });

  test('field provenance preserves privacy and confirmation state', () {
    final provenance = FieldProvenance(
      id: 'provenance-1',
      target: ProvenanceTarget(type: ProvenanceTargetType.event, id: 'event-1'),
      fieldName: 'title',
      sourceId: 'user-entry-1',
      sourceType: ProvenanceSourceType.user,
      extractionMethod: ExtractionMethod.manual,
      confidence: 1,
      userConfirmed: true,
      privacyClassification: PrivacyClassification.neverShare,
      createdAt: createdAt,
      updatedAt: createdAt,
    );

    expect(provenance.userConfirmed, isTrue);
    expect(provenance.privacyClassification, PrivacyClassification.neverShare);
  });

  test('field provenance rejects confidence outside zero to one', () {
    expect(
      () => FieldProvenance(
        id: 'provenance-1',
        target: ProvenanceTarget(
          type: ProvenanceTargetType.event,
          id: 'event-1',
        ),
        fieldName: 'title',
        sourceId: 'source-1',
        sourceType: ProvenanceSourceType.system,
        extractionMethod: ExtractionMethod.deterministic,
        confidence: 1.01,
        userConfirmed: false,
        privacyClassification: PrivacyClassification.personal,
        createdAt: createdAt,
        updatedAt: createdAt,
      ),
      throwsArgumentError,
    );
  });
}
