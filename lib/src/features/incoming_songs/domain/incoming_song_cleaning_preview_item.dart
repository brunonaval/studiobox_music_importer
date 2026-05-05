import 'incoming_song_scanned_file.dart';

class IncomingSongCleaningPreviewItem {
  const IncomingSongCleaningPreviewItem({
    required this.scannedFile,
    required this.originalFileName,
    required this.cleanedFileName,
    required this.appliedRules,
    required this.warnings,
  });

  final IncomingSongScannedFile scannedFile;
  final String originalFileName;
  final String cleanedFileName;
  final List<String> appliedRules;
  final List<String> warnings;

  bool get wasChanged => cleanedFileName != originalFileName;

  bool get hasWarnings => warnings.isNotEmpty;

  String get displayPath => scannedFile.displayPath;
}
