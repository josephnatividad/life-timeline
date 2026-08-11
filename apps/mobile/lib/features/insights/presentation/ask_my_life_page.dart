import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_timeline/app/navigation/app_routes.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/insights/application/insights_providers.dart';
import 'package:life_timeline/features/insights/domain/life_query_models.dart';
import 'package:life_timeline/features/insights/domain/query_language.dart';
import 'package:life_timeline/features/insights/presentation/widgets/ask_life_input.dart';
import 'package:life_timeline/features/insights/presentation/widgets/life_answer_card.dart';
import 'package:life_timeline/features/insights/presentation/widgets/supporting_records_sheet.dart';

final class AskMyLifePage extends ConsumerStatefulWidget {
  const AskMyLifePage({this.initialQuestion, super.key});

  final String? initialQuestion;

  @override
  ConsumerState<AskMyLifePage> createState() => _AskMyLifePageState();
}

final class _AskMyLifePageState extends ConsumerState<AskMyLifePage> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialQuestion,
  );
  LifeQueryResult? _result;
  var _queryFailed = false;
  var _running = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuestion?.trim().isNotEmpty ?? false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _ask(widget.initialQuestion!);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppBar(title: const Text('Ask My Life')),
    body: ScreenContainer(
      child: ListView(
        key: const Key('ask-life-content'),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSignatureIcon(
                kind: AppSignatureIconKind.lifeIntelligence,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ask your life',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Private, structured answers from the confirmed records on this device.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          AskLifeInput(
            controller: _controller,
            enabled: !_running,
            onSubmit: _ask,
          ),
          if (_running) ...[
            const SizedBox(height: AppSpacing.sm),
            Semantics(
              liveRegion: true,
              child: const Text('Checking confirmed records on this device…'),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          const AppSectionHeader(
            title: 'Try asking',
            supportingText:
                'Questions are interpreted locally using a bounded vocabulary.',
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final question in LifeQueryLanguage.supportedExamples)
                SuggestedQuestionChip(
                  label: question,
                  onSelected: () {
                    _controller.text = question;
                    _ask(question);
                  },
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          if (_queryFailed)
            AppErrorState(
              title: 'Local query unavailable',
              message:
                  'The question could not be checked. Your timeline was not changed.',
              actionLabel: 'Try again',
              onAction: () => _ask(_controller.text),
            )
          else if (_result case final result?)
            FadeSlideIn(
              child: LifeAnswerCard(
                key: const Key('ask-life-result'),
                result: result,
                onViewRecords: result.supportingRecords.isEmpty
                    ? null
                    : () => _showRecords(result),
              ),
            )
          else
            const IntelligenceCard(
              title: 'Your timeline stays the source of truth',
              body:
                  'As your timeline grows, answers can connect the things, places, years, and milestones you have confirmed.',
            ),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    ),
  );

  Future<void> _ask(String question) async {
    if (_running || question.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _queryFailed = false;
      _running = true;
    });
    try {
      final result = await ref
          .read(askMyLifeServiceProvider)
          .ask(question, now: DateTime.now().toUtc());
      if (mounted) setState(() => _result = result);
    } on Object {
      if (mounted) {
        setState(() {
          _queryFailed = true;
          _result = null;
        });
      }
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  Future<void> _showRecords(LifeQueryResult result) =>
      AppBottomSheet.show<void>(
        context: context,
        builder: (sheetContext) => SupportingRecordsSheet(
          records: result.supportingRecords,
          onOpenEvent: (eventId) {
            Navigator.of(sheetContext).pop();
            context.pushNamed(
              AppRoute.memoryDetail.name,
              pathParameters: {'memoryId': eventId},
            );
          },
        ),
      );
}
