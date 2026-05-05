class ImportOperationManifestSummary {
  const ImportOperationManifestSummary({
    required this.totalCount,
    required this.renamedCount,
    required this.copiedCount,
    required this.movedCount,
    required this.skippedCount,
    required this.failedCount,
    required this.successCount,
  });

  final int totalCount;
  final int renamedCount;
  final int copiedCount;
  final int movedCount;
  final int skippedCount;
  final int failedCount;
  final int successCount;

  bool get hasFailures => failedCount > 0;
  bool get hasSkipped => skippedCount > 0;
  bool get hasSuccess => successCount > 0;
}
