import 'package:life_timeline/features/insights/domain/life_query_models.dart';

final class DeterministicInsightEngine implements InsightEngine {
  const DeterministicInsightEngine(this._executor, this._dismissalStore);

  final InsightDismissalStore _dismissalStore;
  final LifeQueryExecutor _executor;

  @override
  Future<List<LifeInsight>> generate({
    required DateTime now,
    int limit = 5,
  }) async {
    final candidates = <LifeInsight>[];

    final allEvents = await _executor.execute(
      const CountConfirmedMemories(),
      now: now,
    );
    if (allEvents.status == LifeQueryStatus.answered &&
        (allEvents.numericValue ?? 0) >= 3) {
      candidates.add(_insight(InsightType.confirmedMemories, allEvents));
      final earliest = int.tryParse(allEvents.metadata['earliestYear'] ?? '');
      final latest = int.tryParse(allEvents.metadata['latestYear'] ?? '');
      if (earliest != null && latest != null && earliest < latest) {
        candidates.add(
          _insight(
            InsightType.timelineSpan,
            LifeQueryResult(
              answerType: LifeQueryAnswerType.duration,
              headline: '$earliest–$latest',
              status: LifeQueryStatus.answered,
              summary:
                  'Your confirmed timeline currently spans '
                  '${latest - earliest + 1} years.',
              numericValue: latest - earliest + 1,
              confidence: 1,
              metadata: {'earliestYear': '$earliest', 'latestYear': '$latest'},
              supportingRecords: allEvents.supportingRecords,
            ),
          ),
        );
      }
    }

    for (final category in const [
      LifeEntityCategory.phone,
      LifeEntityCategory.computer,
      LifeEntityCategory.vehicle,
    ]) {
      final result = await _executor.execute(CountEntities(category), now: now);
      if (result.status == LifeQueryStatus.answered &&
          (result.numericValue ?? 0) >= 2) {
        candidates.add(
          _insight(InsightType.entityCount, result, subjectId: category.name),
        );
      }
    }

    final places = await _executor.execute(const FindPlacesVisited(), now: now);
    if (places.status == LifeQueryStatus.answered &&
        (places.numericValue ?? 0) >= 2) {
      candidates.add(_insight(InsightType.placesVisited, places));
    }

    final expiry = await _executor.execute(
      FindExpiringDocuments(now.year),
      now: now,
    );
    if (expiry.status == LifeQueryStatus.answered) {
      candidates.add(
        _insight(InsightType.upcomingExpiry, expiry, subjectId: '${now.year}'),
      );
    }

    for (final category in const [
      LifeEntityCategory.phone,
      LifeEntityCategory.computer,
    ]) {
      final longest = await _executor.execute(
        FindLongestOwnedEntity(category),
        now: now,
      );
      if (longest.status == LifeQueryStatus.answered) {
        candidates.add(
          _insight(InsightType.longestOwned, longest, subjectId: category.name),
        );
      }
    }

    final year = await _executor.execute(SummarizeYear(now.year), now: now);
    if (year.status == LifeQueryStatus.answered &&
        (year.numericValue ?? 0) >= 3) {
      candidates.add(
        _insight(InsightType.yearSummary, year, subjectId: '${now.year}'),
      );
    }

    final mostActive = await _executor.execute(
      const FindMostActiveYear(),
      now: now,
    );
    if (mostActive.status == LifeQueryStatus.answered) {
      candidates.add(_insight(InsightType.mostActiveYear, mostActive));
    }

    final anniversary = await _executor.execute(
      const FindAnniversaryMilestones(),
      now: now,
    );
    if (anniversary.status == LifeQueryStatus.answered) {
      candidates.add(_insight(InsightType.anniversary, anniversary));
    }

    final visible = <LifeInsight>[];
    for (final candidate in candidates) {
      if (!await _dismissalStore.isDismissed(candidate)) {
        visible.add(candidate);
        if (visible.length == limit) break;
      }
    }
    return visible;
  }

  @override
  Future<void> dismiss(LifeInsight insight, DateTime dismissedAt) =>
      _dismissalStore.dismiss(insight, dismissedAt);

  LifeInsight _insight(
    InsightType type,
    LifeQueryResult result, {
    String? subjectId,
  }) => LifeInsight(
    dataFingerprint: _fingerprint(type, subjectId, result),
    result: result,
    subjectId: subjectId,
    type: type,
  );

  String _fingerprint(
    InsightType type,
    String? subjectId,
    LifeQueryResult result,
  ) {
    final source = [
      'v1',
      type.name,
      subjectId ?? '',
      result.headline,
      result.summary,
      '${result.numericValue}',
      ...result.supportingRecordIds.map(
        (record) => '${record.type.name}:${record.id}',
      ),
    ].join('|');
    var hash = 0x811c9dc5;
    for (final unit in source.codeUnits) {
      hash = ((hash ^ unit) * 0x01000193) & 0x7fffffff;
    }
    return 'v1-${hash.toRadixString(16)}';
  }
}
