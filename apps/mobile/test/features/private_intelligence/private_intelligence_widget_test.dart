import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/features/private_intelligence/domain/intelligence_models.dart';
import 'package:life_timeline/features/private_intelligence/presentation/candidate_review_page.dart';
import 'package:life_timeline/shared/database/app_database.dart'
    hide MemoryCandidate;
import 'package:life_timeline/shared/database/app_database_provider.dart';
import 'package:life_timeline/shared/database/repositories/drift_memory_candidate_repository.dart';
import 'package:life_timeline/shared/domain/model/memory_candidate.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';
import 'package:life_timeline/shared/domain/model/temporal_value.dart';

void main() {
  late AppDatabase database;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    final now = DateTime.utc(2026, 8, 10);
    await DriftMemoryCandidateRepository(database).saveCandidate(
      MemoryCandidate(
        metadata: RecordMetadata(
          id: 'candidate-widget',
          privacyClassification: PrivacyClassification.sensitive,
          lifecycle: RecordLifecycle.candidate,
          createdAt: now,
          updatedAt: now,
        ),
        title: 'Purchase at Corner Market',
        temporalValue: TemporalValue.unknown(),
        documentType: DocumentType.receipt,
        overallConfidence: 0.58,
        extractedFields: [
          ExtractedField(
            id: 'field-total',
            key: 'total',
            value: '10.80',
            valueType: ExtractedValueType.money,
            confidence: 0.55,
            privacyClassification: PrivacyClassification.personal,
            extractionMethod: 'deterministic_ocr',
            reviewRecommended: true,
          ),
        ],
      ),
    );
  });

  tearDown(() => database.close());

  testWidgets('review identifies uncertainty without presenting AI truth', (
    tester,
  ) async {
    await tester.pumpWidget(_app(database));
    await tester.pumpAndSettle();

    expect(find.text('A reviewable suggestion'), findsOneWidget);
    expect(
      find.textContaining('Nothing reaches your timeline'),
      findsOneWidget,
    );
    expect(find.text('Needs a closer look'), findsOneWidget);
    expect(find.text('Sensitive'), findsOneWidget);
    expect(find.byKey(const Key('confirm-candidate')), findsOneWidget);
  });

  testWidgets('ignore is reversible from the same review', (tester) async {
    await tester.pumpWidget(_app(database));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('ignore-candidate')));
    await tester.pumpAndSettle();
    expect(find.text('Suggestion ignored'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('A reviewable suggestion'), findsOneWidget);
  });
}

Widget _app(AppDatabase database) => ProviderScope(
  overrides: [appDatabaseProvider.overrideWithValue(database)],
  child: const MaterialApp(
    home: CandidateReviewPage(candidateId: 'candidate-widget'),
  ),
);
