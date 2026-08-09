enum PrivacyClassification { shareSafe, personal, sensitive, neverShare }

enum RecordLifecycle { candidate, confirmed, archived, softDeleted }

final class RecordMetadata {
  RecordMetadata({
    required this.id,
    required this.privacyClassification,
    required this.lifecycle,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) : createdAt = createdAt.toUtc(),
       updatedAt = updatedAt.toUtc(),
       deletedAt = deletedAt?.toUtc() {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Must not be empty.');
    }
    if (this.updatedAt.isBefore(this.createdAt)) {
      throw ArgumentError('updatedAt must not be before createdAt.');
    }
    if ((lifecycle == RecordLifecycle.softDeleted) !=
        (this.deletedAt != null)) {
      throw ArgumentError(
        'softDeleted lifecycle and deletedAt must be set together.',
      );
    }
  }

  final DateTime createdAt;
  final DateTime? deletedAt;
  final String id;
  final RecordLifecycle lifecycle;
  final PrivacyClassification privacyClassification;
  final DateTime updatedAt;

  bool get isDeleted => lifecycle == RecordLifecycle.softDeleted;

  RecordMetadata copyWith({
    PrivacyClassification? privacyClassification,
    RecordLifecycle? lifecycle,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) => RecordMetadata(
    id: id,
    privacyClassification: privacyClassification ?? this.privacyClassification,
    lifecycle: lifecycle ?? this.lifecycle,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
  );
}
