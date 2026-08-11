import 'package:drift/drift.dart';
import 'package:life_timeline/features/insights/domain/life_query_models.dart';
import 'package:life_timeline/features/insights/domain/precision_aware_duration.dart';
import 'package:life_timeline/features/insights/domain/query_language.dart';
import 'package:life_timeline/shared/database/app_database.dart';
import 'package:life_timeline/shared/database/mappers/persistence_value_codec.dart';
import 'package:life_timeline/shared/domain/formatting/temporal_label.dart';
import 'package:life_timeline/shared/domain/model/temporal_value.dart';

final class DriftLifeQueryExecutor implements LifeQueryExecutor {
  const DriftLifeQueryExecutor(this._database);

  final AppDatabase _database;

  @override
  Future<LifeQueryResult> execute(
    LifeQueryIntent intent, {
    required DateTime now,
  }) => switch (intent) {
    CountConfirmedMemories() => _allConfirmedMemories(),
    CountEntities(:final category) => _countEntities(category),
    FindEntity(:final normalizedName) => _findEntity(normalizedName),
    FindLatestEntity(:final category) => _latestEntity(category),
    FindPreviousEntity(:final category) => _previousEntity(category),
    FindEventsByType(:final eventKind) => _eventsByType(eventKind),
    FindEventsByDateRange(:final startYear, :final endYear) =>
      _eventsByDateRange(startYear, endYear),
    FindExpiringDocuments(:final year) => _expiringDocuments(year),
    CalculateOwnershipDuration(:final category, :final entityId) =>
      _ownershipDuration(category, entityId: entityId, now: now),
    FindLongestOwnedEntity(:final category) => _longestOwned(
      category,
      now: now,
    ),
    FindEntitiesByCategory(:final category) => _entitiesByCategory(category),
    FindTripsByYear(:final year) => _tripsByYear(year),
    FindPlacesVisited() => _placesVisited(),
    FindCareerHistory(:final currentOnly) => _careerHistory(
      currentOnly: currentOnly,
    ),
    FindReplacementHistory(:final category) => _replacementHistory(category),
    SummarizeYear(:final year) => _summarizeYear(year),
    FindMostActiveYear() => _mostActiveYear(),
    FindAnniversaryMilestones() => _anniversaries(now),
  };

  Future<LifeQueryResult> _allConfirmedMemories() async {
    final events = await _eventEvidence();
    if (events.isEmpty) {
      return LifeQueryResult.insufficient(subject: 'confirmed memories');
    }
    final years = events
        .map((event) => event.temporalValue.start?.year)
        .whereType<int>()
        .toList();
    final metadata = <String, String>{};
    if (years.isNotEmpty) {
      years.sort();
      metadata['earliestYear'] = '${years.first}';
      metadata['latestYear'] = '${years.last}';
    }
    return LifeQueryResult(
      answerType: LifeQueryAnswerType.count,
      headline:
          '${events.length} confirmed ${events.length == 1 ? 'memory' : 'memories'}',
      status: LifeQueryStatus.answered,
      summary: years.isEmpty
          ? 'Your confirmed timeline includes memories with unknown dates.'
          : years.first == years.last
          ? 'Recorded in ${years.first}.'
          : 'Spanning ${years.first}–${years.last}.',
      numericValue: events.length,
      confidence: 1,
      metadata: metadata,
      supportingRecords: [for (final event in events) event.record],
    );
  }

  Future<LifeQueryResult> _countEntities(LifeEntityCategory category) async {
    final values = await _entityEvidence(category);
    if (values.isEmpty) {
      return LifeQueryResult.insufficient(
        subject: '${LifeQueryLanguage.pluralCategoryLabel(category)} history',
      );
    }
    final count = values.length;
    final earliestYear = values
        .map((value) => value.acquisition?.temporalValue.start?.year)
        .whereType<int>()
        .fold<int?>(null, (earliest, year) {
          if (earliest == null || year < earliest) return year;
          return earliest;
        });
    return LifeQueryResult(
      answerType: LifeQueryAnswerType.count,
      headline: "You've recorded",
      status: LifeQueryStatus.answered,
      summary:
          '${_plural(count, LifeQueryLanguage.categoryLabel(category))}'
          '${earliestYear == null ? '' : ' since $earliestYear'}.',
      numericValue: count,
      confidence: 1,
      metadata: {'unit': LifeQueryLanguage.pluralCategoryLabel(category)},
      supportingRecords: [for (final value in values) value.entityRecord],
    );
  }

  Future<LifeQueryResult> _findEntity(String normalizedName) async {
    final rows = await _database
        .customSelect(
          '''
        SELECT id, name, entity_type
        FROM entities
        WHERE lifecycle = 'confirmed'
          AND normalized_name LIKE ?
        ORDER BY updated_at DESC
        LIMIT 20
      ''',
          variables: [Variable.withString('%$normalizedName%')],
        )
        .get();
    if (rows.isEmpty) {
      return LifeQueryResult.insufficient(subject: 'matching records');
    }
    final records = [
      for (final row in rows)
        LifeSupportingRecord(
          id: row.read<String>('id'),
          recordType: LifeSupportingRecordType.entity,
          title: row.read<String>('name'),
          typeLabel: row.read<String>('entity_type'),
        ),
    ];
    return LifeQueryResult(
      answerType: LifeQueryAnswerType.entity,
      headline: records.first.title,
      status: LifeQueryStatus.answered,
      summary: rows.length == 1
          ? 'One confirmed record matches.'
          : '${rows.length} confirmed records match.',
      supportingRecords: records,
      confidence: 1,
    );
  }

  Future<LifeQueryResult> _latestEntity(LifeEntityCategory category) async {
    final values = (await _entityEvidence(
      category,
    )).where((value) => value.acquisition != null).toList();
    if (values.isEmpty) {
      return LifeQueryResult.insufficient(
        subject:
            '${LifeQueryLanguage.categoryLabel(category)} purchase history',
      );
    }
    final current = values.first;
    final acquired = current.acquisition!;
    return LifeQueryResult(
      answerType: LifeQueryAnswerType.entity,
      headline: current.name,
      status: LifeQueryStatus.answered,
      summary:
          'Your latest recorded ${LifeQueryLanguage.categoryLabel(category)} '
          'was acquired ${TemporalLabel.format(acquired.temporalValue)}.',
      temporalPrecision: acquired.temporalValue.precision,
      confidence: _temporalConfidence(acquired.temporalValue.precision),
      supportingRecords: [current.entityRecord, acquired.record],
    );
  }

  Future<LifeQueryResult> _previousEntity(LifeEntityCategory category) async {
    final values = (await _entityEvidence(
      category,
    )).where((value) => value.acquisition != null).toList();
    if (values.length < 2) {
      return LifeQueryResult.insufficient(
        subject: '${LifeQueryLanguage.categoryLabel(category)} history',
      );
    }
    final current = values[0];
    final previous = values[1];
    return LifeQueryResult(
      answerType: LifeQueryAnswerType.entity,
      headline: previous.name,
      status: LifeQueryStatus.answered,
      summary:
          'This is the ${LifeQueryLanguage.categoryLabel(category)} '
          'recorded before ${current.name}.',
      temporalPrecision: previous.acquisition!.temporalValue.precision,
      confidence: _temporalConfidence(
        previous.acquisition!.temporalValue.precision,
      ),
      supportingRecords: [
        previous.entityRecord,
        previous.acquisition!.record,
        current.entityRecord,
        current.acquisition!.record,
      ],
    );
  }

  Future<LifeQueryResult> _eventsByType(LifeEventKind kind) async {
    final events = await _eventEvidence(kind: kind);
    if (events.isEmpty) {
      return LifeQueryResult.insufficient(subject: 'matching event history');
    }
    return LifeQueryResult(
      answerType: LifeQueryAnswerType.records,
      headline:
          '${events.length} matching ${events.length == 1 ? 'event' : 'events'}',
      status: LifeQueryStatus.answered,
      summary: 'Only confirmed timeline records are included.',
      numericValue: events.length,
      confidence: 1,
      supportingRecords: [for (final event in events) event.record],
    );
  }

  Future<LifeQueryResult> _eventsByDateRange(int startYear, int endYear) async {
    final events = await _eventEvidence(startYear: startYear, endYear: endYear);
    if (events.isEmpty) {
      return LifeQueryResult.insufficient(subject: 'history for this period');
    }
    final earliest = events
        .map((event) => event.temporalValue.start?.year)
        .whereType<int>()
        .reduce((left, right) => left < right ? left : right);
    final latest = events
        .map(
          (event) =>
              event.temporalValue.end?.year ?? event.temporalValue.start?.year,
        )
        .whereType<int>()
        .reduce((left, right) => left > right ? left : right);
    return LifeQueryResult(
      answerType: LifeQueryAnswerType.records,
      headline:
          '${events.length} confirmed ${events.length == 1 ? 'memory' : 'memories'}',
      status: LifeQueryStatus.answered,
      summary: earliest == latest
          ? 'Recorded in $earliest.'
          : 'Spanning $earliest–$latest.',
      numericValue: events.length,
      confidence: 1,
      metadata: {'earliestYear': '$earliest', 'latestYear': '$latest'},
      supportingRecords: [for (final event in events) event.record],
    );
  }

  Future<LifeQueryResult> _expiringDocuments(int year) async {
    final events = await _eventEvidence(
      kind: LifeEventKind.expiry,
      startYear: year,
      endYear: year,
      entityCategory: LifeEntityCategory.document,
    );
    if (events.isEmpty) {
      return LifeQueryResult.insufficient(subject: 'document expiry history');
    }
    return LifeQueryResult(
      answerType: LifeQueryAnswerType.records,
      headline:
          '${events.length} ${events.length == 1 ? 'document' : 'documents'}',
      status: LifeQueryStatus.answered,
      summary:
          '${events.length == 1 ? 'Has' : 'Have'} a recorded expiry in $year.',
      numericValue: events.length,
      confidence: 1,
      supportingRecords: [for (final event in events) event.record],
    );
  }

  Future<LifeQueryResult> _entitiesByCategory(
    LifeEntityCategory category,
  ) async {
    final values = await _entityEvidence(category);
    if (values.isEmpty) {
      return LifeQueryResult.insufficient(
        subject: '${LifeQueryLanguage.pluralCategoryLabel(category)} history',
      );
    }
    return LifeQueryResult(
      answerType: LifeQueryAnswerType.records,
      headline: _plural(
        values.length,
        LifeQueryLanguage.categoryLabel(category),
      ),
      status: LifeQueryStatus.answered,
      summary: 'Recorded in your confirmed timeline.',
      numericValue: values.length,
      confidence: 1,
      supportingRecords: [for (final value in values) value.entityRecord],
    );
  }

  Future<LifeQueryResult> _tripsByYear(int year) async {
    final events = await _eventEvidence(
      kind: LifeEventKind.travel,
      startYear: year,
      endYear: year,
    );
    if (events.isEmpty) {
      return LifeQueryResult.insufficient(subject: 'travel history for $year');
    }
    return LifeQueryResult(
      answerType: LifeQueryAnswerType.records,
      headline: _plural(events.length, 'trip'),
      status: LifeQueryStatus.answered,
      summary: 'Recorded for $year.',
      numericValue: events.length,
      confidence: 1,
      supportingRecords: [for (final event in events) event.record],
    );
  }

  Future<LifeQueryResult> _placesVisited() async {
    final values = await _entityEvidence(LifeEntityCategory.place);
    if (values.isEmpty) {
      return LifeQueryResult.insufficient(subject: 'place and travel history');
    }
    return LifeQueryResult(
      answerType: LifeQueryAnswerType.records,
      headline: _plural(values.length, 'place'),
      status: LifeQueryStatus.answered,
      summary: 'Recorded across your confirmed timeline.',
      numericValue: values.length,
      confidence: 1,
      supportingRecords: [for (final value in values) value.entityRecord],
    );
  }

  Future<LifeQueryResult> _careerHistory({required bool currentOnly}) async {
    final events = await _eventEvidence(
      kind: LifeEventKind.careerStart,
      entityCategory: LifeEntityCategory.employer,
    );
    if (events.isEmpty) {
      return LifeQueryResult.insufficient(subject: 'career history');
    }
    final selected = currentOnly ? [events.first] : events;
    final current = selected.first;
    return LifeQueryResult(
      answerType: currentOnly
          ? LifeQueryAnswerType.entity
          : LifeQueryAnswerType.records,
      headline: currentOnly
          ? current.title
          : _plural(selected.length, 'career event'),
      status: LifeQueryStatus.answered,
      summary: currentOnly
          ? 'Your latest recorded career start was ${TemporalLabel.format(current.temporalValue)}.'
          : 'Confirmed starts and career milestones in your timeline.',
      numericValue: currentOnly ? null : selected.length,
      temporalPrecision: current.temporalValue.precision,
      confidence: _temporalConfidence(current.temporalValue.precision),
      supportingRecords: [for (final event in selected) event.record],
    );
  }

  Future<LifeQueryResult> _replacementHistory(
    LifeEntityCategory category,
  ) async {
    final events = await _eventEvidence(
      kind: LifeEventKind.replacement,
      entityCategory: category,
    );
    if (events.isEmpty) {
      return LifeQueryResult.insufficient(
        subject:
            '${LifeQueryLanguage.categoryLabel(category)} replacement history',
      );
    }
    return LifeQueryResult(
      answerType: LifeQueryAnswerType.records,
      headline: _plural(events.length, 'replacement'),
      status: LifeQueryStatus.answered,
      summary: 'Confirmed replacement events in your timeline.',
      numericValue: events.length,
      confidence: 1,
      supportingRecords: [for (final event in events) event.record],
    );
  }

  Future<LifeQueryResult> _ownershipDuration(
    LifeEntityCategory category, {
    required DateTime now,
    String? entityId,
  }) async {
    final spans = await _ownershipSpans(category, now: now);
    final matching = entityId == null
        ? spans
        : spans.where((span) => span.entityId == entityId).toList();
    if (matching.isEmpty) {
      return LifeQueryResult.insufficient(
        subject: '${LifeQueryLanguage.categoryLabel(category)} ownership dates',
      );
    }
    final span = matching.first;
    return _durationResult(category, span);
  }

  Future<LifeQueryResult> _longestOwned(
    LifeEntityCategory category, {
    required DateTime now,
  }) async {
    final spans = await _ownershipSpans(category, now: now);
    if (spans.length < 2) {
      return LifeQueryResult.insufficient(
        subject: '${LifeQueryLanguage.categoryLabel(category)} ownership dates',
      );
    }
    spans.sort(
      (left, right) => right.duration.months.compareTo(left.duration.months),
    );
    return _durationResult(category, spans.first, longest: true);
  }

  LifeQueryResult _durationResult(
    LifeEntityCategory category,
    _OwnershipSpan span, {
    bool longest = false,
  }) => LifeQueryResult(
    answerType: LifeQueryAnswerType.duration,
    headline: span.entityName,
    status: LifeQueryStatus.answered,
    summary: longest
        ? 'Your longest recorded ${LifeQueryLanguage.categoryLabel(category)} ownership.'
        : 'Recorded ownership duration.',
    numericValue: span.duration.months,
    temporalPrecision: span.duration.precision,
    confidence: _temporalConfidence(span.duration.precision),
    metadata: {'durationLabel': span.duration.label},
    supportingRecords: [
      span.entityRecord,
      span.start.record,
      ?span.end?.record,
    ],
  );

  Future<LifeQueryResult> _summarizeYear(int year) async {
    final events = await _eventEvidence(startYear: year, endYear: year);
    if (events.isEmpty) {
      return LifeQueryResult.insufficient(subject: 'history for $year');
    }
    var trips = 0;
    var purchases = 0;
    var career = 0;
    var documents = 0;
    for (final event in events) {
      final type = LifeQueryLanguage.normalize(event.typeLabel ?? '');
      if (_hasAny(
        type,
        LifeQueryLanguage.eventAliases[LifeEventKind.travel]!,
      )) {
        trips++;
      }
      if (_hasAny(
        type,
        LifeQueryLanguage.eventAliases[LifeEventKind.acquisition]!,
      )) {
        purchases++;
      }
      if (_hasAny(
        type,
        LifeQueryLanguage.eventAliases[LifeEventKind.careerStart]!,
      )) {
        career++;
      }
      if (_hasAny(
        type,
        LifeQueryLanguage.eventAliases[LifeEventKind.expiry]!,
      )) {
        documents++;
      }
    }
    final parts = <String>[
      if (trips > 0) _plural(trips, 'trip'),
      if (purchases > 0) _plural(purchases, 'purchase'),
      if (career > 0) _plural(career, 'career milestone'),
      if (documents > 0) _plural(documents, 'document milestone'),
    ];
    return LifeQueryResult(
      answerType: LifeQueryAnswerType.yearSummary,
      headline: '$year in your timeline',
      status: LifeQueryStatus.answered,
      summary: parts.isEmpty
          ? _plural(events.length, 'memory')
          : '${parts.join(' · ')} · ${_plural(events.length, 'memory')}',
      numericValue: events.length,
      confidence: 1,
      metadata: {
        'year': '$year',
        'trips': '$trips',
        'purchases': '$purchases',
        'careerMilestones': '$career',
        'documentMilestones': '$documents',
      },
      supportingRecords: [for (final event in events) event.record],
    );
  }

  Future<LifeQueryResult> _mostActiveYear() async {
    final row = await _database.customSelect('''
      SELECT start_year AS year, COUNT(*) AS memory_count
      FROM events
      WHERE lifecycle = 'confirmed'
        AND start_year IS NOT NULL
      GROUP BY start_year
      ORDER BY memory_count DESC, start_year DESC
      LIMIT 1
    ''').getSingleOrNull();
    if (row == null) {
      return LifeQueryResult.insufficient(subject: 'dated timeline history');
    }
    final year = row.read<int>('year');
    final summary = await _summarizeYear(year);
    return LifeQueryResult(
      answerType: LifeQueryAnswerType.yearSummary,
      headline: '$year was your most active year',
      status: LifeQueryStatus.answered,
      summary: summary.summary,
      numericValue: summary.numericValue,
      confidence: 1,
      metadata: {...summary.metadata, 'year': '$year'},
      supportingRecords: summary.supportingRecords,
    );
  }

  Future<LifeQueryResult> _anniversaries(DateTime now) async {
    final years = [now.year - 1, now.year - 5, now.year - 10];
    final rows = await _database
        .customSelect(
          '''
        SELECT
          e.id AS event_id,
          e.title AS event_title,
          e.event_type AS event_type,
          e.temporal_precision AS temporal_precision,
          e.start_year AS start_year,
          e.start_month AS start_month,
          e.start_day AS start_day,
          e.end_year AS end_year,
          e.end_month AS end_month,
          e.end_day AS end_day
        FROM events e
        WHERE e.lifecycle = 'confirmed'
          AND e.temporal_precision = 'exact_date'
          AND e.start_month = ?
          AND e.start_day = ?
          AND e.start_year IN (?, ?, ?)
        ORDER BY e.start_year ASC
      ''',
          variables: [
            Variable.withInt(now.month),
            Variable.withInt(now.day),
            for (final year in years) Variable.withInt(year),
          ],
        )
        .get();
    if (rows.isEmpty) {
      return LifeQueryResult.insufficient(subject: 'exact-date anniversaries');
    }
    final events = rows.map(_eventFromRow).toList();
    final first = events.first;
    final anniversaryYears = now.year - first.temporalValue.start!.year;
    return LifeQueryResult(
      answerType: LifeQueryAnswerType.records,
      headline:
          '$anniversaryYears ${anniversaryYears == 1 ? 'year' : 'years'} ago today',
      status: LifeQueryStatus.answered,
      summary: first.title,
      numericValue: anniversaryYears,
      temporalPrecision: TemporalPrecision.exactDate,
      confidence: 1,
      supportingRecords: [for (final event in events) event.record],
    );
  }

  Future<List<_EntityEvidence>> _entityEvidence(
    LifeEntityCategory category,
  ) async {
    final categoryFilter = _categoryFilter('en', category);
    final evidenceKind = switch (category) {
      LifeEntityCategory.place => LifeEventKind.travel,
      LifeEntityCategory.employer => LifeEventKind.careerStart,
      _ => LifeEventKind.acquisition,
    };
    final acquisitionFilter = _eventFilter('e', evidenceKind);
    final rows = await _database
        .customSelect(
          '''
        SELECT
          en.id AS entity_id,
          en.name AS entity_name,
          en.entity_type AS entity_type,
          e.id AS event_id,
          e.title AS event_title,
          e.event_type AS event_type,
          e.temporal_precision AS temporal_precision,
          e.start_year AS start_year,
          e.start_month AS start_month,
          e.start_day AS start_day,
          e.end_year AS end_year,
          e.end_month AS end_month,
          e.end_day AS end_day
        FROM entities en
        JOIN relationships r ON r.lifecycle = 'confirmed' AND (
          r.source_entity_id = en.id OR r.target_entity_id = en.id
        )
        JOIN events e ON e.lifecycle = 'confirmed'
          AND (r.source_event_id = e.id OR r.target_event_id = e.id)
          AND (${acquisitionFilter.sql})
        WHERE en.lifecycle = 'confirmed'
          AND (${categoryFilter.sql})
        ORDER BY
          COALESCE(e.start_year, 0) DESC,
          COALESCE(e.start_month, 0) DESC,
          COALESCE(e.start_day, 0) DESC,
          en.normalized_name ASC
      ''',
          variables: [
            ...acquisitionFilter.variables,
            ...categoryFilter.variables,
          ],
        )
        .get();
    final byEntity = <String, _EntityEvidence>{};
    for (final row in rows) {
      final entityId = row.read<String>('entity_id');
      byEntity.putIfAbsent(
        entityId,
        () => _EntityEvidence(
          entityId: entityId,
          name: row.read<String>('entity_name'),
          type: row.read<String>('entity_type'),
          acquisition: row.readNullable<String>('event_id') == null
              ? null
              : _eventFromRow(row),
        ),
      );
    }
    final values = byEntity.values.toList();
    values.sort((left, right) {
      final leftYear = left.acquisition?.temporalValue.start?.year ?? 0;
      final rightYear = right.acquisition?.temporalValue.start?.year ?? 0;
      final temporal = rightYear.compareTo(leftYear);
      return temporal != 0 ? temporal : left.name.compareTo(right.name);
    });
    return values;
  }

  Future<List<_EventEvidence>> _eventEvidence({
    LifeEventKind? kind,
    int? startYear,
    int? endYear,
    LifeEntityCategory? entityCategory,
  }) async {
    final conditions = <String>["e.lifecycle = 'confirmed'"];
    final variables = <Variable>[];
    if (kind != null) {
      final filter = _eventFilter('e', kind);
      conditions.add('(${filter.sql})');
      variables.addAll(filter.variables);
    }
    if (startYear != null && endYear != null) {
      conditions.add(
        'e.start_year <= ? AND COALESCE(e.end_year, e.start_year) >= ?',
      );
      variables
        ..add(Variable.withInt(endYear))
        ..add(Variable.withInt(startYear));
    }
    if (entityCategory != null) {
      final categoryFilter = _categoryFilter('en', entityCategory);
      conditions.add('''
        EXISTS (
          SELECT 1
          FROM relationships r
          JOIN entities en ON en.lifecycle = 'confirmed' AND (
            r.source_entity_id = en.id OR r.target_entity_id = en.id
          )
          WHERE r.lifecycle = 'confirmed'
            AND (r.source_event_id = e.id OR r.target_event_id = e.id)
            AND (${categoryFilter.sql})
        )
      ''');
      variables.addAll(categoryFilter.variables);
    }
    final rows = await _database.customSelect('''
        SELECT
          e.id AS event_id,
          e.title AS event_title,
          e.event_type AS event_type,
          e.temporal_precision AS temporal_precision,
          e.start_year AS start_year,
          e.start_month AS start_month,
          e.start_day AS start_day,
          e.end_year AS end_year,
          e.end_month AS end_month,
          e.end_day AS end_day
        FROM events e
        WHERE ${conditions.join(' AND ')}
        ORDER BY
          COALESCE(e.start_year, 0) DESC,
          COALESCE(e.start_month, 0) DESC,
          COALESCE(e.start_day, 0) DESC,
          e.updated_at DESC
      ''', variables: variables).get();
    return rows.map(_eventFromRow).toList();
  }

  Future<List<_OwnershipSpan>> _ownershipSpans(
    LifeEntityCategory category, {
    required DateTime now,
  }) async {
    final categoryFilter = _categoryFilter('en', category);
    final acquisitionFilter = _eventFilter('e', LifeEventKind.acquisition);
    final disposalFilter = _eventFilter('e', LifeEventKind.disposal);
    final rows = await _database
        .customSelect(
          '''
        SELECT
          en.id AS entity_id,
          en.name AS entity_name,
          en.entity_type AS entity_type,
          e.id AS event_id,
          e.title AS event_title,
          e.event_type AS event_type,
          e.temporal_precision AS temporal_precision,
          e.start_year AS start_year,
          e.start_month AS start_month,
          e.start_day AS start_day,
          e.end_year AS end_year,
          e.end_month AS end_month,
          e.end_day AS end_day
        FROM entities en
        JOIN relationships r ON r.lifecycle = 'confirmed'
          AND (r.source_entity_id = en.id OR r.target_entity_id = en.id)
        JOIN events e ON e.lifecycle = 'confirmed'
          AND (r.source_event_id = e.id OR r.target_event_id = e.id)
        WHERE en.lifecycle = 'confirmed'
          AND (${categoryFilter.sql})
          AND ((${acquisitionFilter.sql}) OR (${disposalFilter.sql}))
        ORDER BY
          en.id,
          COALESCE(e.start_year, 0),
          COALESCE(e.start_month, 0),
          COALESCE(e.start_day, 0)
      ''',
          variables: [
            ...categoryFilter.variables,
            ...acquisitionFilter.variables,
            ...disposalFilter.variables,
          ],
        )
        .get();
    final grouped = <String, List<_EventEvidence>>{};
    final entities = <String, _EntityEvidence>{};
    for (final row in rows) {
      final entityId = row.read<String>('entity_id');
      final event = _eventFromRow(row);
      grouped.putIfAbsent(entityId, () => []).add(event);
      entities.putIfAbsent(
        entityId,
        () => _EntityEvidence(
          entityId: entityId,
          name: row.read<String>('entity_name'),
          type: row.read<String>('entity_type'),
          acquisition: event,
        ),
      );
    }
    final result = <_OwnershipSpan>[];
    for (final entry in grouped.entries) {
      final entity = entities[entry.key]!;
      final events = entry.value;
      final starts = events
          .where(
            (event) => _hasAny(
              LifeQueryLanguage.normalize(event.typeLabel ?? ''),
              LifeQueryLanguage.eventAliases[LifeEventKind.acquisition]!,
            ),
          )
          .toList();
      if (starts.isEmpty) continue;
      final start = starts.first;
      final ends = events
          .where(
            (event) => _hasAny(
              LifeQueryLanguage.normalize(event.typeLabel ?? ''),
              LifeQueryLanguage.eventAliases[LifeEventKind.disposal]!,
            ),
          )
          .where(
            (event) =>
                (event.temporalValue.start?.year ?? 0) >=
                (start.temporalValue.start?.year ?? 0),
          )
          .toList();
      final end = ends.isEmpty ? null : ends.first;
      final duration = PrecisionAwareDurations.between(
        start.temporalValue,
        end: end?.temporalValue,
        now: now,
      );
      if (duration == null) continue;
      result.add(
        _OwnershipSpan(
          duration: duration,
          end: end,
          entityId: entity.entityId,
          entityName: entity.name,
          entityRecord: entity.entityRecord,
          start: start,
        ),
      );
    }
    return result;
  }

  _EventEvidence _eventFromRow(QueryRow row) {
    final temporal = PersistenceValueCodec.temporalFromStorage(
      precision: row.read<String>('temporal_precision'),
      startYear: row.readNullable<int>('start_year'),
      startMonth: row.readNullable<int>('start_month'),
      startDay: row.readNullable<int>('start_day'),
      endYear: row.readNullable<int>('end_year'),
      endMonth: row.readNullable<int>('end_month'),
      endDay: row.readNullable<int>('end_day'),
    );
    return _EventEvidence(
      id: row.read<String>('event_id'),
      title: row.read<String>('event_title'),
      typeLabel: row.readNullable<String>('event_type'),
      temporalValue: temporal,
    );
  }

  _SqlFilter _categoryFilter(String alias, LifeEntityCategory category) {
    final aliases = LifeQueryLanguage.entityAliases[category]!
        .map(LifeQueryLanguage.normalize)
        .toSet()
        .toList();
    final placeholders = List.filled(aliases.length, '?').join(', ');
    return _SqlFilter(
      '''
        LOWER($alias.entity_type) IN ($placeholders)
        OR EXISTS (
          SELECT 1
          FROM entity_categories ec
          JOIN categories c ON c.id = ec.category_id
          WHERE ec.entity_id = $alias.id
            AND c.lifecycle = 'confirmed'
            AND c.normalized_name IN ($placeholders)
        )
      ''',
      [
        for (final value in aliases) Variable.withString(value),
        for (final value in aliases) Variable.withString(value),
      ],
    );
  }

  _SqlFilter _eventFilter(String alias, LifeEventKind kind) {
    final aliases = LifeQueryLanguage.eventAliases[kind]!
        .map(LifeQueryLanguage.normalize)
        .toSet()
        .toList();
    return _SqlFilter(
      aliases
          .map((_) => "LOWER(COALESCE($alias.event_type, '')) LIKE ?")
          .join(' OR '),
      [for (final value in aliases) Variable.withString('%$value%')],
    );
  }

  bool _hasAny(String normalized, Set<String> aliases) => aliases.any(
    (alias) =>
        ' $normalized '.contains(' ${LifeQueryLanguage.normalize(alias)} '),
  );

  double _temporalConfidence(TemporalPrecision precision) =>
      switch (precision) {
        TemporalPrecision.exactDate || TemporalPrecision.month => 1,
        TemporalPrecision.year => 0.9,
        TemporalPrecision.approximate || TemporalPrecision.range => 0.75,
        TemporalPrecision.before ||
        TemporalPrecision.after ||
        TemporalPrecision.unknown => 0.5,
      };

  String _plural(int count, String singular) =>
      '$count ${count == 1 ? singular : '${singular}s'}';
}

final class _SqlFilter {
  const _SqlFilter(this.sql, this.variables);

  final String sql;
  final List<Variable> variables;
}

final class _EntityEvidence {
  const _EntityEvidence({
    required this.entityId,
    required this.name,
    required this.type,
    this.acquisition,
  });

  final _EventEvidence? acquisition;
  final String entityId;
  final String name;
  final String type;

  LifeSupportingRecord get entityRecord => LifeSupportingRecord(
    id: entityId,
    recordType: LifeSupportingRecordType.entity,
    title: name,
    typeLabel: type,
    temporalValue: acquisition?.temporalValue,
  );
}

final class _EventEvidence {
  const _EventEvidence({
    required this.id,
    required this.temporalValue,
    required this.title,
    required this.typeLabel,
  });

  final String id;
  final TemporalValue temporalValue;
  final String title;
  final String? typeLabel;

  LifeSupportingRecord get record => LifeSupportingRecord(
    id: id,
    recordType: LifeSupportingRecordType.event,
    title: title,
    temporalValue: temporalValue,
    typeLabel: typeLabel,
  );
}

final class _OwnershipSpan {
  const _OwnershipSpan({
    required this.duration,
    required this.entityId,
    required this.entityName,
    required this.entityRecord,
    required this.start,
    this.end,
  });

  final PrecisionAwareDuration duration;
  final _EventEvidence? end;
  final String entityId;
  final String entityName;
  final LifeSupportingRecord entityRecord;
  final _EventEvidence start;
}
