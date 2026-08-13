import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_timeline/features/reminders/application/reminder_providers.dart';
import 'package:life_timeline/features/timeline/application/memory_use_cases.dart';
import 'package:life_timeline/features/timeline/domain/temporal_display.dart';
import 'package:life_timeline/features/timeline/infrastructure/path_provider_attachment_cleanup.dart';
import 'package:life_timeline/shared/database/app_database_provider.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';
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
    onReminderLifecycleChanged: ref.watch(reminderSchedulerProvider).reconcile,
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

final memoryEvidenceProvider =
    FutureProvider.family<List<MemoryEvidenceItem>, String>((
      ref,
      eventId,
    ) async {
      final repository = ref.watch(timelineRepositoryProvider);
      final relationships = await repository.relationshipsFor(
        TimelineRecordReference(type: TimelineRecordType.event, id: eventId),
      );
      final evidenceIds = <String>{};
      for (final relationship in relationships) {
        if (relationship.metadata.lifecycle == RecordLifecycle.softDeleted) {
          continue;
        }
        if (relationship.source.type == TimelineRecordType.evidence) {
          evidenceIds.add(relationship.source.id);
        }
        if (relationship.target.type == TimelineRecordType.evidence) {
          evidenceIds.add(relationship.target.id);
        }
      }
      final items = <MemoryEvidenceItem>[];
      for (final id in evidenceIds) {
        final evidence = await repository.evidenceById(id);
        if (evidence == null) continue;
        items.add(
          MemoryEvidenceItem(
            evidence: evidence,
            attachmentCount: (await repository.attachmentsForEvidence(
              id,
            )).length,
          ),
        );
      }
      return List.unmodifiable(items);
    });

final class MemoryEvidenceItem {
  const MemoryEvidenceItem({
    required this.evidence,
    required this.attachmentCount,
  });

  final int attachmentCount;
  final Evidence evidence;
}
