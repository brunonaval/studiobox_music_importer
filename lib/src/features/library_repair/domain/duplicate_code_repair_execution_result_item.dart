import 'duplicate_code_repair_execution_result_item_status.dart';

class DuplicateCodeRepairExecutionResultItem {
  const DuplicateCodeRepairExecutionResultItem({
    required this.artist,
    required this.title,
    required this.originalCode,
    required this.suggestedCode,
    required this.sourcePath,
    required this.destinationPath,
    required this.suggestedFileName,
    required this.status,
    required this.messages,
  });

  final String artist;
  final String title;
  final String originalCode;
  final String? suggestedCode;
  final String? sourcePath;
  final String? destinationPath;
  final String? suggestedFileName;
  final DuplicateCodeRepairExecutionResultItemStatus status;
  final List<String> messages;

  bool get isRenamed =>
      status == DuplicateCodeRepairExecutionResultItemStatus.renamed;

  bool get isSkipped =>
      status == DuplicateCodeRepairExecutionResultItemStatus.skipped;

  bool get isFailed =>
      status == DuplicateCodeRepairExecutionResultItemStatus.failed;

  bool get hasMessages => messages.isNotEmpty;
}
