import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_timeline/app/navigation/app_routes.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/search/presentation/search_result_tile.dart';
import 'package:life_timeline/features/timeline/application/timeline_providers.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

final class MemorySearchPage extends ConsumerStatefulWidget {
  const MemorySearchPage({super.key});

  @override
  ConsumerState<MemorySearchPage> createState() => _MemorySearchPageState();
}

final class _MemorySearchPageState extends ConsumerState<MemorySearchPage> {
  final _controller = TextEditingController();
  Timer? _debounce;
  var _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final normalized = _query.trim();
    final results = normalized.isEmpty
        ? null
        : ref.watch(memorySearchProvider(normalized));
    return AppScaffold(
      appBar: AppBar(title: const Text('Search')),
      body: ScreenContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSearchField(
              key: const Key('memory-search-field'),
              controller: _controller,
              hintText: 'Title, person, place, type, or category',
              onChanged: _scheduleSearch,
              onSubmitted: _searchNow,
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(child: _results(context, results)),
          ],
        ),
      ),
    );
  }

  Widget _results(
    BuildContext context,
    AsyncValue<List<MemorySearchResult>>? results,
  ) {
    if (results == null) {
      return const AppEmptyState(
        title: 'Search your timeline',
        message: 'Look for a memory, related item, type, or category.',
        icon: AppIcons.search,
      );
    }
    return results.when(
      loading: () => const AppLoadingState(label: 'Searching your timeline'),
      error: (error, stackTrace) => const AppErrorState(
        title: 'Search unavailable',
        message: 'Local search could not be completed.',
      ),
      data: (values) {
        if (values.isEmpty) {
          return const AppEmptyState(
            title: 'Nothing found yet',
            message:
                'Your timeline may not know about this part of your life yet.',
            icon: AppIcons.search,
          );
        }
        return ListView.separated(
          itemCount: values.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final result = values[index];
            return SearchResultTile(
              result: result,
              onTap: () => context.pushNamed(
                AppRoute.memoryDetail.name,
                pathParameters: {'memoryId': result.memory.event.metadata.id},
              ),
            );
          },
        );
      },
    );
  }

  void _scheduleSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(AppMotion.standard, () {
      if (mounted) {
        setState(() => _query = value);
      }
    });
  }

  void _searchNow(String value) {
    _debounce?.cancel();
    setState(() => _query = value);
  }
}
