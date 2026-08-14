import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/backup/application/backup_providers.dart';
import 'package:life_timeline/features/backup/domain/automatic_backup_models.dart';
import 'package:life_timeline/features/backup/domain/backup_models.dart';
import 'package:life_timeline/features/backup/presentation/automatic_backup_page.dart';
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
    expect(find.text('Restore from Google Drive'), findsOneWidget);
  });

  testWidgets('automatic backup requires matching device-only password', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          automaticBackupControllerProvider.overrideWith(
            TestAutomaticBackupController.new,
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const AutomaticBackupPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('never uploaded'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('automatic-backup-password')),
      'correct horse',
    );
    await tester.enterText(
      find.byKey(const Key('automatic-backup-confirm-password')),
      'different horse',
    );
    final enable = find.byKey(const Key('enable-automatic-backup'));
    await tester.ensureVisible(enable);
    await tester.pumpAndSettle();
    await tester.tap(enable);
    await tester.pump();

    expect(find.text('The passwords do not match.'), findsOneWidget);
  });

  testWidgets('Drive authorization completion ignores a deactivated page', (
    tester,
  ) async {
    final authorization = Completer<BackupDestinationStatus>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          automaticBackupControllerProvider.overrideWith(
            () => PendingAuthorizationBackupController(authorization),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const AutomaticBackupPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Connect Google Drive'));
    await tester.pump();

    await tester.pumpWidget(
      MaterialApp(
        home: _CompleteAuthorizationDuringBuild(authorization: authorization),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('missing Drive OAuth configuration is explained', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          automaticBackupControllerProvider.overrideWith(
            MisconfiguredAutomaticBackupController.new,
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const AutomaticBackupPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Google Drive setup required'), findsOneWidget);
    await tester.tap(find.text('Connect Google Drive'));
    await tester.pump();

    expect(
      find.text('Google Drive backup is not configured for this app build.'),
      findsOneWidget,
    );
  });
}

final class _CompleteAuthorizationDuringBuild extends StatelessWidget {
  const _CompleteAuthorizationDuringBuild({required this.authorization});

  final Completer<BackupDestinationStatus> authorization;

  @override
  Widget build(BuildContext context) {
    if (!authorization.isCompleted) {
      authorization.complete(
        const BackupDestinationStatus(
          availability: BackupDestinationAvailability.needsAuthorization,
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

final class PendingAuthorizationBackupController
    extends AutomaticBackupController {
  PendingAuthorizationBackupController(this.authorization);

  final Completer<BackupDestinationStatus> authorization;

  @override
  Future<AutomaticBackupViewState> build() async =>
      const AutomaticBackupViewState(
        settings: AutomaticBackupSettings(),
        runState: AutomaticBackupRunState(),
        destinationStatus: BackupDestinationStatus(
          availability: BackupDestinationAvailability.needsAuthorization,
        ),
      );

  @override
  Future<BackupDestinationStatus> authorize() => authorization.future;
}

final class MisconfiguredAutomaticBackupController
    extends AutomaticBackupController {
  static const missingConfiguration = BackupDestinationStatus(
    availability: BackupDestinationAvailability.misconfigured,
    detailCode: 'drive_client_configuration_missing',
  );

  @override
  Future<AutomaticBackupViewState> build() async =>
      const AutomaticBackupViewState(
        settings: AutomaticBackupSettings(),
        runState: AutomaticBackupRunState(),
        destinationStatus: missingConfiguration,
      );

  @override
  Future<BackupDestinationStatus> authorize() async => missingConfiguration;
}

final class TestAutomaticBackupController extends AutomaticBackupController {
  @override
  Future<AutomaticBackupViewState> build() async =>
      const AutomaticBackupViewState(
        settings: AutomaticBackupSettings(),
        runState: AutomaticBackupRunState(),
        destinationStatus: BackupDestinationStatus(
          availability: BackupDestinationAvailability.ready,
        ),
      );
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
