import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_timeline/features/backup/application/backup_providers.dart';
import 'package:life_timeline/features/backup/domain/automatic_backup_models.dart';
import 'package:life_timeline/features/backup/infrastructure/workmanager_automatic_backup_scheduler.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void automaticBackupCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task != WorkmanagerAutomaticBackupScheduler.periodicTaskName &&
        task != WorkmanagerAutomaticBackupScheduler.periodicUniqueName &&
        task != WorkmanagerAutomaticBackupScheduler.soonUniqueName) {
      return true;
    }
    final container = ProviderContainer();
    try {
      final result = await container
          .read(automaticBackupCoordinatorProvider)
          .run();
      return result != AutomaticBackupRunResult.failed;
    } on Object {
      return false;
    } finally {
      container.dispose();
    }
  });
}
