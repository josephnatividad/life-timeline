import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_timeline/app/navigation/app_router.dart';
import 'package:life_timeline/app/providers/theme_mode_provider.dart';
import 'package:life_timeline/design_system/theme/app_theme.dart';

final class LifeTimelineApp extends ConsumerWidget {
  const LifeTimelineApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      title: 'Life Timeline',
    );
  }
}
