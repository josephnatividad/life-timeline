import 'package:life_timeline/shared/domain/model/timeline_models.dart';

abstract interface class MemoryMediaPathResolver {
  Future<String?> resolve(
    Attachment attachment, {
    required bool preferThumbnail,
  });
}
