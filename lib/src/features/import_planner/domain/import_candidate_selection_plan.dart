import 'import_candidate_selection_item.dart';
import 'import_candidate_selection_status.dart';

class ImportCandidateSelectionPlan {
  const ImportCandidateSelectionPlan({
    required this.items,
    required this.warnings,
  });

  final List<ImportCandidateSelectionItem> items;
  final List<String> warnings;

  int get totalCount => items.length;

  int get selectedCount => items.where((item) => item.isSelected).length;

  int get notSelectedCount => items.where((item) => item.isNotSelected).length;

  int get blockedCount => items.where((item) => item.isBlocked).length;

  int get selectableCount => items.where((item) => item.selectable).length;

  bool get hasSelectedItems => selectedCount > 0;

  bool get hasBlockedItems => blockedCount > 0;

  bool get hasWarnings => warnings.isNotEmpty;

  ImportCandidateSelectionPlan withCandidateSelection(
    String id,
    bool selected,
  ) {
    var changed = false;
    final updatedItems = items
        .map((item) {
          if (item.id != id) {
            return item;
          }
          if (!item.selectable) {
            return item;
          }

          final nextStatus = selected
              ? ImportCandidateSelectionStatus.selected
              : ImportCandidateSelectionStatus.notSelected;

          if (item.selectionStatus == nextStatus) {
            return item;
          }

          changed = true;
          return item.copyWith(selectionStatus: nextStatus);
        })
        .toList(growable: false);

    if (!changed) {
      return this;
    }

    return ImportCandidateSelectionPlan(
      items: List.unmodifiable(updatedItems),
      warnings: warnings,
    );
  }

  ImportCandidateSelectionPlan selectAllReady() {
    var changed = false;

    final updatedItems = items
        .map((item) {
          if (!item.selectable) {
            return item;
          }

          final nextStatus = item.isReadyWithoutDuplicate
              ? ImportCandidateSelectionStatus.selected
              : ImportCandidateSelectionStatus.notSelected;

          if (item.selectionStatus == nextStatus) {
            return item;
          }

          changed = true;
          return item.copyWith(selectionStatus: nextStatus);
        })
        .toList(growable: false);

    if (!changed) {
      return this;
    }

    return ImportCandidateSelectionPlan(
      items: List.unmodifiable(updatedItems),
      warnings: warnings,
    );
  }

  ImportCandidateSelectionPlan clearSelection() {
    var changed = false;

    final updatedItems = items
        .map((item) {
          if (!item.selectable) {
            return item;
          }

          if (item.selectionStatus ==
              ImportCandidateSelectionStatus.notSelected) {
            return item;
          }

          changed = true;
          return item.copyWith(
            selectionStatus: ImportCandidateSelectionStatus.notSelected,
          );
        })
        .toList(growable: false);

    if (!changed) {
      return this;
    }

    return ImportCandidateSelectionPlan(
      items: List.unmodifiable(updatedItems),
      warnings: warnings,
    );
  }
}
