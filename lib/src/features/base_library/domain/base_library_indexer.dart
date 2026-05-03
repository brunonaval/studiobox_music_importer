import 'dart:collection';

import 'base_library_duplicate_code.dart';
import 'base_library_index_entry.dart';
import 'base_library_index_result.dart';
import 'base_library_invalid_file.dart';
import 'official_song_parser.dart';

class BaseLibraryIndexer {
  BaseLibraryIndexer({OfficialSongParser? parser})
    : _parser = parser ?? OfficialSongParser();

  final OfficialSongParser _parser;

  BaseLibraryIndexResult indexFileNames(List<String> fileNames) {
    final entries = <BaseLibraryIndexEntry>[];
    final invalidFiles = <BaseLibraryInvalidFile>[];
    final usedCodes = SplayTreeSet<String>();
    final knownArtists = SplayTreeSet<String>();

    for (final fileName in fileNames) {
      final parseResult = _parser.parseFileName(fileName);

      if (parseResult.isFailure) {
        invalidFiles.add(
          BaseLibraryInvalidFile(
            fileName: fileName,
            reason: parseResult.reason ?? 'Falha ao processar arquivo.',
          ),
        );
        continue;
      }

      final song = parseResult.song!;
      final entry = BaseLibraryIndexEntry(
        song: song,
        originalFileName: fileName,
      );
      entries.add(entry);
      usedCodes.add(entry.code);
      knownArtists.add(entry.artist);
    }

    entries.sort((a, b) {
      final byCode = a.code.compareTo(b.code);
      if (byCode != 0) {
        return byCode;
      }

      final byArtist = a.artist.compareTo(b.artist);
      if (byArtist != 0) {
        return byArtist;
      }

      return a.title.compareTo(b.title);
    });

    final entriesByCode = <String, List<BaseLibraryIndexEntry>>{};
    for (final entry in entries) {
      entriesByCode
          .putIfAbsent(entry.code, () => <BaseLibraryIndexEntry>[])
          .add(entry);
    }

    final duplicateCodes =
        entriesByCode.entries
            .where((group) => group.value.length > 1)
            .map(
              (group) => BaseLibraryDuplicateCode(
                code: group.key,
                entries: List.unmodifiable(group.value),
              ),
            )
            .toList()
          ..sort((a, b) => a.code.compareTo(b.code));

    final maxCodeNumber = usedCodes.isEmpty
        ? null
        : usedCodes
              .map(int.parse)
              .reduce((max, next) => next > max ? next : max);

    final availableCodeGaps = <String>[];
    if (maxCodeNumber != null) {
      for (var number = 1; number <= maxCodeNumber; number++) {
        final code = number.toString().padLeft(5, '0');
        if (!usedCodes.contains(code)) {
          availableCodeGaps.add(code);
        }
      }
    }

    return BaseLibraryIndexResult(
      entries: List.unmodifiable(entries),
      invalidFiles: List.unmodifiable(invalidFiles),
      duplicateCodes: List.unmodifiable(duplicateCodes),
      usedCodes: Set.unmodifiable(usedCodes),
      availableCodeGaps: List.unmodifiable(availableCodeGaps),
      maxCodeNumber: maxCodeNumber,
      knownArtists: Set.unmodifiable(knownArtists),
    );
  }
}
