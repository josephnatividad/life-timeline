import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_timeline/app/navigation/app_router.dart';
import 'package:life_timeline/app/navigation/app_routes.dart';
import 'package:life_timeline/features/reminders/application/reminder_providers.dart';
import 'package:life_timeline/features/security/application/security_providers.dart';

/// Initializes local scheduling and releases notification navigation only
/// after the app-lock session is authenticated.
final class ReminderAppCoordinator extends ConsumerStatefulWidget {
  const ReminderAppCoordinator({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<ReminderAppCoordinator> createState() =>
      _ReminderAppCoordinatorState();
}

final class _ReminderAppCoordinatorState
    extends ConsumerState<ReminderAppCoordinator>
    with WidgetsBindingObserver {
  bool _handlingIntent = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_supportsLocalNotifications && state == AppLifecycleState.resumed) {
      ref.read(reminderBootstrapProvider.notifier).reconcileUnawaited();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_supportsLocalNotifications) return widget.child;
    ref.watch(reminderBootstrapProvider);
    final pending = ref.watch(pendingReminderIntentProvider);
    final security = ref.watch(securityControllerProvider).value;
    if (pending != null && security?.locked == false && !_handlingIntent) {
      _handlingIntent = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_openReminder(pending));
      });
    }
    return widget.child;
  }

  bool get _supportsLocalNotifications =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> _openReminder(String reminderId) async {
    try {
      // Let startup/resume reconciliation settle first so acknowledgement is
      // the final durable write for this notification interaction.
      try {
        await ref.read(reminderBootstrapProvider.future);
      } on Object {
        // Platform scheduling failure must not block local navigation.
      }
      try {
        await ref
            .read(reminderSchedulerProvider)
            .acknowledgeNotification(reminderId);
      } on Object {
        // The destination remains usable even if acknowledgement cannot be
        // persisted; a later reconciliation can still repair scheduling.
      }
      final reminder = await ref.read(reminderStoreProvider).byId(reminderId);
      if (!mounted) return;
      final router = ref.read(appRouterProvider);
      // Notification launches may start with no Navigator history. Establish a
      // safe Timeline destination so system Back never exits unexpectedly.
      router.goNamed(AppRoute.timeline.name);
      if (reminder?.linkedEventId case final eventId?) {
        unawaited(
          router.pushNamed(
            AppRoute.memoryDetail.name,
            pathParameters: {'memoryId': eventId},
          ),
        );
      } else {
        unawaited(router.pushNamed(AppRoute.reminders.name));
      }
      ref.read(pendingReminderIntentProvider.notifier).clear();
    } finally {
      _handlingIntent = false;
    }
  }
}
