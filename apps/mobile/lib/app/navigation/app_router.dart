import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_timeline/app/navigation/app_navigation_shell.dart';
import 'package:life_timeline/app/navigation/app_routes.dart';
import 'package:life_timeline/design_system/components/overlays/app_bottom_sheet.dart';
import 'package:life_timeline/features/backup/presentation/create_backup_pages.dart';
import 'package:life_timeline/features/backup/presentation/restore_pages.dart';
import 'package:life_timeline/features/capture/presentation/capture_foundation_sheet.dart';
import 'package:life_timeline/features/explore/presentation/explore_foundation_page.dart';
import 'package:life_timeline/features/insights/presentation/ask_my_life_page.dart';
import 'package:life_timeline/features/private_intelligence/presentation/candidate_review_page.dart';
import 'package:life_timeline/features/private_intelligence/presentation/memory_inbox_page.dart';
import 'package:life_timeline/features/search/presentation/memory_search_page.dart';
import 'package:life_timeline/features/security/presentation/security_settings_page.dart';
import 'package:life_timeline/features/security/presentation/set_pin_page.dart';
import 'package:life_timeline/features/settings/presentation/you_foundation_page.dart';
import 'package:life_timeline/features/stories/domain/story_models.dart';
import 'package:life_timeline/features/stories/presentation/stories_home_page.dart';
import 'package:life_timeline/features/stories/presentation/story_editor_page.dart';
import 'package:life_timeline/features/stories/presentation/story_preview_page.dart';
import 'package:life_timeline/features/stories/presentation/then_now_selection_page.dart';
import 'package:life_timeline/features/timeline/presentation/archive_page.dart';
import 'package:life_timeline/features/timeline/presentation/memory_detail_page.dart';
import 'package:life_timeline/features/timeline/presentation/memory_editor_page.dart';
import 'package:life_timeline/features/timeline/presentation/timeline_home_page.dart';
import 'package:life_timeline/features/timeline/presentation/trash_page.dart';

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
                builder: (context, state) => const TimelineHomePage(),
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
                builder: (context, state) => const StoriesHomePage(),
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
      GoRoute(
        name: AppRoute.addMemory.name,
        path: AppRoute.addMemory.path,
        builder: (context, state) => const AddMemoryPage(),
      ),
      GoRoute(
        name: AppRoute.memoryDetail.name,
        path: AppRoute.memoryDetail.path,
        builder: (context, state) =>
            MemoryDetailPage(memoryId: state.pathParameters['memoryId']!),
      ),
      GoRoute(
        name: AppRoute.editMemory.name,
        path: AppRoute.editMemory.path,
        builder: (context, state) =>
            EditMemoryPage(memoryId: state.pathParameters['memoryId']!),
      ),
      GoRoute(
        name: AppRoute.search.name,
        path: AppRoute.search.path,
        builder: (context, state) => const MemorySearchPage(),
      ),
      GoRoute(
        name: AppRoute.askMyLife.name,
        path: AppRoute.askMyLife.path,
        builder: (context, state) =>
            AskMyLifePage(initialQuestion: state.extra as String?),
      ),
      GoRoute(
        name: AppRoute.storyEditor.name,
        path: AppRoute.storyEditor.path,
        redirect: (context, state) =>
            state.extra is StorySource ? null : AppRoute.stories.path,
        builder: (context, state) =>
            StoryEditorPage(source: state.extra! as StorySource),
      ),
      GoRoute(
        name: AppRoute.storyPreview.name,
        path: AppRoute.storyPreview.path,
        redirect: (context, state) =>
            state.extra is StoryComposition ? null : AppRoute.stories.path,
        builder: (context, state) =>
            StoryPreviewPage(composition: state.extra! as StoryComposition),
      ),
      GoRoute(
        name: AppRoute.thenNowSelection.name,
        path: AppRoute.thenNowSelection.path,
        builder: (context, state) => const ThenNowSelectionPage(),
      ),
      GoRoute(
        name: AppRoute.archive.name,
        path: AppRoute.archive.path,
        builder: (context, state) => const ArchivePage(),
      ),
      GoRoute(
        name: AppRoute.trash.name,
        path: AppRoute.trash.path,
        builder: (context, state) => const TrashPage(),
      ),
      GoRoute(
        name: AppRoute.memoryInbox.name,
        path: AppRoute.memoryInbox.path,
        builder: (context, state) => const MemoryInboxPage(),
      ),
      GoRoute(
        name: AppRoute.candidateReview.name,
        path: AppRoute.candidateReview.path,
        builder: (context, state) => CandidateReviewPage(
          candidateId: state.pathParameters['candidateId']!,
        ),
      ),
      GoRoute(
        name: AppRoute.security.name,
        path: AppRoute.security.path,
        builder: (context, state) => const SecuritySettingsPage(),
      ),
      GoRoute(
        name: AppRoute.setPin.name,
        path: AppRoute.setPin.path,
        builder: (context, state) => const SetPinPage(),
      ),
      GoRoute(
        name: AppRoute.createBackup.name,
        path: AppRoute.createBackup.path,
        builder: (context, state) => const CreateBackupPage(),
      ),
      GoRoute(
        name: AppRoute.backupProgress.name,
        path: AppRoute.backupProgress.path,
        builder: (context, state) => const BackupProgressPage(),
      ),
      GoRoute(
        name: AppRoute.backupComplete.name,
        path: AppRoute.backupComplete.path,
        builder: (context, state) => const BackupCompletePage(),
      ),
      GoRoute(
        name: AppRoute.restoreEntry.name,
        path: AppRoute.restoreEntry.path,
        builder: (context, state) => const RestoreEntryPage(),
      ),
      GoRoute(
        name: AppRoute.chooseBackup.name,
        path: AppRoute.chooseBackup.path,
        builder: (context, state) => const ChooseBackupPage(),
      ),
      GoRoute(
        name: AppRoute.enterRecoveryPassword.name,
        path: AppRoute.enterRecoveryPassword.path,
        builder: (context, state) => const EnterRecoveryPasswordPage(),
      ),
      GoRoute(
        name: AppRoute.restorePreview.name,
        path: AppRoute.restorePreview.path,
        builder: (context, state) => const RestorePreviewPage(),
      ),
      GoRoute(
        name: AppRoute.restoreProgress.name,
        path: AppRoute.restoreProgress.path,
        builder: (context, state) => const RestoreProgressPage(),
      ),
      GoRoute(
        name: AppRoute.restoreResult.name,
        path: AppRoute.restoreResult.path,
        builder: (context, state) => const RestoreResultPage(),
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});

Future<void> _showCaptureFoundation(BuildContext context) =>
    AppBottomSheet.show<void>(
      context: context,
      builder: (sheetContext) => CaptureFoundationSheet(
        onAddMemory: () {
          Navigator.of(sheetContext).pop();
          context.pushNamed(AppRoute.addMemory.name);
        },
        onCandidateCreated: (candidateId) {
          Navigator.of(sheetContext).pop();
          context.pushNamed(
            AppRoute.candidateReview.name,
            pathParameters: {'candidateId': candidateId},
          );
        },
        onOpenInbox: () {
          Navigator.of(sheetContext).pop();
          context.pushNamed(AppRoute.memoryInbox.name);
        },
      ),
    );
