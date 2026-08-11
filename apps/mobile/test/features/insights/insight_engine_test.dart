import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/features/insights/application/deterministic_insight_engine.dart';
import 'package:life_timeline/features/insights/domain/life_query_models.dart';
import 'package:life_timeline/features/insights/infrastructure/drift_insight_dismissal_store.dart';
import 'package:life_timeline/shared/database/app_database.dart';

void main() {
  late AppDatabase database;
  late _ChangingExecutor executor;
  late DeterministicInsightEngine engine;
  final now = DateTime.utc(2026, 8, 11);

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    executor = _ChangingExecutor();
    engine = DeterministicInsightEngine(
      executor,
      DriftInsightDismissalStore(database),
    );
  });

  tearDown(() => database.close());

  test('only eligible deterministic insights are emitted', () async {
    final insights = await engine.generate(now: now);

    expect(
      insights.map((insight) => insight.type),
      containsAll([
        InsightType.confirmedMemories,
        InsightType.timelineSpan,
        InsightType.entityCount,
      ]),
    );
    expect(insights, hasLength(3));
  });

  test('dismissal persists for the same data fingerprint', () async {
    final insight = (await engine.generate(now: now)).last;

    await engine.dismiss(insight, now);
    final regenerated = await DeterministicInsightEngine(
      executor,
      DriftInsightDismissalStore(database),
    ).generate(now: now);

    expect(
      regenerated.any(
        (candidate) =>
            candidate.type == insight.type &&
            candidate.subjectId == insight.subjectId,
      ),
      isFalse,
    );
  });

  test(
    'material supporting-data change makes an insight eligible again',
    () async {
      final insight = (await engine.generate(now: now)).last;
      await engine.dismiss(insight, now);

      executor.phoneCount = 3;
      final regenerated = await engine.generate(now: now);

      final phone = regenerated.singleWhere(
        (candidate) =>
            candidate.type == InsightType.entityCount &&
            candidate.subjectId == LifeEntityCategory.phone.name,
      );
      expect(phone.dataFingerprint, isNot(insight.dataFingerprint));
      expect(phone.result.numericValue, 3);
    },
  );
}

final class _ChangingExecutor implements LifeQueryExecutor {
  var phoneCount = 2;

  @override
  Future<LifeQueryResult> execute(
    LifeQueryIntent intent, {
    required DateTime now,
  }) async {
    if (intent is CountConfirmedMemories) {
      return LifeQueryResult(
        answerType: LifeQueryAnswerType.records,
        headline: '3 confirmed memories',
        status: LifeQueryStatus.answered,
        summary: 'Spanning 2020–2026.',
        numericValue: 3,
        metadata: const {'earliestYear': '2020', 'latestYear': '2026'},
        supportingRecords: const [
          LifeSupportingRecord(
            id: 'event-1',
            recordType: LifeSupportingRecordType.event,
            title: 'First memory',
          ),
          LifeSupportingRecord(
            id: 'event-2',
            recordType: LifeSupportingRecordType.event,
            title: 'Second memory',
          ),
          LifeSupportingRecord(
            id: 'event-3',
            recordType: LifeSupportingRecordType.event,
            title: 'Third memory',
          ),
        ],
      );
    }
    if (intent is CountEntities &&
        intent.category == LifeEntityCategory.phone) {
      return LifeQueryResult(
        answerType: LifeQueryAnswerType.count,
        headline: "You've recorded",
        status: LifeQueryStatus.answered,
        summary: '$phoneCount phones.',
        numericValue: phoneCount,
        metadata: const {'unit': 'phones'},
        supportingRecords: [
          for (var index = 0; index < phoneCount; index++)
            LifeSupportingRecord(
              id: 'phone-$index',
              recordType: LifeSupportingRecordType.entity,
              title: 'Phone $index',
            ),
        ],
      );
    }
    return LifeQueryResult.insufficient(subject: 'relevant history');
  }
}
