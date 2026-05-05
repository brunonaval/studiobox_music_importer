class ImportOperationManifestWriteResult {
  const ImportOperationManifestWriteResult({
    required this.success,
    required this.filePath,
    required this.messages,
  });

  final bool success;
  final String? filePath;
  final List<String> messages;

  bool get hasMessages => messages.isNotEmpty;
}
