import 'package:life_timeline/features/private_intelligence/domain/intelligence_models.dart';
import 'package:life_timeline/shared/domain/model/record_metadata.dart';

final class OcrLine {
  const OcrLine({required this.text, this.confidence});

  final double? confidence;
  final String text;
}

final class OcrDocument {
  const OcrDocument({required this.lines});

  final List<OcrLine> lines;
  String get text => lines.map((line) => line.text).join('\n');
  bool get isEmpty => lines.every((line) => line.text.trim().isEmpty);
}

abstract interface class TextRecognitionEngine {
  Future<OcrDocument> recognize(String imagePath);
  Future<void> close();
}

abstract interface class DocumentExtractor {
  DocumentType get type;
  ExtractionResult extract(OcrDocument document, String idPrefix);
}

final class DeterministicDocumentClassifier {
  const DeterministicDocumentClassifier();

  ClassificationResult classify(OcrDocument document) {
    final text = document.text.toLowerCase();
    final scores = <DocumentType, List<String>>{};
    void evidence(DocumentType type, String token, [double weight = 1]) {
      if (text.contains(token)) {
        scores.putIfAbsent(type, () => []).add(token);
        if (weight > 1) {
          scores[type]!.add(token);
        }
      }
    }

    for (final token in ['total', 'subtotal', 'tax', 'receipt', 'change']) {
      evidence(DocumentType.receipt, token);
    }
    for (final token in [
      'warranty',
      'guarantee',
      'coverage',
      'proof of purchase',
    ]) {
      evidence(DocumentType.warranty, token, 2);
    }
    for (final token in [
      'passport',
      'identity card',
      'date of birth',
      'nationality',
    ]) {
      evidence(DocumentType.identity, token, 2);
    }
    for (final token in [
      'boarding pass',
      'flight',
      'departure',
      'arrival',
      'booking',
    ]) {
      evidence(DocumentType.travel, token);
    }
    for (final token in ['serial', 'model', 'product', 'imei']) {
      evidence(DocumentType.product, token);
    }
    if (scores.isEmpty) {
      return ClassificationResult(
        documentType: document.text.trim().length >= 20
            ? DocumentType.genericDocument
            : DocumentType.unknown,
        confidence: document.text.trim().length >= 20 ? 0.45 : 0.1,
        reasons: const ['No strong document-specific markers'],
      );
    }
    final ordered = scores.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));
    final winner = ordered.first;
    final confidence = (0.45 + winner.value.length * 0.09).clamp(0.0, 0.94);
    return ClassificationResult(
      documentType: winner.key,
      confidence: confidence,
      reasons: winner.value.toSet().map((token) => 'Found “$token”').toList(),
    );
  }
}

final class DeterministicExtractionPipeline {
  DeterministicExtractionPipeline({List<DocumentExtractor>? extractors})
    : _extractors = {
        for (final extractor in extractors ?? _defaultExtractors)
          extractor.type: extractor,
      };

  static const _defaultExtractors = <DocumentExtractor>[
    ReceiptDocumentExtractor(),
    WarrantyDocumentExtractor(),
    ProductDocumentExtractor(),
    TravelDocumentExtractor(),
    IdentityDocumentExtractor(),
    GenericDocumentExtractor(),
  ];

  final Map<DocumentType, DocumentExtractor> _extractors;

  ExtractionResult extract(
    OcrDocument document,
    ClassificationResult classification,
    String idPrefix,
  ) =>
      (_extractors[classification.documentType] ??
              _extractors[DocumentType.genericDocument]!)
          .extract(document, idPrefix);
}

abstract base class RegexDocumentExtractor implements DocumentExtractor {
  const RegexDocumentExtractor();

  List<String> cleanLines(OcrDocument document) => document.lines
      .map((line) => line.text.trim())
      .where((line) => line.isNotEmpty)
      .toList();

  ExtractedField field(
    String idPrefix,
    int index,
    String key,
    String value, {
    ExtractedValueType type = ExtractedValueType.text,
    double confidence = 0.7,
    PrivacyClassification privacy = PrivacyClassification.personal,
    bool review = false,
  }) => ExtractedField(
    id: '${idPrefix}_field_$index',
    key: key,
    value: value.trim(),
    valueType: type,
    confidence: confidence,
    privacyClassification: privacy,
    extractionMethod: 'deterministic_ocr',
    sourceExcerpt: value.trim(),
    reviewRecommended: review || confidence < 0.7,
  );

  String titleFrom(List<String> lines, String fallback) => lines.firstWhere(
    (line) => line.length >= 3 && line.length <= 80,
    orElse: () => fallback,
  );

  ({String amount, String? currency})? moneyFrom(String text) {
    final match = RegExp(
      r'(?:(USD|EUR|GBP|PHP|CNY|JPY|AUD|CAD)\s*)?([$€£¥₱]?\s*\d{1,3}(?:[,.]\d{3})*(?:[,.]\d{2}))',
      caseSensitive: false,
    ).firstMatch(text);
    if (match == null) {
      return null;
    }
    final symbol = match.group(2)?.trimLeft().substring(0, 1);
    final currency =
        match.group(1)?.toUpperCase() ??
        switch (symbol) {
          r'$' => 'USD',
          '€' => 'EUR',
          '£' => 'GBP',
          '¥' => 'JPY/CNY',
          '₱' => 'PHP',
          _ => null,
        };
    return (amount: match.group(2)!.trim(), currency: currency);
  }

  String? valueAfterLabel(List<String> lines, RegExp label) {
    for (final line in lines) {
      final match = label.firstMatch(line);
      if (match != null) {
        final value = line
            .substring(match.end)
            .replaceFirst(RegExp(r'^\s*[:#-]?\s*'), '');
        if (value.isNotEmpty) {
          return value;
        }
      }
    }
    return null;
  }
}

final class ReceiptDocumentExtractor extends RegexDocumentExtractor {
  const ReceiptDocumentExtractor();
  @override
  DocumentType get type => DocumentType.receipt;

  @override
  ExtractionResult extract(OcrDocument document, String idPrefix) {
    final lines = cleanLines(document);
    final fields = <ExtractedField>[];
    final totalLine = lines.reversed.firstWhere(
      (line) =>
          RegExp(r'\b(grand\s+)?total\b', caseSensitive: false).hasMatch(line),
      orElse: () => '',
    );
    final total = moneyFrom(totalLine);
    if (total != null) {
      fields.add(
        field(
          idPrefix,
          fields.length,
          'total',
          total.amount,
          type: ExtractedValueType.money,
          confidence: 0.88,
        ),
      );
      if (total.currency != null) {
        fields.add(
          field(
            idPrefix,
            fields.length,
            'currency',
            total.currency!,
            confidence: 0.76,
          ),
        );
      }
    }
    final date = _firstDate(lines);
    if (date != null) {
      fields.add(
        field(
          idPrefix,
          fields.length,
          'purchaseDate',
          date,
          type: ExtractedValueType.date,
          confidence: 0.72,
        ),
      );
    }
    final merchant = titleFrom(lines, 'Receipt');
    fields.insert(
      0,
      field(idPrefix, 99, 'merchant', merchant, confidence: 0.74),
    );
    return ExtractionResult(
      title: merchant == 'Receipt' ? merchant : 'Purchase at $merchant',
      description: total == null ? null : 'Receipt total ${total.amount}',
      fields: fields,
      entityProposals: [
        EntityProposal(
          id: '${idPrefix}_entity_0',
          name: merchant,
          entityType: 'organization',
          confidence: 0.7,
        ),
      ],
      overallConfidence: total == null ? 0.55 : 0.79,
    );
  }
}

final class WarrantyDocumentExtractor extends RegexDocumentExtractor {
  const WarrantyDocumentExtractor();
  @override
  DocumentType get type => DocumentType.warranty;
  @override
  ExtractionResult extract(OcrDocument document, String idPrefix) {
    final lines = cleanLines(document);
    final fields = <ExtractedField>[];
    for (final entry in <String, RegExp>{
      'serialNumber': RegExp(
        r'\b(serial(?:\s+number)?|s/n)\b',
        caseSensitive: false,
      ),
      'model': RegExp(r'\bmodel\b', caseSensitive: false),
      'expiryDate': RegExp(
        r'\b(expir(?:y|es)|valid until)\b',
        caseSensitive: false,
      ),
    }.entries) {
      final value = valueAfterLabel(lines, entry.value);
      if (value != null) {
        fields.add(
          field(
            idPrefix,
            fields.length,
            entry.key,
            value,
            type: entry.key == 'expiryDate'
                ? ExtractedValueType.date
                : ExtractedValueType.identifier,
            confidence: 0.72,
            privacy: entry.key == 'serialNumber'
                ? PrivacyClassification.sensitive
                : PrivacyClassification.personal,
          ),
        );
      }
    }
    final product =
        valueAfterLabel(lines, RegExp(r'\bproduct\b', caseSensitive: false)) ??
        titleFrom(lines, 'Warranty');
    return ExtractionResult(
      title: 'Warranty for $product',
      fields: fields,
      entityProposals: [
        EntityProposal(
          id: '${idPrefix}_entity_0',
          name: product,
          entityType: 'product',
          confidence: 0.67,
          serialNumber: _fieldValue(fields, 'serialNumber'),
          model: _fieldValue(fields, 'model'),
        ),
      ],
      overallConfidence: fields.isEmpty ? 0.48 : 0.72,
    );
  }
}

final class ProductDocumentExtractor extends RegexDocumentExtractor {
  const ProductDocumentExtractor();
  @override
  DocumentType get type => DocumentType.product;
  @override
  ExtractionResult extract(OcrDocument document, String idPrefix) {
    final lines = cleanLines(document);
    final fields = <ExtractedField>[];
    for (final entry in <String, RegExp>{
      'brand': RegExp(r'\bbrand\b', caseSensitive: false),
      'model': RegExp(r'\bmodel\b', caseSensitive: false),
      'serialNumber': RegExp(
        r'\b(serial(?:\s+number)?|s/n|imei)\b',
        caseSensitive: false,
      ),
    }.entries) {
      final value = valueAfterLabel(lines, entry.value);
      if (value != null) {
        fields.add(
          field(
            idPrefix,
            fields.length,
            entry.key,
            value,
            type: entry.key == 'serialNumber'
                ? ExtractedValueType.identifier
                : ExtractedValueType.text,
            confidence: 0.73,
            privacy: entry.key == 'serialNumber'
                ? PrivacyClassification.sensitive
                : PrivacyClassification.personal,
          ),
        );
      }
    }
    final name = _fieldValue(fields, 'model') ?? titleFrom(lines, 'Product');
    return ExtractionResult(
      title: name,
      fields: fields,
      entityProposals: [
        EntityProposal(
          id: '${idPrefix}_entity_0',
          name: name,
          entityType: 'product',
          confidence: 0.68,
          brand: _fieldValue(fields, 'brand'),
          model: _fieldValue(fields, 'model'),
          serialNumber: _fieldValue(fields, 'serialNumber'),
        ),
      ],
      overallConfidence: fields.isEmpty ? 0.45 : 0.7,
    );
  }
}

final class TravelDocumentExtractor extends RegexDocumentExtractor {
  const TravelDocumentExtractor();
  @override
  DocumentType get type => DocumentType.travel;
  @override
  ExtractionResult extract(OcrDocument document, String idPrefix) {
    final lines = cleanLines(document);
    final fields = <ExtractedField>[];
    for (final entry in <String, RegExp>{
      'carrier': RegExp(r'\b(carrier|airline)\b', caseSensitive: false),
      'bookingReference': RegExp(
        r'\b(booking|reservation|pnr)\b',
        caseSensitive: false,
      ),
      'departure': RegExp(r'\bdeparture\b', caseSensitive: false),
      'arrival': RegExp(r'\barrival\b', caseSensitive: false),
    }.entries) {
      final value = valueAfterLabel(lines, entry.value);
      if (value != null) {
        fields.add(
          field(
            idPrefix,
            fields.length,
            entry.key,
            value,
            confidence: 0.68,
            privacy: entry.key == 'bookingReference'
                ? PrivacyClassification.sensitive
                : PrivacyClassification.personal,
          ),
        );
      }
    }
    return ExtractionResult(
      title: titleFrom(lines, 'Travel document'),
      fields: fields,
      entityProposals: const [],
      overallConfidence: fields.isEmpty ? 0.45 : 0.68,
    );
  }
}

final class IdentityDocumentExtractor extends RegexDocumentExtractor {
  const IdentityDocumentExtractor();
  @override
  DocumentType get type => DocumentType.identity;
  @override
  ExtractionResult extract(OcrDocument document, String idPrefix) {
    final lines = cleanLines(document);
    final fields = <ExtractedField>[];
    final number = valueAfterLabel(
      lines,
      RegExp(
        r'\b(document|passport|id)(\s+number|\s+no)?\b',
        caseSensitive: false,
      ),
    );
    if (number != null) {
      fields.add(
        field(
          idPrefix,
          0,
          'documentNumber',
          number,
          type: ExtractedValueType.identifier,
          confidence: 0.55,
          privacy: PrivacyClassification.neverShare,
          review: true,
        ),
      );
    }
    return ExtractionResult(
      title: 'Identity document',
      fields: fields,
      entityProposals: const [],
      overallConfidence: 0.45,
    );
  }
}

final class GenericDocumentExtractor extends RegexDocumentExtractor {
  const GenericDocumentExtractor();
  @override
  DocumentType get type => DocumentType.genericDocument;
  @override
  ExtractionResult extract(OcrDocument document, String idPrefix) {
    final lines = cleanLines(document);
    return ExtractionResult(
      title: titleFrom(lines, 'Scanned document'),
      fields: const [],
      entityProposals: const [],
      overallConfidence: lines.isEmpty ? 0.1 : 0.42,
    );
  }
}

String? _fieldValue(List<ExtractedField> fields, String key) {
  for (final field in fields) {
    if (field.key == key) {
      return field.value;
    }
  }
  return null;
}

String? _firstDate(List<String> lines) {
  final pattern = RegExp(
    r'\b(?:\d{4}[-/.]\d{1,2}[-/.]\d{1,2}|\d{1,2}[-/.]\d{1,2}[-/.]\d{2,4})\b',
  );
  for (final line in lines) {
    final match = pattern.firstMatch(line);
    if (match != null) {
      return match.group(0);
    }
  }
  return null;
}
