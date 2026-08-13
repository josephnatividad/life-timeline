import 'package:life_timeline/shared/domain/model/field_provenance.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';
import 'package:life_timeline/shared/domain/model/temporal_value.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

abstract final class PersistenceValueCodec {
  static String privacyToStorage(PrivacyClassification value) =>
      switch (value) {
        PrivacyClassification.shareSafe => 'share_safe',
        PrivacyClassification.personal => 'personal',
        PrivacyClassification.sensitive => 'sensitive',
        PrivacyClassification.neverShare => 'never_share',
      };

  static PrivacyClassification privacyFromStorage(String value) =>
      switch (value) {
        'share_safe' => PrivacyClassification.shareSafe,
        'personal' => PrivacyClassification.personal,
        'sensitive' => PrivacyClassification.sensitive,
        'never_share' => PrivacyClassification.neverShare,
        _ => throw FormatException('Unknown privacy classification: $value'),
      };

  static String lifecycleToStorage(RecordLifecycle value) => switch (value) {
    RecordLifecycle.candidate => 'candidate',
    RecordLifecycle.confirmed => 'confirmed',
    RecordLifecycle.archived => 'archived',
    RecordLifecycle.softDeleted => 'soft_deleted',
  };

  static RecordLifecycle lifecycleFromStorage(String value) => switch (value) {
    'candidate' => RecordLifecycle.candidate,
    'confirmed' => RecordLifecycle.confirmed,
    'archived' => RecordLifecycle.archived,
    'soft_deleted' => RecordLifecycle.softDeleted,
    _ => throw FormatException('Unknown record lifecycle: $value'),
  };

  static String evidenceTypeToStorage(EvidenceType value) => switch (value) {
    EvidenceType.receipt => 'receipt',
    EvidenceType.warranty => 'warranty',
    EvidenceType.certificate => 'certificate',
    EvidenceType.ticket => 'ticket',
    EvidenceType.officialDocument => 'official_document',
    EvidenceType.other => 'other',
  };

  static EvidenceType evidenceTypeFromStorage(String value) => switch (value) {
    'receipt' => EvidenceType.receipt,
    'warranty' => EvidenceType.warranty,
    'certificate' => EvidenceType.certificate,
    'ticket' => EvidenceType.ticket,
    'official_document' || 'document' => EvidenceType.officialDocument,
    // Legacy image evidence remains evidence after migration. Its type is
    // intentionally made non-semantic instead of turning it into Memory Media.
    'photo' || 'screenshot' || 'metadata' || 'other' => EvidenceType.other,
    _ => throw FormatException('Unknown evidence type: $value'),
  };

  static String attachmentStateToStorage(AttachmentStorageState value) =>
      value.name;

  static AttachmentStorageState attachmentStateFromStorage(String value) =>
      AttachmentStorageState.values.firstWhere(
        (candidate) => candidate.name == value,
        orElse: () => throw FormatException('Unknown attachment state: $value'),
      );

  static String attachmentModeToStorage(AttachmentImportMode value) =>
      switch (value) {
        AttachmentImportMode.referenceOriginal => 'reference_original',
        AttachmentImportMode.optimizedCopy => 'optimized_copy',
        AttachmentImportMode.preserveOriginal => 'preserve_original',
      };

  static AttachmentImportMode attachmentModeFromStorage(String value) =>
      switch (value) {
        'reference_original' => AttachmentImportMode.referenceOriginal,
        'optimized_copy' => AttachmentImportMode.optimizedCopy,
        'preserve_original' => AttachmentImportMode.preserveOriginal,
        _ => throw FormatException('Unknown attachment import mode: $value'),
      };

  static String attachmentRoleToStorage(AttachmentRole value) =>
      switch (value) {
        AttachmentRole.heroMedia => 'hero_media',
        AttachmentRole.memoryMedia => 'memory_media',
        AttachmentRole.evidence => 'evidence',
      };

  static AttachmentRole attachmentRoleFromStorage(String value) =>
      switch (value) {
        'hero_media' => AttachmentRole.heroMedia,
        'memory_media' => AttachmentRole.memoryMedia,
        'evidence' => AttachmentRole.evidence,
        _ => throw FormatException('Unknown attachment role: $value'),
      };

  static String sourceTypeToStorage(ProvenanceSourceType value) =>
      switch (value) {
        ProvenanceSourceType.user => 'user',
        ProvenanceSourceType.attachment => 'attachment',
        ProvenanceSourceType.import => 'import',
        ProvenanceSourceType.system => 'system',
        ProvenanceSourceType.rule => 'rule',
        ProvenanceSourceType.localModel => 'local_model',
      };

  static ProvenanceSourceType sourceTypeFromStorage(String value) =>
      switch (value) {
        'user' => ProvenanceSourceType.user,
        'attachment' => ProvenanceSourceType.attachment,
        'import' => ProvenanceSourceType.import,
        'system' => ProvenanceSourceType.system,
        'rule' => ProvenanceSourceType.rule,
        'local_model' => ProvenanceSourceType.localModel,
        _ => throw FormatException('Unknown provenance source type: $value'),
      };

  static String extractionMethodToStorage(ExtractionMethod value) =>
      switch (value) {
        ExtractionMethod.manual => 'manual',
        ExtractionMethod.imported => 'imported',
        ExtractionMethod.metadata => 'metadata',
        ExtractionMethod.deterministic => 'deterministic',
        ExtractionMethod.ocr => 'ocr',
        ExtractionMethod.onDeviceModel => 'on_device_model',
        ExtractionMethod.unknown => 'unknown',
      };

  static ExtractionMethod extractionMethodFromStorage(String value) =>
      switch (value) {
        'manual' => ExtractionMethod.manual,
        'imported' => ExtractionMethod.imported,
        'metadata' => ExtractionMethod.metadata,
        'deterministic' => ExtractionMethod.deterministic,
        'ocr' => ExtractionMethod.ocr,
        'on_device_model' => ExtractionMethod.onDeviceModel,
        'unknown' => ExtractionMethod.unknown,
        _ => throw FormatException('Unknown extraction method: $value'),
      };

  static String normalizeName(String value) => value.trim().toLowerCase();

  static RecordMetadata metadataFromStorage({
    required String id,
    required String privacyClassification,
    required String lifecycle,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) => RecordMetadata(
    id: id,
    privacyClassification: privacyFromStorage(privacyClassification),
    lifecycle: lifecycleFromStorage(lifecycle),
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
  );

  static TemporalColumnsData temporalToStorage(TemporalValue value) =>
      TemporalColumnsData(
        precision: _temporalPrecisionToStorage(value.precision),
        startYear: value.start?.year,
        startMonth: value.start?.month,
        startDay: value.start?.day,
        endYear: value.end?.year,
        endMonth: value.end?.month,
        endDay: value.end?.day,
      );

  static TemporalValue temporalFromStorage({
    required String precision,
    required int? startYear,
    required int? startMonth,
    required int? startDay,
    required int? endYear,
    required int? endMonth,
    required int? endDay,
  }) {
    TemporalPoint point(int year, int? month, int? day) =>
        TemporalPoint(year: year, month: month, day: day);

    return switch (precision) {
      'exact_date' => TemporalValue.exactDate(
        year: startYear!,
        month: startMonth!,
        day: startDay!,
      ),
      'month' => TemporalValue.month(year: startYear!, month: startMonth!),
      'year' => TemporalValue.year(startYear!),
      'approximate' => TemporalValue.approximate(
        point(startYear!, startMonth, startDay),
      ),
      'range' => TemporalValue.range(
        start: point(startYear!, startMonth, startDay),
        end: point(endYear!, endMonth, endDay),
      ),
      'before' => TemporalValue.before(point(startYear!, startMonth, startDay)),
      'after' => TemporalValue.after(point(startYear!, startMonth, startDay)),
      'unknown' => TemporalValue.unknown(),
      _ => throw FormatException('Unknown temporal precision: $precision'),
    };
  }

  static String _temporalPrecisionToStorage(TemporalPrecision value) =>
      switch (value) {
        TemporalPrecision.exactDate => 'exact_date',
        TemporalPrecision.month => 'month',
        TemporalPrecision.year => 'year',
        TemporalPrecision.approximate => 'approximate',
        TemporalPrecision.range => 'range',
        TemporalPrecision.before => 'before',
        TemporalPrecision.after => 'after',
        TemporalPrecision.unknown => 'unknown',
      };
}

final class TemporalColumnsData {
  const TemporalColumnsData({
    required this.precision,
    required this.startYear,
    required this.startMonth,
    required this.startDay,
    required this.endYear,
    required this.endMonth,
    required this.endDay,
  });

  final String precision;
  final int? startYear;
  final int? startMonth;
  final int? startDay;
  final int? endYear;
  final int? endMonth;
  final int? endDay;
}
