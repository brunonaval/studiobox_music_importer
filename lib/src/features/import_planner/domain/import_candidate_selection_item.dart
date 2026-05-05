import 'import_candidate_selection_status.dart';
import 'import_candidate_status.dart';
import 'import_suggestion_candidate.dart';

class ImportCandidateSelectionItem {
  const ImportCandidateSelectionItem({
    required this.id,
    required this.candidate,
    required this.selectionStatus,
    required this.selectable,
    required this.warnings,
  });

  final String id;
  final ImportSuggestionCandidate candidate;
  final ImportCandidateSelectionStatus selectionStatus;
  final bool selectable;
  final List<String> warnings;

  bool get isSelected =>
      selectionStatus == ImportCandidateSelectionStatus.selected;

  bool get isNotSelected =>
      selectionStatus == ImportCandidateSelectionStatus.notSelected;

  bool get isBlocked =>
      selectionStatus == ImportCandidateSelectionStatus.blocked;

  bool get hasWarnings => warnings.isNotEmpty;

  bool get isReadyWithoutDuplicate =>
      candidate.status == ImportCandidateStatus.autoApproved &&
      candidate.duplicateMatch == null;

  ImportCandidateSelectionItem copyWith({
    ImportCandidateSelectionStatus? selectionStatus,
    List<String>? warnings,
  }) {
    return ImportCandidateSelectionItem(
      id: id,
      candidate: candidate,
      selectionStatus: selectionStatus ?? this.selectionStatus,
      selectable: selectable,
      warnings: warnings ?? this.warnings,
    );
  }
}
