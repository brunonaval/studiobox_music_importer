import 'output_operation_item.dart';
import 'output_operation_item_status.dart';
import 'output_operation_mode.dart';
import 'output_transfer_action.dart';

class OutputOperationPlan {
  const OutputOperationPlan({
    required this.mode,
    required this.transferAction,
    required this.items,
    required this.warnings,
  });

  final OutputOperationMode mode;
  final OutputTransferAction transferAction;
  final List<OutputOperationItem> items;
  final List<String> warnings;

  int get totalCount => items.length;

  int get readyCount => items
      .where((item) => item.status == OutputOperationItemStatus.ready)
      .length;

  int get skippedCount => items
      .where((item) => item.status == OutputOperationItemStatus.skipped)
      .length;

  int get blockedCount => items
      .where((item) => item.status == OutputOperationItemStatus.blocked)
      .length;

  bool get hasWarnings => warnings.isNotEmpty;

  bool get hasReadyItems => readyCount > 0;

  bool get hasBlockedItems => blockedCount > 0;
}
