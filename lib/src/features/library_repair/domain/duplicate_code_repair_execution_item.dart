import 'duplicate_code_repair_execution_item_status.dart';

class DuplicateCodeRepairExecutionItem {
  const DuplicateCodeRepairExecutionItem({
    required this.originalCode,
    required this.suggestedCode,
    required this.artist,
    required this.title,
    required this.originalFileName,
    required this.displayPath,
    required this.sourcePathPreview,
    required this.destinationPathPreview,
    required this.suggestedFileName,
    required this.status,
    required this.warnings,
  });

  final String originalCode;
  final String? suggestedCode;
  final String artist;
  final String title;
  final String originalFileName;
  final String displayPath;
  final String? sourcePathPreview;
  final String? destinationPathPreview;
  final String? suggestedFileName;
  final DuplicateCodeRepairExecutionItemStatus status;
  final List<String> warnings;

  bool get isReadyToRename =>
      status == DuplicateCodeRepairExecutionItemStatus.readyToRename;

  bool get isSkipped =>
      status == DuplicateCodeRepairExecutionItemStatus.skippedKeepOriginal;

  bool get isBlocked =>
      status == DuplicateCodeRepairExecutionItemStatus.blocked;

  bool get hasWarnings => warnings.isNotEmpty;
}
