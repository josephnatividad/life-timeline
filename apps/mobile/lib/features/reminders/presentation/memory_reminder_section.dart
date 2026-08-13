import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_timeline/app/navigation/app_routes.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/reminders/application/reminder_providers.dart';
import 'package:life_timeline/features/reminders/domain/reminder.dart';
import 'package:life_timeline/features/reminders/presentation/reminders_page.dart';
import 'package:life_timeline/shared/domain/model/temporal_value.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

final class MemoryReminderSection extends ConsumerWidget {
  const MemoryReminderSection({required this.memory, super.key});

  final TimelineMemory memory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventId = memory.event.metadata.id;
    final reminders = ref.watch(eventRemindersProvider(eventId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSectionHeader(
          title: 'Reminder',
          supportingText:
              memory.event.temporalValue.precision ==
                  TemporalPrecision.exactDate
              ? 'A quiet nudge before this date.'
              : "This memory doesn't have an exact date yet. You can choose a separate reminder date.",
          action: AppButton(
            key: const Key('add-memory-reminder'),
            label: 'Add reminder',
            variant: AppButtonVariant.tertiary,
            onPressed: () => context.pushNamed(
              AppRoute.addReminder.name,
              queryParameters: {'memoryId': eventId},
            ),
          ),
        ),
        reminders.when(
          loading: () => const Padding(
            padding: EdgeInsets.only(top: AppSpacing.sm),
            child: AppLoadingState(label: 'Loading reminders'),
          ),
          error: (error, stackTrace) => const SizedBox.shrink(),
          data: (items) => Column(
            children: [
              for (final reminder in items)
                _CompactReminderRow(reminder: reminder),
            ],
          ),
        ),
      ],
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
        '${reminderLeadLabel(reminder.leadTime)} · ${reminder.status == ReminderStatus.scheduled ? 'Scheduled' : 'Inactive'}',
      ),
      trailing: const Text('Edit'),
      onTap: () => context.pushNamed(
        AppRoute.editReminder.name,
        pathParameters: {'reminderId': reminder.id},
      ),
    );
  }
}
