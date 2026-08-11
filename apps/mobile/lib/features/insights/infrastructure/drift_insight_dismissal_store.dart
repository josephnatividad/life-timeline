import 'package:drift/drift.dart';
import 'package:life_timeline/features/insights/domain/life_query_models.dart';
import 'package:life_timeline/shared/database/app_database.dart';

final class DriftInsightDismissalStore implements InsightDismissalStore {
  const DriftInsightDismissalStore(this._database);

  final AppDatabase _database;

  @override
  Future<bool> isDismissed(LifeInsight insight) async {
    final row =
        await (_database.select(_database.insightDismissals)..where(
              (row) =>
                  row.insightType.equals(insight.type.name) &
                  row.subjectKey.equals(insight.subjectId ?? '') &
                  row.dataFingerprint.equals(insight.dataFingerprint),
            ))
            .getSingleOrNull();
    return row != null;
  }

  @override
  Future<void> dismiss(LifeInsight insight, DateTime dismissedAt) => _database
      .into(_database.insightDismissals)
      .insertOnConflictUpdate(
        InsightDismissalsCompanion(
          insightType: Value(insight.type.name),
          subjectKey: Value(insight.subjectId ?? ''),
          dataFingerprint: Value(insight.dataFingerprint),
          dismissedAt: Value(dismissedAt.toUtc()),
        ),
      );
}
