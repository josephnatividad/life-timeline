import 'package:flutter/material.dart';
import 'package:life_timeline/design_system/components/actions/app_icon_button.dart';
import 'package:life_timeline/design_system/icons/app_icons.dart';
import 'package:life_timeline/design_system/motion/app_motion.dart';
import 'package:life_timeline/design_system/tokens/app_spacing.dart';

final class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    required this.child,
    this.description,
    this.showCloseButton = false,
    this.title,
    super.key,
  });

  final Widget child;
  final String? description;
  final bool showCloseButton;
  final String? title;

  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isDismissible = true,
  }) => showModalBottomSheet<T>(
    context: context,
    isDismissible: isDismissible,
    isScrollControlled: true,
    sheetAnimationStyle: AppMotion.bottomSheetStyle(context),
    useSafeArea: true,
    builder: builder,
  );

  @override
  Widget build(BuildContext context) => Semantics(
    explicitChildNodes: true,
    namesRoute: title != null,
    scopesRoute: true,
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.sm,
        AppSpacing.xl,
        AppSpacing.xl + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null || showCloseButton)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title case final title?)
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  )
                else
                  const Spacer(),
                if (showCloseButton)
                  AppIconButton(
                    icon: AppIcons.close,
                    label: 'Close',
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
              ],
            ),
          if (description case final description?) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(description, style: Theme.of(context).textTheme.bodyLarge),
          ],
          if (title != null || description != null)
            const SizedBox(height: AppSpacing.lg),
          Flexible(child: SingleChildScrollView(child: child)),
        ],
      ),
    ),
  );
}
