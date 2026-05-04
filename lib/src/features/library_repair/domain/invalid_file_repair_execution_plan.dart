import 'invalid_file_repair_execution_item.dart';

class InvalidFileRepairExecutionPlan {
  const InvalidFileRepairExecutionPlan({
    required this.items,
    required this.warnings,
  });

  final List<InvalidFileRepairExecutionItem> items;
  final List<String> warnings;

  int get totalCount => items.length;

  int get readyToRenameCount =>
      items.where((item) => item.isReadyToRename).length;

  int get skippedCount => items.where((item) => item.isSkipped).length;

  int get blockedCount => items.where((item) => item.isBlocked).length;

  bool get hasReadyItems => items.any((item) => item.isReadyToRename);

  bool get hasSkippedItems => items.any((item) => item.isSkipped);

  bool get hasBlockedItems => items.any((item) => item.isBlocked);

  bool get hasWarnings =>
      warnings.isNotEmpty || items.any((item) => item.hasWarnings);
}
