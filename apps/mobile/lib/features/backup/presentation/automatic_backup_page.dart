import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/backup/application/backup_providers.dart';
import 'package:life_timeline/features/backup/domain/automatic_backup_models.dart';
import 'package:life_timeline/features/backup/domain/backup_models.dart';

final class AutomaticBackupPage extends ConsumerStatefulWidget {
  const AutomaticBackupPage({super.key});

  @override
  ConsumerState<AutomaticBackupPage> createState() =>
      _AutomaticBackupPageState();
}

final class _AutomaticBackupPageState
    extends ConsumerState<AutomaticBackupPage> {
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  ScaffoldMessengerState? _messenger;
  String? _formError;
  bool _active = true;
  bool _working = false;

  bool get _canUseUi => mounted && _active;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _active = true;
    _messenger = ScaffoldMessenger.maybeOf(context);
  }

  @override
  void activate() {
    super.activate();
    _active = true;
  }

  @override
  void deactivate() {
    _active = false;
    super.deactivate();
  }

  @override
  void dispose() {
    _active = false;
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final automatic = ref.watch(automaticBackupControllerProvider);
    return AppScaffold(
      appBar: AppBar(title: const Text('Automatic backup')),
      body: automatic.when(
        loading: () => const Center(
          child: AppLoadingState(label: 'Loading automatic backup settings'),
        ),
        error: (error, stackTrace) => const Center(
          child: AppErrorState(
            title: 'Backup settings unavailable',
            message: 'These device-only settings could not be read safely.',
          ),
        ),
        data: (value) => ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          children: [
            ScreenContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AppSectionHeader(
                    title: 'Encrypted Google Drive backup',
                    supportingText:
                        'The same LTBACK01 backup is encrypted and verified on this device before it enters Google Drive’s hidden app-data folder.',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const IntelligenceCard(
                    title: 'Private by design',
                    body:
                        'Google Drive is used only as an approved encrypted backup destination. OCR, insights, Stories, search, and image processing remain local.',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _DestinationStatus(status: value.destinationStatus),
                  if (!value.destinationStatus.isReady) ...[
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      label: 'Connect Google Drive',
                      icon: AppIcons.privacy,
                      expanded: true,
                      loading: _working,
                      onPressed: _working ? null : _connect,
                    ),
                  ] else if (!value.settings.enabled) ...[
                    const SizedBox(height: AppSpacing.xl),
                    const AppSectionHeader(
                      title: 'Device-only recovery password',
                      supportingText:
                          'Required for unattended encryption. It is stored only in this device’s non-migrating secure storage and is never uploaded.',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      key: const Key('automatic-backup-password'),
                      controller: _password,
                      label: 'Recovery password',
                      obscureText: true,
                      errorText: _formError,
                      autofillHints: const [AutofillHints.newPassword],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      key: const Key('automatic-backup-confirm-password'),
                      controller: _confirmation,
                      label: 'Confirm recovery password',
                      obscureText: true,
                      autofillHints: const [AutofillHints.newPassword],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      key: const Key('enable-automatic-backup'),
                      label: 'Enable automatic backup',
                      icon: AppIcons.database,
                      expanded: true,
                      loading: _working,
                      onPressed: _working ? null : _enable,
                    ),
                  ] else ...[
                    const SizedBox(height: AppSpacing.xl),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Automatic backup'),
                      subtitle: const Text('Enabled on this device'),
                      value: value.settings.enabled,
                      onChanged: _working
                          ? null
                          : (enabled) {
                              if (!enabled) unawaited(_disable());
                            },
                    ),
                    const AppDivider(),
                    AppDropdownField<AutomaticBackupFrequency>(
                      initialValue: value.settings.frequency,
                      label: 'Frequency',
                      items: const [
                        DropdownMenuItem(
                          value: AutomaticBackupFrequency.daily,
                          child: Text('Daily'),
                        ),
                        DropdownMenuItem(
                          value: AutomaticBackupFrequency.weekly,
                          child: Text('Weekly'),
                        ),
                      ],
                      onChanged: _working
                          ? null
                          : (frequency) {
                              if (frequency != null) {
                                unawaited(
                                  _update(
                                    value.settings.copyWith(
                                      frequency: frequency,
                                    ),
                                  ),
                                );
                              }
                            },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppDropdownField<AutomaticBackupNetworkPolicy>(
                      initialValue: value.settings.networkPolicy,
                      label: 'Network',
                      items: const [
                        DropdownMenuItem(
                          value: AutomaticBackupNetworkPolicy.wifiOnly,
                          child: Text('Wi-Fi only'),
                        ),
                        DropdownMenuItem(
                          value: AutomaticBackupNetworkPolicy.anyNetwork,
                          child: Text('Wi-Fi or mobile data'),
                        ),
                      ],
                      onChanged: _working
                          ? null
                          : (network) {
                              if (network != null) {
                                unawaited(
                                  _update(
                                    value.settings.copyWith(
                                      networkPolicy: network,
                                    ),
                                  ),
                                );
                              }
                            },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Prefer charging'),
                      subtitle: const Text(
                        'Background work waits for charging when the operating system supports it.',
                      ),
                      value: value.settings.preferCharging,
                      onChanged: _working
                          ? null
                          : (enabled) => unawaited(
                              _update(
                                value.settings.copyWith(
                                  preferCharging: enabled,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Keeps the latest ${value.settings.retentionCount} verified backups. Older copies are removed only after a new backup is verified.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: 'Back up now',
                      icon: AppIcons.database,
                      expanded: true,
                      loading: value.runState.running || _working,
                      onPressed: value.runState.running || _working
                          ? null
                          : _runNow,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppButton(
                      label: 'Disconnect Google Drive',
                      variant: AppButtonVariant.tertiary,
                      expanded: true,
                      onPressed: _working ? null : _disconnect,
                    ),
                    if (value.runState.lastSuccessAt case final success?) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Last verified: ${success.toLocal().toString().split('.').first}',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _connect() async {
    await _work(() async {
      final status = await ref
          .read(automaticBackupControllerProvider.notifier)
          .authorize();
      if (!_canUseUi) return;
      if (!status.isReady) {
        _message(_authorizationMessage(status));
      }
    });
  }

  Future<void> _enable() async {
    final password = _password.text;
    if (password.length < 8) {
      setState(() => _formError = 'Use at least 8 characters.');
      return;
    }
    if (password != _confirmation.text) {
      setState(() => _formError = 'The passwords do not match.');
      return;
    }
    setState(() => _formError = null);
    await _work(() async {
      await ref
          .read(automaticBackupControllerProvider.notifier)
          .enable(password);
      if (!_canUseUi) return;
      _password.clear();
      _confirmation.clear();
      _message('Automatic encrypted backup enabled.');
    });
  }

  Future<void> _disable() => _work(() async {
    await ref.read(automaticBackupControllerProvider.notifier).disable();
    if (!_canUseUi) return;
    _message('Automatic backup disabled on this device.');
  });

  Future<void> _disconnect() => _work(() async {
    await ref.read(automaticBackupControllerProvider.notifier).disconnect();
    if (!_canUseUi) return;
    _message('Google Drive backup access disconnected.');
  });

  Future<void> _update(AutomaticBackupSettings settings) => _work(() async {
    await ref
        .read(automaticBackupControllerProvider.notifier)
        .updateSettings(settings);
  });

  Future<void> _runNow() => _work(() async {
    final result = await ref
        .read(automaticBackupControllerProvider.notifier)
        .runNow();
    if (!_canUseUi) return;
    _message(switch (result) {
      AutomaticBackupRunResult.completed =>
        'Encrypted backup uploaded and verified.',
      AutomaticBackupRunResult.networkDeferred =>
        'Backup is waiting for the selected network.',
      AutomaticBackupRunResult.authorizationRequired =>
        'Google Drive authorization needs attention.',
      AutomaticBackupRunResult.credentialUnavailable =>
        'The device-only recovery password is unavailable.',
      _ => 'The automatic backup was not completed.',
    });
  });

  Future<void> _work(Future<void> Function() action) async {
    if (_working) return;
    setState(() => _working = true);
    try {
      await action();
    } on BackupFailure catch (error) {
      _message(_errorMessage(error.code));
    } on Object {
      _message('The automatic backup setting could not be changed safely.');
    } finally {
      if (_canUseUi) setState(() => _working = false);
    }
  }

  void _message(String message) {
    final messenger = _messenger;
    if (!_canUseUi || messenger == null || !messenger.mounted) return;
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  static String _errorMessage(String code) => switch (code) {
    'recovery_password_too_short' => 'Use at least 8 characters.',
    'drive_authorization_required' =>
      'Connect Google Drive before enabling automatic backup.',
    _ => 'The automatic backup setting could not be changed safely.',
  };

  static String _authorizationMessage(BackupDestinationStatus status) =>
      switch (status.detailCode) {
        'drive_client_configuration_missing' ||
        'drive_client_configuration_invalid' =>
          'Google Drive backup is not configured for this app build.',
        'drive_authorization_canceled' =>
          'Google Drive connection was canceled.',
        'drive_authorization_interrupted' =>
          'Google Drive connection was interrupted. Try again.',
        'drive_provider_configuration_error' =>
          'Google Play services could not provide Google Drive sign-in.',
        'drive_authorization_ui_unavailable' =>
          'Google Drive sign-in could not open on this device.',
        'drive_authorization_user_mismatch' =>
          'Choose the same Google account to continue.',
        _ => 'Google Drive authorization was not completed.',
      };
}

final class _DestinationStatus extends StatelessWidget {
  const _DestinationStatus({required this.status});

  final BackupDestinationStatus status;

  @override
  Widget build(BuildContext context) => AppBadge(
    label: switch (status.availability) {
      BackupDestinationAvailability.ready => 'Google Drive connected',
      BackupDestinationAvailability.needsAuthorization =>
        'Google Drive not connected',
      BackupDestinationAvailability.misconfigured =>
        'Google Drive setup required',
      BackupDestinationAvailability.unavailable => 'Google Drive unavailable',
    },
    icon: status.isReady ? AppIcons.success : AppIcons.information,
  );
}
