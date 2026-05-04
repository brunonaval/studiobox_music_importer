import 'invalid_file_repair_item.dart';

class InvalidFileRepairPlan {
  const InvalidFileRepairPlan({required this.items, required this.warnings});

  final List<InvalidFileRepairItem> items;
  final List<String> warnings;

  int get totalCount => items.length;

  int get readyToSuggestCount =>
      items.where((item) => item.isReadyToSuggest).length;

  int get needsReviewCount => items.where((item) => item.needsReview).length;

  int get blockedCount => items.where((item) => item.isBlocked).length;

  bool get hasItems => items.isNotEmpty;

  bool get hasWarnings =>
      warnings.isNotEmpty || items.any((item) => item.hasWarnings);

  bool get hasBlockedItems => items.any((item) => item.isBlocked);

  bool get hasReviewItems => items.any((item) => item.needsReview);
}
