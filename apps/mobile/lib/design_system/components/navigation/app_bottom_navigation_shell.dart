import 'package:flutter/material.dart';
import 'package:life_timeline/design_system/components/layout/app_scaffold.dart';
import 'package:life_timeline/design_system/icons/app_icons.dart';

final class AppBottomNavigationShell extends StatelessWidget {
  const AppBottomNavigationShell({
    required this.body,
    required this.onDestinationSelected,
    required this.selectedIndex,
    super.key,
  });

  final Widget body;
  final ValueChanged<int> onDestinationSelected;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) => AppScaffold(
    body: body,
    bottomNavigationBar: AppBottomNavigation(
      onDestinationSelected: onDestinationSelected,
      selectedIndex: selectedIndex,
    ),
  );
}

final class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    required this.onDestinationSelected,
    required this.selectedIndex,
    super.key,
  });

  final ValueChanged<int> onDestinationSelected;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) => NavigationBar(
    labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    onDestinationSelected: onDestinationSelected,
    selectedIndex: selectedIndex,
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
  );
}
