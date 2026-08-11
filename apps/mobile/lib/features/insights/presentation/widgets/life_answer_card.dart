import 'package:flutter/material.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/insights/domain/life_query_models.dart';

final class LifeAnswerCard extends StatelessWidget {
  const LifeAnswerCard({required this.result, this.onViewRecords, super.key});

  final VoidCallback? onViewRecords;
  final LifeQueryResult result;

  @override
  Widget build(BuildContext context) {
    final metric = _metric(result);
    return Semantics(
      container: true,
      liveRegion: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IntelligenceCard(
            title: result.headline,
            supportingText: switch (result.status) {
              LifeQueryStatus.answered => 'From your confirmed timeline',
              LifeQueryStatus.insufficientData => 'More history needed',
              LifeQueryStatus.unsupported => 'Supported questions are bounded',
            },
            metric: metric,
            body: result.summary,
            actionLabel: result.supportingRecords.isEmpty
                ? null
                : 'View ${result.supportingRecords.length} '
                      '${result.supportingRecords.length == 1 ? 'record' : 'records'}',
            onAction: result.supportingRecords.isEmpty ? null : onViewRecords,
          ),
          if (result.answerType == LifeQueryAnswerType.yearSummary) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final entry in _yearDetails(result))
                  AppBadge(label: entry),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String? _metric(LifeQueryResult result) {
    final duration = result.metadata['durationLabel'];
    if (duration != null) return duration;
    final value = result.numericValue;
    if (value == null || result.answerType == LifeQueryAnswerType.yearSummary) {
      return null;
    }
    final unit = result.metadata['unit'];
    return unit == null ? '$value' : '$value $unit';
  }

  List<String> _yearDetails(LifeQueryResult result) {
    final values = <String>[];
    void add(String key, String label) {
      final count = int.tryParse(result.metadata[key] ?? '') ?? 0;
      if (count > 0) values.add('$count $label');
    }

    add('trips', 'trips');
    add('purchases', 'purchases');
    add('careerMilestones', 'career milestones');
    add('documentMilestones', 'document milestones');
    return values;
  }
}
