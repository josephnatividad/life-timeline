import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/media/application/media_providers.dart';
import 'package:life_timeline/features/media/presentation/managed_memory_image.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

final class ReorderMemoryMediaPage extends ConsumerStatefulWidget {
  const ReorderMemoryMediaPage({required this.memoryId, super.key});

  final String memoryId;

  @override
  ConsumerState<ReorderMemoryMediaPage> createState() =>
      _ReorderMemoryMediaPageState();
}

final class _ReorderMemoryMediaPageState
    extends ConsumerState<ReorderMemoryMediaPage> {
  List<MemoryMedia>? _ordered;
  var _saving = false;

  @override
  Widget build(BuildContext context) {
    final media = ref.watch(memoryMediaProvider(widget.memoryId));
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Reorder photos'),
        actions: [
          TextButton(
            onPressed: _saving || _ordered == null ? null : _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: media.when(
        loading: () =>
            const Center(child: AppLoadingState(label: 'Loading photos')),
        error: (error, stackTrace) => const Center(
          child: AppErrorState(
            title: 'Photos unavailable',
            message: 'The order could not be loaded.',
          ),
        ),
        data: (values) {
          _ordered ??= List.of(values);
          return ReorderableListView.builder(
            padding: const EdgeInsets.all(AppSpacing.xl),
            itemCount: _ordered!.length,
            onReorderItem: (oldIndex, newIndex) {
              setState(() {
                final item = _ordered!.removeAt(oldIndex);
                _ordered!.insert(newIndex, item);
              });
            },
            itemBuilder: (context, index) {
              final item = _ordered![index];
              return ListTile(
                key: ValueKey(item.link.id),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.xs,
                ),
                leading: SizedBox.square(
                  dimension: AppSpacing.huge,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.smallControl),
                    child: ManagedMemoryImage(
                      media: item,
                      semanticLabel: item.link.caption ?? 'Memory photo',
                      cacheWidth: 128,
                    ),
                  ),
                ),
                title: Text(item.link.caption ?? 'Photo ${index + 1}'),
                subtitle: item.isHero ? const Text('Hero photo') : null,
                trailing: const AppIcon(icon: AppIcons.reorder),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await ref
        .read(memoryMediaRepositoryProvider)
        .reorder(
          eventId: widget.memoryId,
          orderedLinkIds: _ordered!.map((item) => item.link.id).toList(),
        );
    if (mounted) Navigator.of(context).pop();
  }
}
