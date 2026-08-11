import 'package:drift/drift.dart';
import 'package:life_timeline/features/private_intelligence/domain/intelligence_models.dart';
import 'package:life_timeline/shared/database/app_database.dart';

final class DriftFeatureUsageRepository implements FeatureUsageRepository {
  const DriftFeatureUsageRepository(this._database);
  final AppDatabase _database;

  @override
  Future<int> usageCount(ProFeature feature) async {
    final query = _database.select(_database.featureUsage)
      ..where((row) => row.feature.equals(feature.name));
    return (await query.getSingleOrNull())?.usageCount ?? 0;
  }

  @override
  Future<void> increment(ProFeature feature, DateTime at) =>
      _database.transaction(() async {
        final query = _database.select(_database.featureUsage)
          ..where((row) => row.feature.equals(feature.name));
        final current = await query.getSingleOrNull();
        await _database
            .into(_database.featureUsage)
            .insertOnConflictUpdate(
              FeatureUsageCompanion.insert(
                feature: feature.name,
                usageCount: Value((current?.usageCount ?? 0) + 1),
                updatedAt: at.toUtc(),
              ),
            );
      });
}
