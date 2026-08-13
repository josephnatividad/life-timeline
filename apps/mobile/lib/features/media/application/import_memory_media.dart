import 'package:life_timeline/features/media/domain/memory_media_import.dart';
import 'package:life_timeline/features/media/domain/memory_media_repository.dart';
import 'package:life_timeline/features/timeline/application/memory_use_cases.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

final class ImportMemoryMedia {
  const ImportMemoryMedia(
    this._picker,
    this._processor,
    this._repository,
    this._idGenerator,
  );

  final RecordIdGenerator _idGenerator;
  final MemoryMediaPicker _picker;
  final MemoryImageProcessor _processor;
  final MemoryMediaRepository _repository;

  Future<List<MemoryMedia>> call({
    required String eventId,
    required MemoryMediaSource source,
    bool preserveOriginal = true,
  }) async {
    final selected = await _picker.pick(source);
    if (selected.isEmpty) return const [];
    final current = await _repository.forEvent(eventId);
    final added = <MemoryMedia>[];
    var nextOrder = current.length;
    var hasHero = current.any((media) => media.isHero);
    for (final image in selected) {
      final attachmentId = _idGenerator.next('attachment');
      final processed = await _processor.process(
        selected: image,
        attachmentId: attachmentId,
        preserveOriginal: preserveOriginal,
      );
      final now = DateTime.now().toUtc();
      final link = AttachmentLink(
        id: _idGenerator.next('media-link'),
        attachmentId: attachmentId,
        eventId: eventId,
        role: hasHero ? AttachmentRole.memoryMedia : AttachmentRole.heroMedia,
        sortOrder: nextOrder++,
        capturedAt: image.capturedAt,
        importedAt: now,
      );
      try {
        await _repository.add(attachment: processed.attachment, link: link);
      } on Object {
        await _processor.deleteManagedFiles(processed.managedRelativePaths);
        rethrow;
      }
      hasHero = true;
      added.add(MemoryMedia(attachment: processed.attachment, link: link));
    }
    return List.unmodifiable(added);
  }
}
