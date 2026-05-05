import 'import_candidate_edit_item.dart';
import 'import_candidate_edit_planner.dart';

class ImportCandidateEditPlan {
  const ImportCandidateEditPlan({
    required this.items,
    required this.warnings,
    required this.usedCodes,
  });

  final List<ImportCandidateEditItem> items;
  final List<String> warnings;
  final Set<String> usedCodes;

  int get totalCount => items.length;

  int get editableCount => items.where((item) => item.editable).length;

  int get validCount => items.where((item) => item.isValid).length;

  int get invalidCount => items.where((item) => item.isInvalid).length;

  int get blockedCount => items.where((item) => item.isBlocked).length;

  bool get hasValidItems => validCount > 0;

  bool get hasInvalidItems => invalidCount > 0;

  bool get hasBlockedItems => blockedCount > 0;

  bool get hasWarnings => warnings.isNotEmpty;

  ImportCandidateEditPlan withManualEdit({
    required String id,
    String? artist,
    String? title,
    String? code,
  }) {
    var changed = false;

    final updated = items
        .map((item) {
          if (item.id != id) {
            return item;
          }
          if (!item.editable) {
            return item;
          }

          final nextArtist = artist ?? item.artist;
          final nextTitle = title ?? item.title;
          final nextCode = code ?? item.code;

          if (nextArtist == item.artist &&
              nextTitle == item.title &&
              nextCode == item.code) {
            return item;
          }

          changed = true;
          return item.copyWith(
            artist: nextArtist,
            title: nextTitle,
            code: nextCode,
          );
        })
        .toList(growable: false);

    if (!changed) {
      return this;
    }

    return ImportCandidateEditPlanner.revalidatePlan(
      items: updated,
      usedCodes: usedCodes,
    );
  }

  ImportCandidateEditPlan resetCandidate(String id) {
    var changed = false;

    final updated = items
        .map((item) {
          if (item.id != id) {
            return item;
          }
          if (!item.editable) {
            return item;
          }

          final candidate = item.selectionItem.candidate;
          final resetArtist = candidate.analysis.detectedArtist ?? '';
          final resetTitle = candidate.analysis.detectedTitle ?? '';
          final resetCode = candidate.suggestedCode ?? '';

          if (item.artist == resetArtist &&
              item.title == resetTitle &&
              item.code == resetCode) {
            return item;
          }

          changed = true;
          return item.copyWith(
            artist: resetArtist,
            title: resetTitle,
            code: resetCode,
          );
        })
        .toList(growable: false);

    if (!changed) {
      return this;
    }

    return ImportCandidateEditPlanner.revalidatePlan(
      items: updated,
      usedCodes: usedCodes,
    );
  }
}
