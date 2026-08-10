import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_timeline/design_system/components/feedback/app_badge.dart';
import 'package:life_timeline/design_system/components/overlays/app_bottom_sheet.dart';
import 'package:life_timeline/design_system/icons/app_icons.dart';
import 'package:life_timeline/design_system/tokens/app_icon_size.dart';
import 'package:life_timeline/design_system/tokens/app_spacing.dart';
import 'package:life_timeline/features/private_intelligence/application/capture_intelligence_use_case.dart';
import 'package:life_timeline/features/private_intelligence/application/intelligence_providers.dart';
import 'package:life_timeline/features/private_intelligence/domain/intelligence_models.dart';

final class CaptureFoundationSheet extends ConsumerStatefulWidget {
  const CaptureFoundationSheet({
    required this.onAddMemory,
    this.onCandidateCreated,
    this.onOpenInbox,
    super.key,
  });

  final VoidCallback onAddMemory;
  final ValueChanged<String>? onCandidateCreated;
  final VoidCallback? onOpenInbox;

  @override
  ConsumerState<CaptureFoundationSheet> createState() =>
      _CaptureFoundationSheetState();
}

final class _CaptureFoundationSheetState
    extends ConsumerState<CaptureFoundationSheet> {
  String? _stage;

  @override
  Widget build(BuildContext context) {
    final usage = ref.watch(aiCaptureUsageProvider).value;
    return AppBottomSheet(
      title: 'Capture',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppIcon(
            icon: AppIcons.capture,
            semanticLabel: 'Capture',
            size: AppIconSize.signature,
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Images are read on this device. Nothing is uploaded.',
            textAlign: TextAlign.center,
          ),
          if (usage != null) ...[
            const SizedBox(height: AppSpacing.sm),
            AppBadge(
              label: '${usage.allowance - usage.used} complimentary reads left',
              tone: AppBadgeTone.neutral,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          if (_stage case final stage?) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: AppSpacing.sm),
            Semantics(liveRegion: true, child: Text(stage)),
          ] else ...[
            _action(
              key: const Key('capture-scan'),
              icon: AppIcons.intelligence,
              title: 'Scan a document',
              subtitle: 'Use the camera, then review every suggestion.',
              source: CaptureSource.scan,
            ),
            _action(
              key: const Key('capture-camera'),
              icon: AppIcons.image,
              title: 'Take a photo',
              subtitle: 'Capture a receipt, product, ticket, or document.',
              source: CaptureSource.camera,
            ),
            _action(
              key: const Key('capture-photo'),
              icon: AppIcons.image,
              title: 'Choose an existing photo',
              subtitle: 'The original remains unchanged.',
              source: CaptureSource.photoLibrary,
            ),
            ListTile(
              key: const Key('capture-manual-memory'),
              contentPadding: EdgeInsets.zero,
              leading: const AppIcon(icon: AppIcons.capture),
              title: const Text('Add memory manually'),
              subtitle: const Text(
                'Always available and never uses an AI action.',
              ),
              trailing: const AppIcon(icon: AppIcons.next),
              onTap: widget.onAddMemory,
            ),
            if (widget.onOpenInbox != null)
              ListTile(
                key: const Key('capture-open-inbox'),
                contentPadding: EdgeInsets.zero,
                leading: const AppIcon(icon: AppIcons.database),
                title: const Text('Memory Inbox'),
                subtitle: const Text(
                  'Review suggestions before they reach your timeline.',
                ),
                trailing: const AppIcon(icon: AppIcons.next),
                onTap: widget.onOpenInbox,
              ),
          ],
        ],
      ),
    );
  }

  Widget _action({
    required Key key,
    required AppIconData icon,
    required String title,
    required String subtitle,
    required CaptureSource source,
  }) => ListTile(
    key: key,
    contentPadding: EdgeInsets.zero,
    leading: AppIcon(icon: icon),
    title: Text(title),
    subtitle: Text(subtitle),
    trailing: const AppIcon(icon: AppIcons.next),
    onTap: () => _capture(source),
  );

  Future<void> _capture(CaptureSource source) async {
    setState(() => _stage = 'Starting private capture');
    try {
      final result = await ref
          .read(captureIntelligenceUseCaseProvider)
          .call(
            source,
            onStage: (stage) {
              if (mounted) setState(() => _stage = stage);
            },
          );
      if (!mounted) return;
      ref.invalidate(aiCaptureUsageProvider);
      switch (result.outcome) {
        case CaptureIntelligenceOutcome.created:
          widget.onCandidateCreated?.call(result.candidateId!);
        case CaptureIntelligenceOutcome.cancelled:
          setState(() => _stage = null);
        case CaptureIntelligenceOutcome.noUsefulText:
          setState(() => _stage = null);
          _message(
            'No reliable text was found. Try another image or add it manually.',
          );
        case CaptureIntelligenceOutcome.limitReached:
          setState(() => _stage = null);
          _message(
            'Complimentary private reads are used. Manual entry is still available.',
          );
      }
    } on Object {
      if (!mounted) return;
      setState(() => _stage = null);
      _message(
        'This image could not be read locally. Your timeline was not changed.',
      );
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
