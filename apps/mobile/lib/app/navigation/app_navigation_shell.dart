import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:life_timeline/design_system/components/navigation/app_bottom_navigation_shell.dart';

final class AppNavigationShell extends StatelessWidget {
  const AppNavigationShell({
    required this.navigationShell,
    required this.onCaptureSelected,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final VoidCallback onCaptureSelected;

  int get _selectedDestination => switch (navigationShell.currentIndex) {
    0 => 0,
    1 => 1,
    2 => 3,
    3 => 4,
    _ => 0,
  };

  @override
  Widget build(BuildContext context) => AppBottomNavigationShell(
    body: navigationShell,
    selectedIndex: _selectedDestination,
    onDestinationSelected: _selectDestination,
  );

  void _selectDestination(int destinationIndex) {
    if (destinationIndex == 2) {
      onCaptureSelected();
      return;
    }

    final branchIndex = destinationIndex > 2
        ? destinationIndex - 1
        : destinationIndex;
    navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == navigationShell.currentIndex,
    );
  }
}
