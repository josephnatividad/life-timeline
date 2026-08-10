import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/timeline/application/memory_use_cases.dart';
import 'package:life_timeline/features/timeline/application/timeline_providers.dart';
import 'package:life_timeline/features/timeline/presentation/archive_page.dart';
import 'package:life_timeline/features/timeline/presentation/trash_page.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';
import 'package:life_timeline/shared/domain/model/temporal_value.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';
import 'package:life_timeline/shared/domain/repositories/timeline_repository.dart';

void main() {
  testWidgets(
    'Archive allows a memory to be restored',
    (tester) async {
      final repository = _RecordingTimelineRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            archivedMemoriesProvider.overrideWith(
              (ref) => Stream.value([_memory()]),
            ),
            setMemoryArchiveStateUseCaseProvider.overrideWithValue(
              SetMemoryArchiveStateUseCase(repository),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const ArchivePage(),
          ),
        ),
      );
      await _pumpUi(tester);

      expect(find.text('Archived memory'), findsOneWidget);
      await tester.tap(find.byTooltip('Restore Archived memory'));
      await _pumpUi(tester);

      expect(repository.restoredId, 'memory-lifecycle');
    },
    timeout: const Timeout(Duration(seconds: 10)),
  );

  testWidgets(
    'permanent delete is explicitly confirmed in Trash',
    (tester) async {
      final repository = _RecordingTimelineRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            trashedMemoriesProvider.overrideWith(
              (ref) => Stream.value([_memory().copyWithSoftDeletedForTest()]),
            ),
            deleteMemoryUseCaseProvider.overrideWithValue(
              DeleteMemoryUseCase(repository, const _NoOpAttachmentCleanup()),
            ),
          ],
          child: MaterialApp(theme: AppTheme.dark(), home: const TrashPage()),
        ),
      );
      await _pumpUi(tester);

      await tester.tap(find.byTooltip('Permanently delete Archived memory'));
      await _pumpUi(tester);
      expect(find.text('Permanently delete this memory?'), findsOneWidget);
      expect(find.textContaining('This cannot be undone'), findsOneWidget);

      await tester.tap(find.byKey(const Key('confirm-permanent-delete')));
      await _pumpUi(tester);

      expect(repository.permanentlyDeletedId, 'memory-lifecycle');
    },
    timeout: const Timeout(Duration(seconds: 10)),
  );
}

extension on TimelineMemory {
  TimelineMemory copyWithSoftDeletedForTest() => TimelineMemory(
    event: Event(
      metadata: event.metadata.copyWith(
        lifecycle: RecordLifecycle.softDeleted,
        updatedAt: DateTime.utc(2026, 8, 10),
        deletedAt: DateTime.utc(2026, 8, 10),
      ),
      title: event.title,
      temporalValue: event.temporalValue,
      description: event.description,
      eventType: event.eventType,
    ),
  );
}

Future<void> _pumpUi(WidgetTester tester) async {
  for (var frame = 0; frame < 6; frame++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

TimelineMemory _memory() {
  final at = DateTime.utc(2026, 8, 9);
  return TimelineMemory(
    event: Event(
      metadata: RecordMetadata(
        id: 'memory-lifecycle',
        privacyClassification: PrivacyClassification.personal,
        lifecycle: RecordLifecycle.confirmed,
        createdAt: at,
        updatedAt: at,
      ),
      title: 'Archived memory',
      temporalValue: TemporalValue.year(2024),
      eventType: 'Milestone',
    ),
  );
}

final class _NoOpAttachmentCleanup implements ManagedAttachmentCleanup {
  const _NoOpAttachmentCleanup();

  @override
  Future<void> deleteManagedFiles(Iterable<String> relativePaths) async {}
}

final class _RecordingTimelineRepository implements TimelineRepository {
  String? permanentlyDeletedId;
  String? restoredId;

  @override
  Future<PermanentMemoryDeletion> permanentlyDeleteEvent(String id) async {
    permanentlyDeletedId = id;
    return const PermanentMemoryDeletion();
  }

  @override
  Future<void> restoreEvent(String id, DateTime restoredAt) async {
    restoredId = id;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
