import 'package:flutter/material.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/timeline/domain/temporal_display.dart';
import 'package:life_timeline/features/timeline/presentation/widgets/memory_summary.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

final class SearchResultTile extends StatelessWidget {
  const SearchResultTile({
    required this.result,
    required this.onTap,
    super.key,
  });

  final VoidCallback onTap;
  final MemorySearchResult result;

  @override
  Widget build(BuildContext context) {
    final memory = result.memory;
    return MemoryCard(
      title: memory.event.title,
      metadata: TemporalDisplay.label(memory.event.temporalValue),
      subtitle: _matchLabel(result.matchedField),
      badge: MemoryPrivacyBadge(
        classification: memory.event.metadata.privacyClassification,
      ),
      trailing: const AppIcon(icon: AppIcons.next),
      onTap: onTap,
      semanticLabel:
          '${memory.event.title}. ${TemporalDisplay.label(memory.event.temporalValue)}. ${_matchLabel(result.matchedField)}',
    );
  }

  String _matchLabel(MemoryMatchField field) => switch (field) {
    MemoryMatchField.title => 'Matched title',
    MemoryMatchField.description => 'Matched description',
    MemoryMatchField.eventType => 'Matched memory type',
    MemoryMatchField.entity => 'Matched related item',
    MemoryMatchField.category => 'Matched category',
    MemoryMatchField.mediaCaption => 'Matched photo caption',
  };
}
