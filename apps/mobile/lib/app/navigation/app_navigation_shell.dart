import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:life_timeline/design_system/icons/app_icons.dart';

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
  Widget build(BuildContext context) => Scaffold(
    body: navigationShell,
    bottomNavigationBar: NavigationBar(
      selectedIndex: _selectedDestination,
      onDestinationSelected: (index) => _selectDestination(index),
      destinations: const [
        NavigationDestination(
          icon: AppIcon(icon: AppIcons.timeline),
          label: 'Timeline',
        ),
        NavigationDestination(
          icon: AppIcon(icon: AppIcons.explore),
          label: 'Explore',
        ),
        NavigationDestination(
          icon: AppIcon(icon: AppIcons.capture),
          label: 'Capture',
        ),
        NavigationDestination(
          icon: AppIcon(icon: AppIcons.stories),
          label: 'Stories',
        ),
        NavigationDestination(
          icon: AppIcon(icon: AppIcons.you),
          label: 'You',
        ),
      ],
    ),
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
