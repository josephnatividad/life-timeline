import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/security/application/security_providers.dart';
import 'package:life_timeline/features/security/domain/security_models.dart';

final class UnlockPage extends ConsumerStatefulWidget {
  const UnlockPage({super.key});

  @override
  ConsumerState<UnlockPage> createState() => _UnlockPageState();
}

final class _UnlockPageState extends ConsumerState<UnlockPage> {
  final _pin = TextEditingController();
  String? _message;
  bool _working = false;

  @override
  void dispose() {
    _pin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(securityControllerProvider).value;
    return AppScaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ScreenContainer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Align(
                    alignment: Alignment.center,
                    child: AppIcon(
                      icon: AppIcons.lock,
                      semanticLabel: 'Locked',
                      size: AppIconSize.signature,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Your timeline is locked',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Unlock locally to continue.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppTextField(
                    key: const Key('unlock-pin'),
                    controller: _pin,
                    label: 'PIN',
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => unawaited(_unlockPin()),
                    errorText: _message,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    key: const Key('unlock-with-pin'),
                    label: 'Unlock',
                    icon: AppIcons.lock,
                    loading: _working,
                    expanded: true,
                    onPressed: _unlockPin,
                  ),
                  if (session?.settings.biometricsEnabled == true &&
                      session?.biometricAvailable == true) ...[
                    const SizedBox(height: AppSpacing.sm),
                    AppButton(
                      key: const Key('unlock-with-biometrics'),
                      label: 'Use biometrics',
                      icon: AppIcons.privacy,
                      variant: AppButtonVariant.secondary,
                      expanded: true,
                      onPressed: _unlockBiometrics,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _unlockPin() async {
    if (_working) {
      return;
    }
    setState(() {
      _working = true;
      _message = null;
    });
    final result = await ref
        .read(securityControllerProvider.notifier)
        .unlockWithPin(_pin.text);
    _pin.clear();
    if (!mounted) {
      return;
    }
    setState(() {
      _working = false;
      _message = switch (result.status) {
        PinAttemptStatus.success => null,
        PinAttemptStatus.invalid => 'That PIN did not match.',
        PinAttemptStatus.throttled =>
          'Try again in ${result.retryAfter.inSeconds.clamp(1, 300)} seconds.',
        PinAttemptStatus.notConfigured => 'No local PIN is configured.',
      };
    });
  }

  Future<void> _unlockBiometrics() async {
    final result = await ref
        .read(securityControllerProvider.notifier)
        .unlockWithBiometrics();
    if (!mounted || result == BiometricResult.success) {
      return;
    }
    setState(() {
      _message = switch (result) {
        BiometricResult.unavailable =>
          'Biometrics are unavailable. Use your PIN.',
        BiometricResult.temporarilyLocked =>
          'Biometrics are temporarily locked. Use your PIN.',
        BiometricResult.canceled => null,
        BiometricResult.failed => 'Biometric unlock failed. Use your PIN.',
        BiometricResult.success => null,
      };
    });
  }
}
