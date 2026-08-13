import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_timeline/features/media/application/media_providers.dart';
import 'package:life_timeline/features/stories/application/default_story_composer.dart';
import 'package:life_timeline/features/stories/application/default_story_privacy_sanitizer.dart';
import 'package:life_timeline/features/stories/application/deterministic_milestone_engine.dart';
import 'package:life_timeline/features/stories/application/story_source_factory.dart';
import 'package:life_timeline/features/stories/application/story_template_access_policy.dart';
import 'package:life_timeline/features/stories/domain/milestone_models.dart';
import 'package:life_timeline/features/stories/domain/story_models.dart';
import 'package:life_timeline/features/stories/infrastructure/local_story_file_services.dart';
import 'package:life_timeline/features/stories/infrastructure/platform_story_services.dart';
import 'package:life_timeline/features/timeline/application/timeline_providers.dart';
import 'package:life_timeline/shared/application/entitlement_providers.dart';
import 'package:life_timeline/shared/database/app_database_provider.dart';

final storyPrivacySanitizerProvider = Provider<StoryPrivacySanitizer>((ref) {
  return const DefaultStoryPrivacySanitizer();
});

final storyComposerProvider = Provider<StoryComposer>((ref) {
  return DefaultStoryComposer(ref.watch(storyPrivacySanitizerProvider));
});

final storyBrandingConfigProvider = Provider<StoryBrandingConfig>((ref) {
  return const StoryBrandingConfig();
});

final storyAttachmentPathResolverProvider =
    Provider<StoryAttachmentPathResolver>((ref) {
      return const LocalStoryAttachmentPathResolver();
    });

final storySourceFactoryProvider = Provider<StorySourceFactory>((ref) {
  return LocalStorySourceFactory(
    ref.watch(timelineRepositoryProvider),
    ref.watch(memoryMediaRepositoryProvider),
    ref.watch(storyAttachmentPathResolverProvider),
  );
});

final milestoneEngineProvider = Provider<MilestoneEngine>((ref) {
  return const DeterministicMilestoneEngine();
});

final milestoneCandidatesProvider =
    Provider<AsyncValue<List<MilestoneCandidate>>>((ref) {
      final memories = ref.watch(timelineMemoriesProvider);
      return memories.whenData(
        (value) => ref
            .watch(milestoneEngineProvider)
            .detect(value, now: DateTime.now().toUtc()),
      );
    });

final storyMediaPickerProvider = Provider<StoryMediaPicker>((ref) {
  return ImagePickerStoryMediaPicker();
});

final storyTemporaryFileStoreProvider = Provider<StoryTemporaryFileStore>((
  ref,
) {
  return PathProviderStoryTemporaryFileStore();
});

final storyShareServiceProvider = Provider<StoryShareService>((ref) {
  return const SharePlusStoryShareService();
});

final storyTemporaryCleanupProvider = FutureProvider<void>((ref) {
  return ref
      .watch(storyTemporaryFileStoreProvider)
      .cleanupStaleFiles(DateTime.now().toUtc());
});

final storyTemplateAccessPolicyProvider = Provider<StoryTemplateAccessPolicy>((
  ref,
) {
  return StoryTemplateAccessPolicy(ref.watch(entitlementServiceProvider));
});
