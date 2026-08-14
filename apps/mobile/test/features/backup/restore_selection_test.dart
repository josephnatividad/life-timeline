import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/backup/application/backup_providers.dart';
import 'package:life_timeline/features/backup/domain/backup_models.dart';
import 'package:life_timeline/features/backup/domain/backup_ports.dart';
import 'package:life_timeline/features/backup/presentation/restore_pages.dart';
import 'package:life_timeline/features/security/application/security_providers.dart';
import 'package:life_timeline/features/security/domain/security_models.dart';
import 'package:life_timeline/features/security/presentation/app_lock_gate.dart';

void main() {
  test(
    'restore selection failure becomes a visible controller error',
    () async {
      final container = ProviderContainer(
        overrides: [
          backupDestinationProvider.overrideWithValue(
            const _SelectionBackupDestination(shouldFail: true),
          ),
        ],
      );
      addTearDown(container.dispose);

      final selected = await container
          .read(restoreControllerProvider.notifier)
          .chooseAndInspect();

      expect(selected, isFalse);
      expect(
        container.read(restoreControllerProvider).errorCode,
        'backup_file_selection_failed',
      );
    },
  );

  test(
    'cancelled restore selection returns to idle without an error',
    () async {
      final container = ProviderContainer(
        overrides: [
          backupDestinationProvider.overrideWithValue(
            const _SelectionBackupDestination(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final selected = await container
          .read(restoreControllerProvider.notifier)
          .chooseAndInspect();

      expect(selected, isFalse);
      expect(
        container.read(restoreControllerProvider),
        isA<RestoreOperationState>()
            .having((state) => state.stage, 'stage', RestoreOperationStage.idle)
            .having((state) => state.errorCode, 'errorCode', isNull),
      );
    },
  );

  testWidgets(
    'backup picker failure is shown instead of leaving a silent page',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            backupDestinationProvider.overrideWithValue(
              const _SelectionBackupDestination(shouldFail: true),
            ),
          ],
          child: const MaterialApp(home: ChooseBackupPage()),
        ),
      );

      await tester.tap(find.widgetWithText(AppButton, 'Choose backup'));
      await tester.pump();
      expect(find.text('Inspecting backup locally'), findsOneWidget);
      await tester.pumpAndSettle();

      expect(find.text('This backup cannot be opened'), findsOneWidget);
      expect(
        find.textContaining('could not be copied for local inspection'),
        findsOneWidget,
      );
      expect(find.text('Choose another file'), findsOneWidget);
    },
  );

  testWidgets(
    'picker result survives privacy cover and immediate app-lock round trip',
    (tester) async {
      final selection = Completer<String?>();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            backupDestinationProvider.overrideWithValue(
              _CompletingBackupDestination(selection.future),
            ),
            securityControllerProvider.overrideWith(
              _ImmediateLockSecurityController.new,
            ),
          ],
          child: const MaterialApp(
            home: AppLockGate(child: ChooseBackupPage()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(AppButton, 'Choose backup'));
      await tester.pump();
      expect(find.text('Inspecting backup locally'), findsOneWidget);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      expect(find.bySemanticsLabel('Privacy screen'), findsOneWidget);
      selection.completeError(
        const BackupFailure('backup_file_selection_failed'),
      );
      await tester.pump();

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(find.text('Your timeline is locked'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('unlock-pin')), '1234');
      await tester.tap(find.byKey(const Key('unlock-with-pin')));
      await tester.pumpAndSettle();

      expect(find.text('This backup cannot be opened'), findsOneWidget);
      expect(find.text('Choose another file'), findsOneWidget);
    },
  );
}

final class _SelectionBackupDestination implements BackupFileGateway {
  const _SelectionBackupDestination({this.shouldFail = false});

  final bool shouldFail;

  @override
  Future<String?> chooseImportPath() async {
    await Future<void>.delayed(const Duration(milliseconds: 1));
    if (shouldFail) {
      throw const BackupFailure('backup_file_selection_failed');
    }
    return null;
  }

  @override
  Future<BackupDestinationReceipt?> saveExport({
    required String sourcePath,
    required String suggestedName,
    required String expectedSha256,
  }) {
    throw UnsupportedError('Not used by restore-selection tests.');
  }
}

final class _CompletingBackupDestination implements BackupFileGateway {
  const _CompletingBackupDestination(this.selection);

  final Future<String?> selection;

  @override
  Future<String?> chooseImportPath() => selection;

  @override
  Future<BackupDestinationReceipt?> saveExport({
    required String sourcePath,
    required String suggestedName,
    required String expectedSha256,
  }) {
    throw UnsupportedError('Not used by restore-selection tests.');
  }
}

final class _ImmediateLockSecurityController extends SecurityController {
  @override
  Future<SecuritySessionState> build() async => const SecuritySessionState(
    settings: SecuritySettings(
      appLockEnabled: true,
      autoLock: AutoLockPreference.immediately,
    ),
    locked: false,
    biometricAvailable: false,
  );

  @override
  Future<PinAttemptResult> unlockWithPin(String pin) async {
    if (pin != '1234') {
      return const PinAttemptResult(PinAttemptStatus.invalid);
    }
    state = AsyncData(state.requireValue.copyWith(locked: false));
    return const PinAttemptResult(PinAttemptStatus.success);
  }
}
