import 'package:life_timeline/features/insights/domain/life_query_models.dart';

final class ExploreOverview {
  ExploreOverview({
    required List<ExploreSummary> categories,
    required List<LifeInsight> insights,
    required List<LifeSupportingRecord> places,
    required List<LifeSupportingRecord> things,
    required List<ExploreSummary> years,
  }) : categories = List.unmodifiable(categories),
       insights = List.unmodifiable(insights),
       places = List.unmodifiable(places),
       things = List.unmodifiable(things),
       years = List.unmodifiable(years);

  final List<ExploreSummary> categories;
  final List<LifeInsight> insights;
  final List<LifeSupportingRecord> places;
  final List<LifeSupportingRecord> things;
  final List<ExploreSummary> years;
}

final class ExploreSummary {
  const ExploreSummary({required this.label, required this.value, this.result});

  final String label;
  final LifeQueryResult? result;
  final String value;
}

final class ExploreOverviewLoader {
  const ExploreOverviewLoader(this._executor, this._engine);

  final InsightEngine _engine;
  final LifeQueryExecutor _executor;

  Future<ExploreOverview> load({required DateTime now}) async {
    final insights = await _engine.generate(now: now);
    final things = <LifeSupportingRecord>[];
    final categories = <ExploreSummary>[];
    for (final category in const [
      LifeEntityCategory.phone,
      LifeEntityCategory.computer,
      LifeEntityCategory.vehicle,
      LifeEntityCategory.document,
    ]) {
      final result = await _executor.execute(
        FindEntitiesByCategory(category),
        now: now,
      );
      if (result.status != LifeQueryStatus.answered) continue;
      categories.add(
        ExploreSummary(
          label: _categoryTitle(category),
          value: '${result.numericValue ?? result.supportingRecords.length}',
          result: result,
        ),
      );
      things.addAll(result.supportingRecords.take(2));
    }

    final years = <ExploreSummary>[];
    for (var year = now.year; year >= now.year - 4; year--) {
      final result = await _executor.execute(SummarizeYear(year), now: now);
      if (result.status == LifeQueryStatus.answered) {
        years.add(
          ExploreSummary(
            label: '$year',
            value: '${result.numericValue} memories',
            result: result,
          ),
        );
      }
    }

    final placeResult = await _executor.execute(
      const FindPlacesVisited(),
      now: now,
    );
    return ExploreOverview(
      categories: categories,
      insights: insights,
      places: placeResult.status == LifeQueryStatus.answered
          ? placeResult.supportingRecords.take(6).toList(growable: false)
          : const [],
      things: things,
      years: years,
    );
  }

  String _categoryTitle(LifeEntityCategory category) => switch (category) {
    LifeEntityCategory.phone => 'Phones',
    LifeEntityCategory.computer => 'Computers',
    LifeEntityCategory.vehicle => 'Vehicles',
    LifeEntityCategory.document => 'Documents',
    LifeEntityCategory.place => 'Places',
    LifeEntityCategory.employer => 'Career',
  };
}
