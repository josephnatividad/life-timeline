import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_timeline/design_system/components/feedback/app_badge.dart';
import 'package:life_timeline/design_system/components/feedback/app_state_views.dart';
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
    required this.onAddPhotos,
    this.onCandidateCreated,
    this.onOpenInbox,
    super.key,
  });

  final VoidCallback onAddMemory;
  final VoidCallback onAddPhotos;
  final ValueChanged<String>? onCandidateCreated;
  final VoidCallback? onOpenInbox;

  @override
  ConsumerState<CaptureFoundationSheet> createState() =>
      _CaptureFoundationSheetState();
}

final class _CaptureFoundationSheetState
    extends ConsumerState<CaptureFoundationSheet> {
  String? _stage;
  var _showScanSources = false;

  @override
  Widget build(BuildContext context) {
    final capabilities = ref.watch(privateIntelligenceCapabilitiesProvider);
    final usage = capabilities.documentExtractionAvailable
        ? ref.watch(aiCaptureUsageProvider).value
        : null;
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
          Text(
            _showScanSources
                ? capabilities.textRecognitionAvailable
                      ? 'Document text is read on this device. Nothing is uploaded.'
                      : 'Documents stay on this device. Add the important details yourself.'
                : 'Record a memory, add its photos, or scan supporting documents.',
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
          ] else if (_showScanSources) ...[
            if (!capabilities.textRecognitionAvailable) ...[
              const AppUnavailableState(
                title: "Private text extraction isn't available yet",
                message: 'Manual document capture remains available.',
                icon: AppIcons.lock,
                variant: AppEmptyStateVariant.section,
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            _action(
              key: const Key('scan-document-camera'),
              icon: AppIcons.camera,
              title: 'Take document photo',
              subtitle: capabilities.documentExtractionAvailable
                  ? 'Extract details locally, then review every suggestion.'
                  : 'Attach it privately, then enter the details yourself.',
              source: CaptureSource.scan,
            ),
            _action(
              key: const Key('scan-document-library'),
              icon: AppIcons.gallery,
              title: 'Choose document photo',
              subtitle: capabilities.documentExtractionAvailable
                  ? 'Use an existing receipt, warranty, ticket, or document.'
                  : 'Attach an existing document without uploading it.',
              source: CaptureSource.photoLibrary,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const AppIcon(icon: AppIcons.back),
              title: const Text('Back to Capture'),
              onTap: () => setState(() => _showScanSources = false),
            ),
          ] else ...[
            ListTile(
              key: const Key('capture-manual-memory'),
              contentPadding: EdgeInsets.zero,
              leading: const AppIcon(icon: AppIcons.capture),
              title: const Text('Add Memory'),
              subtitle: const Text('Record something that happened.'),
              trailing: const AppIcon(icon: AppIcons.next),
              onTap: widget.onAddMemory,
            ),
            ListTile(
              key: const Key('capture-add-photos'),
              contentPadding: EdgeInsets.zero,
              leading: const AppIcon(icon: AppIcons.gallery),
              title: const Text('Add Photos'),
              subtitle: const Text(
                'Add photos to a memory without scanning them.',
              ),
              trailing: const AppIcon(icon: AppIcons.next),
              onTap: widget.onAddPhotos,
            ),
            ListTile(
              key: const Key('capture-scan'),
              contentPadding: EdgeInsets.zero,
              leading: const AppIcon(icon: AppIcons.intelligence),
              title: const Text('Scan Document'),
              subtitle: const Text(
                'Attach a receipt, warranty, ticket, or document privately.',
              ),
              trailing: const AppIcon(icon: AppIcons.next),
              onTap: () => setState(() => _showScanSources = true),
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
    final capabilities = ref.read(privateIntelligenceCapabilitiesProvider);
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
        capabilities.textRecognitionAvailable
            ? 'This image could not be read locally. Your timeline was not changed.'
            : 'This document could not be attached. Your timeline was not changed.',
      );
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
