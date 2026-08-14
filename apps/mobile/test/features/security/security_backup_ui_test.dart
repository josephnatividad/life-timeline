import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/backup/presentation/create_backup_pages.dart';
import 'package:life_timeline/features/backup/presentation/restore_pages.dart';
import 'package:life_timeline/features/security/application/security_providers.dart';
import 'package:life_timeline/features/security/domain/security_models.dart';
import 'package:life_timeline/features/security/presentation/app_lock_gate.dart';

void main() {
  testWidgets('locked app accepts PIN through the security abstraction', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          securityControllerProvider.overrideWith(
            TestLockedSecurityController.new,
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const AppLockGate(child: Text('Private timeline')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your timeline is locked'), findsOneWidget);
    expect(find.text('Private timeline'), findsNothing);
    await tester.enterText(find.byKey(const Key('unlock-pin')), '1234');
    await tester.tap(find.byKey(const Key('unlock-with-pin')));
    await tester.pumpAndSettle();

    expect(find.text('Private timeline'), findsOneWidget);
    expect(find.text('1234'), findsNothing);
  });

  testWidgets('backup setup explains recovery and validates confirmation', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light(), home: const CreateBackupPage()),
    );

    expect(
      find.textContaining('may be required if this device is lost'),
      findsOneWidget,
    );
    expect(find.textContaining('cannot recover it for you'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('backup-password')),
      'correct horse battery staple',
    );
    await tester.enterText(
      find.byKey(const Key('backup-password-confirmation')),
      'different recovery phrase',
    );
    await tester.tap(find.byKey(const Key('start-backup')));
    await tester.pump();

    expect(find.text('The recovery passwords do not match.'), findsOneWidget);
  });

  testWidgets('inactive app obscures private content for system snapshots', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          securityControllerProvider.overrideWith(
            TestUnlockedSecurityController.new,
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const AppLockGate(child: Text('Private timeline content')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Private timeline content'), findsOneWidget);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    // The opaque privacy cover prevents interaction while preserving the routed
    // subtree for pending platform activity results.
    expect(find.text('Private timeline content'), findsOneWidget);
    expect(find.text('Private timeline content').hitTestable(), findsNothing);
    expect(find.bySemanticsLabel('Privacy screen'), findsOneWidget);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(find.text('Private timeline content'), findsOneWidget);
  });

  testWidgets('fresh-install restore states original device is unnecessary', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.dark(), home: const RestoreEntryPage()),
    );

    expect(find.text('Restore an existing timeline'), findsOneWidget);
    expect(
      find.textContaining('The original device is not required'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('restore-entry-continue')), findsOneWidget);
  });
}

final class TestLockedSecurityController extends SecurityController {
  @override
  Future<SecuritySessionState> build() async => const SecuritySessionState(
    settings: SecuritySettings(appLockEnabled: true),
    locked: true,
    biometricAvailable: false,
  );

  @override
  Future<PinAttemptResult> unlockWithPin(String pin) async {
    if (pin != '1234') {
      return const PinAttemptResult(PinAttemptStatus.invalid);
    }
    final current = state.requireValue;
    state = AsyncData(current.copyWith(locked: false));
    return const PinAttemptResult(PinAttemptStatus.success);
  }
}

final class TestUnlockedSecurityController extends SecurityController {
  @override
  Future<SecuritySessionState> build() async => const SecuritySessionState(
    settings: SecuritySettings(),
    locked: false,
    biometricAvailable: false,
  );
}
