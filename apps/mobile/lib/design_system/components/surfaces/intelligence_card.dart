import 'package:flutter/material.dart';
import 'package:life_timeline/design_system/components/actions/app_button.dart';
import 'package:life_timeline/design_system/icons/app_icons.dart';
import 'package:life_timeline/design_system/tokens/app_radius.dart';
import 'package:life_timeline/design_system/tokens/app_spacing.dart';

final class IntelligenceCard extends StatelessWidget {
  const IntelligenceCard({
    required this.body,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.signatureIconProvider,
    super.key,
  });

  final String? actionLabel;
  final String body;
  final VoidCallback? onAction;
  final AppSignatureIconProvider? signatureIconProvider;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.primaryContainer,
          border: Border.all(color: colors.primary),
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSignatureIcon(
                    kind: AppSignatureIconKind.lifeIntelligence,
                    color: colors.primary,
                    provider: signatureIconProvider,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                body,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colors.onPrimaryContainer,
                ),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: actionLabel!,
                  onPressed: onAction,
                  variant: AppButtonVariant.tertiary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
