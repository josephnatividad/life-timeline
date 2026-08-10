import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_timeline/app/navigation/app_routes.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/backup/application/backup_providers.dart';
import 'package:life_timeline/features/backup/domain/backup_models.dart';

final class CreateBackupPage extends ConsumerStatefulWidget {
  const CreateBackupPage({super.key});

  @override
  ConsumerState<CreateBackupPage> createState() => _CreateBackupPageState();
}

final class _CreateBackupPageState extends ConsumerState<CreateBackupPage> {
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppBar(title: const Text('Create backup')),
    body: SingleChildScrollView(
      child: ScreenContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppSectionHeader(
              title: 'Protect this backup',
              supportingText:
                  'Choose a memorable recovery password. A longer phrase is usually easier to remember and harder to guess.',
            ),
            const SizedBox(height: AppSpacing.md),
            const IntelligenceCard(
              title: 'Recovery matters',
              body:
                  'This password protects your backup and may be required if this device is lost. We cannot recover it for you.',
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              key: const Key('backup-password'),
              controller: _password,
              label: 'Recovery password',
              obscureText: true,
              autofillHints: const [AutofillHints.newPassword],
              helperText:
                  'Use at least 8 characters; a multi-word phrase is encouraged.',
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              key: const Key('backup-password-confirmation'),
              controller: _confirmation,
              label: 'Confirm recovery password',
              obscureText: true,
              autofillHints: const [AutofillHints.newPassword],
              errorText: _error,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              key: const Key('start-backup'),
              label: 'Choose destination and create backup',
              icon: AppIcons.database,
              expanded: true,
              onPressed: _start,
            ),
          ],
        ),
      ),
    ),
  );

  void _start() {
    final password = _password.text;
    if (password.length < 8) {
      setState(() => _error = 'Use at least 8 characters.');
      return;
    }
    if (password != _confirmation.text) {
      setState(() => _error = 'The recovery passwords do not match.');
      return;
    }
    FocusScope.of(context).unfocus();
    ref.read(backupControllerProvider.notifier).reset();
    unawaited(ref.read(backupControllerProvider.notifier).start(password));
    _password.clear();
    _confirmation.clear();
    context.pushNamed(AppRoute.backupProgress.name);
  }
}

final class BackupProgressPage extends ConsumerWidget {
  const BackupProgressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final operation = ref.watch(backupControllerProvider);
    if (operation.result != null) {
      return AppScaffold(
        appBar: AppBar(title: const Text('Backup verified')),
        body: Center(
          child: AppEmptyState(
            title: 'Backup complete',
            message: 'The encrypted backup was saved and verified.',
            icon: AppIcons.success,
            actionLabel: 'View details',
            onAction: () => context.goNamed(AppRoute.backupComplete.name),
          ),
        ),
      );
    }
    if (operation.canceled) {
      return AppScaffold(
        appBar: AppBar(title: const Text('Backup canceled')),
        body: Center(
          child: AppEmptyState(
            title: 'No backup was saved',
            message: 'Your timeline was not changed.',
            actionLabel: 'Done',
            onAction: () => context.pop(),
          ),
        ),
      );
    }
    if (operation.errorCode != null) {
      return AppScaffold(
        appBar: AppBar(title: const Text('Backup not created')),
        body: Center(
          child: AppErrorState(
            title: 'The backup could not be verified',
            message: _backupError(operation.errorCode!),
            actionLabel: 'Back',
            onAction: () => context.pop(),
          ),
        ),
      );
    }
    final phase = operation.progress?.phase ?? BackupPhase.preparing;
    return AppScaffold(
      appBar: AppBar(title: const Text('Creating backup')),
      body: Center(
        child: Semantics(
          liveRegion: true,
          label: _phaseLabel(phase),
          child: AppLoadingState(label: _phaseLabel(phase)),
        ),
      ),
    );
  }
}

final class BackupCompletePage extends ConsumerWidget {
  const BackupCompletePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(backupControllerProvider).result;
    return AppScaffold(
      appBar: AppBar(title: const Text('Backup complete')),
      body: result == null
          ? const Center(
              child: AppErrorState(
                title: 'Backup details unavailable',
                message: 'Create a new backup to see verification details.',
              ),
            )
          : SingleChildScrollView(
              child: ScreenContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AppEmptyState(
                      title: 'Your backup is protected',
                      message:
                          'The encrypted file is stored only at the destination you selected.',
                      icon: AppIcons.success,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _BackupFact(
                      label: 'Created',
                      value: result.createdAt.toLocal().toString(),
                    ),
                    const AppDivider(),
                    _BackupFact(
                      label: 'Size',
                      value: _formatBytes(result.byteSize),
                    ),
                    const AppDivider(),
                    _BackupFact(
                      label: 'Verification',
                      value: result.verified ? 'Passed' : 'Not verified',
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppButton(
                      label: 'Done',
                      expanded: true,
                      onPressed: () => context.goNamed(AppRoute.security.name),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

final class _BackupFact extends StatelessWidget {
  const _BackupFact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        const SizedBox(width: AppSpacing.md),
        Flexible(child: Text(value, textAlign: TextAlign.end)),
      ],
    ),
  );
}

String _phaseLabel(BackupPhase phase) => switch (phase) {
  BackupPhase.preparing => 'Preparing timeline data',
  BackupPhase.packaging => 'Packaging backup contents',
  BackupPhase.encrypting => 'Encrypting locally',
  BackupPhase.saving => 'Saving to your chosen destination',
  BackupPhase.verifying => 'Verifying the saved backup',
};

String _backupError(String code) => switch (code) {
  'managed_attachment_missing' =>
    'An app-managed attachment is missing. No incomplete backup was kept.',
  'backup_verification_failed' =>
    'The saved file did not pass verification. Try another destination.',
  'backup_destination_verification_failed' =>
    'The destination did not preserve the backup correctly. Try another destination.',
  'backup_destination_write_failed' =>
    'The backup could not be written to that destination. Try another destination.',
  _ =>
    'Your timeline was not changed. Try again or choose another destination.',
};

String _formatBytes(int bytes) {
  if (bytes < 1024) {
    return '$bytes B';
  }
  if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
