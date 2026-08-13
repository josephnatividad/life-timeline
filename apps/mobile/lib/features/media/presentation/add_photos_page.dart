import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_timeline/app/navigation/app_routes.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/media/application/media_providers.dart';
import 'package:life_timeline/features/media/domain/memory_media_import.dart';
import 'package:life_timeline/features/timeline/application/timeline_providers.dart';
import 'package:life_timeline/features/timeline/domain/temporal_display.dart';

final class AddPhotosPage extends ConsumerStatefulWidget {
  const AddPhotosPage({this.memoryId, this.returnToDetail = false, super.key});

  final String? memoryId;
  final bool returnToDetail;

  @override
  ConsumerState<AddPhotosPage> createState() => _AddPhotosPageState();
}

final class _AddPhotosPageState extends ConsumerState<AddPhotosPage> {
  String? _selectedMemoryId;
  var _busy = false;
  String? _error;

  String? get _memoryId => widget.memoryId ?? _selectedMemoryId;

  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppBar(title: const Text('Add photos')),
    body: ScreenContainer(
      child: _memoryId == null ? _memoryChooser() : _sourceChooser(),
    ),
  );

  Widget _memoryChooser() {
    final memories = ref.watch(timelineMemoriesProvider);
    return memories.when(
      loading: () =>
          const Center(child: AppLoadingState(label: 'Loading memories')),
      error: (error, stackTrace) => const Center(
        child: AppErrorState(
          title: 'Memories unavailable',
          message: 'Your local timeline could not be opened.',
        ),
      ),
      data: (values) => values.isEmpty
          ? AppEmptyState(
              title: 'Add a memory first',
              message: 'Photos belong to a moment on your timeline.',
              actionLabel: 'Add memory',
              icon: AppIcons.timeline,
              onAction: () =>
                  context.pushReplacementNamed(AppRoute.addMemory.name),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              itemCount: values.length,
              separatorBuilder: (_, _) => const AppDivider(),
              itemBuilder: (context, index) {
                final memory = values[index];
                return ListTile(
                  key: ValueKey('photo-memory-${memory.event.metadata.id}'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(memory.event.title),
                  subtitle: Text(
                    TemporalDisplay.label(memory.event.temporalValue),
                  ),
                  trailing: const AppIcon(icon: AppIcons.next),
                  onTap: () => setState(
                    () => _selectedMemoryId = memory.event.metadata.id,
                  ),
                );
              },
            ),
    );
  }

  Widget _sourceChooser() {
    final media = ref.watch(memoryMediaProvider(_memoryId!));
    return ListView(
      children: [
        const AppSectionHeader(
          title: 'What did this moment look like?',
          supportingText:
              'Photos stay on this device. Adding one here does not scan it for text.',
        ),
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          key: const Key('add-photo-camera'),
          label: 'Take photo',
          icon: AppIcons.camera,
          expanded: true,
          loading: _busy,
          onPressed: _busy ? null : () => _add(MemoryMediaSource.camera),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          key: const Key('add-photo-library'),
          label: 'Choose from Photos',
          icon: AppIcons.gallery,
          expanded: true,
          loading: _busy,
          variant: AppButtonVariant.secondary,
          onPressed: _busy ? null : () => _add(MemoryMediaSource.photoLibrary),
        ),
        if (_error case final error?) ...[
          const SizedBox(height: AppSpacing.md),
          Semantics(
            liveRegion: true,
            child: Text(
              error,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xxl),
        media.when(
          loading: () => const AppLoadingState(label: 'Loading photos'),
          error: (error, stackTrace) => const SizedBox.shrink(),
          data: (values) => Text(
            values.isEmpty
                ? 'No photos added yet.'
                : '${values.length} ${values.length == 1 ? 'photo' : 'photos'} in this memory.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: 'Done',
          expanded: true,
          variant: AppButtonVariant.tertiary,
          onPressed: _finish,
        ),
      ],
    );
  }

  Future<void> _add(MemoryMediaSource source) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(importMemoryMediaProvider)(
        eventId: _memoryId!,
        source: source,
      );
    } on Object {
      if (mounted) {
        setState(() {
          _error =
              'This photo could not be prepared locally. Your memory was not changed.';
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _finish() {
    if (widget.returnToDetail || widget.memoryId == null) {
      context.pushReplacementNamed(
        AppRoute.memoryDetail.name,
        pathParameters: {'memoryId': _memoryId!},
      );
    } else {
      context.pop();
    }
  }
}
