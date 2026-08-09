import 'package:flutter/material.dart';
import 'package:life_timeline/design_system/icons/app_icons.dart';
import 'package:life_timeline/shared/ui/foundation_destination_view.dart';

final class TimelineFoundationPage extends StatelessWidget {
  const TimelineFoundationPage({super.key});

  @override
  Widget build(BuildContext context) => const FoundationDestinationView(
    description: 'Timeline feature implementation is intentionally deferred.',
    icon: AppIcons.timeline,
    title: 'Life Timeline',
  );
}
