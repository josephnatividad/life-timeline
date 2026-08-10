import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:life_timeline/app/navigation/app_routes.dart';
import 'package:life_timeline/design_system/design_system.dart';

final class YouFoundationPage extends StatelessWidget {
  const YouFoundationPage({super.key});

  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppBar(title: const Text('You')),
    body: ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      children: [
        ScreenContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppSectionHeader(
                title: 'Privacy and control',
                supportingText:
                    'Your timeline remains local unless you explicitly export a backup.',
              ),
              const SizedBox(height: AppSpacing.md),
              ListTile(
                key: const Key('security-settings-row'),
                contentPadding: EdgeInsets.zero,
                leading: const AppIcon(icon: AppIcons.privacy),
                title: const Text('Security & recovery'),
                subtitle: const Text(
                  'App lock, PIN, biometrics, encrypted backup, and restore',
                ),
                trailing: const AppIcon(icon: AppIcons.next),
                onTap: () => context.pushNamed(AppRoute.security.name),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
