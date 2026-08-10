import 'dart:async';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/app/providers/restored_data_refresh.dart';
import 'package:life_timeline/features/timeline/application/timeline_providers.dart';
import 'package:life_timeline/shared/database/app_database.dart' hide Event;
import 'package:life_timeline/shared/database/app_database_provider.dart';
import 'package:life_timeline/shared/database/backup/drift_backup_data_source.dart';
import 'package:life_timeline/shared/database/repositories/drift_timeline_repository.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';
import 'package:life_timeline/shared/domain/model/temporal_value.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);
  tearDownAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = false);

  test('restored read models reload the committed database snapshot', () async {
    final source = AppDatabase.forTesting(NativeDatabase.memory());
    final target = AppDatabase.forTesting(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(target)],
    );
    addTearDown(() async {
      container.dispose();
      await source.close();
      await target.close();
    });

    await _saveEvent(target, id: 'old', title: 'Old local timeline');
    await _saveEvent(source, id: 'restored', title: 'Restored timeline');

    final initialEmission = Completer<List<TimelineMemory>>();
    final restoredEmission = Completer<List<TimelineMemory>>();
    final subscription = container.listen(timelineMemoriesProvider, (_, next) {
      next.whenData((memories) {
        if (!initialEmission.isCompleted) {
          initialEmission.complete(memories);
        }
        if (!restoredEmission.isCompleted &&
            memories.any((memory) => memory.event.metadata.id == 'restored')) {
          restoredEmission.complete(memories);
        }
      });
    }, fireImmediately: true);
    addTearDown(subscription.close);

    final before = await initialEmission.future;
    expect(before.single.event.title, 'Old local timeline');

    final snapshot = await DriftBackupDataSource(source).exportSnapshot();
    await DriftBackupDataSource(target).replaceWithSnapshot(snapshot);

    container.read(restoredDataRefreshCoordinatorProvider).refresh();
    final after = await restoredEmission.future.timeout(
      const Duration(seconds: 2),
    );

    expect(after.single.event.metadata.id, 'restored');
    expect(after.single.event.title, 'Restored timeline');
  });
}

Future<void> _saveEvent(
  AppDatabase database, {
  required String id,
  required String title,
}) {
  final at = DateTime.utc(2026, 8, 10);
  return DriftTimelineRepository(database).saveEvent(
    Event(
      metadata: RecordMetadata(
        id: id,
        privacyClassification: PrivacyClassification.personal,
        lifecycle: RecordLifecycle.confirmed,
        createdAt: at,
        updatedAt: at,
      ),
      title: title,
      temporalValue: TemporalValue.year(2026),
      eventType: 'Test',
    ),
  );
}
