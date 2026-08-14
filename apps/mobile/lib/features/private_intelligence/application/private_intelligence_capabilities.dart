/// Central capability state for optional private-intelligence engines.
///
/// Presentation code observes this value instead of checking platforms or
/// implementation packages directly. The domain and stored candidate model
/// remain available while a local OCR engine is temporarily absent.
final class PrivateIntelligenceCapabilities {
  const PrivateIntelligenceCapabilities({
    required this.textRecognitionAvailable,
    required this.documentExtractionAvailable,
  }) : assert(
         !documentExtractionAvailable || textRecognitionAvailable,
         'Document extraction requires a local text-recognition engine.',
       );

  const PrivateIntelligenceCapabilities.localOcr()
    : textRecognitionAvailable = true,
      documentExtractionAvailable = true;

  const PrivateIntelligenceCapabilities.manualDocumentsOnly()
    : textRecognitionAvailable = false,
      documentExtractionAvailable = false;

  final bool documentExtractionAvailable;
  final bool textRecognitionAvailable;
}
