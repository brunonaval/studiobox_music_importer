import '../../base_library/domain/base_library_index_entry.dart';
import '../../base_library/domain/base_library_index_result.dart';
import '../../base_library/domain/song_code_allocation_strategy.dart';
import '../../base_library/domain/song_code_allocator.dart';
import '../../incoming_songs/domain/incoming_song_name_analysis.dart';
import '../../incoming_songs/domain/incoming_song_name_parser.dart';
import '../../incoming_songs/domain/incoming_song_parse_confidence.dart';
import 'import_candidate_status.dart';
import 'import_duplicate_match.dart';
import 'import_suggestion_candidate.dart';
import 'import_suggestion_plan.dart';

class ImportSuggestionPlanner {
  ImportSuggestionPlanner({
    IncomingSongNameParser? nameParser,
    SongCodeAllocator? codeAllocator,
  }) : _nameParser = nameParser ?? IncomingSongNameParser(),
       _codeAllocator = codeAllocator ?? SongCodeAllocator();

  final IncomingSongNameParser _nameParser;
  final SongCodeAllocator _codeAllocator;

  ImportSuggestionPlan buildPlan({
    required List<String> incomingFileNames,
    required BaseLibraryIndexResult baseIndex,
    required SongCodeAllocationStrategy codeStrategy,
  }) {
    final analyses = incomingFileNames
        .map(
          (fileName) => _nameParser.analyzeFileName(
            fileName: fileName,
            knownArtists: baseIndex.knownArtists,
          ),
        )
        .toList(growable: false);

    final usableCount = analyses.where((analysis) => analysis.isUsable).length;

    final allocation = _codeAllocator.allocateCodes(
      usedCodes: baseIndex.usedCodes,
      availableCodeGaps: baseIndex.availableCodeGaps,
      maxCodeNumber: baseIndex.maxCodeNumber,
      quantity: usableCount,
      strategy: codeStrategy,
    );

    final duplicateLookup = _buildDuplicateLookup(baseIndex.entries);
    final planWarnings = <String>[...allocation.warnings];

    final candidates = <ImportSuggestionCandidate>[];
    var codeIndex = 0;

    for (var i = 0; i < incomingFileNames.length; i++) {
      final originalFileName = incomingFileNames[i];
      final analysis = analyses[i];
      final warnings = <String>[...analysis.warnings];

      String? suggestedCode;
      String? suggestedOfficialFileName;
      ImportDuplicateMatch? duplicateMatch;

      if (analysis.isUsable) {
        if (codeIndex < allocation.codes.length) {
          suggestedCode = allocation.codes[codeIndex];
          codeIndex++;
        } else {
          warnings.add('Codigo nao disponivel para este item.');
        }

        final artist = analysis.detectedArtist!.trim();
        final title = analysis.detectedTitle!.trim();
        final duplicate = duplicateLookup[_duplicateKey(artist, title)];
        if (duplicate != null) {
          duplicateMatch = ImportDuplicateMatch(
            existingCode: duplicate.code,
            existingArtist: duplicate.artist,
            existingTitle: duplicate.title,
          );
          warnings.add('Possivel duplicidade encontrada na biblioteca base.');
        }

        if (suggestedCode != null) {
          suggestedOfficialFileName = _buildOfficialFileName(
            artist: artist,
            title: title,
            code: suggestedCode,
          );
        }
      }

      final status = _resolveStatus(
        analysis: analysis,
        suggestedCode: suggestedCode,
        duplicateMatch: duplicateMatch,
      );

      candidates.add(
        ImportSuggestionCandidate(
          originalFileName: originalFileName,
          analysis: analysis,
          suggestedCode: suggestedCode,
          suggestedOfficialFileName: suggestedOfficialFileName,
          status: status,
          duplicateMatch: duplicateMatch,
          warnings: List.unmodifiable(warnings),
        ),
      );
    }

    if (candidates.any((candidate) => candidate.isBlocked)) {
      planWarnings.add(
        'Existem itens bloqueados que precisam de correcao manual.',
      );
    }

    return ImportSuggestionPlan(
      candidates: List.unmodifiable(candidates),
      warnings: List.unmodifiable(planWarnings),
    );
  }

  String _buildOfficialFileName({
    required String artist,
    required String title,
    required String code,
  }) {
    return '$artist - $title - $code.mp4';
  }

  Map<String, BaseLibraryIndexEntry> _buildDuplicateLookup(
    List<BaseLibraryIndexEntry> entries,
  ) {
    final lookup = <String, BaseLibraryIndexEntry>{};

    for (final entry in entries) {
      final key = _duplicateKey(entry.artist, entry.title);
      lookup.putIfAbsent(key, () => entry);
    }

    return lookup;
  }

  String _duplicateKey(String artist, String title) {
    return '${artist.trim().toLowerCase()}|${title.trim().toLowerCase()}';
  }

  ImportCandidateStatus _resolveStatus({
    required IncomingSongNameAnalysis analysis,
    required String? suggestedCode,
    required ImportDuplicateMatch? duplicateMatch,
  }) {
    if (!analysis.isUsable || suggestedCode == null) {
      return ImportCandidateStatus.blocked;
    }

    if (analysis.confidence == IncomingSongParseConfidence.high &&
        !analysis.hasWarnings &&
        duplicateMatch == null) {
      return ImportCandidateStatus.autoApproved;
    }

    return ImportCandidateStatus.needsReview;
  }
}
