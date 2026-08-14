import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_timeline/app/life_timeline_app.dart';
import 'package:life_timeline/features/backup/application/automatic_backup_background.dart';
import 'package:workmanager/workmanager.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid || Platform.isIOS) {
    await Workmanager().initialize(automaticBackupCallbackDispatcher);
  }
  runApp(const ProviderScope(child: LifeTimelineApp()));
}
