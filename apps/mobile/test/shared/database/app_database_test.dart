import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/shared/database/app_database.dart';

void main() {
  test('opens the empty versioned Drift foundation', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    final row = await database.customSelect('SELECT 1 AS value').getSingle();

    expect(database.schemaVersion, 1);
    expect(row.read<int>('value'), 1);
  });
}
