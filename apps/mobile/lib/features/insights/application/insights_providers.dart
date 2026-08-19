import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_timeline/features/insights/application/ask_my_life_service.dart';
import 'package:life_timeline/features/insights/application/deterministic_insight_engine.dart';
import 'package:life_timeline/features/insights/application/explore_overview.dart';
import 'package:life_timeline/features/insights/application/rule_based_life_query_interpreter.dart';
import 'package:life_timeline/features/insights/domain/life_query_models.dart';
import 'package:life_timeline/features/insights/infrastructure/drift_insight_dismissal_store.dart';
import 'package:life_timeline/features/insights/infrastructure/drift_life_query_executor.dart';
import 'package:life_timeline/features/timeline/application/timeline_providers.dart';
import 'package:life_timeline/shared/database/app_database_provider.dart';

final lifeQueryInterpreterProvider = Provider<LifeQueryInterpreter>((ref) {
  return const RuleBasedLifeQueryInterpreter();
});

final lifeQueryExecutorProvider = Provider<LifeQueryExecutor>((ref) {
  return DriftLifeQueryExecutor(ref.watch(appDatabaseProvider));
});

final insightDismissalStoreProvider = Provider<InsightDismissalStore>((ref) {
  return DriftInsightDismissalStore(ref.watch(appDatabaseProvider));
});

final insightEngineProvider = Provider<InsightEngine>((ref) {
  return DeterministicInsightEngine(
    ref.watch(lifeQueryExecutorProvider),
    ref.watch(insightDismissalStoreProvider),
  );
});

final askMyLifeServiceProvider = Provider<AskMyLifeService>((ref) {
  return AskMyLifeService(
    ref.watch(lifeQueryInterpreterProvider),
    ref.watch(lifeQueryExecutorProvider),
  );
});

final lifeInsightsProvider = FutureProvider<List<LifeInsight>>((ref) {
  ref.watch(timelineRevisionProvider);
  return ref.watch(insightEngineProvider).generate(now: DateTime.now().toUtc());
});

final exploreOverviewProvider = FutureProvider<ExploreOverview>((ref) {
  ref.watch(timelineRevisionProvider);
  return ExploreOverviewLoader(
    ref.watch(lifeQueryExecutorProvider),
    ref.watch(insightEngineProvider),
  ).load(now: DateTime.now().toUtc());
});
