import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_timeline/app/navigation/app_routes.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/insights/application/explore_overview.dart';
import 'package:life_timeline/features/insights/application/insights_providers.dart';
import 'package:life_timeline/features/insights/domain/life_query_models.dart';
import 'package:life_timeline/features/insights/presentation/widgets/supporting_records_sheet.dart';

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
        const AppSectionHeader(title: 'For you'),
        const SizedBox(height: AppSpacing.md),
        if (overview.insights.isEmpty)
          const AppEmptyState(
            title: 'Your patterns are still taking shape',
            message: 'Confirmed history can reveal a useful pattern over time.',
            icon: AppIcons.intelligence,
            variant: AppEmptyStateVariant.compact,
          )
        else
          _PrimaryInsight(
            insight: overview.insights.first,
            onDismiss: () => _dismiss(ref, overview.insights.first),
            onView: () => _showRecords(
              context,
              overview.insights.first.result.supportingRecords,
            ),
          ),
        if (overview.insights.length > 1) ...[
          const SizedBox(height: AppSpacing.xxxl),
          AppCollectionPreview(
            title: 'Recent insights',
            count: overview.insights.length - 1,
            viewAllLabel: overview.insights.length > 3
                ? 'View all insights'
                : null,
            onViewAll: overview.insights.length > 3
                ? () => context.pushNamed(AppRoute.insights.name)
                : null,
            child: Column(
              children: [
                for (final insight in overview.insights.skip(1).take(2))
                  _CompactInsightRow(
                    insight: insight,
                    onDismiss: () => _dismiss(ref, insight),
                    onTap: () =>
                        _showRecords(context, insight.result.supportingRecords),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xxxl),
        AppSection(
          title: 'Browse your life',
          supportingText:
              'Move through confirmed history without leaving Explore.',
          child: Column(
            children: [
              if (overview.things.isNotEmpty)
                _BrowseRow(
                  title: 'Things',
                  value: '${overview.things.length} recent records',
                  icon: AppIcons.explore,
                  onTap: () => _showRecords(context, overview.things),
                ),
              if (overview.places.isNotEmpty)
                _BrowseRow(
                  title: 'Places',
                  value: '${overview.places.length} confirmed places',
                  icon: AppIcons.explore,
                  onTap: () => _showRecords(context, overview.places),
                ),
              if (overview.years.isNotEmpty)
                _BrowseRow(
                  title: 'Years',
                  value: '${overview.years.length} recent years',
                  icon: AppIcons.time,
                  onTap: () => _showRecords(context, [
                    for (final year in overview.years)
                      ...?year.result?.supportingRecords,
                  ]),
                ),
              if (overview.categories.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (final category in overview.categories)
                      AppChip(
                        label: '${category.label} · ${category.value}',
                        onSelected: (_) => context.pushNamed(
                          AppRoute.askMyLife.name,
                          extra:
                              'What ${category.label.toLowerCase()} have I owned?',
                        ),
                      ),
                  ],
                ),
              ],
              if (overview.things.isEmpty &&
                  overview.places.isEmpty &&
                  overview.years.isEmpty &&
                  overview.categories.isEmpty)
                const AppEmptyState(
                  title: 'Your browse paths will appear here',
                  message: 'Add confirmed memories to begin.',
                  icon: AppIcons.explore,
                  variant: AppEmptyStateVariant.compact,
                ),
            ],
          ),
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

final class _BrowseRow extends StatelessWidget {
  const _BrowseRow({
    required this.title,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final AppIconData icon;
  final VoidCallback onTap;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: AppIcon(icon: icon),
    title: Text(title),
    subtitle: Text(value),
    trailing: const AppIcon(icon: AppIcons.next),
    onTap: onTap,
  );
}

final class ExploreInsightsPage extends ConsumerWidget {
  const ExploreInsightsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insights = ref.watch(lifeInsightsProvider);
    return AppScaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: insights.when(
        loading: () => const Center(
          child: AppLoadingState(label: 'Reading local insights'),
        ),
        error: (error, stackTrace) => Center(
          child: AppErrorState(
            title: 'Insights unavailable',
            message: 'Your local timeline could not be summarized.',
            actionLabel: 'Try again',
            onAction: () => ref.invalidate(lifeInsightsProvider),
          ),
        ),
        data: (values) => values.isEmpty
            ? const Center(
                child: AppEmptyState(
                  title: 'No durable patterns yet',
                  message: 'Confirmed history can reveal patterns over time.',
                  icon: AppIcons.intelligence,
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.xl),
                itemCount: values.length,
                separatorBuilder: (context, index) => const AppDivider(),
                itemBuilder: (context, index) {
                  final insight = values[index];
                  return _CompactInsightRow(
                    insight: insight,
                    onDismiss: () async {
                      await ref
                          .read(insightEngineProvider)
                          .dismiss(insight, DateTime.now().toUtc());
                      ref
                        ..invalidate(lifeInsightsProvider)
                        ..invalidate(exploreOverviewProvider);
                    },
                    onTap: () => _openSupportingRecords(
                      context,
                      insight.result.supportingRecords,
                    ),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _openSupportingRecords(
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
