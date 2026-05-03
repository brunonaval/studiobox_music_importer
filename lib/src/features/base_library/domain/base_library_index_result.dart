import 'base_library_duplicate_code.dart';
import 'base_library_index_entry.dart';
import 'base_library_invalid_file.dart';

class BaseLibraryIndexResult {
  const BaseLibraryIndexResult({
    required this.entries,
    required this.invalidFiles,
    required this.duplicateCodes,
    required this.usedCodes,
    required this.availableCodeGaps,
    required this.maxCodeNumber,
    required this.knownArtists,
  });

  final List<BaseLibraryIndexEntry> entries;
  final List<BaseLibraryInvalidFile> invalidFiles;
  final List<BaseLibraryDuplicateCode> duplicateCodes;
  final Set<String> usedCodes;
  final List<String> availableCodeGaps;
  final int? maxCodeNumber;
  final Set<String> knownArtists;

  int get validCount => entries.length;

  int get invalidCount => invalidFiles.length;

  int get duplicateCodeCount => duplicateCodes.length;

  bool get hasDuplicates => duplicateCodes.isNotEmpty;

  bool get hasInvalidFiles => invalidFiles.isNotEmpty;
}
