import 'duplicate_code_repair_item.dart';

class DuplicateCodeRepairGroup {
  const DuplicateCodeRepairGroup({
    required this.duplicatedCode,
    required this.items,
    required this.warnings,
  });

  final String duplicatedCode;
  final List<DuplicateCodeRepairItem> items;
  final List<String> warnings;

  int get totalItems => items.length;

  int get keepOriginalCount =>
      items.where((item) => item.keepsOriginalCode).length;

  int get assignNewCodeCount =>
      items.where((item) => item.assignsNewCode).length;

  int get blockedCount => items.where((item) => item.isBlocked).length;

  bool get hasWarnings =>
      warnings.isNotEmpty || items.any((item) => item.hasWarnings);

  bool get hasBlockedItems => items.any((item) => item.isBlocked);
}
