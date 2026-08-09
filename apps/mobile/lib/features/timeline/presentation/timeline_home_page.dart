import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_timeline/app/navigation/app_routes.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/timeline/application/timeline_providers.dart';
import 'package:life_timeline/features/timeline/domain/temporal_display.dart';
import 'package:life_timeline/features/timeline/presentation/widgets/timeline_event_tile.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

final class TimelineHomePage extends ConsumerWidget {
  const TimelineHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memories = ref.watch(timelineMemoriesProvider);
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Timeline'),
        actions: [
          AppIconButton(
            icon: AppIcons.search,
            label: 'Search memories',
            onPressed: () => context.pushNamed(AppRoute.search.name),
          ),
          AppIconButton(
            icon: AppIcons.database,
            label: 'Archived memories',
            onPressed: () => context.pushNamed(AppRoute.archive.name),
          ),
        ],
      ),
      body: memories.when(
        loading: () => const Center(
          child: AppLoadingState(label: 'Loading your timeline'),
        ),
        error: (error, stackTrace) => Center(
          child: AppErrorState(
            title: 'Timeline unavailable',
            message: 'Your local timeline could not be opened.',
            actionLabel: 'Try again',
            onAction: () => ref.invalidate(timelineMemoriesProvider),
          ),
        ),
        data: (values) => values.isEmpty
            ? Center(
                child: AppEmptyState(
                  title: 'Your story starts here.',
                  message: 'Add a memory from any time in your life.',
                  actionLabel: 'Add memory',
                  icon: AppIcons.timeline,
                  onAction: () => context.pushNamed(AppRoute.addMemory.name),
                ),
              )
            : _TimelineList(memories: values),
      ),
    );
  }
}

final class _TimelineList extends StatelessWidget {
  const _TimelineList({required this.memories});

  final List<TimelineMemory> memories;

  @override
  Widget build(BuildContext context) {
    final rows = <_TimelineRow>[];
    String? currentSection;
    for (final memory in memories) {
      final section = TemporalDisplay.sectionLabel(memory.event.temporalValue);
      if (section != currentSection) {
        rows.add(_TimelineRow.header(section));
        currentSection = section;
      }
      rows.add(_TimelineRow.memory(memory));
    }

    return ListView.builder(
      key: const Key('timeline-list'),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        AppSpacing.xxxl,
      ),
      itemCount: rows.length,
      itemBuilder: (context, index) {
        final row = rows[index];
        if (row.header case final header?) {
          return Padding(
            padding: EdgeInsets.only(
              top: index == 0 ? AppSpacing.sm : AppSpacing.xl,
              bottom: AppSpacing.sm,
            ),
            child: TimelineSectionHeader(period: header),
          );
        }
        final memory = row.memory!;
        final nextIsHeader =
            index == rows.length - 1 || rows[index + 1].header != null;
        return FadeSlideIn(
          child: TimelineEventTile(
            memory: memory,
            isLast: nextIsHeader,
            onTap: () => context.pushNamed(
              AppRoute.memoryDetail.name,
              pathParameters: {'memoryId': memory.event.metadata.id},
            ),
          ),
        );
      },
    );
  }
}

final class _TimelineRow {
  const _TimelineRow._({this.header, this.memory});

  factory _TimelineRow.header(String value) => _TimelineRow._(header: value);

  factory _TimelineRow.memory(TimelineMemory value) =>
      _TimelineRow._(memory: value);

  final String? header;
  final TimelineMemory? memory;
}
