import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_timeline/app/navigation/app_routes.dart';
import 'package:life_timeline/app/providers/restored_data_refresh.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/backup/application/backup_providers.dart';
import 'package:life_timeline/features/backup/domain/backup_models.dart';

final class RestoreEntryPage extends StatelessWidget {
  const RestoreEntryPage({super.key});

  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppBar(title: const Text('Restore timeline')),
    body: Center(
      child: ScreenContainer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppIcon(
              icon: AppIcons.database,
              semanticLabel: 'Encrypted backup',
              size: AppIconSize.signature,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Restore an existing timeline',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Choose an encrypted backup you control. The original device is not required.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              key: const Key('restore-entry-continue'),
              label: 'Continue',
              expanded: true,
              onPressed: () => context.pushNamed(AppRoute.chooseBackup.name),
            ),
          ],
        ),
      ),
    ),
  );
}

final class ChooseBackupPage extends ConsumerStatefulWidget {
  const ChooseBackupPage({super.key});

  @override
  ConsumerState<ChooseBackupPage> createState() => _ChooseBackupPageState();
}

final class _ChooseBackupPageState extends ConsumerState<ChooseBackupPage> {
  bool _working = false;

  @override
  Widget build(BuildContext context) {
    final restore = ref.watch(restoreControllerProvider);
    return AppScaffold(
      appBar: AppBar(title: const Text('Choose backup')),
      body: Center(
        child: _working
            ? const AppLoadingState(label: 'Inspecting backup locally')
            : restore.errorCode == null
            ? AppEmptyState(
                title: 'Select a backup file',
                message:
                    'The file is inspected locally before a recovery password is requested.',
                icon: AppIcons.database,
                actionLabel: 'Choose backup',
                onAction: _choose,
              )
            : AppErrorState(
                title: 'This backup cannot be opened',
                message: _restoreError(restore.errorCode!),
                actionLabel: 'Choose another file',
                onAction: _choose,
              ),
      ),
    );
  }

  Future<void> _choose() async {
    if (_working) return;
    setState(() => _working = true);
    try {
      final selected = await ref
          .read(restoreControllerProvider.notifier)
          .chooseAndInspect();
      if (mounted && selected) {
        await context.pushNamed(AppRoute.enterRecoveryPassword.name);
      }
    } finally {
      if (mounted) {
        setState(() => _working = false);
      }
    }
  }
}

final class EnterRecoveryPasswordPage extends ConsumerStatefulWidget {
  const EnterRecoveryPasswordPage({super.key});

  @override
  ConsumerState<EnterRecoveryPasswordPage> createState() =>
      _EnterRecoveryPasswordPageState();
}

final class _EnterRecoveryPasswordPageState
    extends ConsumerState<EnterRecoveryPasswordPage> {
  final _password = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final header = ref.watch(restoreControllerProvider).header;
    return AppScaffold(
      appBar: AppBar(title: const Text('Recovery password')),
      body: SingleChildScrollView(
        child: ScreenContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppSectionHeader(
                title: 'Unlock this backup',
                supportingText:
                    'The password is used only on this device to authenticate and decrypt the selected file.',
              ),
              if (header != null) ...[
                const SizedBox(height: AppSpacing.md),
                AppBadge(
                  label:
                      'Backup from ${header.createdAt.toLocal().toString().split('.').first}',
                  icon: AppIcons.time,
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                key: const Key('restore-password'),
                controller: _password,
                label: 'Recovery password',
                obscureText: true,
                autofillHints: const [AutofillHints.password],
                errorText: _error,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _continue(),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                key: const Key('prepare-restore'),
                label: 'Verify backup',
                icon: AppIcons.privacy,
                expanded: true,
                onPressed: _continue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _continue() {
    if (_password.text.isEmpty) {
      setState(() => _error = 'Enter the recovery password.');
      return;
    }
    final password = _password.text;
    _password.clear();
    unawaited(ref.read(restoreControllerProvider.notifier).prepare(password));
    context.pushNamed(AppRoute.restoreProgress.name);
  }
}

final class RestorePreviewPage extends ConsumerStatefulWidget {
  const RestorePreviewPage({super.key});

  @override
  ConsumerState<RestorePreviewPage> createState() => _RestorePreviewPageState();
}

final class _RestorePreviewPageState extends ConsumerState<RestorePreviewPage> {
  bool _confirmedReplace = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(restoreControllerProvider);
    final preview = state.prepared?.preview;
    return AppScaffold(
      appBar: AppBar(title: const Text('Restore preview')),
      body: preview == null
          ? const Center(
              child: AppErrorState(
                title: 'Preview unavailable',
                message: 'Verify the backup again before restoring.',
              ),
            )
          : SingleChildScrollView(
              child: ScreenContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AppSectionHeader(
                      title: 'Backup verified',
                      supportingText:
                          'The encrypted container and included checksums passed validation.',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _PreviewFact(
                      label: 'Created',
                      value: preview.createdAt.toLocal().toString(),
                    ),
                    const AppDivider(),
                    _PreviewFact(
                      label: 'App version',
                      value: preview.appVersion,
                    ),
                    const AppDivider(),
                    _PreviewFact(
                      label: 'Database schema',
                      value: 'Version ${preview.databaseSchemaVersion}',
                    ),
                    const AppDivider(),
                    _PreviewFact(
                      label: 'Managed attachments',
                      value: '${preview.attachmentCount}',
                    ),
                    if (state.existingData) ...[
                      const SizedBox(height: AppSpacing.xl),
                      IntelligenceCard(
                        title: 'Current timeline detected',
                        body:
                            'Restoring will replace current timeline records only after the backup is staged and verified. A failed restore leaves current records unchanged.',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _confirmedReplace,
                        onChanged: (value) =>
                            setState(() => _confirmedReplace = value ?? false),
                        title: const Text(
                          'I understand this will replace current timeline records.',
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    AppButton(
                      key: const Key('commit-restore'),
                      label: 'Restore timeline',
                      icon: AppIcons.success,
                      expanded: true,
                      onPressed: state.existingData && !_confirmedReplace
                          ? null
                          : _restore,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _restore() {
    final existing = ref.read(restoreControllerProvider).existingData;
    unawaited(
      ref
          .read(restoreControllerProvider.notifier)
          .commit(replaceExisting: existing),
    );
    context.pushNamed(AppRoute.restoreProgress.name);
  }
}

final class RestoreProgressPage extends ConsumerWidget {
  const RestoreProgressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restore = ref.watch(restoreControllerProvider);
    if (restore.errorCode != null) {
      return AppScaffold(
        appBar: AppBar(title: const Text('Restore stopped')),
        body: Center(
          child: AppErrorState(
            title: 'The timeline was not restored',
            message: _restoreError(restore.errorCode!),
            actionLabel: 'Back',
            onAction: () => context.pop(),
          ),
        ),
      );
    }
    if (restore.stage == RestoreOperationStage.ready) {
      return AppScaffold(
        appBar: AppBar(title: const Text('Backup verified')),
        body: Center(
          child: AppEmptyState(
            title: 'Ready to restore',
            message: 'Review the backup summary before changing local data.',
            icon: AppIcons.success,
            actionLabel: 'Review backup',
            onAction: () => context.goNamed(AppRoute.restorePreview.name),
          ),
        ),
      );
    }
    if (restore.stage == RestoreOperationStage.complete) {
      return AppScaffold(
        appBar: AppBar(title: const Text('Restore complete')),
        body: Center(
          child: AppEmptyState(
            title: 'Timeline restored',
            message: 'The restored data passed final integrity checks.',
            icon: AppIcons.success,
            actionLabel: 'Continue',
            onAction: () => context.goNamed(AppRoute.restoreResult.name),
          ),
        ),
      );
    }
    final phase = restore.progress?.phase ?? RestorePhase.reading;
    return AppScaffold(
      appBar: AppBar(title: const Text('Restoring timeline')),
      body: Center(child: AppLoadingState(label: _restorePhaseLabel(phase))),
    );
  }
}

final class RestoreResultPage extends ConsumerWidget {
  const RestoreResultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => AppScaffold(
    appBar: AppBar(title: const Text('Restore result')),
    body: Center(
      child: AppEmptyState(
        title: 'Your timeline is ready',
        message:
            'The backup was authenticated, migrated where required, and restored locally.',
        icon: AppIcons.success,
        actionLabel: 'Open timeline',
        onAction: () async {
          await ref.read(restoreControllerProvider.notifier).reset();
          ref.read(restoredDataRefreshCoordinatorProvider).refresh();
          if (context.mounted) {
            context.goNamed(AppRoute.timeline.name);
          }
        },
      ),
    ),
  );
}

final class _PreviewFact extends StatelessWidget {
  const _PreviewFact({required this.label, required this.value});

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

String _restorePhaseLabel(RestorePhase phase) => switch (phase) {
  RestorePhase.reading => 'Reading backup header',
  RestorePhase.decrypting => 'Authenticating and decrypting locally',
  RestorePhase.verifying => 'Verifying checksums and compatibility',
  RestorePhase.staging => 'Staging restored files safely',
  RestorePhase.restoring => 'Restoring timeline records',
  RestorePhase.migrating => 'Applying required migrations',
  RestorePhase.complete => 'Verifying restored data',
};

String _restoreError(String code) => switch (code) {
  'newer_backup_not_supported' =>
    'This backup was created by a newer app version. Update the app before restoring it.',
  'wrong_password_or_damaged_backup' || 'authentication_failed' =>
    'The password did not match or the backup was changed. Current timeline data is unchanged.',
  'checksum_failed' || 'archive_corrupted' =>
    'The backup is damaged and cannot be restored. Current timeline data is unchanged.',
  'unsupported_database_version' =>
    'This database version cannot be restored safely by the current app.',
  'backup_file_selection_failed' =>
    'The selected file could not be copied for local inspection. Try the file again or choose another storage provider.',
  _ =>
    'The backup could not be restored safely. Current timeline data is unchanged.',
};
