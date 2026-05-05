class ImportOperationManifestItem {
  const ImportOperationManifestItem({
    required this.id,
    required this.action,
    required this.status,
    required this.originalFileName,
    required this.officialFileName,
    required this.sourcePath,
    required this.destinationPath,
    required this.messages,
  });

  final String id;
  final String action;
  final String status;
  final String originalFileName;
  final String officialFileName;
  final String? sourcePath;
  final String? destinationPath;
  final List<String> messages;

  bool get hasMessages => messages.isNotEmpty;
}
