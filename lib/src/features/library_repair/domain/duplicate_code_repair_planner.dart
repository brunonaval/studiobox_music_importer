import '../../base_library/domain/base_library.dart';
import 'duplicate_code_repair_group.dart';
import 'duplicate_code_repair_item.dart';
import 'duplicate_code_repair_item_status.dart';
import 'duplicate_code_repair_plan.dart';

class DuplicateCodeRepairPlanner {
  DuplicateCodeRepairPlanner({SongCodeAllocator? allocator})
    : _allocator = allocator ?? SongCodeAllocator();

  final SongCodeAllocator _allocator;

  DuplicateCodeRepairPlan buildPlan({
    required BaseLibraryIndexResult baseIndex,
    SongCodeAllocationStrategy codeStrategy =
        SongCodeAllocationStrategy.afterHighestExisting,
  }) {
    if (baseIndex.duplicateCodes.isEmpty) {
      return const DuplicateCodeRepairPlan(groups: [], warnings: []);
    }

    final sortedGroups = baseIndex.duplicateCodes.toList()
      ..sort((a, b) => a.code.compareTo(b.code));

    final totalCodesNeeded = sortedGroups.fold<int>(
      0,
      (total, group) => total + (group.entries.length - 1),
    );

    final allocationResult = _allocator.allocateCodes(
      usedCodes: baseIndex.usedCodes,
      availableCodeGaps: baseIndex.availableCodeGaps,
      maxCodeNumber: baseIndex.maxCodeNumber,
      quantity: totalCodesNeeded,
      strategy: codeStrategy,
    );

    var allocationIndex = 0;
    final groups = <DuplicateCodeRepairGroup>[];

    for (final duplicate in sortedGroups) {
      final sortedEntries = _sortedEntries(duplicate.entries);
      final items = <DuplicateCodeRepairItem>[];

      for (var i = 0; i < sortedEntries.length; i++) {
        final entry = sortedEntries[i];

        if (i == 0) {
          items.add(
            DuplicateCodeRepairItem(
              originalCode: duplicate.code,
              suggestedCode: null,
              artist: entry.song.artist,
              title: entry.song.title,
              originalFileName: entry.originalFileName,
              fullPath: entry.fullPath,
              relativePath: entry.relativePath,
              displayPath: entry.displayPath,
              suggestedFileName: null,
              status: DuplicateCodeRepairItemStatus.keepOriginalCode,
              warnings: const [],
            ),
          );
          continue;
        }

        String? suggestedCode;
        if (allocationIndex < allocationResult.codes.length) {
          suggestedCode = allocationResult.codes[allocationIndex];
          allocationIndex++;
        }

        if (suggestedCode != null) {
          items.add(
            DuplicateCodeRepairItem(
              originalCode: duplicate.code,
              suggestedCode: suggestedCode,
              artist: entry.song.artist,
              title: entry.song.title,
              originalFileName: entry.originalFileName,
              fullPath: entry.fullPath,
              relativePath: entry.relativePath,
              displayPath: entry.displayPath,
              suggestedFileName: _buildSuggestedFileName(
                artist: entry.song.artist,
                title: entry.song.title,
                code: suggestedCode,
              ),
              status: DuplicateCodeRepairItemStatus.assignNewCode,
              warnings: const [],
            ),
          );
        } else {
          items.add(
            DuplicateCodeRepairItem(
              originalCode: duplicate.code,
              suggestedCode: null,
              artist: entry.song.artist,
              title: entry.song.title,
              originalFileName: entry.originalFileName,
              fullPath: entry.fullPath,
              relativePath: entry.relativePath,
              displayPath: entry.displayPath,
              suggestedFileName: null,
              status: DuplicateCodeRepairItemStatus.blocked,
              warnings: const [
                'Codigo novo indisponivel para reparar este item.',
              ],
            ),
          );
        }
      }

      groups.add(
        DuplicateCodeRepairGroup(
          duplicatedCode: duplicate.code,
          items: List.unmodifiable(items),
          warnings: const [],
        ),
      );
    }

    final warnings = <String>[...allocationResult.warnings];
    final hasBlocked = groups.any((group) => group.hasBlockedItems);
    if (hasBlocked) {
      warnings.add(
        'Existem reparos bloqueados por falta de codigos disponiveis.',
      );
    }

    return DuplicateCodeRepairPlan(
      groups: List.unmodifiable(groups),
      warnings: List.unmodifiable(warnings),
    );
  }

  String _buildSuggestedFileName({
    required String artist,
    required String title,
    required String code,
  }) {
    return '$artist - $title - $code.mp4';
  }

  List<BaseLibraryIndexEntry> _sortedEntries(
    List<BaseLibraryIndexEntry> entries,
  ) {
    final sorted = entries.toList()
      ..sort((a, b) {
        final byPath = a.displayPath.compareTo(b.displayPath);
        if (byPath != 0) {
          return byPath;
        }

        final byArtist = a.artist.compareTo(b.artist);
        if (byArtist != 0) {
          return byArtist;
        }

        return a.title.compareTo(b.title);
      });
    return sorted;
  }
}
