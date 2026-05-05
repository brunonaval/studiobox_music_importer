class IncomingSongScannedFile {
  IncomingSongScannedFile({
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

  String get displayPath => relativePath.isNotEmpty ? relativePath : fileName;

  static String _resolveRelativePath({
    required String relativePath,
    required String fileName,
  }) {
    final trimmed = relativePath.trim();
    return trimmed.isNotEmpty ? trimmed : fileName.trim();
  }
}
