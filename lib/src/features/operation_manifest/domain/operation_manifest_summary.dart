class OperationManifestSummary {
  const OperationManifestSummary({
    required this.totalCount,
    required this.readyCount,
    required this.skippedCount,
    required this.blockedCount,
    required this.warningCount,
  });

  final int totalCount;
  final int readyCount;
  final int skippedCount;
  final int blockedCount;
  final int warningCount;

  bool get hasWarnings => warningCount > 0;

  bool get hasBlockedItems => blockedCount > 0;

  bool get hasReadyItems => readyCount > 0;

  Map<String, dynamic> toMap() {
    return {
      'totalCount': totalCount,
      'readyCount': readyCount,
      'skippedCount': skippedCount,
      'blockedCount': blockedCount,
      'warningCount': warningCount,
    };
  }
}
