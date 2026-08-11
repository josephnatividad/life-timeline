import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_timeline/features/private_intelligence/application/capture_intelligence_use_case.dart';
import 'package:life_timeline/features/private_intelligence/application/confirm_candidate_use_case.dart';
import 'package:life_timeline/features/private_intelligence/application/intelligence_ports.dart';
import 'package:life_timeline/features/private_intelligence/domain/document_intelligence.dart';
import 'package:life_timeline/features/private_intelligence/domain/intelligence_models.dart';
import 'package:life_timeline/features/private_intelligence/infrastructure/drift_intelligence_services.dart';
import 'package:life_timeline/features/private_intelligence/infrastructure/mobile_intelligence_adapters.dart';
import 'package:life_timeline/shared/application/entitlement_providers.dart';
import 'package:life_timeline/shared/database/app_database_provider.dart';
import 'package:life_timeline/shared/domain/model/memory_candidate.dart';

final complimentaryUsagePolicyProvider = Provider(
  (ref) => const ComplimentaryUsagePolicy(aiCaptureActions: 10),
);

final featureUsageRepositoryProvider = Provider<FeatureUsageRepository>(
  (ref) => DriftFeatureUsageRepository(ref.watch(appDatabaseProvider)),
);

final imageAcquisitionServiceProvider = Provider<ImageAcquisitionService>(
  (ref) => ImagePickerAcquisitionService(),
);
final imagePreparationServiceProvider = Provider<ImagePreparationService>(
  (ref) => const IsolateImagePreparationService(),
);
final candidateAttachmentStoreProvider = Provider<CandidateAttachmentStore>(
  (ref) => const AppPrivateCandidateAttachmentStore(),
);
final textRecognitionEngineProvider = Provider<TextRecognitionEngine>((ref) {
  final engine = MlKitTextRecognitionEngine();
  ref.onDispose(() => unawaited(engine.close()));
  return engine;
});

final captureIntelligenceUseCaseProvider = Provider<CaptureIntelligenceUseCase>(
  (ref) => CaptureIntelligenceUseCase(
    acquisition: ref.watch(imageAcquisitionServiceProvider),
    preparation: ref.watch(imagePreparationServiceProvider),
    attachments: ref.watch(candidateAttachmentStoreProvider),
    recognizer: ref.watch(textRecognitionEngineProvider),
    candidates: ref.watch(memoryCandidateRepositoryProvider),
    timeline: ref.watch(timelineRepositoryProvider),
    usage: ref.watch(featureUsageRepositoryProvider),
    entitlements: ref.watch(entitlementServiceProvider),
    usagePolicy: ref.watch(complimentaryUsagePolicyProvider),
  ),
);

final confirmCandidateUseCaseProvider = Provider<ConfirmCandidateUseCase>(
  (ref) => ConfirmCandidateUseCase(
    candidates: ref.watch(memoryCandidateRepositoryProvider),
    timeline: ref.watch(timelineRepositoryProvider),
  ),
);

final pendingCandidatesProvider = StreamProvider<List<MemoryCandidate>>(
  (ref) =>
      ref.watch(memoryCandidateRepositoryProvider).watchPendingCandidates(),
);

final candidateProvider = FutureProvider.family<MemoryCandidate?, String>(
  (ref, id) => ref.watch(memoryCandidateRepositoryProvider).candidateById(id),
);

final candidateReviewRepositoryProvider = Provider(
  (ref) => ref.watch(memoryCandidateRepositoryProvider),
);

final aiCaptureUsageProvider = FutureProvider<({int used, int allowance})>(
  (ref) async => (
    used: await ref
        .watch(featureUsageRepositoryProvider)
        .usageCount(ProFeature.aiCapture),
    allowance: ref.watch(complimentaryUsagePolicyProvider).aiCaptureActions,
  ),
);
