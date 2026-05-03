import 'incoming_song_parse_confidence.dart';

class IncomingSongNameAnalysis {
  const IncomingSongNameAnalysis({
    required this.originalFileName,
    required this.cleanedName,
    required this.detectedArtist,
    required this.detectedTitle,
    required this.detectedExtra,
    required this.confidence,
    required this.warnings,
  });

  final String originalFileName;
  final String cleanedName;
  final String? detectedArtist;
  final String? detectedTitle;
  final String? detectedExtra;
  final IncomingSongParseConfidence confidence;
  final List<String> warnings;

  bool get isUsable {
    final artist = detectedArtist?.trim() ?? '';
    final title = detectedTitle?.trim() ?? '';
    return confidence != IncomingSongParseConfidence.failed &&
        artist.isNotEmpty &&
        title.isNotEmpty;
  }

  bool get hasWarnings => warnings.isNotEmpty;

  bool get hasExtra => (detectedExtra?.trim().isNotEmpty ?? false);
}
