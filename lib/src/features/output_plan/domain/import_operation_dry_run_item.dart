import 'import_operation_action.dart';
import 'import_operation_dry_run_item_status.dart';

class ImportOperationDryRunItem {
  const ImportOperationDryRunItem({
    required this.id,
    required this.action,
    required this.status,
    required this.originalFileName,
    required this.cleanedFileName,
    required this.displayPath,
    required this.sourcePathPreview,
    required this.destinationPathPreview,
    required this.officialFileName,
    required this.artist,
    required this.title,
    required this.code,
    required this.warnings,
  });

  final String id;
  final ImportOperationAction action;
  final ImportOperationDryRunItemStatus status;
  final String originalFileName;
  final String cleanedFileName;
  final String displayPath;
  final String? sourcePathPreview;
  final String? destinationPathPreview;
  final String officialFileName;
  final String? artist;
  final String? title;
  final String? code;
  final List<String> warnings;

  bool get isReady => status == ImportOperationDryRunItemStatus.ready;

  bool get isBlocked => status == ImportOperationDryRunItemStatus.blocked;

  bool get hasWarnings => warnings.isNotEmpty;

  bool get hasSource =>
      sourcePathPreview != null && sourcePathPreview!.isNotEmpty;

  bool get hasDestination =>
      destinationPathPreview != null && destinationPathPreview!.isNotEmpty;

  ImportOperationDryRunItem copyWith({
    ImportOperationDryRunItemStatus? status,
    String? destinationPathPreview,
    List<String>? warnings,
  }) {
    return ImportOperationDryRunItem(
      id: id,
      action: action,
      status: status ?? this.status,
      originalFileName: originalFileName,
      cleanedFileName: cleanedFileName,
      displayPath: displayPath,
      sourcePathPreview: sourcePathPreview,
      destinationPathPreview:
          destinationPathPreview ?? this.destinationPathPreview,
      officialFileName: officialFileName,
      artist: artist,
      title: title,
      code: code,
      warnings: warnings ?? this.warnings,
    );
  }
}
