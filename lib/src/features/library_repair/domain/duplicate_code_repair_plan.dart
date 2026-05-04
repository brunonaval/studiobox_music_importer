import 'duplicate_code_repair_group.dart';

class DuplicateCodeRepairPlan {
  const DuplicateCodeRepairPlan({required this.groups, required this.warnings});

  final List<DuplicateCodeRepairGroup> groups;
  final List<String> warnings;

  int get totalGroups => groups.length;

  int get totalItems =>
      groups.fold(0, (total, group) => total + group.totalItems);

  int get totalKeepOriginal =>
      groups.fold(0, (total, group) => total + group.keepOriginalCount);

  int get totalAssignNewCode =>
      groups.fold(0, (total, group) => total + group.assignNewCodeCount);

  int get totalBlocked =>
      groups.fold(0, (total, group) => total + group.blockedCount);

  bool get hasGroups => groups.isNotEmpty;

  bool get hasWarnings =>
      warnings.isNotEmpty || groups.any((group) => group.hasWarnings);

  bool get hasBlockedItems => groups.any((group) => group.hasBlockedItems);
}
