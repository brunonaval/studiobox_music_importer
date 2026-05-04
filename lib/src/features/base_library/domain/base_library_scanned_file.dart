class BaseLibraryScannedFile {
  BaseLibraryScannedFile({
    required String fileName,
    required String fullPath,
    required String relativePath,
  }) : fileName = fileName.trim(),
       fullPath = fullPath.trim(),
       relativePath = _resolveRelativePath(
         relativePath: relativePath,
         fileName: fileName,
       );

  final String fileName;
  final String fullPath;
  final String relativePath;

  bool get hasFullPath => fullPath.isNotEmpty;

  bool get hasRelativePath => relativePath.isNotEmpty;

  static String _resolveRelativePath({
    required String relativePath,
    required String fileName,
  }) {
    final trimmedRelative = relativePath.trim();
    if (trimmedRelative.isNotEmpty) {
      return trimmedRelative;
    }
    return fileName.trim();
  }
}
