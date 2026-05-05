import 'import_candidate_edit_status.dart';
import 'import_candidate_selection_item.dart';

class ImportCandidateEditItem {
  const ImportCandidateEditItem({
    required this.id,
    required this.selectionItem,
    required this.artist,
    required this.title,
    required this.code,
    required this.officialFileName,
    required this.editStatus,
    required this.editable,
    required this.warnings,
  });

  final String id;
  final ImportCandidateSelectionItem selectionItem;
  final String artist;
  final String title;
  final String code;
  final String officialFileName;
  final ImportCandidateEditStatus editStatus;
  final bool editable;
  final List<String> warnings;

  bool get isValid => editStatus == ImportCandidateEditStatus.valid;

  bool get isInvalid => editStatus == ImportCandidateEditStatus.invalid;

  bool get isBlocked => editStatus == ImportCandidateEditStatus.blocked;

  bool get hasWarnings => warnings.isNotEmpty;

  ImportCandidateEditItem copyWith({
    String? artist,
    String? title,
    String? code,
  }) {
    return ImportCandidateEditItem(
      id: id,
      selectionItem: selectionItem,
      artist: artist ?? this.artist,
      title: title ?? this.title,
      code: code ?? this.code,
      officialFileName: officialFileName,
      editStatus: editStatus,
      editable: editable,
      warnings: warnings,
    );
  }
}
