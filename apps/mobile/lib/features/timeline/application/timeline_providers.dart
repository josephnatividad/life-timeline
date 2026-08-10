import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_timeline/features/timeline/application/memory_use_cases.dart';
import 'package:life_timeline/features/timeline/domain/temporal_display.dart';
import 'package:life_timeline/features/timeline/infrastructure/path_provider_attachment_cleanup.dart';
import 'package:life_timeline/shared/database/app_database_provider.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

final recordIdGeneratorProvider = Provider<RecordIdGenerator>((ref) {
  return LocalRecordIdGenerator();
});

final saveMemoryUseCaseProvider = Provider<SaveMemoryUseCase>((ref) {
  return SaveMemoryUseCase(
    ref.watch(timelineRepositoryProvider),
    ref.watch(recordIdGeneratorProvider),
  );
});

final setMemoryArchiveStateUseCaseProvider =
    Provider<SetMemoryArchiveStateUseCase>((ref) {
      return SetMemoryArchiveStateUseCase(
        ref.watch(timelineRepositoryProvider),
      );
    });

final managedAttachmentCleanupProvider = Provider<ManagedAttachmentCleanup>((
  ref,
) {
  return const PathProviderAttachmentCleanup();
});

final deleteMemoryUseCaseProvider = Provider<DeleteMemoryUseCase>((ref) {
  return DeleteMemoryUseCase(
    ref.watch(timelineRepositoryProvider),
    ref.watch(managedAttachmentCleanupProvider),
  );
});

final timelineMemoriesProvider = StreamProvider<List<TimelineMemory>>((ref) {
  return ref
      .watch(timelineRepositoryProvider)
      .watchMemories()
      .map(TemporalDisplay.sortNewestFirst);
});

final archivedMemoriesProvider = StreamProvider<List<TimelineMemory>>((ref) {
  return ref
      .watch(timelineRepositoryProvider)
      .watchMemories(archived: true)
      .map(TemporalDisplay.sortNewestFirst);
});

final trashedMemoriesProvider = StreamProvider<List<TimelineMemory>>((ref) {
  return ref
      .watch(timelineRepositoryProvider)
      .watchTrashedMemories()
      .map(TemporalDisplay.sortNewestFirst);
});

final memoryDetailProvider = FutureProvider.family<TimelineMemory?, String>((
  ref,
  id,
) {
  return ref.watch(timelineRepositoryProvider).memoryById(id);
});

final memorySearchProvider =
    FutureProvider.family<List<MemorySearchResult>, String>((ref, query) {
      return ref.watch(timelineRepositoryProvider).searchMemories(query);
    });
