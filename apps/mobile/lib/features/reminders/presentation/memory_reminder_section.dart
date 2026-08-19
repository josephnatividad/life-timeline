import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_timeline/app/navigation/app_routes.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/reminders/application/reminder_providers.dart';
import 'package:life_timeline/features/reminders/domain/reminder.dart';
import 'package:life_timeline/features/reminders/presentation/reminders_page.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

final class MemoryReminderSection extends ConsumerWidget {
  const MemoryReminderSection({required this.memory, super.key});

  final TimelineMemory memory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventId = memory.event.metadata.id;
    final count = ref.watch(eventReminderCountProvider(eventId)).value;
    if (count == null || count == 0) return const SizedBox.shrink();
    final reminders = ref.watch(eventReminderPreviewProvider(eventId));
    return reminders.when(
      loading: () => const AppLoadingState(label: 'Loading reminder preview'),
      error: (error, stackTrace) => const SizedBox.shrink(),
      data: (items) => Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xxxl),
        child: AppCollectionPreview(
          title: count == 1 ? 'Reminder' : 'Reminders',
          count: count,
          viewAllLabel: count > items.length ? 'View all reminders' : null,
          onViewAll: count > items.length
              ? () => context.pushNamed(
                  AppRoute.reminders.name,
                  queryParameters: {'memoryId': eventId},
                )
              : null,
          child: Column(
            children: [
              for (final reminder in items)
                _CompactReminderRow(reminder: reminder),
            ],
          ),
        ),
      ),
    );
  }
}

final class _CompactReminderRow extends StatelessWidget {
  const _CompactReminderRow({required this.reminder});

  final Reminder reminder;

  @override
  Widget build(BuildContext context) {
    final date = DateTime(
      reminder.reminderDate.year,
      reminder.reminderDate.month,
      reminder.reminderDate.day,
    );
    return ListTile(
      key: Key('memory-reminder-${reminder.id}'),
      contentPadding: EdgeInsets.zero,
      leading: const AppIcon(icon: AppIcons.reminder),
      title: Text(MaterialLocalizations.of(context).formatFullDate(date)),
      subtitle: Text(
        '${reminderLeadLabel(reminder.leadTime)} · ${reminderStatusLabel(reminder)}',
      ),
      trailing: const Text('Edit'),
      onTap: () => context.pushNamed(
        AppRoute.editReminder.name,
        pathParameters: {'reminderId': reminder.id},
      ),
    );
  }
}
