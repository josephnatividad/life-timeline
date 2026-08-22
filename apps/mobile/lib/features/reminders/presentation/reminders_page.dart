import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_timeline/app/navigation/app_routes.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/reminders/application/notification_ports.dart';
import 'package:life_timeline/features/reminders/application/reminder_providers.dart';
import 'package:life_timeline/features/reminders/domain/reminder.dart';

final class RemindersPage extends ConsumerWidget {
  const RemindersPage({this.memoryId, super.key});

  final String? memoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = memoryId == null
        ? ref.watch(remindersProvider)
        : ref.watch(eventRemindersProvider(memoryId!));
    return AppScaffold(
      appBar: AppBar(
        title: Text(memoryId == null ? 'Reminders' : 'Memory reminders'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(
          AppRoute.addReminder.name,
          queryParameters: {'memoryId': ?memoryId},
        ),
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
            return Center(
              child: ScreenContainer(
                child: AppCompletedState(
                  title: 'Nothing needs your attention',
                  message: memoryId == null
                      ? 'Create a reminder when a future date matters.'
                      : 'This memory has no saved reminders.',
                  actionLabel: 'Add reminder',
                  onAction: () => context.pushNamed(
                    AppRoute.addReminder.name,
                    queryParameters: {'memoryId': ?memoryId},
                  ),
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
          return CustomScrollView(
            key: const Key('reminders-scroll'),
            slivers: [
              const SliverPadding(
                padding: EdgeInsets.only(top: AppSpacing.lg),
                sliver: SliverToBoxAdapter(
                  child: _NotificationPermissionSurface(),
                ),
              ),
              if (upcoming.isNotEmpty)
                ..._reminderGroupSlivers('Upcoming', upcoming),
              if (past.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xl),
                ),
                ..._reminderGroupSlivers('Past / inactive', past),
              ],
              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.xxxl),
              ),
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
              child: AppPermissionRequiredState(
                title: 'Notifications are off',
                message:
                    'Your reminders are still saved. Enable device notifications when you want local nudges.',
                actionLabel: 'Enable notifications',
                variant: AppEmptyStateVariant.section,
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

List<Widget> _reminderGroupSlivers(String title, List<Reminder> reminders) => [
  SliverPadding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
    sliver: SliverToBoxAdapter(child: AppSectionHeader(title: title)),
  ),
  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
  SliverPadding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
    sliver: SliverList.builder(
      itemCount: reminders.length,
      itemBuilder: (context, index) => _ReminderRow(reminder: reminders[index]),
    ),
  ),
];

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
    final status = reminderStatusLabel(reminder);
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

String reminderStatusLabel(Reminder reminder) => switch (reminder.status) {
  ReminderStatus.completed => 'Completed',
  ReminderStatus.cancelled => 'Cancelled',
  ReminderStatus.disabled => 'Notifications off',
  ReminderStatus.scheduled ||
  ReminderStatus.missed when reminder.dismissedAt != null => 'Opened',
  ReminderStatus.scheduled => 'Scheduled',
  ReminderStatus.missed => 'Missed',
};
