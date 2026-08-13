import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_timeline/app/navigation/app_routes.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/reminders/application/notification_ports.dart';
import 'package:life_timeline/features/reminders/application/reminder_providers.dart';
import 'package:life_timeline/features/reminders/domain/reminder.dart';

final class RemindersPage extends ConsumerWidget {
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = ref.watch(remindersProvider);
    return AppScaffold(
      appBar: AppBar(title: const Text('Reminders')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(AppRoute.addReminder.name),
        icon: const AppIcon(icon: AppIcons.reminder),
        label: const Text('Add reminder'),
      ),
      body: reminders.when(
        loading: () =>
            const Center(child: AppLoadingState(label: 'Loading reminders')),
        error: (error, stackTrace) => const Center(
          child: AppErrorState(
            title: 'Reminders unavailable',
            message: 'Your saved reminders could not be opened.',
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: ScreenContainer(
                child: AppEmptyState(
                  title: 'Nothing to remember yet',
                  message:
                      'Add a reminder from a dated memory, or create one here.',
                  icon: AppIcons.reminder,
                ),
              ),
            );
          }
          final upcoming = items
              .where((item) => item.status == ReminderStatus.scheduled)
              .toList(growable: false);
          final past = items
              .where((item) => item.status != ReminderStatus.scheduled)
              .toList(growable: false);
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            children: [
              const _NotificationPermissionSurface(),
              if (upcoming.isNotEmpty)
                _ReminderGroup(title: 'Upcoming', reminders: upcoming),
              if (past.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xl),
                _ReminderGroup(title: 'Past / inactive', reminders: past),
              ],
              const SizedBox(height: AppSpacing.xxl),
            ],
          );
        },
      ),
    );
  }
}

final class _NotificationPermissionSurface extends ConsumerWidget {
  const _NotificationPermissionSurface();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permission = ref.watch(notificationPermissionProvider);
    return permission.maybeWhen(
      data: (state) => state == NotificationPermissionState.granted
          ? const SizedBox.shrink()
          : ScreenContainer(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                AppSpacing.xl,
              ),
              child: IntelligenceCard(
                title: 'Notifications are off',
                body:
                    'Your reminders are still saved. Enable device notifications when you want local nudges.',
                actionLabel: 'Enable notifications',
                onAction: () async {
                  await ref.read(reminderSchedulerProvider).requestPermission();
                  ref.invalidate(notificationPermissionProvider);
                },
              ),
            ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

final class _ReminderGroup extends StatelessWidget {
  const _ReminderGroup({required this.title, required this.reminders});

  final List<Reminder> reminders;
  final String title;

  @override
  Widget build(BuildContext context) => ScreenContainer(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSectionHeader(title: title),
        const SizedBox(height: AppSpacing.sm),
        for (final reminder in reminders) _ReminderRow(reminder: reminder),
      ],
    ),
  );
}

final class _ReminderRow extends StatelessWidget {
  const _ReminderRow({required this.reminder});

  final Reminder reminder;

  @override
  Widget build(BuildContext context) {
    final date = DateTime(
      reminder.reminderDate.year,
      reminder.reminderDate.month,
      reminder.reminderDate.day,
    );
    final dateLabel = MaterialLocalizations.of(context).formatFullDate(date);
    final status = _statusLabel(reminder.status);
    return Semantics(
      button: true,
      label: '${reminder.title}, $dateLabel, $status',
      child: ListTile(
        key: Key('reminder-row-${reminder.id}'),
        contentPadding: EdgeInsets.zero,
        leading: const AppIcon(icon: AppIcons.reminder),
        title: Text(reminder.title),
        subtitle: Text(
          '$dateLabel · ${_leadLabel(reminder.leadTime)} · $status',
        ),
        trailing: const AppIcon(icon: AppIcons.next),
        onTap: () => context.pushNamed(
          AppRoute.editReminder.name,
          pathParameters: {'reminderId': reminder.id},
        ),
      ),
    );
  }
}

String reminderLeadLabel(ReminderLeadTime value) => _leadLabel(value);

String _leadLabel(ReminderLeadTime value) => switch (value) {
  ReminderLeadTime.onDay => 'On the day',
  ReminderLeadTime.oneDay => '1 day before',
  ReminderLeadTime.sevenDays => '1 week before',
  ReminderLeadTime.thirtyDays => '30 days before',
  ReminderLeadTime.ninetyDays => '90 days before',
  ReminderLeadTime.sixMonths => '6 months before',
  ReminderLeadTime.custom => 'Custom date',
};

String _statusLabel(ReminderStatus value) => switch (value) {
  ReminderStatus.scheduled => 'Scheduled',
  ReminderStatus.disabled => 'Notifications off',
  ReminderStatus.completed => 'Completed',
  ReminderStatus.missed => 'Missed',
  ReminderStatus.cancelled => 'Cancelled',
};
