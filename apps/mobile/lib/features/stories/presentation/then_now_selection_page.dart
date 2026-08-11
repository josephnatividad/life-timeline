import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_timeline/app/navigation/app_routes.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/stories/application/story_providers.dart';
import 'package:life_timeline/features/timeline/application/timeline_providers.dart';
import 'package:life_timeline/shared/domain/formatting/temporal_label.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

final class ThenNowSelectionPage extends ConsumerStatefulWidget {
  const ThenNowSelectionPage({super.key});

  @override
  ConsumerState<ThenNowSelectionPage> createState() =>
      _ThenNowSelectionPageState();
}

final class _ThenNowSelectionPageState
    extends ConsumerState<ThenNowSelectionPage> {
  String? _firstId;
  String? _secondId;
  var _creating = false;

  @override
  Widget build(BuildContext context) {
    final memories = ref.watch(timelineMemoriesProvider);
    return AppScaffold(
      appBar: AppBar(title: const Text('Then & Now')),
      body: memories.when(
        loading: () => const Center(
          child: AppLoadingState(label: 'Loading confirmed memories'),
        ),
        error: (error, stackTrace) => const Center(
          child: AppErrorState(
            title: 'Memories unavailable',
            message: 'The pair could not be prepared on this device.',
          ),
        ),
        data: (value) => _content(value),
      ),
    );
  }

  Widget _content(List<TimelineMemory> memories) {
    if (memories.length < 2) {
      return const Center(
        child: AppEmptyState(
          title: 'Two memories are needed',
          message: 'Confirm another memory before creating a Then & Now Story.',
        ),
      );
    }
    return ScreenContainer(
      child: ListView(
        children: [
          Text(
            'Choose two moments deliberately',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'The first becomes Then. The second becomes Now. Nothing is paired automatically.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.xxl),
          const AppSectionHeader(title: 'Then'),
          const SizedBox(height: AppSpacing.sm),
          for (final memory in memories)
            _SelectionRow(
              key: Key('then-${memory.event.metadata.id}'),
              memory: memory,
              selected: _firstId == memory.event.metadata.id,
              enabled: _secondId != memory.event.metadata.id,
              onTap: () => setState(() => _firstId = memory.event.metadata.id),
            ),
          const SizedBox(height: AppSpacing.xxl),
          const AppSectionHeader(title: 'Now'),
          const SizedBox(height: AppSpacing.sm),
          for (final memory in memories)
            _SelectionRow(
              key: Key('now-${memory.event.metadata.id}'),
              memory: memory,
              selected: _secondId == memory.event.metadata.id,
              enabled: _firstId != memory.event.metadata.id,
              onTap: () => setState(() => _secondId = memory.event.metadata.id),
            ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            key: const Key('build-then-now'),
            label: 'Build Then & Now',
            icon: AppIcons.stories,
            loading: _creating,
            expanded: true,
            onPressed: _firstId == null || _secondId == null || _creating
                ? null
                : _create,
          ),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  Future<void> _create() async {
    setState(() => _creating = true);
    try {
      final factory = ref.read(storySourceFactoryProvider);
      final first = await factory.fromEvent(_firstId!);
      final second = await factory.fromEvent(_secondId!);
      if (!mounted) return;
      if (first == null || second == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('One selected memory is unavailable.')),
        );
        return;
      }
      final pair = factory.thenAndNow(first, second);
      await context.pushNamed(AppRoute.storyEditor.name, extra: pair);
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }
}

final class _SelectionRow extends StatelessWidget {
  const _SelectionRow({
    required this.memory,
    required this.selected,
    required this.enabled,
    required this.onTap,
    super.key,
  });

  final bool enabled;
  final TimelineMemory memory;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: enabled,
    selected: selected,
    label:
        '${memory.event.title}, ${TemporalLabel.format(memory.event.temporalValue)}',
    child: ListTile(
      contentPadding: EdgeInsets.zero,
      enabled: enabled,
      leading: AppIcon(icon: selected ? AppIcons.success : AppIcons.timeline),
      title: Text(memory.event.title),
      subtitle: Text(TemporalLabel.format(memory.event.temporalValue)),
      selected: selected,
      onTap: enabled ? onTap : null,
    ),
  );
}
