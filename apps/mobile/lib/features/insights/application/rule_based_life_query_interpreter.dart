import 'package:life_timeline/features/insights/domain/life_query_models.dart';
import 'package:life_timeline/features/insights/domain/query_language.dart';

final class RuleBasedLifeQueryInterpreter implements LifeQueryInterpreter {
  const RuleBasedLifeQueryInterpreter();

  @override
  LifeQueryInterpretation interpret(String question, {required DateTime now}) {
    final normalized = LifeQueryLanguage.normalize(question);
    if (normalized.isEmpty) {
      return const LifeQueryInterpretation.unsupported();
    }
    final category = LifeQueryLanguage.categoryIn(normalized);
    final year = LifeQueryLanguage.requestedYear(normalized, now);

    if ((normalized.contains('what happened') ||
            normalized.contains('summarize') ||
            normalized.contains('summary')) &&
        (LifeQueryLanguage.explicitYear(normalized) != null ||
            normalized.contains('this year') ||
            normalized.contains('last year'))) {
      return LifeQueryInterpretation.supported(SummarizeYear(year));
    }

    if ((normalized.contains('where') || normalized.contains('trips')) &&
        LifeQueryLanguage.mentionsEvent(normalized, LifeEventKind.travel) &&
        (LifeQueryLanguage.explicitYear(normalized) != null ||
            normalized.contains('this year') ||
            normalized.contains('last year'))) {
      return LifeQueryInterpretation.supported(FindTripsByYear(year));
    }

    if ((normalized.contains('where') || normalized.contains('places')) &&
        (normalized.contains('visited') || normalized.contains('travel'))) {
      return const LifeQueryInterpretation.supported(FindPlacesVisited());
    }

    if (category == LifeEntityCategory.document &&
        LifeQueryLanguage.mentionsEvent(normalized, LifeEventKind.expiry)) {
      return LifeQueryInterpretation.supported(FindExpiringDocuments(year));
    }

    if (category == LifeEntityCategory.employer &&
        (normalized.contains('current job') ||
            normalized.contains('start') ||
            normalized.contains('career history'))) {
      return LifeQueryInterpretation.supported(
        FindCareerHistory(currentOnly: normalized.contains('current')),
      );
    }

    if (category != null &&
        (normalized.startsWith('how many') ||
            normalized.contains('number of'))) {
      return LifeQueryInterpretation.supported(CountEntities(category));
    }

    if (category != null &&
        (normalized.contains('longest owned') ||
            normalized.contains('owned the longest'))) {
      return LifeQueryInterpretation.supported(
        FindLongestOwnedEntity(category),
      );
    }

    if (category != null &&
        (normalized.contains('previous') ||
            normalized.contains('before this') ||
            normalized.contains('before my current'))) {
      return LifeQueryInterpretation.supported(FindPreviousEntity(category));
    }

    if (category != null &&
        (normalized.contains('current') ||
            LifeQueryLanguage.mentionsEvent(
              normalized,
              LifeEventKind.acquisition,
            ))) {
      return LifeQueryInterpretation.supported(FindLatestEntity(category));
    }

    if (category != null &&
        LifeQueryLanguage.mentionsEvent(
          normalized,
          LifeEventKind.replacement,
        )) {
      return LifeQueryInterpretation.supported(
        FindReplacementHistory(category),
      );
    }

    if (category != null &&
        (normalized.contains('owned') || normalized.contains('have i had'))) {
      return LifeQueryInterpretation.supported(
        FindEntitiesByCategory(category),
      );
    }

    return const LifeQueryInterpretation.unsupported();
  }
}
