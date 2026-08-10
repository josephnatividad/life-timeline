import 'dart:math';

import 'package:life_timeline/features/timeline/application/memory_editor_draft.dart';
import 'package:life_timeline/shared/domain/model/field_provenance.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';
import 'package:life_timeline/shared/domain/repositories/timeline_repository.dart';

final class MemoryValidationException implements Exception {
  const MemoryValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract interface class RecordIdGenerator {
  String next(String prefix);
}

final class LocalRecordIdGenerator implements RecordIdGenerator {
  LocalRecordIdGenerator({Random? random})
    : _random = random ?? Random.secure();

  final Random _random;

  @override
  String next(String prefix) {
    final timestamp = DateTime.now().toUtc().microsecondsSinceEpoch;
    final entropy = _random.nextInt(0x7fffffff).toRadixString(36);
    return '$prefix-$timestamp-$entropy';
  }
}

final class SaveMemoryUseCase {
  const SaveMemoryUseCase(
    this._repository,
    this._idGenerator, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final RecordIdGenerator _idGenerator;
  final DateTime Function() _now;
  final TimelineRepository _repository;

  Future<String> call(MemoryEditorDraft draft) async {
    final title = draft.title.trim();
    final eventType = draft.eventType.trim();
    final categoryName = draft.categoryName?.trim();
    final relatedEntityName = draft.relatedEntityName?.trim();
    if (title.isEmpty) {
      throw const MemoryValidationException('Add a title for this memory.');
    }
    if (eventType.isEmpty) {
      throw const MemoryValidationException('Choose or enter a memory type.');
    }
    if (categoryName == null || categoryName.isEmpty) {
      throw const MemoryValidationException('Choose or enter a category.');
    }

    final now = _now().toUtc();
    final eventId = draft.eventId ?? _idGenerator.next('event');
    final createdAt = draft.createdAt?.toUtc() ?? now;
    final metadata = RecordMetadata(
      id: eventId,
      privacyClassification: draft.privacyClassification,
      lifecycle: draft.lifecycle,
      createdAt: createdAt,
      updatedAt: now.isBefore(createdAt) ? createdAt : now,
    );
    final event = Event(
      metadata: metadata,
      title: title,
      temporalValue: draft.temporalValue,
      description: _nullIfEmpty(draft.description),
      eventType: eventType,
    );

    Entity? entity;
    Relationship? relationship;
    if (relatedEntityName != null && relatedEntityName.isNotEmpty) {
      final entityId = draft.relatedEntityId ?? _idGenerator.next('entity');
      entity = Entity(
        metadata: RecordMetadata(
          id: entityId,
          privacyClassification: draft.privacyClassification,
          lifecycle: RecordLifecycle.confirmed,
          createdAt: createdAt,
          updatedAt: metadata.updatedAt,
        ),
        name: relatedEntityName,
        entityType: 'related',
      );
      relationship = Relationship(
        metadata: RecordMetadata(
          id: draft.relationshipId ?? _idGenerator.next('relationship'),
          privacyClassification: draft.privacyClassification,
          lifecycle: RecordLifecycle.confirmed,
          createdAt: createdAt,
          updatedAt: metadata.updatedAt,
        ),
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
    }

    final category = Category(
      metadata: RecordMetadata(
        id: draft.categoryId ?? _idGenerator.next('category'),
        privacyClassification: draft.privacyClassification,
        lifecycle: RecordLifecycle.confirmed,
        createdAt: createdAt,
        updatedAt: metadata.updatedAt,
      ),
      name: categoryName,
    );
    final provenance = _manualProvenance(event, now: metadata.updatedAt);

    await _repository.saveMemory(
      TimelineMemory(
        event: event,
        category: category,
        relatedEntity: entity,
        relatedEntityRelationship: relationship,
      ),
      provenance: provenance,
    );
    return eventId;
  }

  List<FieldProvenance> _manualProvenance(
    Event event, {
    required DateTime now,
  }) {
    final fields = <String>[
      'title',
      'temporal_value',
      'event_type',
      'privacy_classification',
      if (event.description != null) 'description',
    ];
    return [
      for (final field in fields)
        FieldProvenance(
          id: 'manual-${event.metadata.id}-$field',
          target: ProvenanceTarget(
            type: ProvenanceTargetType.event,
            id: event.metadata.id,
          ),
          fieldName: field,
          sourceId: 'manual-${event.metadata.id}',
          sourceType: ProvenanceSourceType.user,
          extractionMethod: ExtractionMethod.manual,
          confidence: 1,
          userConfirmed: true,
          privacyClassification: event.metadata.privacyClassification,
          createdAt: event.metadata.createdAt,
          updatedAt: now,
        ),
    ];
  }

  String? _nullIfEmpty(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}

final class SetMemoryArchiveStateUseCase {
  const SetMemoryArchiveStateUseCase(
    this._repository, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final DateTime Function() _now;
  final TimelineRepository _repository;

  Future<void> archive(String id) =>
      _repository.archiveEvent(id, _now().toUtc());

  Future<void> restore(String id) =>
      _repository.restoreEvent(id, _now().toUtc());
}

abstract interface class ManagedAttachmentCleanup {
  Future<void> deleteManagedFiles(Iterable<String> relativePaths);
}

final class DeleteMemoryUseCase {
  const DeleteMemoryUseCase(
    this._repository,
    this._attachmentCleanup, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final ManagedAttachmentCleanup _attachmentCleanup;
  final DateTime Function() _now;
  final TimelineRepository _repository;

  Future<void> moveToTrash(String id) =>
      _repository.softDeleteEvent(id, _now().toUtc());

  Future<void> restoreFromTrash(String id) =>
      _repository.restoreSoftDeletedEvent(id, _now().toUtc());

  /// Returns whether every app-managed attachment copy was removed.
  ///
  /// The database deletion remains authoritative. Cleanup is deliberately
  /// best-effort because a filesystem failure must not make the UI claim that
  /// a database transaction was rolled back after it already committed.
  Future<bool> permanentlyDelete(String id) async {
    final deletion = await _repository.permanentlyDeleteEvent(id);
    try {
      await _attachmentCleanup.deleteManagedFiles(
        deletion.managedRelativePaths,
      );
      return true;
    } on Object {
      return false;
    }
  }
}
