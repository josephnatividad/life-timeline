import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_timeline/features/reminders/application/reminder_providers.dart';
import 'package:life_timeline/features/timeline/application/memory_use_cases.dart';
import 'package:life_timeline/features/timeline/domain/temporal_display.dart';
import 'package:life_timeline/features/timeline/infrastructure/path_provider_attachment_cleanup.dart';
import 'package:life_timeline/shared/database/app_database_provider.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';
import 'package:life_timeline/shared/domain/repositories/timeline_repository.dart';

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
    onReminderLifecycleChanged: ref.watch(reminderSchedulerProvider).reconcile,
  );
});

final timelineMemoriesProvider = StreamProvider<List<TimelineMemory>>((ref) {
  return ref
      .watch(timelineRepositoryProvider)
      .watchMemories()
      .map(TemporalDisplay.sortNewestFirst);
});

final timelineMemoryPreviewProvider = StreamProvider.autoDispose
    .family<List<TimelineMemory>, int>((ref, limit) {
      return ref
          .watch(timelineRepositoryProvider)
          .watchMemoryPreview(limit: limit)
          .map(TemporalDisplay.sortNewestFirst);
    });

final timelineMemoryCountProvider = StreamProvider.autoDispose<int>((ref) {
  return ref.watch(timelineRepositoryProvider).watchMemoryCount();
});

final timelineRevisionProvider = StreamProvider<String>((ref) {
  return ref.watch(timelineRepositoryProvider).watchTimelineRevision();
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

final memoryEvidenceProvider =
    FutureProvider.family<MemoryEvidenceCollection, String>((ref, eventId) {
      return ref.watch(timelineRepositoryProvider).evidenceForMemory(eventId);
    });

final memoryEvidencePreviewProvider =
    FutureProvider.family<MemoryEvidenceCollection, String>((ref, eventId) {
      return ref
          .watch(timelineRepositoryProvider)
          .evidenceForMemory(eventId, limit: 3);
    });
