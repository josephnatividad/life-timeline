import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_timeline/features/reminders/domain/reminder_repository.dart';
import 'package:life_timeline/features/reminders/infrastructure/drift_reminder_repository.dart';
import 'package:life_timeline/shared/database/app_database.dart';
import 'package:life_timeline/shared/database/repositories/drift_memory_candidate_repository.dart';
import 'package:life_timeline/shared/database/repositories/drift_timeline_repository.dart';
import 'package:life_timeline/shared/domain/repositories/timeline_repository.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(() => unawaited(database.close()));
  return database;
});

final timelineRepositoryProvider = Provider<TimelineRepository>((ref) {
  return DriftTimelineRepository(ref.watch(appDatabaseProvider));
});

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  return DriftReminderRepository(ref.watch(appDatabaseProvider));
});

final memoryCandidateRepositoryProvider = Provider<MemoryCandidateRepository>((
  ref,
) {
  return DriftMemoryCandidateRepository(ref.watch(appDatabaseProvider));
});
