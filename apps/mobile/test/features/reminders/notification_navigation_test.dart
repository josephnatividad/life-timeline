import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:life_timeline/app/navigation/app_router.dart';
import 'package:life_timeline/app/navigation/app_routes.dart';
import 'package:life_timeline/design_system/theme/app_theme.dart';
import 'package:life_timeline/features/reminders/application/reminder_providers.dart';
import 'package:life_timeline/features/reminders/domain/reminder.dart';
import 'package:life_timeline/features/reminders/presentation/reminder_app_coordinator.dart';
import 'package:life_timeline/features/security/application/security_providers.dart';
import 'package:life_timeline/features/security/domain/security_models.dart';
import 'package:life_timeline/features/security/presentation/app_lock_gate.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';

import '../../helpers/reminder_test_services.dart';

void main() {
  setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.android);

  testWidgets('notification intent waits behind App Lock then opens memory', (
    tester,
  ) async {
    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appRouterProvider.overrideWithValue(router),
          securityControllerProvider.overrideWith(
            _LockedSecurityController.new,
          ),
          reminderStoreProvider.overrideWithValue(
            TestReminderRepository([_reminder()]),
          ),
          localNotificationServiceProvider.overrideWithValue(
            _LaunchNotificationService(),
          ),
          deviceTimeZoneServiceProvider.overrideWithValue(
            TestDeviceTimeZoneService(),
          ),
        ],
        child: _NotificationTestApp(router: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your timeline is locked'), findsOneWidget);
    expect(find.text('Private reminder destination'), findsNothing);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(ReminderAppCoordinator)),
    );
    await container
        .read(securityControllerProvider.notifier)
        .unlockWithPin('1234');
    await tester.pumpAndSettle();

    expect(find.text('Private reminder destination'), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('unlocked notification intent opens memory directly', (
    tester,
  ) async {
    final router = _router();
    final reminders = TestReminderRepository([_reminder()]);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appRouterProvider.overrideWithValue(router),
          securityControllerProvider.overrideWith(
            _UnlockedSecurityController.new,
          ),
          reminderStoreProvider.overrideWithValue(reminders),
          localNotificationServiceProvider.overrideWithValue(
            _LaunchNotificationService(),
          ),
          deviceTimeZoneServiceProvider.overrideWithValue(
            TestDeviceTimeZoneService(),
          ),
        ],
        child: _NotificationTestApp(router: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Private reminder destination'), findsOneWidget);
    expect((await reminders.byId('reminder-1'))?.dismissedAt, isNotNull);
    expect(
      (await reminders.byId('reminder-1'))?.status,
      ReminderStatus.scheduled,
    );
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Timeline'), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
  });
}

GoRouter _router() => GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      name: AppRoute.timeline.name,
      path: '/',
      builder: (context, state) => const Text('Timeline'),
    ),
    GoRoute(
      name: AppRoute.memoryDetail.name,
      path: AppRoute.memoryDetail.path,
      builder: (context, state) =>
          const Scaffold(body: Text('Private reminder destination')),
    ),
    GoRoute(
      name: AppRoute.reminders.name,
      path: AppRoute.reminders.path,
      builder: (context, state) => const Text('Reminders'),
    ),
  ],
);

final class _NotificationTestApp extends StatelessWidget {
  const _NotificationTestApp({required this.router});
  final GoRouter router;

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    routerConfig: router,
    theme: AppTheme.light(),
    builder: (context, child) => ReminderAppCoordinator(
      child: AppLockGate(child: child ?? const SizedBox.shrink()),
    ),
  );
}

final class _LaunchNotificationService extends TestLocalNotificationService {
  @override
  Future<String?> initialize({
    required void Function(String reminderId) onTap,
  }) async => 'reminder-1';
}

final class _LockedSecurityController extends SecurityController {
  @override
  Future<SecuritySessionState> build() async => const SecuritySessionState(
    settings: SecuritySettings(appLockEnabled: true),
    locked: true,
    biometricAvailable: false,
  );

  @override
  Future<PinAttemptResult> unlockWithPin(String pin) async {
    final current = state.requireValue;
    state = AsyncData(current.copyWith(locked: false));
    return const PinAttemptResult(PinAttemptStatus.success);
  }
}

final class _UnlockedSecurityController extends SecurityController {
  @override
  Future<SecuritySessionState> build() async => const SecuritySessionState(
    settings: SecuritySettings(),
    locked: false,
    biometricAvailable: false,
  );
}

Reminder _reminder() => Reminder(
  id: 'reminder-1',
  linkedEventId: 'event-1',
  title: 'Private record',
  targetDate: LocalDate(2031, 6, 12),
  reminderDate: LocalDate(2031, 3, 12),
  reminderTime: LocalTimeOfDay(9, 0),
  timeZoneId: 'UTC',
  scheduledAtUtc: DateTime.utc(2031, 3, 12, 9),
  type: ReminderType.expiry,
  leadTime: ReminderLeadTime.ninetyDays,
  status: ReminderStatus.scheduled,
  notificationId: 1,
  privacyClassification: PrivacyClassification.sensitive,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);
