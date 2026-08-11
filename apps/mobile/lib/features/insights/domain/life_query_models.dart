import 'package:life_timeline/shared/domain/model/temporal_value.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

enum LifeEntityCategory { phone, computer, vehicle, document, place, employer }

enum LifeEventKind {
  acquisition,
  expiry,
  travel,
  careerStart,
  replacement,
  disposal,
}

sealed class LifeQueryIntent {
  const LifeQueryIntent();
}

final class CountConfirmedMemories extends LifeQueryIntent {
  const CountConfirmedMemories();
}

final class CountEntities extends LifeQueryIntent {
  const CountEntities(this.category);

  final LifeEntityCategory category;
}

final class FindEntity extends LifeQueryIntent {
  const FindEntity(this.normalizedName);

  final String normalizedName;
}

final class FindLatestEntity extends LifeQueryIntent {
  const FindLatestEntity(this.category);

  final LifeEntityCategory category;
}

final class FindPreviousEntity extends LifeQueryIntent {
  const FindPreviousEntity(this.category);

  final LifeEntityCategory category;
}

final class FindEventsByType extends LifeQueryIntent {
  const FindEventsByType(this.eventKind);

  final LifeEventKind eventKind;
}

final class FindEventsByDateRange extends LifeQueryIntent {
  const FindEventsByDateRange({required this.startYear, required this.endYear});

  final int endYear;
  final int startYear;
}

final class FindExpiringDocuments extends LifeQueryIntent {
  const FindExpiringDocuments(this.year);

  final int year;
}

final class CalculateOwnershipDuration extends LifeQueryIntent {
  const CalculateOwnershipDuration(this.category, {this.entityId});

  final LifeEntityCategory category;
  final String? entityId;
}

final class FindLongestOwnedEntity extends LifeQueryIntent {
  const FindLongestOwnedEntity(this.category);

  final LifeEntityCategory category;
}

final class FindEntitiesByCategory extends LifeQueryIntent {
  const FindEntitiesByCategory(this.category);

  final LifeEntityCategory category;
}

final class FindTripsByYear extends LifeQueryIntent {
  const FindTripsByYear(this.year);

  final int year;
}

final class FindPlacesVisited extends LifeQueryIntent {
  const FindPlacesVisited();
}

final class FindCareerHistory extends LifeQueryIntent {
  const FindCareerHistory({this.currentOnly = false});

  final bool currentOnly;
}

final class FindReplacementHistory extends LifeQueryIntent {
  const FindReplacementHistory(this.category);

  final LifeEntityCategory category;
}

final class SummarizeYear extends LifeQueryIntent {
  const SummarizeYear(this.year);

  final int year;
}

final class FindMostActiveYear extends LifeQueryIntent {
  const FindMostActiveYear();
}

final class FindAnniversaryMilestones extends LifeQueryIntent {
  const FindAnniversaryMilestones();
}

enum LifeQueryStatus { answered, insufficientData, unsupported }

enum LifeQueryAnswerType {
  count,
  entity,
  records,
  duration,
  yearSummary,
  unsupported,
  insufficientData,
}

enum LifeSupportingRecordType { event, entity }

final class LifeSupportingRecord {
  const LifeSupportingRecord({
    required this.id,
    required this.recordType,
    required this.title,
    this.context,
    this.temporalValue,
    this.typeLabel,
  });

  final String? context;
  final String id;
  final LifeSupportingRecordType recordType;
  final TemporalValue? temporalValue;
  final String title;
  final String? typeLabel;
}

final class LifeQueryResult {
  LifeQueryResult({
    required this.answerType,
    required this.headline,
    required this.status,
    required this.summary,
    this.confidence,
    Map<String, String> metadata = const {},
    this.numericValue,
    List<LifeSupportingRecord> supportingRecords = const [],
    this.temporalPrecision,
  }) : metadata = Map.unmodifiable(metadata),
       supportingRecords = List.unmodifiable(supportingRecords);

  factory LifeQueryResult.unsupported() => LifeQueryResult(
    answerType: LifeQueryAnswerType.unsupported,
    headline: "I don't know how to answer that yet.",
    status: LifeQueryStatus.unsupported,
    summary: 'Try one of the supported questions below.',
  );

  factory LifeQueryResult.insufficient({required String subject}) =>
      LifeQueryResult(
        answerType: LifeQueryAnswerType.insufficientData,
        headline: 'Not enough timeline history yet',
        status: LifeQueryStatus.insufficientData,
        summary: 'I can answer this once your timeline has more $subject.',
      );

  final LifeQueryAnswerType answerType;
  final double? confidence;
  final String headline;
  final Map<String, String> metadata;
  final num? numericValue;
  final LifeQueryStatus status;
  final String summary;
  final List<LifeSupportingRecord> supportingRecords;
  final TemporalPrecision? temporalPrecision;

  List<String> get eventIds => [
    for (final record in supportingRecords)
      if (record.recordType == LifeSupportingRecordType.event) record.id,
  ];

  List<String> get entityIds => [
    for (final record in supportingRecords)
      if (record.recordType == LifeSupportingRecordType.entity) record.id,
  ];

  List<TimelineRecordReference> get supportingRecordIds => [
    for (final record in supportingRecords)
      TimelineRecordReference(
        type: record.recordType == LifeSupportingRecordType.event
            ? TimelineRecordType.event
            : TimelineRecordType.entity,
        id: record.id,
      ),
  ];
}

final class LifeQueryInterpretation {
  const LifeQueryInterpretation.supported(this.intent) : supported = true;

  const LifeQueryInterpretation.unsupported()
    : intent = null,
      supported = false;

  final LifeQueryIntent? intent;
  final bool supported;
}

abstract interface class LifeQueryInterpreter {
  LifeQueryInterpretation interpret(String question, {required DateTime now});
}

abstract interface class LifeQueryExecutor {
  Future<LifeQueryResult> execute(
    LifeQueryIntent intent, {
    required DateTime now,
  });
}

enum InsightType {
  confirmedMemories,
  timelineSpan,
  entityCount,
  placesVisited,
  longestOwned,
  upcomingExpiry,
  mostActiveYear,
  yearSummary,
  anniversary,
}

final class LifeInsight {
  const LifeInsight({
    required this.dataFingerprint,
    required this.result,
    required this.type,
    this.subjectId,
  });

  final String dataFingerprint;
  final LifeQueryResult result;
  final String? subjectId;
  final InsightType type;
}

abstract interface class InsightDismissalStore {
  Future<bool> isDismissed(LifeInsight insight);
  Future<void> dismiss(LifeInsight insight, DateTime dismissedAt);
}

abstract interface class InsightEngine {
  Future<List<LifeInsight>> generate({required DateTime now, int limit = 5});
  Future<void> dismiss(LifeInsight insight, DateTime dismissedAt);
}
