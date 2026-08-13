import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/reminders/application/notification_ports.dart';
import 'package:life_timeline/features/reminders/application/reminder_policy.dart';
import 'package:life_timeline/features/reminders/application/reminder_providers.dart';
import 'package:life_timeline/features/reminders/domain/reminder.dart';
import 'package:life_timeline/features/reminders/presentation/reminders_page.dart';
import 'package:life_timeline/features/timeline/application/timeline_providers.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';
import 'package:life_timeline/shared/domain/model/timeline_models.dart';

final class ReminderEditorPage extends ConsumerWidget {
  const ReminderEditorPage({this.reminderId, this.memoryId, super.key});

  final String? memoryId;
  final String? reminderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (reminderId case final id?) {
      return ref
          .watch(reminderProvider(id))
          .when(
            loading: () => const AppScaffold(
              body: Center(child: AppLoadingState(label: 'Loading reminder')),
            ),
            error: (error, stackTrace) => const AppScaffold(
              body: Center(
                child: AppErrorState(
                  title: 'Reminder unavailable',
                  message: 'This local reminder could not be opened.',
                ),
              ),
            ),
            data: (reminder) => reminder == null
                ? const AppScaffold(
                    body: Center(
                      child: AppErrorState(
                        title: 'Reminder not found',
                        message: 'It may already have been deleted.',
                      ),
                    ),
                  )
                : _ReminderForm(existing: reminder),
          );
    }
    if (memoryId case final id?) {
      return ref
          .watch(memoryDetailProvider(id))
          .when(
            loading: () => const AppScaffold(
              body: Center(child: AppLoadingState(label: 'Preparing reminder')),
            ),
            error: (error, stackTrace) => const AppScaffold(
              body: Center(
                child: AppErrorState(
                  title: 'Memory unavailable',
                  message:
                      'A reminder can be added after the memory is opened.',
                ),
              ),
            ),
            data: (memory) => _ReminderForm(memory: memory),
          );
    }
    return const _ReminderForm();
  }
}

final class _ReminderForm extends ConsumerStatefulWidget {
  const _ReminderForm({this.existing, this.memory});

  final Reminder? existing;
  final TimelineMemory? memory;

  @override
  ConsumerState<_ReminderForm> createState() => _ReminderFormState();
}

final class _ReminderFormState extends ConsumerState<_ReminderForm> {
  late final TextEditingController _title;
  late final TextEditingController _note;
  late LocalDate _target;
  late LocalDate _reminderDate;
  late LocalTimeOfDay _time;
  late ReminderType _type;
  late ReminderLeadTime _lead;
  late bool _enabled;
  bool _saving = false;
  bool _memoryDateIsExact = true;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    final now = DateTime.now();
    LocalDate target;
    if (existing != null) {
      target = existing.targetDate;
    } else if (widget.memory != null) {
      try {
        target = ReminderPolicy.exactDate(widget.memory!.event.temporalValue);
      } on ReminderDateUnavailable {
        _memoryDateIsExact = false;
        target = LocalDate.fromDateTime(now.add(const Duration(days: 30)));
      }
    } else {
      target = LocalDate.fromDateTime(now.add(const Duration(days: 30)));
    }
    _type = existing?.type ?? _typeForMemory(widget.memory);
    if (existing == null && _type == ReminderType.anniversary) {
      target = ReminderPolicy.nextAnniversary(
        target,
        LocalDate.fromDateTime(now),
      );
    }
    _lead = existing?.leadTime ?? ReminderPolicy.presets(_type).first;
    _target = target;
    _reminderDate =
        existing?.reminderDate ?? ReminderPolicy.dateFor(target, _lead);
    _time = existing?.reminderTime ?? LocalTimeOfDay.defaultReminderTime;
    _enabled = existing?.status == ReminderStatus.scheduled || existing == null;
    _title = TextEditingController(
      text: existing?.title ?? widget.memory?.event.title ?? '',
    );
    _note = TextEditingController(text: existing?.note ?? '');
  }

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppBar(
      title: Text(widget.existing == null ? 'Add reminder' : 'Edit reminder'),
    ),
    body: SingleChildScrollView(
      child: ScreenContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Your timeline quietly remembers for you.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (!_memoryDateIsExact) ...[
              const SizedBox(height: AppSpacing.lg),
              const IntelligenceCard(
                title: 'Choose an exact reminder date',
                body:
                    "This memory doesn't have an exact date yet. The reminder date stays separate from its historical date.",
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            AppTextField(
              key: const Key('reminder-title'),
              label: 'Reminder title',
              controller: _title,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              key: const Key('reminder-note'),
              label: 'Private note (optional)',
              controller: _note,
              maxLines: 3,
              helperText: 'Notes are never shown in notification content.',
            ),
            const SizedBox(height: AppSpacing.xl),
            AppSectionHeader(
              title: 'Target date',
              supportingText:
                  '${_formatDate(context, _target)} · The date this reminder is about.',
              action: AppButton(
                label: 'Change',
                variant: AppButtonVariant.tertiary,
                onPressed: () => _pickTargetDate(context),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const AppSectionHeader(title: 'Remind me'),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final preset in ReminderPolicy.presets(_type))
                  AppChip(
                    key: Key('reminder-preset-${preset.name}'),
                    label: reminderLeadLabel(preset),
                    selected: _lead == preset,
                    onSelected: (_) => _selectPreset(preset),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const AppIcon(icon: AppIcons.timeline),
              title: const Text('Reminder date'),
              subtitle: Text(
                '${_formatDate(context, _reminderDate)} · When your device will notify you.',
              ),
              trailing: const AppIcon(icon: AppIcons.next),
              onTap: () => _pickReminderDate(context),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const AppIcon(icon: AppIcons.time),
              title: const Text('Local time'),
              subtitle: Text(
                MaterialLocalizations.of(context).formatTimeOfDay(
                  TimeOfDay(hour: _time.hour, minute: _time.minute),
                ),
              ),
              trailing: const AppIcon(icon: AppIcons.next),
              onTap: () => _pickTime(context),
            ),
            SwitchListTile.adaptive(
              key: const Key('reminder-enabled'),
              contentPadding: EdgeInsets.zero,
              title: const Text('Reminder enabled'),
              subtitle: const Text(
                'The reminder stays saved if notifications are turned off.',
              ),
              value: _enabled,
              onChanged: (value) => setState(() => _enabled = value),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              key: const Key('save-reminder'),
              label: widget.existing == null ? 'Save reminder' : 'Save changes',
              icon: AppIcons.reminder,
              expanded: true,
              loading: _saving,
              onPressed: _saving ? null : _save,
            ),
            if (widget.existing != null) ...[
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                key: const Key('delete-reminder'),
                label: 'Delete reminder',
                variant: AppButtonVariant.tertiary,
                expanded: true,
                onPressed: _delete,
              ),
            ],
          ],
        ),
      ),
    ),
  );

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a title for this reminder.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final repository = ref.read(reminderStoreProvider);
      final timeZones = ref.read(deviceTimeZoneServiceProvider);
      final now = DateTime.now().toUtc();
      final zone = await timeZones.currentTimeZoneId();
      final reminder = Reminder(
        id: widget.existing?.id ?? 'reminder-${now.microsecondsSinceEpoch}',
        linkedEventId:
            widget.existing?.linkedEventId ?? widget.memory?.event.metadata.id,
        linkedEntityId:
            widget.existing?.linkedEntityId ??
            widget.memory?.relatedEntity?.metadata.id,
        sourceEvidenceId: widget.existing?.sourceEvidenceId,
        title: title,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
        targetDate: _target,
        reminderDate: _reminderDate,
        reminderTime: _time,
        timeZoneId: zone,
        scheduledAtUtc: timeZones.scheduledUtc(
          date: _reminderDate,
          time: _time,
          timeZoneId: zone,
        ),
        type: _type,
        leadTime: _lead,
        status: _enabled ? ReminderStatus.scheduled : ReminderStatus.disabled,
        notificationId:
            widget.existing?.notificationId ??
            await repository.nextNotificationId(),
        privacyClassification:
            widget.existing?.privacyClassification ??
            widget.memory?.event.metadata.privacyClassification ??
            PrivacyClassification.personal,
        createdAt: widget.existing?.createdAt ?? now,
        updatedAt: now,
      );
      final result = await ref.read(reminderSchedulerProvider).save(reminder);
      final permission = result.notificationPermission;
      if (!mounted) return;
      final confirmation = _saveConfirmation(
        context,
        result.reminder,
        now: DateTime.now().toUtc(),
      );
      final messenger = ScaffoldMessenger.of(context);
      ref.invalidate(reminderProvider(result.reminder.id));
      context.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            !_enabled
                ? '$confirmation This reminder is disabled.'
                : permission == NotificationPermissionState.granted
                ? confirmation
                : '$confirmation Notifications are currently turned off.',
          ),
          action: _enabled && permission != NotificationPermissionState.granted
              ? SnackBarAction(
                  label: 'Enable notifications',
                  onPressed: () async {
                    await ref
                        .read(reminderSchedulerProvider)
                        .requestPermission();
                    ref.invalidate(notificationPermissionProvider);
                  },
                )
              : null,
        ),
      );
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('The reminder could not be saved.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final reminder = widget.existing;
    if (reminder == null) return;
    await ref.read(reminderSchedulerProvider).delete(reminder);
    if (mounted) context.pop();
  }

  void _selectPreset(ReminderLeadTime value) {
    setState(() {
      _lead = value;
      if (value != ReminderLeadTime.custom) {
        _reminderDate = ReminderPolicy.dateFor(_target, value);
      }
    });
    if (value == ReminderLeadTime.custom) _pickReminderDate(context);
  }

  Future<void> _pickTargetDate(BuildContext context) async {
    final value = await showDatePicker(
      context: context,
      initialDate: _target.asUtcDate.toLocal(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );
    if (value == null || !mounted) return;
    setState(() {
      _target = LocalDate.fromDateTime(value);
      if (_lead != ReminderLeadTime.custom) {
        _reminderDate = ReminderPolicy.dateFor(_target, _lead);
      }
    });
  }

  Future<void> _pickReminderDate(BuildContext context) async {
    final value = await showDatePicker(
      context: context,
      initialDate: _reminderDate.asUtcDate.toLocal(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );
    if (value == null || !mounted) return;
    setState(() {
      _reminderDate = LocalDate.fromDateTime(value);
      _lead = ReminderLeadTime.custom;
    });
  }

  Future<void> _pickTime(BuildContext context) async {
    final value = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _time.hour, minute: _time.minute),
    );
    if (value != null && mounted) {
      setState(() => _time = LocalTimeOfDay(value.hour, value.minute));
    }
  }

  static ReminderType _typeForMemory(TimelineMemory? memory) {
    final eventType = memory?.event.eventType?.toLowerCase() ?? '';
    if (eventType.contains('warranty')) return ReminderType.warranty;
    if (eventType.contains('anniversary')) return ReminderType.anniversary;
    if (eventType.contains('renew')) return ReminderType.renewal;
    if (eventType.contains('expir') || eventType.contains('document')) {
      return ReminderType.expiry;
    }
    return ReminderType.custom;
  }

  static String _formatDate(BuildContext context, LocalDate value) =>
      MaterialLocalizations.of(
        context,
      ).formatFullDate(DateTime(value.year, value.month, value.day));

  static String _saveConfirmation(
    BuildContext context,
    Reminder reminder, {
    required DateTime now,
  }) {
    final scheduledAt = reminder.scheduledAtUtc.toLocal();
    final localizations = MaterialLocalizations.of(context);
    final date = localizations.formatMediumDate(scheduledAt);
    final time = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(scheduledAt),
    );
    final difference = reminder.scheduledAtUtc.difference(now.toUtc());
    if (!difference.isNegative && difference > Duration.zero) {
      final totalMinutes = (difference.inSeconds / 60).ceil();
      final hours = totalMinutes ~/ 60;
      final minutes = totalMinutes.remainder(60);
      return 'Reminder saved for $date at $time — '
          '${_quantity(hours, 'hour')} and ${_quantity(minutes, 'minute')} '
          'from now.';
    }
    return 'Reminder saved for $date at $time. '
        'The selected time has already passed.';
  }

  static String _quantity(int value, String unit) =>
      '$value $unit${value == 1 ? '' : 's'}';
}
