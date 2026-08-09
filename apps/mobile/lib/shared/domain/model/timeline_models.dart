import 'package:life_timeline/shared/domain/model/record_metadata.dart';
import 'package:life_timeline/shared/domain/model/temporal_value.dart';

enum TimelineRecordType { entity, event, evidence }

final class TimelineRecordReference {
  TimelineRecordReference({required this.type, required this.id}) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Must not be empty.');
    }
  }

  final String id;
  final TimelineRecordType type;
}

final class Entity {
  Entity({
    required this.metadata,
    required this.name,
    required this.entityType,
    this.notes,
  }) {
    if (name.trim().isEmpty || entityType.trim().isEmpty) {
      throw ArgumentError('Entity name and type must not be empty.');
    }
  }

  final String entityType;
  final RecordMetadata metadata;
  final String name;
  final String? notes;
}

final class Event {
  Event({
    required this.metadata,
    required this.title,
    required this.temporalValue,
    this.description,
    this.eventType,
  }) {
    if (title.trim().isEmpty) {
      throw ArgumentError.value(title, 'title', 'Must not be empty.');
    }
  }

  final String? description;
  final String? eventType;
  final RecordMetadata metadata;
  final TemporalValue temporalValue;
  final String title;
}

enum EvidenceType {
  photo,
  document,
  receipt,
  certificate,
  ticket,
  screenshot,
  metadata,
  other,
}

final class Evidence {
  Evidence({
    required this.metadata,
    required this.evidenceType,
    required this.title,
    this.summary,
  }) {
    if (title.trim().isEmpty) {
      throw ArgumentError.value(title, 'title', 'Must not be empty.');
    }
  }

  final EvidenceType evidenceType;
  final RecordMetadata metadata;
  final String? summary;
  final String title;
}

final class Relationship {
  Relationship({
    required this.metadata,
    required this.source,
    required this.target,
    required this.relationshipType,
    this.notes,
  }) {
    if (relationshipType.trim().isEmpty) {
      throw ArgumentError.value(
        relationshipType,
        'relationshipType',
        'Must not be empty.',
      );
    }
    if (source.type == target.type && source.id == target.id) {
      throw ArgumentError('A relationship cannot target itself.');
    }
  }

  final RecordMetadata metadata;
  final String? notes;
  final String relationshipType;
  final TimelineRecordReference source;
  final TimelineRecordReference target;
}

enum AttachmentStorageState { local, referenced, archived, unavailable }

enum AttachmentImportMode { referenceOriginal, optimizedCopy, preserveOriginal }

final class Attachment {
  Attachment({
    required this.metadata,
    required this.evidenceId,
    required this.storageState,
    required this.importMode,
    required this.mimeType,
    required this.byteSize,
    this.checksum,
    this.displayName,
    this.relativePath,
    this.thumbnailRelativePath,
  }) {
    if (evidenceId.trim().isEmpty || mimeType.trim().isEmpty) {
      throw ArgumentError('Evidence ID and MIME type must not be empty.');
    }
    if (byteSize < 0) {
      throw ArgumentError.value(byteSize, 'byteSize', 'Must not be negative.');
    }
  }

  final int byteSize;
  final String? checksum;
  final String? displayName;
  final String evidenceId;
  final AttachmentImportMode importMode;
  final RecordMetadata metadata;
  final String mimeType;
  final String? relativePath;
  final AttachmentStorageState storageState;
  final String? thumbnailRelativePath;
}

final class Tag {
  Tag({required this.metadata, required this.name}) {
    if (name.trim().isEmpty) {
      throw ArgumentError.value(name, 'name', 'Must not be empty.');
    }
  }

  final RecordMetadata metadata;
  final String name;
}

final class Category {
  Category({required this.metadata, required this.name, this.parentId}) {
    if (name.trim().isEmpty || parentId == metadata.id) {
      throw ArgumentError(
        'Category name must be set and cannot parent itself.',
      );
    }
  }

  final RecordMetadata metadata;
  final String name;
  final String? parentId;
}
