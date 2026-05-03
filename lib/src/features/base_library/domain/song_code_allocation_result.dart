class SongCodeAllocationResult {
  const SongCodeAllocationResult({required this.codes, required this.warnings});

  final List<String> codes;
  final List<String> warnings;

  bool get hasWarnings => warnings.isNotEmpty;

  bool get isEmpty => codes.isEmpty;
}
