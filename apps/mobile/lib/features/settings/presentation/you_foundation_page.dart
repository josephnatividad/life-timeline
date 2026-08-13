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
              ListTile(
                key: const Key('storage-manager-row'),
                contentPadding: EdgeInsets.zero,
                leading: const AppIcon(icon: AppIcons.database),
                title: const Text('Storage'),
                subtitle: const Text(
                  'Usage, safe cleanup, archive, and backup protection',
                ),
                trailing: const AppIcon(icon: AppIcons.next),
                onTap: () => context.pushNamed(AppRoute.storageManager.name),
              ),
              ListTile(
                key: const Key('reminders-row'),
                contentPadding: EdgeInsets.zero,
                leading: const AppIcon(icon: AppIcons.reminder),
                title: const Text('Reminders'),
                subtitle: const Text('Upcoming dates your timeline remembers'),
                trailing: const AppIcon(icon: AppIcons.next),
                onTap: () => context.pushNamed(AppRoute.reminders.name),
              ),
              const SizedBox(height: AppSpacing.xl),
              const AppDivider(),
              const SizedBox(height: AppSpacing.xl),
              const AppSectionHeader(
                title: 'Memory lifecycle',
                supportingText:
                    'Keep historical records without crowding your active timeline.',
              ),
              const SizedBox(height: AppSpacing.sm),
              ListTile(
                key: const Key('archived-memories-row'),
                contentPadding: EdgeInsets.zero,
                leading: const AppIcon(icon: AppIcons.archive),
                title: const Text('Archived memories'),
                subtitle: const Text('Preserved outside the active timeline'),
                trailing: const AppIcon(icon: AppIcons.next),
                onTap: () => context.pushNamed(AppRoute.archive.name),
              ),
              ListTile(
                key: const Key('trash-row'),
                contentPadding: EdgeInsets.zero,
                leading: const AppIcon(icon: AppIcons.trash),
                title: const Text('Trash'),
                subtitle: const Text('Restore or permanently delete mistakes'),
                trailing: const AppIcon(icon: AppIcons.next),
                onTap: () => context.pushNamed(AppRoute.trash.name),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
