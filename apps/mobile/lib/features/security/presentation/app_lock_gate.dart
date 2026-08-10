import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/security/application/security_providers.dart';
import 'package:life_timeline/features/security/presentation/unlock_page.dart';

final class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

final class _AppLockGateState extends ConsumerState<AppLockGate>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = ref.read(securityControllerProvider.notifier);
    switch (state) {
      case AppLifecycleState.paused ||
          AppLifecycleState.inactive ||
          AppLifecycleState.hidden:
        controller.onBackgrounded();
      case AppLifecycleState.resumed:
        controller.onResumed();
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final security = ref.watch(securityControllerProvider);
    return security.when(
      loading: () => const ColoredBox(
        color: AppColors.lightBackground,
        child: Center(
          child: AppLoadingState(label: 'Preparing private access'),
        ),
      ),
      error: (error, stackTrace) => const Scaffold(
        body: Center(
          child: AppErrorState(
            title: 'Security settings unavailable',
            message: 'The app could not safely read its local lock settings.',
          ),
        ),
      ),
      data: (value) => value.locked ? const UnlockPage() : widget.child,
    );
  }
}
