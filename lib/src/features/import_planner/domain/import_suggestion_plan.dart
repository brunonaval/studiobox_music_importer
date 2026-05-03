import 'import_candidate_status.dart';
import 'import_suggestion_candidate.dart';

class ImportSuggestionPlan {
  const ImportSuggestionPlan({
    required this.candidates,
    required this.warnings,
  });

  final List<ImportSuggestionCandidate> candidates;
  final List<String> warnings;

  int get totalCount => candidates.length;

  int get autoApprovedCount => candidates
      .where(
        (candidate) => candidate.status == ImportCandidateStatus.autoApproved,
      )
      .length;

  int get needsReviewCount =>
      candidates.where((candidate) => candidate.needsReview).length;

  int get blockedCount =>
      candidates.where((candidate) => candidate.isBlocked).length;

  bool get hasWarnings => warnings.isNotEmpty;

  bool get hasBlockedCandidates => blockedCount > 0;

  bool get hasReviewCandidates => needsReviewCount > 0;
}
