import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_timeline/app/navigation/app_routes.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/insights/application/explore_overview.dart';
import 'package:life_timeline/features/insights/application/insights_providers.dart';
import 'package:life_timeline/features/insights/domain/life_query_models.dart';
import 'package:life_timeline/features/insights/presentation/widgets/supporting_records_sheet.dart';
import 'package:life_timeline/shared/domain/formatting/temporal_label.dart';

final class ExploreFoundationPage extends ConsumerWidget {
  const ExploreFoundationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(exploreOverviewProvider);
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        actions: [
          AppIconButton(
            icon: AppIcons.intelligence,
            label: 'Ask My Life',
            onPressed: () => context.pushNamed(AppRoute.askMyLife.name),
          ),
        ],
      ),
      body: overview.when(
        loading: () => const Center(
          child: AppLoadingState(label: 'Reading your local timeline'),
        ),
        error: (error, stackTrace) => Center(
          child: AppErrorState(
            title: 'Explore unavailable',
            message: 'Your local timeline could not be summarized.',
            actionLabel: 'Try again',
            onAction: () => ref.invalidate(exploreOverviewProvider),
          ),
        ),
        data: (value) => _ExploreContent(overview: value),
      ),
    );
  }
}

final class _ExploreContent extends ConsumerWidget {
  const _ExploreContent({required this.overview});

  final ExploreOverview overview;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ScreenContainer(
    child: ListView(
      key: const Key('explore-content'),
      children: [
        Text(
          'Patterns in your life',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Deterministic insights from confirmed records on this device.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: 'Ask My Life',
          icon: AppIcons.intelligence,
          variant: AppButtonVariant.secondary,
          onPressed: () => context.pushNamed(AppRoute.askMyLife.name),
        ),
        const SizedBox(height: AppSpacing.xxxl),
        const AppSectionHeader(
          title: 'Insights',
          supportingText:
              'Eligible insights appear only when the supporting history is strong enough.',
        ),
        const SizedBox(height: AppSpacing.md),
        if (overview.insights.isEmpty)
          const _SectionEmpty(
            message:
                'Add and confirm more history to reveal durable patterns without guesswork.',
          )
        else ...[
          _PrimaryInsight(
            insight: overview.insights.first,
            onDismiss: () => _dismiss(ref, overview.insights.first),
            onView: () => _showRecords(
              context,
              overview.insights.first.result.supportingRecords,
            ),
          ),
          for (final insight in overview.insights.skip(1)) ...[
            const SizedBox(height: AppSpacing.sm),
            _CompactInsightRow(
              insight: insight,
              onDismiss: () => _dismiss(ref, insight),
              onTap: () =>
                  _showRecords(context, insight.result.supportingRecords),
            ),
          ],
        ],
        const SizedBox(height: AppSpacing.xxxl),
        const AppSectionHeader(
          title: 'Things',
          supportingText: 'A few confirmed things from across your timeline.',
        ),
        const SizedBox(height: AppSpacing.sm),
        if (overview.things.isEmpty)
          const _SectionEmpty(
            message: 'No categorized things are recorded yet.',
          )
        else
          for (final record in overview.things.take(6))
            _RecordRow(record: record),
        const SizedBox(height: AppSpacing.xxxl),
        const AppSectionHeader(
          title: 'Years',
          supportingText: 'Recent years with confirmed memories.',
        ),
        const SizedBox(height: AppSpacing.sm),
        if (overview.years.isEmpty)
          const _SectionEmpty(message: 'No year summaries are ready yet.')
        else
          for (final year in overview.years)
            _SummaryRow(
              summary: year,
              onTap: year.result == null
                  ? null
                  : () => _showRecords(context, year.result!.supportingRecords),
            ),
        const SizedBox(height: AppSpacing.xxxl),
        const AppSectionHeader(
          title: 'Places',
          supportingText: 'Places connected to confirmed history.',
        ),
        const SizedBox(height: AppSpacing.sm),
        if (overview.places.isEmpty)
          const _SectionEmpty(
            message: 'Travel and place history will appear here.',
          )
        else
          for (final place in overview.places.take(6))
            _RecordRow(record: place),
        const SizedBox(height: AppSpacing.xxxl),
        const AppSectionHeader(
          title: 'Categories',
          supportingText: 'Ask a focused question about a category.',
        ),
        const SizedBox(height: AppSpacing.sm),
        if (overview.categories.isEmpty)
          const _SectionEmpty(
            message: 'Categories appear as records are confirmed.',
          )
        else
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final category in overview.categories)
                AppChip(
                  label: '${category.label} · ${category.value}',
                  onSelected: (_) => context.pushNamed(
                    AppRoute.askMyLife.name,
                    extra: 'What ${category.label.toLowerCase()} have I owned?',
                  ),
                ),
            ],
          ),
        const SizedBox(height: AppSpacing.xxxl),
      ],
    ),
  );

  Future<void> _dismiss(WidgetRef ref, LifeInsight insight) async {
    await ref
        .read(insightEngineProvider)
        .dismiss(insight, DateTime.now().toUtc());
    ref
      ..invalidate(lifeInsightsProvider)
      ..invalidate(exploreOverviewProvider);
  }

  Future<void> _showRecords(
    BuildContext context,
    List<LifeSupportingRecord> records,
  ) {
    if (records.isEmpty) return Future.value();
    return AppBottomSheet.show<void>(
      context: context,
      builder: (sheetContext) => SupportingRecordsSheet(
        records: records,
        onOpenEvent: (eventId) {
          Navigator.of(sheetContext).pop();
          context.pushNamed(
            AppRoute.memoryDetail.name,
            pathParameters: {'memoryId': eventId},
          );
        },
      ),
    );
  }
}

final class _PrimaryInsight extends StatelessWidget {
  const _PrimaryInsight({
    required this.insight,
    required this.onDismiss,
    required this.onView,
  });

  final LifeInsight insight;
  final VoidCallback onDismiss;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final result = insight.result;
    return FadeSlideIn(
      child: IntelligenceCard(
        title: result.headline,
        supportingText: 'I noticed something',
        metric:
            result.metadata['durationLabel'] ??
            (result.numericValue == null ? null : '${result.numericValue}'),
        body: result.summary,
        actionLabel: result.supportingRecords.isEmpty
            ? null
            : 'Explore records',
        onAction: result.supportingRecords.isEmpty ? null : onView,
        dismissLabel: 'Dismiss insight',
        onDismiss: onDismiss,
      ),
    );
  }
}

final class _CompactInsightRow extends StatelessWidget {
  const _CompactInsightRow({
    required this.insight,
    required this.onDismiss,
    required this.onTap,
  });

  final LifeInsight insight;
  final VoidCallback onDismiss;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const AppSignatureIcon(
      kind: AppSignatureIconKind.lifeIntelligence,
    ),
    title: Text(insight.result.headline),
    subtitle: Text(insight.result.summary),
    trailing: AppIconButton(
      icon: AppIcons.close,
      label: 'Dismiss insight',
      onPressed: onDismiss,
    ),
    onTap: insight.result.supportingRecords.isEmpty ? null : onTap,
  );
}

final class _RecordRow extends StatelessWidget {
  const _RecordRow({required this.record});

  final LifeSupportingRecord record;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const AppIcon(icon: AppIcons.explore),
    title: Text(record.title),
    subtitle: Text(
      [
        ?record.temporalValue == null
            ? null
            : TemporalLabel.format(record.temporalValue!),
        ?record.typeLabel,
      ].join(' · '),
    ),
  );
}

final class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.summary, this.onTap});

  final VoidCallback? onTap;
  final ExploreSummary summary;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const TimelineNode(icon: AppIcons.time, label: 'Year summary'),
    title: Text(summary.label),
    subtitle: Text(summary.value),
    trailing: onTap == null ? null : const AppIcon(icon: AppIcons.next),
    onTap: onTap,
  );
}

final class _SectionEmpty extends StatelessWidget {
  const _SectionEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
    child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
  );
}
