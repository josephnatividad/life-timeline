import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_timeline/app/navigation/app_routes.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/timeline/application/memory_editor_draft.dart';
import 'package:life_timeline/features/timeline/application/timeline_providers.dart';
import 'package:life_timeline/features/timeline/presentation/widgets/memory_editor.dart';

final class AddMemoryPage extends StatelessWidget {
  const AddMemoryPage({super.key});

  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppBar(title: const Text('Add memory')),
    body: SingleChildScrollView(
      child: ScreenContainer(
        child: MemoryEditor(
          onSaved: (id) => context.pushReplacementNamed(
            AppRoute.memoryDetail.name,
            pathParameters: {'memoryId': id},
          ),
          onSavedAndAddPhoto: (id) => context.pushReplacementNamed(
            AppRoute.memoryPhotos.name,
            pathParameters: {'memoryId': id},
            queryParameters: const {'returnToDetail': 'true'},
          ),
        ),
      ),
    ),
  );
}

final class EditMemoryPage extends ConsumerWidget {
  const EditMemoryPage({required this.memoryId, super.key});

  final String memoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memory = ref.watch(memoryDetailProvider(memoryId));
    return AppScaffold(
      appBar: AppBar(title: const Text('Edit memory')),
      body: memory.when(
        loading: () =>
            const Center(child: AppLoadingState(label: 'Loading memory')),
        error: (error, stackTrace) => const Center(
          child: AppErrorState(
            title: 'Memory unavailable',
            message: 'This local memory could not be opened.',
          ),
        ),
        data: (value) => value == null
            ? const Center(
                child: AppErrorState(
                  title: 'Memory not found',
                  message: 'It may have been moved to Trash.',
                ),
              )
            : SingleChildScrollView(
                child: ScreenContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      MemoryEditor(
                        initialDraft: MemoryEditorDraft.fromMemory(value),
                        onSaved: (id) {
                          ref.invalidate(memoryDetailProvider(id));
                          context.pop();
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppButton(
                        key: const Key('edit-memory-add-photo'),
                        label: 'Add photo',
                        icon: AppIcons.image,
                        variant: AppButtonVariant.secondary,
                        onPressed: () => context.pushNamed(
                          AppRoute.memoryPhotos.name,
                          pathParameters: {'memoryId': memoryId},
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
