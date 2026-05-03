class OperationManifestItem {
  const OperationManifestItem({
    required this.originalFileName,
    required this.suggestedOfficialFileName,
    required this.sourcePathPreview,
    required this.destinationPathPreview,
    required this.sourceFolderPath,
    required this.destinationFolderPath,
    required this.action,
    required this.status,
    required this.warnings,
  });

  final String originalFileName;
  final String? suggestedOfficialFileName;
  final String? sourcePathPreview;
  final String? destinationPathPreview;
  final String? sourceFolderPath;
  final String? destinationFolderPath;
  final String action;
  final String status;
  final List<String> warnings;

  bool get hasWarnings => warnings.isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'originalFileName': originalFileName,
      'suggestedOfficialFileName': suggestedOfficialFileName,
      'sourcePathPreview': sourcePathPreview,
      'destinationPathPreview': destinationPathPreview,
      'sourceFolderPath': sourceFolderPath,
      'destinationFolderPath': destinationFolderPath,
      'action': action,
      'status': status,
      'warnings': warnings,
    };
  }
}
