import 'import_operation_execution_result_item.dart';

class ImportOperationExecutionResult {
  const ImportOperationExecutionResult({
    required this.items,
    required this.warnings,
  });

  final List<ImportOperationExecutionResultItem> items;
  final List<String> warnings;

  int get totalCount => items.length;
  int get renamedCount => items.where((item) => item.isRenamed).length;
  int get copiedCount => items.where((item) => item.isCopied).length;
  int get movedCount => items.where((item) => item.isMoved).length;
  int get skippedCount => items.where((item) => item.isSkipped).length;
  int get failedCount => items.where((item) => item.isFailed).length;
  int get successCount => items.where((item) => item.isSuccess).length;
  bool get hasSuccessItems => successCount > 0;
  bool get hasSkippedItems => skippedCount > 0;
  bool get hasFailedItems => failedCount > 0;
  bool get hasWarnings => warnings.isNotEmpty;
}
