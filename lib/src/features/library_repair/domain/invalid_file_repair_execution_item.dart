import 'invalid_file_repair_execution_item_status.dart';

class InvalidFileRepairExecutionItem {
  const InvalidFileRepairExecutionItem({
    required this.originalFileName,
    required this.originalReason,
    required this.displayPath,
    this.fullPath,
    this.relativePath,
    this.suggestedCode,
    this.suggestedFileName,
    this.sourcePathPreview,
    this.destinationPathPreview,
    this.detectedArtist,
    this.detectedTitle,
    required this.status,
    required this.warnings,
  });

  final String originalFileName;
  final String originalReason;
  final String displayPath;
  final String? fullPath;
  final String? relativePath;
  final String? suggestedCode;
  final String? suggestedFileName;
  final String? sourcePathPreview;
  final String? destinationPathPreview;
  final String? detectedArtist;
  final String? detectedTitle;
  final InvalidFileRepairExecutionItemStatus status;
  final List<String> warnings;

  bool get isReadyToRename =>
      status == InvalidFileRepairExecutionItemStatus.readyToRename;

  bool get isSkipped =>
      status == InvalidFileRepairExecutionItemStatus.skippedNeedsReview;

  bool get isBlocked => status == InvalidFileRepairExecutionItemStatus.blocked;

  bool get hasWarnings => warnings.isNotEmpty;

  bool get hasDestination => destinationPathPreview != null;
}
