import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_timeline/app/navigation/app_routes.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/security/application/security_providers.dart';
import 'package:life_timeline/features/security/domain/security_models.dart';

final class SecuritySettingsPage extends ConsumerWidget {
  const SecuritySettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(securityControllerProvider);
    return AppScaffold(
      appBar: AppBar(title: const Text('Security & recovery')),
      body: session.when(
        loading: () => const Center(
          child: AppLoadingState(label: 'Loading security settings'),
        ),
        error: (error, stackTrace) => const Center(
          child: AppErrorState(
            title: 'Security settings unavailable',
            message: 'These local settings could not be read safely.',
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
                    title: 'App lock',
                    supportingText:
                        'Protect access on this device. Your PIN is always the fallback.',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SecuritySwitchRow(
                    title: 'App Lock',
                    subtitle: value.settings.appLockEnabled
                        ? 'Enabled'
                        : 'Disabled',
                    value: value.settings.appLockEnabled,
                    onChanged: (enabled) =>
                        unawaited(_toggleAppLock(context, ref, enabled)),
                  ),
                  const AppDivider(),
                  _SecurityActionRow(
                    title: value.settings.appLockEnabled
                        ? 'Change PIN'
                        : 'Set PIN',
                    subtitle:
                        'PIN verification material stays in secure storage.',
                    icon: AppIcons.lock,
                    onTap: () => context.pushNamed(AppRoute.setPin.name),
                  ),
                  const AppDivider(),
                  _SecuritySwitchRow(
                    title: 'Biometrics',
                    subtitle: value.biometricAvailable
                        ? 'Use face or fingerprint authentication supported by this device.'
                        : 'Biometric authentication is not available on this device.',
                    value: value.settings.biometricsEnabled,
                    enabled:
                        value.settings.appLockEnabled &&
                        value.biometricAvailable,
                    onChanged: (enabled) =>
                        unawaited(_toggleBiometrics(context, ref, enabled)),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const AppSectionHeader(title: 'Auto-lock'),
                  const SizedBox(height: AppSpacing.sm),
                  AppDropdownField<AutoLockPreference>(
                    key: const Key('auto-lock-preference'),
                    initialValue: value.settings.autoLock,
                    label: 'Lock timing',
                    items: [
                      for (final option in AutoLockPreference.values)
                        DropdownMenuItem(
                          value: option,
                          child: Text(_autoLockLabel(option)),
                        ),
                    ],
                    onChanged: value.settings.appLockEnabled
                        ? (option) {
                            if (option != null) {
                              unawaited(
                                ref
                                    .read(securityControllerProvider.notifier)
                                    .setAutoLock(option),
                              );
                            }
                          }
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const AppSectionHeader(
                    title: 'Backup & recovery',
                    supportingText:
                        'Backups are encrypted locally and saved only where you choose.',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SecurityActionRow(
                    title: 'Create encrypted backup',
                    subtitle: value.settings.recoveryConfigured
                        ? 'Recovery password configured'
                        : 'Recovery password not configured',
                    icon: AppIcons.database,
                    onTap: () => context.pushNamed(AppRoute.createBackup.name),
                  ),
                  const AppDivider(),
                  _SecurityActionRow(
                    title: 'Automatic encrypted backup',
                    subtitle:
                        'Optional Google Drive app-data backup with device-only credentials.',
                    icon: AppIcons.privacy,
                    onTap: () =>
                        context.pushNamed(AppRoute.automaticBackup.name),
                  ),
                  const AppDivider(),
                  _SecurityActionRow(
                    title: 'Restore existing timeline',
                    subtitle: 'Restore from a backup you control.',
                    icon: AppIcons.success,
                    onTap: () => context.pushNamed(AppRoute.restoreEntry.name),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: 'Lock now',
                    icon: AppIcons.lock,
                    variant: AppButtonVariant.secondary,
                    expanded: true,
                    onPressed: value.settings.appLockEnabled
                        ? () {
                            ref
                                .read(securityControllerProvider.notifier)
                                .lock();
                            context.goNamed(AppRoute.timeline.name);
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleAppLock(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    final controller = ref.read(securityControllerProvider.notifier);
    if (enabled && !await controller.hasPin()) {
      if (context.mounted) {
        await context.pushNamed(AppRoute.setPin.name);
      }
      return;
    }
    await controller.setAppLockEnabled(enabled);
  }

  Future<void> _toggleBiometrics(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    final result = await ref
        .read(securityControllerProvider.notifier)
        .setBiometricsEnabled(enabled);
    if (!context.mounted || result == BiometricResult.success) {
      return;
    }
    final message = switch (result) {
      BiometricResult.unavailable =>
        'No usable biometric method is enrolled. Check your device settings and try again.',
      BiometricResult.temporarilyLocked =>
        'Biometrics are temporarily locked. Unlock your device and try again.',
      BiometricResult.failed =>
        'Biometric verification failed. The setting was not enabled.',
      BiometricResult.canceled =>
        'Biometric verification was canceled. The setting was not enabled.',
      BiometricResult.success => null,
    };
    if (message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  static String _autoLockLabel(AutoLockPreference value) => switch (value) {
    AutoLockPreference.immediately => 'Immediately',
    AutoLockPreference.oneMinute => 'After 1 minute',
    AutoLockPreference.fiveMinutes => 'After 5 minutes',
    AutoLockPreference.fifteenMinutes => 'After 15 minutes',
    AutoLockPreference.appRestart => 'When app restarts',
  };
}

final class _SecuritySwitchRow extends StatelessWidget {
  const _SecuritySwitchRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final bool enabled;
  final ValueChanged<bool> onChanged;
  final String subtitle;
  final String title;
  final bool value;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    child: ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(value: value, onChanged: enabled ? onChanged : null),
    ),
  );
}

final class _SecurityActionRow extends StatelessWidget {
  const _SecurityActionRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final AppIconData icon;
  final VoidCallback onTap;
  final String subtitle;
  final String title;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: AppIcon(icon: icon),
    title: Text(title),
    subtitle: Text(subtitle),
    trailing: const AppIcon(icon: AppIcons.next),
    onTap: onTap,
  );
}
