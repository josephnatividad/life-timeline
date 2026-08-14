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
  bool _contentHasBeenPresented = false;
  bool _obscureForSystemSnapshot = false;

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
        if (!_obscureForSystemSnapshot && mounted) {
          setState(() => _obscureForSystemSnapshot = true);
        }
        controller.onBackgrounded();
      case AppLifecycleState.resumed:
        controller.onResumed();
        if (_obscureForSystemSnapshot && mounted) {
          setState(() => _obscureForSystemSnapshot = false);
        }
      case AppLifecycleState.detached:
        if (!_obscureForSystemSnapshot && mounted) {
          setState(() => _obscureForSystemSnapshot = true);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final security = ref.watch(securityControllerProvider);
    final accessOverlay = security.when<Widget?>(
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
      data: (value) {
        if (!value.locked) {
          // Once private content has been admitted, keep the navigator mounted
          // behind future lock/snapshot overlays. External document and camera
          // activities can then complete their pending Futures without losing
          // the originating route state.
          _contentHasBeenPresented = true;
          return null;
        }
        return const UnlockPage();
      },
    );
    final blocked = _obscureForSystemSnapshot || accessOverlay != null;
    return Stack(
      fit: StackFit.expand,
      children: [
        ExcludeSemantics(
          excluding: blocked,
          child: IgnorePointer(
            ignoring: blocked,
            child: TickerMode(
              enabled: !blocked,
              child: _contentHasBeenPresented
                  ? widget.child
                  : const SizedBox.expand(),
            ),
          ),
        ),
        if (accessOverlay != null)
          Positioned.fill(
            child: ExcludeSemantics(
              excluding: _obscureForSystemSnapshot,
              child: IgnorePointer(
                ignoring: _obscureForSystemSnapshot,
                child: accessOverlay,
              ),
            ),
          ),
        if (_obscureForSystemSnapshot)
          Positioned.fill(
            child: Semantics(
              label: 'Privacy screen',
              child: ColoredBox(
                color: Theme.of(context).colorScheme.surface,
                child: const Center(
                  child: AppIcon(
                    icon: AppIcons.privacy,
                    size: AppIconSize.signature,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
