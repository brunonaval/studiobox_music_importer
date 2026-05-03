import 'song_code_allocation_result.dart';
import 'song_code_allocation_strategy.dart';

class SongCodeAllocator {
  static const int minCode = 1;
  static const int maxCode = 99999;

  SongCodeAllocationResult allocateCodes({
    required Set<String> usedCodes,
    required List<String> availableCodeGaps,
    required int? maxCodeNumber,
    required int quantity,
    required SongCodeAllocationStrategy strategy,
  }) {
    if (quantity <= 0) {
      return const SongCodeAllocationResult(codes: [], warnings: []);
    }

    final unavailable = <int>{};
    for (final code in usedCodes) {
      final parsed = _parseCode(code);
      if (parsed != null) {
        unavailable.add(parsed);
      }
    }

    final allocated = <int>[];
    final allocatedSet = <int>{};

    if (strategy == SongCodeAllocationStrategy.fillGapsFirst) {
      final normalizedGaps = _normalizedGapNumbers(
        availableCodeGaps,
        unavailable,
      );

      for (final gap in normalizedGaps) {
        if (allocated.length >= quantity) {
          break;
        }

        if (allocatedSet.contains(gap) || unavailable.contains(gap)) {
          continue;
        }

        allocated.add(gap);
        allocatedSet.add(gap);
      }
    }

    var next = (maxCodeNumber ?? 0) + 1;
    while (allocated.length < quantity && next <= maxCode) {
      if (next >= minCode &&
          !unavailable.contains(next) &&
          !allocatedSet.contains(next)) {
        allocated.add(next);
        allocatedSet.add(next);
      }
      next++;
    }

    final warnings = <String>[];
    if (allocated.length < quantity) {
      warnings.add('Nao ha codigos disponiveis suficientes ate 99999.');
    }

    return SongCodeAllocationResult(
      codes: allocated.map(_formatCode).toList(growable: false),
      warnings: List.unmodifiable(warnings),
    );
  }

  String _formatCode(int value) => value.toString().padLeft(5, '0');

  int? _parseCode(String value) {
    final codeRegex = RegExp(r'^\d{5}$');
    if (!codeRegex.hasMatch(value)) {
      return null;
    }

    final number = int.tryParse(value);
    if (number == null || number < minCode || number > maxCode) {
      return null;
    }

    return number;
  }

  List<int> _normalizedGapNumbers(List<String> gaps, Set<int> unavailable) {
    final gapNumbers = <int>{};

    for (final gap in gaps) {
      final parsed = _parseCode(gap);
      if (parsed == null || unavailable.contains(parsed)) {
        continue;
      }
      gapNumbers.add(parsed);
    }

    final sorted = gapNumbers.toList()..sort();
    return sorted;
  }
}
