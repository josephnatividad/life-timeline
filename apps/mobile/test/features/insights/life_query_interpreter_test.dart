import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/features/insights/application/rule_based_life_query_interpreter.dart';
import 'package:life_timeline/features/insights/domain/life_query_models.dart';

void main() {
  const interpreter = RuleBasedLifeQueryInterpreter();
  final now = DateTime.utc(2026, 8, 11);

  test('interprets phone count aliases', () {
    final result = interpreter.interpret(
      'How many mobile phones have I owned?',
      now: now,
    );

    expect(result.intent, isA<CountEntities>());
    expect(
      (result.intent! as CountEntities).category,
      LifeEntityCategory.phone,
    );
  });

  test('interprets current laptop acquisition', () {
    final result = interpreter.interpret(
      'When did I buy my current laptop?',
      now: now,
    );

    expect(result.intent, isA<FindLatestEntity>());
    expect(
      (result.intent! as FindLatestEntity).category,
      LifeEntityCategory.computer,
    );
  });

  test('interprets previous laptop', () {
    final result = interpreter.interpret(
      'What laptop did I have before this one?',
      now: now,
    );

    expect(result.intent, isA<FindPreviousEntity>());
  });

  test('interprets document expiry for this year', () {
    final result = interpreter.interpret(
      'Which documents expire this year?',
      now: now,
    );

    expect(result.intent, isA<FindExpiringDocuments>());
    expect((result.intent! as FindExpiringDocuments).year, 2026);
  });

  test('interprets vehicle history', () {
    final result = interpreter.interpret(
      'What vehicles have I owned?',
      now: now,
    );

    expect(result.intent, isA<FindEntitiesByCategory>());
  });

  test('interprets travel and year summary', () {
    expect(
      interpreter.interpret('Where did I travel in 2025?', now: now).intent,
      isA<FindTripsByYear>(),
    );
    final summary = interpreter.interpret('What happened in 2026?', now: now);
    expect(summary.intent, isA<SummarizeYear>());
    expect((summary.intent! as SummarizeYear).year, 2026);
  });

  test('unsupported input remains unsupported', () {
    final result = interpreter.interpret(
      'Write a poem about my entire life',
      now: now,
    );

    expect(result.supported, isFalse);
    expect(result.intent, isNull);
  });
}
