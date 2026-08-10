import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_timeline/features/private_intelligence/application/intelligence_providers.dart';
import 'package:life_timeline/features/timeline/application/timeline_providers.dart';

final restoredDataRefreshCoordinatorProvider =
    Provider<RestoredDataRefreshCoordinator>(
      RestoredDataRefreshCoordinator.new,
    );

/// Recreates UI-facing read models after a completed database restore.
///
/// Restore writes through validated SQL inside a single transaction. Refreshing
/// these providers after the operation has finished makes the indexed navigation
/// shell read the committed snapshot without replacing repositories or the live
/// database while restore is running.
final class RestoredDataRefreshCoordinator {
  const RestoredDataRefreshCoordinator(this._ref);

  final Ref _ref;

  void refresh() {
    _ref
      ..invalidate(timelineMemoriesProvider)
      ..invalidate(archivedMemoriesProvider)
      ..invalidate(memoryDetailProvider)
      ..invalidate(memorySearchProvider)
      ..invalidate(pendingCandidatesProvider)
      ..invalidate(candidateProvider)
      ..invalidate(aiCaptureUsageProvider);
  }
}
