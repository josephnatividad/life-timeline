import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/security/application/security_providers.dart';
import 'package:life_timeline/features/security/domain/security_models.dart';

final class SetPinPage extends ConsumerStatefulWidget {
  const SetPinPage({super.key});

  @override
  ConsumerState<SetPinPage> createState() => _SetPinPageState();
}

final class _SetPinPageState extends ConsumerState<SetPinPage> {
  final _current = TextEditingController();
  final _pin = TextEditingController();
  final _confirmation = TextEditingController();
  bool _hasExistingPin = false;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _current.dispose();
    _pin.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final hasPin = await ref.read(securityControllerProvider.notifier).hasPin();
    if (mounted) {
      setState(() {
        _hasExistingPin = hasPin;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppBar(title: Text(_hasExistingPin ? 'Change PIN' : 'Set PIN')),
    body: _loading
        ? const Center(child: AppLoadingState(label: 'Checking local security'))
        : SingleChildScrollView(
            child: ScreenContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AppSectionHeader(
                    title: 'Local app lock',
                    supportingText:
                        'Use 4–12 digits. Your PIN stays on this device and is never stored in plain text.',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (_hasExistingPin) ...[
                    AppTextField(
                      key: const Key('current-pin'),
                      controller: _current,
                      label: 'Current PIN',
                      obscureText: true,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  AppTextField(
                    key: const Key('new-pin'),
                    controller: _pin,
                    label: 'New PIN',
                    obscureText: true,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    key: const Key('confirm-pin'),
                    controller: _confirmation,
                    label: 'Confirm PIN',
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    errorText: _error,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    key: const Key('save-pin'),
                    label: _hasExistingPin ? 'Change PIN' : 'Enable app lock',
                    icon: AppIcons.lock,
                    expanded: true,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
          ),
  );

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    final pin = _pin.text;
    if (!RegExp(r'^\d{4,12}$').hasMatch(pin)) {
      setState(() => _error = 'Use 4–12 digits.');
      return;
    }
    if (pin != _confirmation.text) {
      setState(() => _error = 'The PINs do not match.');
      return;
    }
    final controller = ref.read(securityControllerProvider.notifier);
    if (_hasExistingPin) {
      final verification = await controller.verifyCurrentPin(_current.text);
      if (verification.status != PinAttemptStatus.success) {
        if (mounted) {
          setState(() {
            _error = verification.status == PinAttemptStatus.throttled
                ? 'Wait ${verification.retryAfter.inSeconds.clamp(1, 300)} seconds, then try again.'
                : 'The current PIN did not match.';
          });
        }
        return;
      }
    }
    await controller.configurePin(pin);
    _current.clear();
    _pin.clear();
    _confirmation.clear();
    if (mounted) {
      context.pop();
    }
  }
}
