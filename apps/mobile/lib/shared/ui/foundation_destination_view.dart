import 'package:flutter/material.dart';
import 'package:life_timeline/design_system/components/layout/app_scaffold.dart';
import 'package:life_timeline/design_system/icons/app_icons.dart';
import 'package:life_timeline/design_system/tokens/app_icon_size.dart';
import 'package:life_timeline/design_system/tokens/app_spacing.dart';

final class FoundationDestinationView extends StatelessWidget {
  const FoundationDestinationView({
    required this.description,
    required this.icon,
    required this.title,
    super.key,
  });

  final String description;
  final AppIconData icon;
  final String title;

  @override
  Widget build(BuildContext context) => ScreenContainer(
    alignment: Alignment.center,
    padding: const EdgeInsets.all(AppSpacing.xl),
    child: Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(
                icon: icon,
                semanticLabel: '$title destination',
                size: AppIconSize.signature,
              ),
              const SizedBox(height: AppSpacing.md),
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
