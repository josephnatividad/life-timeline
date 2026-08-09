import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_timeline/app/navigation/app_navigation_shell.dart';
import 'package:life_timeline/app/navigation/app_routes.dart';
import 'package:life_timeline/design_system/motion/app_motion.dart';
import 'package:life_timeline/features/capture/presentation/capture_foundation_sheet.dart';
import 'package:life_timeline/features/explore/presentation/explore_foundation_page.dart';
import 'package:life_timeline/features/settings/presentation/you_foundation_page.dart';
import 'package:life_timeline/features/stories/presentation/stories_foundation_page.dart';
import 'package:life_timeline/features/timeline/presentation/timeline_foundation_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoute.timeline.path,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppNavigationShell(
          navigationShell: navigationShell,
          onCaptureSelected: () => _showCaptureFoundation(context),
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRoute.timeline.name,
                path: AppRoute.timeline.path,
                builder: (context, state) => const TimelineFoundationPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRoute.explore.name,
                path: AppRoute.explore.path,
                builder: (context, state) => const ExploreFoundationPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRoute.stories.name,
                path: AppRoute.stories.path,
                builder: (context, state) => const StoriesFoundationPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRoute.you.name,
                path: AppRoute.you.path,
                builder: (context, state) => const YouFoundationPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});

Future<void> _showCaptureFoundation(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      sheetAnimationStyle: AppMotion.bottomSheetStyle(context),
      useSafeArea: true,
      builder: (context) => const CaptureFoundationSheet(),
    );
