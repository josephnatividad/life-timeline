import 'package:flutter/material.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/insights/domain/life_query_models.dart';
import 'package:life_timeline/shared/domain/formatting/temporal_label.dart';

final class SupportingRecordsSheet extends StatelessWidget {
  const SupportingRecordsSheet({
    required this.records,
    this.onOpenEvent,
    super.key,
  });

  final ValueChanged<String>? onOpenEvent;
  final List<LifeSupportingRecord> records;

  @override
  Widget build(BuildContext context) => AppBottomSheet(
    title: 'Supporting records',
    description:
        'These confirmed local records produced the answer. Dates retain their recorded precision.',
    child: ListView.separated(
      shrinkWrap: true,
      itemCount: records.length,
      separatorBuilder: (_, _) => const AppDivider(),
      itemBuilder: (context, index) {
        final record = records[index];
        final canOpen =
            record.recordType == LifeSupportingRecordType.event &&
            onOpenEvent != null;
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: AppIcon(
            icon: record.recordType == LifeSupportingRecordType.event
                ? AppIcons.timeline
                : AppIcons.explore,
          ),
          title: Text(record.title),
          subtitle: Text(
            [
              ?record.temporalValue == null
                  ? null
                  : TemporalLabel.format(record.temporalValue!),
              ?record.typeLabel,
              ?record.context,
            ].join(' · '),
          ),
          trailing: canOpen ? const AppIcon(icon: AppIcons.next) : null,
          onTap: canOpen ? () => onOpenEvent!(record.id) : null,
        );
      },
    ),
  );
}
