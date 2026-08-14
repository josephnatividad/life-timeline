import 'dart:io';

import 'package:life_timeline/features/backup/domain/automatic_backup_models.dart';
import 'package:life_timeline/features/backup/domain/automatic_backup_ports.dart';
import 'package:workmanager/workmanager.dart';

final class WorkmanagerAutomaticBackupScheduler
    implements AutomaticBackupScheduler {
  const WorkmanagerAutomaticBackupScheduler();

  static const periodicTaskName = 'life_timeline_automatic_backup';
  static const periodicUniqueName =
      'com.lifetimeline.lifeTimeline.automaticBackup';
  static const soonUniqueName =
      'com.lifetimeline.lifeTimeline.automaticBackup.soon';

  bool get _supported => Platform.isAndroid || Platform.isIOS;

  @override
  Future<void> configure(AutomaticBackupSettings settings) async {
    if (!_supported) return;
    await Workmanager().cancelByUniqueName(periodicUniqueName);
    await Workmanager().cancelByUniqueName(soonUniqueName);
    if (!settings.enabled) return;
    await Workmanager().registerPeriodicTask(
      periodicUniqueName,
      periodicTaskName,
      frequency: settings.interval,
      constraints: _constraints(settings),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    );
  }

  @override
  Future<void> scheduleSoon(AutomaticBackupSettings settings) async {
    if (!_supported || !settings.enabled) return;
    await Workmanager().registerOneOffTask(
      soonUniqueName,
      periodicTaskName,
      initialDelay: const Duration(minutes: 1),
      constraints: _constraints(settings),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }

  Constraints _constraints(AutomaticBackupSettings settings) => Constraints(
    networkType: settings.networkPolicy == AutomaticBackupNetworkPolicy.wifiOnly
        ? NetworkType.unmetered
        : NetworkType.connected,
    requiresCharging: settings.preferCharging,
    requiresBatteryNotLow: true,
    requiresStorageNotLow: true,
  );
}
