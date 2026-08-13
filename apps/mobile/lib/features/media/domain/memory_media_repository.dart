import 'package:life_timeline/shared/domain/model/timeline_models.dart';

abstract interface class MemoryMediaRepository {
  Stream<List<MemoryMedia>> watchForEvent(String eventId);
  Future<List<MemoryMedia>> forEvent(String eventId);
  Future<MemoryMedia?> byLinkId(String linkId);

  Future<void> add({
    required Attachment attachment,
    required AttachmentLink link,
  });

  Future<void> updateCaption({
    required String linkId,
    required String? caption,
  });

  Future<void> reorder({
    required String eventId,
    required List<String> orderedLinkIds,
  });

  Future<void> setHero({required String eventId, required String linkId});
  Future<void> clearHero({required String eventId, required String linkId});

  /// Removes only the contextual event link. The physical asset remains.
  Future<void> removeFromMemory({
    required String eventId,
    required String linkId,
  });

  /// Removes the contextual link and deletes the asset row only when no other
  /// event, evidence, archive, or provenance reference still needs it.
  Future<UnreferencedMediaDeletion> deleteUnreferenced({
    required String eventId,
    required String linkId,
  });

  Future<void> completeManagedDeletion(String attachmentId);
}

final class UnreferencedMediaDeletion {
  const UnreferencedMediaDeletion({
    required this.assetDeleted,
    this.attachmentId,
    this.managedRelativePaths = const [],
  });

  final bool assetDeleted;
  final String? attachmentId;
  final List<String> managedRelativePaths;
}
