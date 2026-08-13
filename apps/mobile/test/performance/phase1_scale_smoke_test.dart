import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/features/insights/domain/life_query_models.dart';
import 'package:life_timeline/features/insights/infrastructure/drift_life_query_executor.dart';
import 'package:life_timeline/shared/database/app_database.dart';
import 'package:life_timeline/shared/database/repositories/drift_timeline_repository.dart';
import 'package:life_timeline/shared/database/schema_migrations.dart';

void main() {
  test(
    '100, 1,000, and 10,000-memory local query smoke test',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final timeline = DriftTimelineRepository(database);
      final lifeQueries = DriftLifeQueryExecutor(database);
      var seeded = 0;

      for (final target in [100, 1000, 10000]) {
        final at = DateTime.utc(2026, 8, 14);
        await database.batch((batch) {
          batch.insertAll(database.events, [
            for (var index = seeded; index < target; index++)
              EventsCompanion.insert(
                id: 'scale-event-$index',
                privacyClassification: 'personal',
                lifecycle: 'confirmed',
                createdAt: at,
                updatedAt: at,
                temporalPrecision: 'year',
                startYear: Value(1900 + (index % 126)),
                title: index == target - 1
                    ? 'Unique scale needle $target'
                    : 'Scale memory $index',
                normalizedTitle: index == target - 1
                    ? 'unique scale needle $target'
                    : 'scale memory $index',
                eventType: const Value('milestone'),
              ),
          ]);
        });
        seeded = target;
        await rebuildEventSearchIndex(database);

        final timelineWatch = Stopwatch()..start();
        final memories = await timeline.watchMemories().first;
        timelineWatch.stop();
        expect(memories, hasLength(target));
        expect(timelineWatch.elapsed, lessThan(const Duration(seconds: 30)));

        final searchWatch = Stopwatch()..start();
        final search = await timeline.searchMemories('needle $target');
        searchWatch.stop();
        expect(
          search.single.memory.event.metadata.id,
          'scale-event-${target - 1}',
        );
        expect(searchWatch.elapsed, lessThan(const Duration(seconds: 5)));

        final askWatch = Stopwatch()..start();
        final answer = await lifeQueries.execute(
          const CountConfirmedMemories(),
          now: at,
        );
        askWatch.stop();
        expect(answer.numericValue, target);
        expect(askWatch.elapsed, lessThan(const Duration(seconds: 30)));
      }
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
