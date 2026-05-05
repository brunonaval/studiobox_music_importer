import 'import_output_mode.dart';

class ImportOutputConfiguration {
  const ImportOutputConfiguration({
    required this.mode,
    required this.incomingSongsFolderPath,
    required this.officialLibraryFolderPath,
    required this.customOutputFolderPath,
  });

  final ImportOutputMode mode;
  final String? incomingSongsFolderPath;
  final String? officialLibraryFolderPath;
  final String? customOutputFolderPath;

  bool get requiresIncomingFolder => true;

  bool get requiresOfficialLibraryFolder => mode.targetsOfficialLibrary;

  bool get requiresCustomOutputFolder => mode.targetsCustomFolder;

  String? get targetFolderPath {
    switch (mode) {
      case ImportOutputMode.renameInIncomingFolder:
        return incomingSongsFolderPath;
      case ImportOutputMode.copyToOfficialLibrary:
      case ImportOutputMode.moveToOfficialLibrary:
        return officialLibraryFolderPath;
      case ImportOutputMode.copyToCustomFolder:
      case ImportOutputMode.moveToCustomFolder:
        return customOutputFolderPath;
    }
  }

  bool get hasTargetFolder =>
      (targetFolderPath != null && targetFolderPath!.trim().isNotEmpty);
}
