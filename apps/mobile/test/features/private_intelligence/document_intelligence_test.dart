import 'package:flutter_test/flutter_test.dart';
import 'package:life_timeline/features/private_intelligence/domain/document_intelligence.dart';
import 'package:life_timeline/features/private_intelligence/domain/intelligence_models.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';

void main() {
  const classifier = DeterministicDocumentClassifier();
  final extraction = DeterministicExtractionPipeline();

  test('receipt classification and extraction are deterministic', () {
    const document = OcrDocument(
      lines: [
        OcrLine(text: 'Corner Market'),
        OcrLine(text: '2026-08-09'),
        OcrLine(text: 'Subtotal 10.00'),
        OcrLine(text: 'Tax 0.80'),
        OcrLine(text: 'TOTAL USD 10.80'),
      ],
    );
    final classification = classifier.classify(document);
    final result = extraction.extract(document, classification, 'candidate');

    expect(classification.documentType, DocumentType.receipt);
    expect(result.title, 'Purchase at Corner Market');
    expect(
      result.fields.where((field) => field.key == 'total').single.value,
      '10.80',
    );
    expect(
      result.fields.where((field) => field.key == 'purchaseDate').single.value,
      '2026-08-09',
    );
    expect(result.entityProposals.single.name, 'Corner Market');
  });

  test('identity numbers are never-share and always require review', () {
    const document = OcrDocument(
      lines: [
        OcrLine(text: 'PASSPORT'),
        OcrLine(text: 'Document number: A1234567'),
        OcrLine(text: 'Nationality Example'),
      ],
    );
    final classification = classifier.classify(document);
    final result = extraction.extract(document, classification, 'identity');
    final number = result.fields.single;

    expect(classification.documentType, DocumentType.identity);
    expect(number.key, 'documentNumber');
    expect(number.privacyClassification, PrivacyClassification.neverShare);
    expect(number.reviewRecommended, isTrue);
  });

  test('short or empty text remains unknown instead of inventing content', () {
    const document = OcrDocument(lines: [OcrLine(text: 'blur')]);
    final result = classifier.classify(document);

    expect(result.documentType, DocumentType.unknown);
    expect(result.confidence, lessThan(0.5));
  });
}
