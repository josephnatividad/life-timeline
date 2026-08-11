import 'package:drift/drift.dart';

@TableIndex(
  name: 'insight_dismissals_dismissed_at_idx',
  columns: {#dismissedAt},
)
class InsightDismissals extends Table {
  TextColumn get insightType => text()();
  TextColumn get subjectKey => text().withDefault(const Constant(''))();
  TextColumn get dataFingerprint => text()();
  DateTimeColumn get dismissedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {
    insightType,
    subjectKey,
    dataFingerprint,
  };
}
