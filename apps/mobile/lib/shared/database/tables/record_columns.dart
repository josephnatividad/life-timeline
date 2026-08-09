// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';
import 'package:life_timeline/shared/database/tables/schema_constraints.dart';

mixin RecordColumns on Table {
  TextColumn get id => text()();

  // Drift resolves these getter references to generated column expressions.
  TextColumn get privacyClassification =>
      text().check(privacyClassification.isIn(SchemaValues.privacy))();

  TextColumn get lifecycle =>
      text().check(lifecycle.isIn(SchemaValues.lifecycle))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

mixin TemporalColumns on Table {
  TextColumn get temporalPrecision =>
      text().check(temporalPrecision.isIn(SchemaValues.temporalPrecision))();

  IntColumn get startYear => integer().nullable()();
  IntColumn get startMonth => integer().nullable()();
  IntColumn get startDay => integer().nullable()();
  IntColumn get endYear => integer().nullable()();
  IntColumn get endMonth => integer().nullable()();
  IntColumn get endDay => integer().nullable()();
}
