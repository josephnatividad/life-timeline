import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_timeline/app/navigation/app_routes.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/private_intelligence/application/intelligence_providers.dart';

final class MemoryInboxPage extends ConsumerWidget {
  const MemoryInboxPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final candidates = ref.watch(pendingCandidatesProvider);
    return AppScaffold(
      appBar: AppBar(title: const Text('Memory Inbox')),
      body: candidates.when(
        loading: () =>
            const Center(child: AppLoadingState(label: 'Loading Inbox')),
        error: (error, stack) => Center(
          child: AppErrorState(
            title: 'Inbox unavailable',
            message: 'Your local suggestions could not be opened.',
            actionLabel: 'Try again',
            onAction: () => ref.invalidate(pendingCandidatesProvider),
          ),
        ),
        data: (items) => items.isEmpty
            ? const Center(
                child: AppEmptyState(
                  title: 'Nothing waiting for review',
                  message: 'Private capture suggestions will appear here.',
                  icon: AppIcons.database,
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.xl),
                itemCount: items.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final candidate = items[index];
                  final confidence = candidate.overallConfidence;
                  return MemoryCard(
                    title: candidate.title,
                    metadata: _label(candidate.documentType.name),
                    subtitle: confidence == null
                        ? 'Review needed'
                        : confidence < 0.7
                        ? 'Some fields need a closer look'
                        : 'Ready for your review',
                    badge: PrivacyBadge(
                      level:
                          PrivacyBadgeLevel.values[candidate
                              .metadata
                              .privacyClassification
                              .index],
                    ),
                    trailing: const AppIcon(icon: AppIcons.next),
                    onTap: () => context.pushNamed(
                      AppRoute.candidateReview.name,
                      pathParameters: {'candidateId': candidate.metadata.id},
                    ),
                  );
                },
              ),
      ),
    );
  }
}

String _label(String value) => value
    .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
    .trim();
