import '../../base_library/domain/base_library_index_result.dart';
import '../../base_library/domain/song_code_allocation_strategy.dart';
import '../../base_library/domain/song_code_allocator.dart';
import '../../incoming_songs/domain/incoming_song_name_analysis.dart';
import '../../incoming_songs/domain/incoming_song_name_parser.dart';
import '../../incoming_songs/domain/incoming_song_parse_confidence.dart';
import 'invalid_file_repair_item.dart';
import 'invalid_file_repair_item_status.dart';
import 'invalid_file_repair_plan.dart';

class InvalidFileRepairPlanner {
  final _parser = IncomingSongNameParser();
  final _allocator = SongCodeAllocator();

  InvalidFileRepairPlan buildPlan({
    required BaseLibraryIndexResult baseIndex,
    SongCodeAllocationStrategy codeStrategy =
        SongCodeAllocationStrategy.afterHighestExisting,
  }) {
    if (baseIndex.invalidFiles.isEmpty) {
      return const InvalidFileRepairPlan(items: [], warnings: []);
    }

    final analyses = <IncomingSongNameAnalysis>[];
    for (final invalid in baseIndex.invalidFiles) {
      analyses.add(
        _parser.analyzeFileName(
          fileName: invalid.fileName,
          knownArtists: baseIndex.knownArtists,
        ),
      );
    }

    final usableCount = analyses.where((a) => a.isUsable).length;

    final allocationResult = _allocator.allocateCodes(
      usedCodes: baseIndex.usedCodes,
      availableCodeGaps: baseIndex.availableCodeGaps,
      maxCodeNumber: baseIndex.maxCodeNumber,
      quantity: usableCount,
      strategy: codeStrategy,
    );

    var codeIndex = 0;
    final items = <InvalidFileRepairItem>[];

    for (var i = 0; i < baseIndex.invalidFiles.length; i++) {
      final invalid = baseIndex.invalidFiles[i];
      final analysis = analyses[i];
      final itemWarnings = <String>[];

      itemWarnings.add('Arquivo inválido: ${invalid.reason}');

      if (!analysis.isUsable) {
        itemWarnings.addAll(analysis.warnings);
        itemWarnings.add('Não foi possível detectar artista e música.');

        items.add(
          InvalidFileRepairItem(
            originalFileName: invalid.fileName,
            originalReason: invalid.reason,
            displayPath: invalid.displayPath,
            fullPath: invalid.fullPath,
            relativePath: invalid.relativePath,
            analysis: analysis,
            suggestedCode: null,
            suggestedFileName: null,
            status: InvalidFileRepairItemStatus.blocked,
            warnings: List.unmodifiable(itemWarnings),
          ),
        );
        continue;
      }

      itemWarnings.addAll(analysis.warnings);

      final String? code;
      if (codeIndex < allocationResult.codes.length) {
        code = allocationResult.codes[codeIndex];
        codeIndex++;
      } else {
        code = null;
      }

      if (code == null) {
        itemWarnings.add('Código novo indisponível para reparar este arquivo.');

        items.add(
          InvalidFileRepairItem(
            originalFileName: invalid.fileName,
            originalReason: invalid.reason,
            displayPath: invalid.displayPath,
            fullPath: invalid.fullPath,
            relativePath: invalid.relativePath,
            analysis: analysis,
            suggestedCode: null,
            suggestedFileName: null,
            status: InvalidFileRepairItemStatus.blocked,
            warnings: List.unmodifiable(itemWarnings),
          ),
        );
        continue;
      }

      final artist = analysis.detectedArtist!;
      final title = analysis.detectedTitle!;
      final suggestedFileName = '$artist - $title - $code.mp4';

      final InvalidFileRepairItemStatus status;
      if (analysis.confidence == IncomingSongParseConfidence.high &&
          !analysis.hasWarnings) {
        status = InvalidFileRepairItemStatus.readyToSuggest;
      } else {
        status = InvalidFileRepairItemStatus.needsReview;
      }

      items.add(
        InvalidFileRepairItem(
          originalFileName: invalid.fileName,
          originalReason: invalid.reason,
          displayPath: invalid.displayPath,
          fullPath: invalid.fullPath,
          relativePath: invalid.relativePath,
          analysis: analysis,
          suggestedCode: code,
          suggestedFileName: suggestedFileName,
          status: status,
          warnings: List.unmodifiable(itemWarnings),
        ),
      );
    }

    final planWarnings = <String>[];
    planWarnings.addAll(allocationResult.warnings);

    if (items.any((item) => item.isBlocked)) {
      planWarnings.add(
        'Existem arquivos inválidos bloqueados para reparo automático.',
      );
    }

    if (items.any((item) => item.needsReview)) {
      planWarnings.add(
        'Existem arquivos inválidos que precisam de revisão manual.',
      );
    }

    return InvalidFileRepairPlan(
      items: List.unmodifiable(items),
      warnings: List.unmodifiable(planWarnings),
    );
  }
}
