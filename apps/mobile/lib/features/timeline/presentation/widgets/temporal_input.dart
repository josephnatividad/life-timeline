import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:life_timeline/design_system/design_system.dart';
import 'package:life_timeline/features/timeline/domain/temporal_display.dart';
import 'package:life_timeline/shared/domain/model/temporal_value.dart';

final class TemporalInput extends StatefulWidget {
  const TemporalInput({
    required this.onChanged,
    this.initialValue,
    this.showError = false,
    super.key,
  });

  final TemporalValue? initialValue;
  final ValueChanged<TemporalValue?> onChanged;
  final bool showError;

  @override
  State<TemporalInput> createState() => _TemporalInputState();
}

final class _TemporalInputState extends State<TemporalInput> {
  late TemporalPrecision? _precision = widget.initialValue?.precision;
  DateTime? _exactDate;
  late final _startYear = TextEditingController();
  late final _startMonth = TextEditingController();
  late final _startDay = TextEditingController();
  late final _endYear = TextEditingController();
  late final _endMonth = TextEditingController();
  late final _endDay = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load(widget.initialValue);
  }

  @override
  void dispose() {
    _startYear.dispose();
    _startMonth.dispose();
    _startDay.dispose();
    _endYear.dispose();
    _endMonth.dispose();
    _endDay.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      DropdownButtonFormField<TemporalPrecision>(
        key: const Key('temporal-precision'),
        initialValue: _precision,
        decoration: InputDecoration(
          labelText: 'When did it happen?',
          errorText: widget.showError && _currentValue() == null
              ? 'Choose a date precision and value.'
              : null,
        ),
        items: [
          for (final precision in TemporalPrecision.values)
            DropdownMenuItem(
              value: precision,
              child: Text(_precisionLabel(precision)),
            ),
        ],
        onChanged: _changePrecision,
      ),
      if (_precision != null) ...[
        const SizedBox(height: AppSpacing.md),
        _fieldsForPrecision(context),
      ],
      if (_currentValue() case final value?) ...[
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Shown as: ${TemporalDisplay.label(value)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ],
  );

  Widget _fieldsForPrecision(BuildContext context) => switch (_precision!) {
    TemporalPrecision.exactDate => AppButton(
      key: const Key('choose-exact-date'),
      label: _exactDate == null
          ? 'Choose exact date'
          : MaterialLocalizations.of(context).formatMediumDate(_exactDate!),
      icon: AppIcons.time,
      variant: AppButtonVariant.secondary,
      onPressed: _chooseExactDate,
    ),
    TemporalPrecision.month => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _numberField(_startMonth, 'Month', maxLength: 2)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _numberField(_startYear, 'Year', maxLength: 4)),
      ],
    ),
    TemporalPrecision.year => _numberField(_startYear, 'Year', maxLength: 4),
    TemporalPrecision.approximate ||
    TemporalPrecision.before ||
    TemporalPrecision.after => _partialDateFields(),
    TemporalPrecision.range => Column(
      children: [
        _partialDateFields(prefix: 'Start '),
        const SizedBox(height: AppSpacing.sm),
        _partialDateFields(prefix: 'End ', end: true),
      ],
    ),
    TemporalPrecision.unknown => Text(
      'No date will be invented. You can refine it later.',
      style: Theme.of(context).textTheme.bodyMedium,
    ),
  };

  Widget _partialDateFields({String prefix = '', bool end = false}) {
    final year = end ? _endYear : _startYear;
    final month = end ? _endMonth : _startMonth;
    final day = end ? _endDay : _startDay;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _numberField(year, '${prefix}year', maxLength: 4),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _numberField(month, 'Month', maxLength: 2, optional: true),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _numberField(day, 'Day', maxLength: 2, optional: true)),
      ],
    );
  }

  Widget _numberField(
    TextEditingController controller,
    String label, {
    required int maxLength,
    bool optional = false,
  }) => TextField(
    key: ValueKey('temporal-${label.toLowerCase().replaceAll(' ', '-')}'),
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      helperText: optional ? 'Optional' : null,
      counterText: '',
    ),
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(maxLength),
    ],
    keyboardType: TextInputType.number,
    onChanged: (_) => _emit(),
  );

  Future<void> _chooseExactDate() async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(1),
      lastDate: DateTime(9999, 12, 31),
      initialDate: _exactDate ?? DateTime.now(),
    );
    if (selected != null) {
      setState(() => _exactDate = selected);
      _emit();
    }
  }

  void _changePrecision(TemporalPrecision? precision) {
    setState(() {
      _precision = precision;
      _exactDate = null;
      for (final controller in [
        _startYear,
        _startMonth,
        _startDay,
        _endYear,
        _endMonth,
        _endDay,
      ]) {
        controller.clear();
      }
    });
    _emit();
  }

  void _emit() {
    final value = _currentValue();
    setState(() {});
    widget.onChanged(value);
  }

  TemporalValue? _currentValue() {
    try {
      final year = int.tryParse(_startYear.text);
      final month = int.tryParse(_startMonth.text);
      final day = int.tryParse(_startDay.text);
      return switch (_precision) {
        null => null,
        TemporalPrecision.exactDate =>
          _exactDate == null
              ? null
              : TemporalValue.exactDate(
                  year: _exactDate!.year,
                  month: _exactDate!.month,
                  day: _exactDate!.day,
                ),
        TemporalPrecision.month =>
          year == null || month == null
              ? null
              : TemporalValue.month(year: year, month: month),
        TemporalPrecision.year =>
          year == null ? null : TemporalValue.year(year),
        TemporalPrecision.approximate =>
          year == null
              ? null
              : TemporalValue.approximate(
                  TemporalPoint(year: year, month: month, day: day),
                ),
        TemporalPrecision.before =>
          year == null
              ? null
              : TemporalValue.before(
                  TemporalPoint(year: year, month: month, day: day),
                ),
        TemporalPrecision.after =>
          year == null
              ? null
              : TemporalValue.after(
                  TemporalPoint(year: year, month: month, day: day),
                ),
        TemporalPrecision.range =>
          year == null || int.tryParse(_endYear.text) == null
              ? null
              : TemporalValue.range(
                  start: TemporalPoint(year: year, month: month, day: day),
                  end: TemporalPoint(
                    year: int.parse(_endYear.text),
                    month: int.tryParse(_endMonth.text),
                    day: int.tryParse(_endDay.text),
                  ),
                ),
        TemporalPrecision.unknown => TemporalValue.unknown(),
      };
    } on ArgumentError {
      return null;
    }
  }

  void _load(TemporalValue? value) {
    if (value == null) {
      return;
    }
    final start = value.start;
    final end = value.end;
    if (value.precision == TemporalPrecision.exactDate && start != null) {
      _exactDate = DateTime(start.year, start.month!, start.day!);
    }
    _startYear.text = start?.year.toString() ?? '';
    _startMonth.text = start?.month?.toString() ?? '';
    _startDay.text = start?.day?.toString() ?? '';
    _endYear.text = end?.year.toString() ?? '';
    _endMonth.text = end?.month?.toString() ?? '';
    _endDay.text = end?.day?.toString() ?? '';
  }

  String _precisionLabel(TemporalPrecision precision) => switch (precision) {
    TemporalPrecision.exactDate => 'Exact date',
    TemporalPrecision.month => 'Month and year',
    TemporalPrecision.year => 'Year only',
    TemporalPrecision.approximate => 'Approximate date',
    TemporalPrecision.range => 'Date range',
    TemporalPrecision.before => 'Before a date',
    TemporalPrecision.after => 'After a date',
    TemporalPrecision.unknown => 'Unknown',
  };
}
