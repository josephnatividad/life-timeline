import 'package:life_timeline/shared/domain/model/record_metadata.dart';
import 'package:life_timeline/shared/domain/model/temporal_value.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

final class MemoryEditorDraft {
  const MemoryEditorDraft({
    required this.title,
    required this.eventType,
    required this.temporalValue,
    required this.privacyClassification,
    this.lifecycle = RecordLifecycle.confirmed,
    this.categoryName,
    this.description,
    this.eventId,
    this.createdAt,
    this.relatedEntityId,
    this.relatedEntityName,
    this.relationshipId,
    this.categoryId,
  });

  factory MemoryEditorDraft.fromMemory(TimelineMemory memory) =>
      MemoryEditorDraft(
        eventId: memory.event.metadata.id,
        createdAt: memory.event.metadata.createdAt,
        title: memory.event.title,
        eventType: memory.event.eventType ?? '',
        categoryName: memory.category?.name,
        categoryId: memory.category?.metadata.id,
        temporalValue: memory.event.temporalValue,
        description: memory.event.description,
        relatedEntityId: memory.relatedEntity?.metadata.id,
        relatedEntityName: memory.relatedEntity?.name,
        relationshipId: memory.relatedEntityRelationship?.metadata.id,
        privacyClassification: memory.event.metadata.privacyClassification,
        lifecycle: memory.event.metadata.lifecycle,
      );

  final String? categoryId;
  final String? categoryName;
  final DateTime? createdAt;
  final String? description;
  final String? eventId;
  final String eventType;
  final RecordLifecycle lifecycle;
  final PrivacyClassification privacyClassification;
  final String? relatedEntityId;
  final String? relatedEntityName;
  final String? relationshipId;
  final TemporalValue temporalValue;
  final String title;

  bool get isEditing => eventId != null;
}
