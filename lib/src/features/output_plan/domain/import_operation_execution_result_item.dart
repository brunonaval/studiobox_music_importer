import 'import_operation_action.dart';
import 'import_operation_execution_result_item_status.dart';

class ImportOperationExecutionResultItem {
  const ImportOperationExecutionResultItem({
    required this.id,
    required this.action,
    required this.status,
    required this.originalFileName,
    required this.officialFileName,
    required this.sourcePath,
    required this.destinationPath,
    required this.messages,
  });

  final String id;
  final ImportOperationAction action;
  final ImportOperationExecutionResultItemStatus status;
  final String originalFileName;
  final String officialFileName;
  final String? sourcePath;
  final String? destinationPath;
  final List<String> messages;

  bool get isRenamed =>
      status == ImportOperationExecutionResultItemStatus.renamed;
  bool get isCopied =>
      status == ImportOperationExecutionResultItemStatus.copied;
  bool get isMoved => status == ImportOperationExecutionResultItemStatus.moved;
  bool get isSkipped =>
      status == ImportOperationExecutionResultItemStatus.skipped;
  bool get isFailed =>
      status == ImportOperationExecutionResultItemStatus.failed;
  bool get isSuccess => isRenamed || isCopied || isMoved;
  bool get hasMessages => messages.isNotEmpty;
}
