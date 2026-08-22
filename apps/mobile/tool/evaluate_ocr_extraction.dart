import 'dart:convert';
import 'dart:io';

import 'package:life_timeline/features/private_intelligence/domain/document_intelligence.dart';
import 'package:life_timeline/features/private_intelligence/domain/intelligence_models.dart';

/// Research-only adapter that proves benchmark output can feed the existing
/// private-intelligence pipeline without exposing engine-specific types.
Future<void> main(List<String> arguments) async {
  if (arguments.length != 2) {
    stderr.writeln(
      'Usage: dart run tool/evaluate_ocr_extraction.dart '
      '<result.json> <resolved-manifest.json>',
    );
    exitCode = 64;
    return;
  }

  final resultFile = File(arguments[0]);
  final manifestFile = File(arguments[1]);
  final result =
      jsonDecode(await resultFile.readAsString()) as Map<String, Object?>;
  final manifest =
      jsonDecode(await manifestFile.readAsString()) as Map<String, Object?>;
  final fixtureById = <String, Map<String, Object?>>{
    for (final raw in manifest['fixtures']! as List<Object?>)
      (raw! as Map<String, Object?>)['id']! as String:
          raw as Map<String, Object?>,
  };
  const classifier = DeterministicDocumentClassifier();
  final extractor = DeterministicExtractionPipeline();

  var classificationsCorrect = 0;
  var extractionFieldsCorrect = 0;
  var extractionFieldsExpected = 0;
  final records = result['records']! as List<Object?>;
  for (final rawRecord in records) {
    final record = rawRecord! as Map<String, Object?>;
    final fixtureId = record['fixture_id']! as String;
    final fixture = fixtureById[fixtureId]!;
    final lines = (record['lines']! as List<Object?>)
        .map((raw) => raw! as Map<String, Object?>)
        .map(
          (line) => OcrLine(
            text: line['text']! as String,
            confidence: (line['confidence'] as num?)?.toDouble(),
          ),
        )
        .toList(growable: false);
    final document = OcrDocument(lines: lines);
    final classification = classifier.classify(document);
    final extraction = extractor.extract(
      document,
      classification,
      'benchmark_$fixtureId',
    );
    final expectedType = _typeFor(fixture['kind']! as String);
    final classificationCorrect = classification.documentType == expectedType;
    if (classificationCorrect) classificationsCorrect += 1;

    final expected = (fixture['important_fields']! as Map<String, Object?>).map(
      (key, value) => MapEntry(key, value! as String),
    );
    final actual = {
      for (final field in extraction.fields) field.key: field.value,
    };
    final supportedKeys = _supportedFieldsFor(expectedType);
    final supportedExpected = expected.entries
        .where((entry) => supportedKeys.contains(entry.key))
        .toList(growable: false);
    final correct = supportedExpected
        .where(
          (entry) =>
              actual.containsKey(entry.key) &&
              _normalize(actual[entry.key]!) == _normalize(entry.value),
        )
        .length;
    extractionFieldsCorrect += correct;
    extractionFieldsExpected += supportedExpected.length;
    record['project_pipeline'] = <String, Object?>{
      'classification': classification.documentType.name,
      'classification_expected': expectedType.name,
      'classification_correct': classificationCorrect,
      'title': extraction.title,
      'fields': actual,
      'supported_expected_fields_correct': correct,
      'supported_expected_fields_total': supportedExpected.length,
      'supported_expected_fields_missing': supportedExpected
          .map((entry) => entry.key)
          .where((key) => !actual.containsKey(key))
          .toList(growable: false),
      'important_fields_not_currently_extracted': expected.keys
          .where((key) => !supportedKeys.contains(key))
          .toList(growable: false),
    };
  }
  result['project_pipeline_summary'] = <String, Object?>{
    'records': records.length,
    'classifications_correct': classificationsCorrect,
    'classification_accuracy': classificationsCorrect / records.length,
    'supported_extraction_fields_correct': extractionFieldsCorrect,
    'supported_extraction_fields_total': extractionFieldsExpected,
    'supported_extraction_field_accuracy': extractionFieldsExpected == 0
        ? null
        : extractionFieldsCorrect / extractionFieldsExpected,
    'note':
        'Unsupported fixture fields are reported per record and are not counted '
        'as OCR errors or silently treated as extraction successes.',
  };
  await resultFile.writeAsString(
    '${const JsonEncoder.withIndent('  ').convert(result)}\n',
  );
}

DocumentType _typeFor(String value) => switch (value) {
  'receipt' => DocumentType.receipt,
  'warranty' => DocumentType.warranty,
  'identity' => DocumentType.identity,
  'travel' => DocumentType.travel,
  'product' => DocumentType.product,
  'genericDocument' => DocumentType.genericDocument,
  _ => throw FormatException('Unknown fixture document type: $value'),
};

Set<String> _supportedFieldsFor(DocumentType type) => switch (type) {
  DocumentType.receipt => const {'purchaseDate', 'total', 'currency'},
  DocumentType.warranty => const {'model', 'serialNumber', 'expiryDate'},
  DocumentType.identity => const {'documentNumber'},
  DocumentType.travel => const {
    'carrier',
    'bookingReference',
    'departure',
    'arrival',
  },
  DocumentType.product => const {'brand', 'model', 'serialNumber'},
  DocumentType.genericDocument || DocumentType.unknown => const {},
};

String _normalize(String value) => value
    .toUpperCase()
    .replaceAll(RegExp(r'[^A-Z0-9./:-]+'), ' ')
    .trim()
    .replaceAll(RegExp(r'\s+'), ' ');
