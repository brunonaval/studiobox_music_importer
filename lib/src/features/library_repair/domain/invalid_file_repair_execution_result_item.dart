import 'invalid_file_repair_execution_result_item_status.dart';

class InvalidFileRepairExecutionResultItem {
  const InvalidFileRepairExecutionResultItem({
    required this.originalFileName,
    required this.originalReason,
    this.detectedArtist,
    this.detectedTitle,
    this.suggestedCode,
    this.sourcePath,
    this.destinationPath,
    this.suggestedFileName,
    required this.status,
    required this.messages,
  });

  final String originalFileName;
  final String originalReason;
  final String? detectedArtist;
  final String? detectedTitle;
  final String? suggestedCode;
  final String? sourcePath;
  final String? destinationPath;
  final String? suggestedFileName;
  final InvalidFileRepairExecutionResultItemStatus status;
  final List<String> messages;

  bool get isRenamed =>
      status == InvalidFileRepairExecutionResultItemStatus.renamed;

  bool get isSkipped =>
      status == InvalidFileRepairExecutionResultItemStatus.skipped;

  bool get isFailed =>
      status == InvalidFileRepairExecutionResultItemStatus.failed;

  bool get hasMessages => messages.isNotEmpty;
}
