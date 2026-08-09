import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_timeline/shared/database/app_database.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(() => unawaited(database.close()));
  return database;
});
