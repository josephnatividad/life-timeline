import 'package:flutter/material.dart';
import 'package:life_timeline/design_system/icons/app_icons.dart';
import 'package:life_timeline/shared/ui/foundation_destination_view.dart';

final class YouFoundationPage extends StatelessWidget {
  const YouFoundationPage({super.key});

  @override
  Widget build(BuildContext context) => const FoundationDestinationView(
    description: 'Settings and data controls are intentionally deferred.',
    icon: AppIcons.you,
    title: 'You',
  );
}
