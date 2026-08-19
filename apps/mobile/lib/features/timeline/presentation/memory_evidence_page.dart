import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_timeline/app/navigation/app_routes.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/timeline/application/timeline_providers.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';
import 'package:life_timeline/shared/domain/repositories/timeline_repository.dart';

final class MemoryEvidencePreview extends ConsumerWidget {
  const MemoryEvidencePreview({required this.memoryId, super.key});

  final String memoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final evidence = ref.watch(memoryEvidencePreviewProvider(memoryId));
    return evidence.when(
      loading: () => const AppLoadingState(label: 'Loading evidence preview'),
      error: (error, stackTrace) => const SizedBox.shrink(),
      data: (value) {
        if (value.totalCount == 0) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xxxl),
          child: AppCollectionPreview(
            title: 'Evidence',
            count: value.totalCount,
            viewAllLabel: 'View all evidence',
            onViewAll: () => context.pushNamed(
              AppRoute.memoryEvidence.name,
              pathParameters: {'memoryId': memoryId},
            ),
            child: Column(
              children: [
                for (final item in value.items) MemoryEvidenceRow(item: item),
              ],
            ),
          ),
        );
      },
    );
  }
}

final class MemoryEvidencePage extends ConsumerWidget {
  const MemoryEvidencePage({required this.memoryId, super.key});

  final String memoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final evidence = ref.watch(memoryEvidenceProvider(memoryId));
    return AppScaffold(
      appBar: AppBar(title: const Text('Evidence')),
      body: evidence.when(
        loading: () =>
            const Center(child: AppLoadingState(label: 'Loading evidence')),
        error: (error, stackTrace) => Center(
          child: AppErrorState(
            title: 'Evidence unavailable',
            message: 'Supporting records could not be opened.',
            actionLabel: 'Try again',
            onAction: () => ref.invalidate(memoryEvidenceProvider(memoryId)),
          ),
        ),
        data: (value) => value.items.isEmpty
            ? const Center(
                child: ScreenContainer(
                  child: AppEmptyState(
                    title: 'No evidence attached',
                    message: 'Supporting documents will appear here.',
                    icon: AppIcons.database,
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.lg,
                ),
                itemCount: value.items.length,
                itemBuilder: (context, index) => MemoryEvidenceRow(
                  item: value.items[index],
                  showDivider: index < value.items.length - 1,
                ),
              ),
      ),
    );
  }
}

final class MemoryEvidenceRow extends StatelessWidget {
  const MemoryEvidenceRow({
    required this.item,
    this.showDivider = false,
    super.key,
  });

  final MemoryEvidenceItem item;
  final bool showDivider;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const AppIcon(icon: AppIcons.database),
        title: Text(item.evidence.title),
        subtitle: Text(
          '${evidenceTypeLabel(item.evidence.evidenceType)} · '
          '${item.attachmentCount} '
          '${item.attachmentCount == 1 ? 'attachment' : 'attachments'}',
        ),
      ),
      if (showDivider) const AppDivider(),
    ],
  );
}

String evidenceTypeLabel(EvidenceType value) => switch (value) {
  EvidenceType.receipt => 'Receipt',
  EvidenceType.warranty => 'Warranty',
  EvidenceType.certificate => 'Certificate',
  EvidenceType.ticket => 'Ticket',
  EvidenceType.officialDocument => 'Official document',
  EvidenceType.other => 'Other evidence',
};
