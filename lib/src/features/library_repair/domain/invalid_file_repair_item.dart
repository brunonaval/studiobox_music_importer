import '../../incoming_songs/domain/incoming_song_name_analysis.dart';
import 'invalid_file_repair_item_status.dart';

class InvalidFileRepairItem {
  const InvalidFileRepairItem({
    required this.originalFileName,
    required this.originalReason,
    required this.displayPath,
    this.fullPath,
    this.relativePath,
    required this.analysis,
    this.suggestedCode,
    this.suggestedFileName,
    required this.status,
    required this.warnings,
  });

  final String originalFileName;
  final String originalReason;
  final String displayPath;
  final String? fullPath;
  final String? relativePath;
  final IncomingSongNameAnalysis analysis;
  final String? suggestedCode;
  final String? suggestedFileName;
  final InvalidFileRepairItemStatus status;
  final List<String> warnings;

  bool get hasSuggestedCode => suggestedCode != null;

  bool get hasSuggestedFileName => suggestedFileName != null;

  bool get isReadyToSuggest =>
      status == InvalidFileRepairItemStatus.readyToSuggest;

  bool get needsReview => status == InvalidFileRepairItemStatus.needsReview;

  bool get isBlocked => status == InvalidFileRepairItemStatus.blocked;

  bool get hasWarnings => warnings.isNotEmpty;
}
