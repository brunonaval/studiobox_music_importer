import 'import_candidate_selection_item.dart';
import 'import_candidate_selection_plan.dart';
import 'import_candidate_selection_status.dart';
import 'import_candidate_status.dart';
import 'import_suggestion_candidate.dart';
import 'import_suggestion_plan.dart';

class ImportCandidateSelectionPlanner {
  ImportCandidateSelectionPlan buildInitialPlan(
    ImportSuggestionPlan suggestionPlan,
  ) {
    final items = suggestionPlan.candidates
        .map(_buildSelectionItem)
        .toList(growable: false);

    final hasBlocked = items.any((item) => item.isBlocked);
    final hasNeedsReview = suggestionPlan.candidates.any(
      (candidate) => candidate.status == ImportCandidateStatus.needsReview,
    );
    final hasDuplicate = suggestionPlan.candidates.any(
      (candidate) => candidate.duplicateMatch != null,
    );

    final warnings = <String>[];
    if (hasBlocked) {
      warnings.add('Existem candidatos bloqueados.');
    }
    if (hasNeedsReview) {
      warnings.add('Existem candidatos aguardando revisao.');
    }
    if (hasDuplicate) {
      warnings.add('Existem possiveis duplicados.');
    }

    return ImportCandidateSelectionPlan(
      items: List.unmodifiable(items),
      warnings: List.unmodifiable(warnings),
    );
  }

  ImportCandidateSelectionItem _buildSelectionItem(
    ImportSuggestionCandidate candidate,
  ) {
    final warnings = <String>[...candidate.warnings];

    if (candidate.status == ImportCandidateStatus.blocked) {
      warnings.add('Candidato bloqueado nao pode ser selecionado.');
      return ImportCandidateSelectionItem(
        id: _buildStableId(candidate),
        candidate: candidate,
        selectionStatus: ImportCandidateSelectionStatus.blocked,
        selectable: false,
        warnings: List.unmodifiable(warnings),
      );
    }

    if (candidate.status == ImportCandidateStatus.autoApproved &&
        candidate.duplicateMatch == null) {
      return ImportCandidateSelectionItem(
        id: _buildStableId(candidate),
        candidate: candidate,
        selectionStatus: ImportCandidateSelectionStatus.selected,
        selectable: true,
        warnings: List.unmodifiable(warnings),
      );
    }

    if (candidate.duplicateMatch != null) {
      warnings.add('Possivel duplicado; revise antes de selecionar.');
    } else if (candidate.status == ImportCandidateStatus.needsReview &&
        warnings.isEmpty) {
      warnings.add('Candidato precisa de revisao antes da importacao.');
    }

    return ImportCandidateSelectionItem(
      id: _buildStableId(candidate),
      candidate: candidate,
      selectionStatus: ImportCandidateSelectionStatus.notSelected,
      selectable: true,
      warnings: List.unmodifiable(warnings),
    );
  }

  String _buildStableId(ImportSuggestionCandidate candidate) {
    final code = candidate.suggestedCode ?? '';
    final officialName = candidate.suggestedOfficialFileName ?? '';
    return '${candidate.originalFileName}||$officialName||$code';
  }
}
