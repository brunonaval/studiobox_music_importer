import '../../incoming_songs/domain/incoming_song_name_analysis.dart';
import 'import_candidate_status.dart';
import 'import_duplicate_match.dart';

class ImportSuggestionCandidate {
  const ImportSuggestionCandidate({
    required this.originalFileName,
    required this.analysis,
    required this.suggestedCode,
    required this.suggestedOfficialFileName,
    required this.status,
    required this.duplicateMatch,
    required this.warnings,
  });

  final String originalFileName;
  final IncomingSongNameAnalysis analysis;
  final String? suggestedCode;
  final String? suggestedOfficialFileName;
  final ImportCandidateStatus status;
  final ImportDuplicateMatch? duplicateMatch;
  final List<String> warnings;

  bool get hasSuggestedCode => suggestedCode != null;

  bool get hasDuplicate => duplicateMatch != null;

  bool get isBlocked => status == ImportCandidateStatus.blocked;

  bool get needsReview => status == ImportCandidateStatus.needsReview;
}
