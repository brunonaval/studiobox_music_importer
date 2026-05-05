import 'import_operation_dry_run_item.dart';

class ImportOperationDryRunPlan {
  const ImportOperationDryRunPlan({
    required this.items,
    required this.warnings,
  });

  final List<ImportOperationDryRunItem> items;
  final List<String> warnings;

  int get totalCount => items.length;

  int get readyCount => items.where((item) => item.isReady).length;

  int get blockedCount => items.where((item) => item.isBlocked).length;

  bool get hasItems => items.isNotEmpty;

  bool get hasReadyItems => readyCount > 0;

  bool get hasBlockedItems => blockedCount > 0;

  bool get hasWarnings => warnings.isNotEmpty;
}
