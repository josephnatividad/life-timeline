import 'package:drift/drift.dart';

/// Applies every additive migration in order.
///
/// Schema v1 is created by `Migrator.createAll`. Future versions must add an
/// explicit case here and accompanying migration tests. There is intentionally
/// no destructive fallback or reset-on-mismatch behavior.
Future<void> migrateSchema(
  Migrator migrator, {
  required int from,
  required int to,
}) async {
  if (to > from) {
    throw StateError('Missing explicit migration to schema v${from + 1}.');
  }
}
