import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/explore/presentation/explore_foundation_page.dart';
import 'package:life_timeline/features/insights/application/ask_my_life_service.dart';
import 'package:life_timeline/features/insights/application/explore_overview.dart';
import 'package:life_timeline/features/insights/application/insights_providers.dart';
import 'package:life_timeline/features/insights/domain/life_query_models.dart';
import 'package:life_timeline/features/insights/presentation/ask_my_life_page.dart';
import 'package:life_timeline/shared/domain/model/temporal_value.dart';

void main() {
  test('Explore overview bounds a 10,000-record place fixture', () async {
    final overview = await ExploreOverviewLoader(
      const _LargeFixtureExecutor(),
      _NoOpInsightEngine(),
    ).load(now: DateTime.utc(2026, 8, 19));

    expect(overview.places, hasLength(6));
    expect(overview.insights, isEmpty);
  });

  testWidgets('Ask My Life renders suggestions and an evidence-backed answer', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          askMyLifeServiceProvider.overrideWithValue(
            AskMyLifeService(
              const _SupportedInterpreter(),
              _ResultExecutor(_answeredResult()),
            ),
          ),
        ],
        child: const _TestApp(child: AskMyLifePage()),
      ),
    );

    expect(find.text('Ask your life'), findsWidgets);
    expect(find.text('How many phones have I owned?'), findsWidgets);
    await tester.enterText(
      find.byKey(const Key('ask-life-input')),
      'How many phones have I owned?',
    );
    await tester.tap(find.byKey(const Key('ask-life-submit')));
    await tester.pumpAndSettle();
    await _reveal(
      tester,
      find.byKey(const Key('ask-life-result')),
      const Key('ask-life-content'),
    );

    expect(find.byKey(const Key('ask-life-result')), findsOneWidget);
    expect(find.text("You've recorded"), findsOneWidget);
    expect(find.text('2 phones'), findsOneWidget);
    expect(find.text('View 2 records'), findsOneWidget);

    await tester.tap(find.text('View 2 records'));
    await tester.pumpAndSettle();
    expect(find.text('Supporting records'), findsOneWidget);
    expect(find.text('Phone One'), findsOneWidget);
    expect(find.text('Phone Two'), findsOneWidget);
  });

  testWidgets('unsupported and low-data answers are deliberate states', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          askMyLifeServiceProvider.overrideWithValue(
            AskMyLifeService(
              const _UnsupportedInterpreter(),
              _ResultExecutor(_answeredResult()),
            ),
          ),
        ],
        child: const _TestApp(child: AskMyLifePage()),
      ),
    );
    await tester.enterText(
      find.byKey(const Key('ask-life-input')),
      'Write my autobiography',
    );
    await tester.tap(find.byKey(const Key('ask-life-submit')));
    await tester.pumpAndSettle();
    await _reveal(
      tester,
      find.byKey(const Key('ask-life-result')),
      const Key('ask-life-content'),
    );

    expect(find.text("I don't know how to answer that yet."), findsOneWidget);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          askMyLifeServiceProvider.overrideWithValue(
            AskMyLifeService(
              const _SupportedInterpreter(),
              _ResultExecutor(
                LifeQueryResult.insufficient(subject: 'vehicle history'),
              ),
            ),
          ),
        ],
        child: const _TestApp(child: AskMyLifePage(key: ValueKey('low-data'))),
      ),
    );
    await tester.enterText(
      find.byKey(const Key('ask-life-input')),
      'What vehicles have I owned?',
    );
    await tester.tap(find.byKey(const Key('ask-life-submit')));
    await tester.pumpAndSettle();
    await _reveal(
      tester,
      find.byKey(const Key('ask-life-result')),
      const Key('ask-life-content'),
    );

    expect(
      find.text(
        'I can answer this once your timeline has more vehicle history.',
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'Explore uses editorial sections in dark mode and Reduced Motion',
    (tester) async {
      final result = _answeredResult();
      final insight = LifeInsight(
        dataFingerprint: 'fingerprint',
        result: result,
        type: InsightType.entityCount,
        subjectId: 'phone',
      );
      final overview = ExploreOverview(
        categories: [
          ExploreSummary(label: 'Phones', value: '2', result: result),
        ],
        insights: [insight],
        places: const [
          LifeSupportingRecord(
            id: 'place-japan',
            recordType: LifeSupportingRecordType.entity,
            title: 'Japan',
            typeLabel: 'Country',
          ),
        ],
        things: result.supportingRecords,
        years: [
          ExploreSummary(label: '2026', value: '2 memories', result: result),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exploreOverviewProvider.overrideWith((ref) async => overview),
            insightEngineProvider.overrideWithValue(_NoOpInsightEngine()),
          ],
          child: const _TestApp(
            dark: true,
            reducedMotion: true,
            child: ExploreFoundationPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('For you'), findsOneWidget);
      await _reveal(
        tester,
        find.text('Browse your life'),
        const Key('explore-content'),
      );
      expect(find.text('Browse your life'), findsOneWidget);
      await _reveal(tester, find.text('Things'), const Key('explore-content'));
      expect(find.text('Things'), findsOneWidget);
      await _reveal(tester, find.text('Years'), const Key('explore-content'));
      expect(find.text('Years'), findsOneWidget);
      await _reveal(tester, find.text('Places'), const Key('explore-content'));
      expect(find.text('Places'), findsOneWidget);
      await _reveal(
        tester,
        find.text('Phones · 2'),
        const Key('explore-content'),
      );
      expect(find.text('Phones · 2'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Ask My Life adapts to a small phone with large text', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(320, 720)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          askMyLifeServiceProvider.overrideWithValue(
            AskMyLifeService(
              const _SupportedInterpreter(),
              _ResultExecutor(_answeredResult()),
            ),
          ),
        ],
        child: const _TestApp(
          textScaler: TextScaler.linear(2),
          child: AskMyLifePage(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Ask your life'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _reveal(
  WidgetTester tester,
  Finder target,
  Key scrollViewKey,
) async {
  for (var attempt = 0; attempt < 12 && target.evaluate().isEmpty; attempt++) {
    await tester.drag(find.byKey(scrollViewKey), const Offset(0, -250));
    await tester.pump();
  }
  expect(target, findsWidgets);
  await tester.ensureVisible(target.first);
  await tester.pump();
}

LifeQueryResult _answeredResult() => LifeQueryResult(
  answerType: LifeQueryAnswerType.count,
  headline: "You've recorded",
  status: LifeQueryStatus.answered,
  summary: '2 phones since 2012.',
  numericValue: 2,
  metadata: const {'unit': 'phones'},
  supportingRecords: [
    LifeSupportingRecord(
      id: 'phone-1',
      recordType: LifeSupportingRecordType.entity,
      title: 'Phone One',
      temporalValue: TemporalValue.year(2012),
      typeLabel: 'Phone',
    ),
    LifeSupportingRecord(
      id: 'phone-2',
      recordType: LifeSupportingRecordType.entity,
      title: 'Phone Two',
      temporalValue: TemporalValue.approximate(TemporalPoint(year: 2020)),
      typeLabel: 'Phone',
    ),
  ],
);

final class _SupportedInterpreter implements LifeQueryInterpreter {
  const _SupportedInterpreter();

  @override
  LifeQueryInterpretation interpret(String question, {required DateTime now}) =>
      const LifeQueryInterpretation.supported(
        CountEntities(LifeEntityCategory.phone),
      );
}

final class _UnsupportedInterpreter implements LifeQueryInterpreter {
  const _UnsupportedInterpreter();

  @override
  LifeQueryInterpretation interpret(String question, {required DateTime now}) =>
      const LifeQueryInterpretation.unsupported();
}

final class _ResultExecutor implements LifeQueryExecutor {
  const _ResultExecutor(this.result);

  final LifeQueryResult result;

  @override
  Future<LifeQueryResult> execute(
    LifeQueryIntent intent, {
    required DateTime now,
  }) async => result;
}

final class _LargeFixtureExecutor implements LifeQueryExecutor {
  const _LargeFixtureExecutor();

  @override
  Future<LifeQueryResult> execute(
    LifeQueryIntent intent, {
    required DateTime now,
  }) async {
    if (intent is! FindPlacesVisited) {
      return LifeQueryResult.insufficient(subject: 'confirmed history');
    }
    return LifeQueryResult(
      answerType: LifeQueryAnswerType.records,
      headline: 'Places',
      status: LifeQueryStatus.answered,
      summary: 'Confirmed places.',
      supportingRecords: List.generate(
        10000,
        (index) => LifeSupportingRecord(
          id: 'place-$index',
          recordType: LifeSupportingRecordType.entity,
          title: 'Place $index',
        ),
      ),
    );
  }
}

final class _NoOpInsightEngine implements InsightEngine {
  @override
  Future<void> dismiss(LifeInsight insight, DateTime dismissedAt) async {}

  @override
  Future<List<LifeInsight>> generate({
    required DateTime now,
    int limit = 5,
  }) async => const [];
}

final class _TestApp extends StatelessWidget {
  const _TestApp({
    required this.child,
    this.dark = false,
    this.reducedMotion = false,
    this.textScaler,
  });

  final Widget child;
  final bool dark;
  final bool reducedMotion;
  final TextScaler? textScaler;

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: dark ? AppTheme.dark() : AppTheme.light(),
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(disableAnimations: reducedMotion, textScaler: textScaler),
        child: child,
      ),
    ),
  );
}
