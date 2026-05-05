import 'invalid_file_repair_execution_result_item.dart';

class InvalidFileRepairExecutionResult {
  const InvalidFileRepairExecutionResult({
    required this.items,
    required this.warnings,
  });

  final List<InvalidFileRepairExecutionResultItem> items;
  final List<String> warnings;

  int get totalCount => items.length;

  int get renamedCount => items.where((item) => item.isRenamed).length;

  int get skippedCount => items.where((item) => item.isSkipped).length;

  int get failedCount => items.where((item) => item.isFailed).length;

  bool get hasRenamedItems => items.any((item) => item.isRenamed);

  bool get hasSkippedItems => items.any((item) => item.isSkipped);

  bool get hasFailedItems => items.any((item) => item.isFailed);

  bool get hasWarnings => warnings.isNotEmpty;
}
