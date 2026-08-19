import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_timeline/features/media/application/import_memory_media.dart';
import 'package:life_timeline/features/media/domain/memory_media_import.dart';
import 'package:life_timeline/features/media/domain/memory_media_paths.dart';
import 'package:life_timeline/features/media/domain/memory_media_repository.dart';
import 'package:life_timeline/features/media/infrastructure/drift_memory_media_repository.dart';
import 'package:life_timeline/features/media/infrastructure/local_memory_media_path_resolver.dart';
import 'package:life_timeline/features/media/infrastructure/local_memory_media_services.dart';
import 'package:life_timeline/features/timeline/application/timeline_providers.dart';
import 'package:life_timeline/shared/database/app_database_provider.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

final memoryMediaRepositoryProvider = Provider<MemoryMediaRepository>((ref) {
  return DriftMemoryMediaRepository(ref.watch(appDatabaseProvider));
});

final memoryMediaPickerProvider = Provider<MemoryMediaPicker>((ref) {
  return ImagePickerMemoryMediaPicker();
});

final memoryImageProcessorProvider = Provider<MemoryImageProcessor>((ref) {
  return const LocalMemoryImageProcessor();
});

final memoryMediaPathResolverProvider = Provider<MemoryMediaPathResolver>((
  ref,
) {
  return const LocalMemoryMediaPathResolver();
});

final importMemoryMediaProvider = Provider<ImportMemoryMedia>((ref) {
  return ImportMemoryMedia(
    ref.watch(memoryMediaPickerProvider),
    ref.watch(memoryImageProcessorProvider),
    ref.watch(memoryMediaRepositoryProvider),
    ref.watch(recordIdGeneratorProvider),
  );
});

final memoryMediaProvider = StreamProvider.autoDispose
    .family<List<MemoryMedia>, String>((ref, eventId) {
      return ref.watch(memoryMediaRepositoryProvider).watchForEvent(eventId);
    });

final memoryMediaPreviewProvider = StreamProvider.autoDispose
    .family<List<MemoryMedia>, String>((ref, eventId) {
      return ref
          .watch(memoryMediaRepositoryProvider)
          .watchGalleryPreview(eventId, limit: 4);
    });

final memoryHeroMediaProvider = StreamProvider.autoDispose
    .family<MemoryMedia?, String>((ref, eventId) {
      return ref
          .watch(memoryMediaRepositoryProvider)
          .watchHeroForEvent(eventId);
    });

final memoryMediaCountProvider = StreamProvider.autoDispose.family<int, String>(
  (ref, eventId) {
    return ref.watch(memoryMediaRepositoryProvider).watchMediaCount(eventId);
  },
);
