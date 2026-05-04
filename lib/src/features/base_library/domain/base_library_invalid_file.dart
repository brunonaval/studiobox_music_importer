class BaseLibraryInvalidFile {
  const BaseLibraryInvalidFile({
    required this.fileName,
    required this.reason,
    this.fullPath,
    this.relativePath,
  });

  final String fileName;
  final String reason;
  final String? fullPath;
  final String? relativePath;

  String get displayPath {
    final trimmedRelative = relativePath?.trim();
    if (trimmedRelative != null && trimmedRelative.isNotEmpty) {
      return trimmedRelative;
    }
    return fileName;
  }
}
