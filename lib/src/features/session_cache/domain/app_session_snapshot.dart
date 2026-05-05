class AppSessionSnapshot {
  factory AppSessionSnapshot({
    required String? officialLibraryFolderPath,
    required String? incomingSongsFolderPath,
    required String? customImportOutputFolderPath,
    required String? importManifestFolderPath,
    required String? importOutputModeName,
    required String? savedAtIso8601,
  }) {
    return AppSessionSnapshot._(
      officialLibraryFolderPath: _trimOrNull(officialLibraryFolderPath),
      incomingSongsFolderPath: _trimOrNull(incomingSongsFolderPath),
      customImportOutputFolderPath: _trimOrNull(customImportOutputFolderPath),
      importManifestFolderPath: _trimOrNull(importManifestFolderPath),
      importOutputModeName: _trimOrNull(importOutputModeName),
      savedAtIso8601: _trimOrNull(savedAtIso8601),
    );
  }

  const AppSessionSnapshot._({
    required this.officialLibraryFolderPath,
    required this.incomingSongsFolderPath,
    required this.customImportOutputFolderPath,
    required this.importManifestFolderPath,
    required this.importOutputModeName,
    required this.savedAtIso8601,
  });

  final String? officialLibraryFolderPath;
  final String? incomingSongsFolderPath;
  final String? customImportOutputFolderPath;
  final String? importManifestFolderPath;
  final String? importOutputModeName;
  final String? savedAtIso8601;

  bool get hasOfficialLibraryFolderPath =>
      officialLibraryFolderPath != null &&
      officialLibraryFolderPath!.isNotEmpty;
  bool get hasIncomingSongsFolderPath =>
      incomingSongsFolderPath != null && incomingSongsFolderPath!.isNotEmpty;
  bool get hasCustomImportOutputFolderPath =>
      customImportOutputFolderPath != null &&
      customImportOutputFolderPath!.isNotEmpty;
  bool get hasImportManifestFolderPath =>
      importManifestFolderPath != null && importManifestFolderPath!.isNotEmpty;
  bool get hasImportOutputModeName =>
      importOutputModeName != null && importOutputModeName!.isNotEmpty;
  bool get hasSavedAt => savedAtIso8601 != null && savedAtIso8601!.isNotEmpty;
  bool get isEmpty =>
      !hasOfficialLibraryFolderPath &&
      !hasIncomingSongsFolderPath &&
      !hasCustomImportOutputFolderPath &&
      !hasImportManifestFolderPath &&
      !hasImportOutputModeName &&
      !hasSavedAt;
  bool get isNotEmpty => !isEmpty;

  AppSessionSnapshot copyWith({
    String? officialLibraryFolderPath,
    String? incomingSongsFolderPath,
    String? customImportOutputFolderPath,
    String? importManifestFolderPath,
    String? importOutputModeName,
    String? savedAtIso8601,
  }) {
    return AppSessionSnapshot(
      officialLibraryFolderPath: _trimOrNull(
        officialLibraryFolderPath ?? this.officialLibraryFolderPath,
      ),
      incomingSongsFolderPath: _trimOrNull(
        incomingSongsFolderPath ?? this.incomingSongsFolderPath,
      ),
      customImportOutputFolderPath: _trimOrNull(
        customImportOutputFolderPath ?? this.customImportOutputFolderPath,
      ),
      importManifestFolderPath: _trimOrNull(
        importManifestFolderPath ?? this.importManifestFolderPath,
      ),
      importOutputModeName: _trimOrNull(
        importOutputModeName ?? this.importOutputModeName,
      ),
      savedAtIso8601: _trimOrNull(savedAtIso8601 ?? this.savedAtIso8601),
    );
  }

  Map<String, String> toStringMap() {
    final map = <String, String>{};
    void putIfNotNull(String key, String? value) {
      final trimmed = _trimOrNull(value);
      if (trimmed != null) {
        map[key] = trimmed;
      }
    }

    putIfNotNull('officialLibraryFolderPath', officialLibraryFolderPath);
    putIfNotNull('incomingSongsFolderPath', incomingSongsFolderPath);
    putIfNotNull('customImportOutputFolderPath', customImportOutputFolderPath);
    putIfNotNull('importManifestFolderPath', importManifestFolderPath);
    putIfNotNull('importOutputModeName', importOutputModeName);
    putIfNotNull('savedAtIso8601', savedAtIso8601);
    return map;
  }

  static AppSessionSnapshot fromStringMap(Map<String, String> values) {
    return AppSessionSnapshot(
      officialLibraryFolderPath: _trimOrNull(
        values['officialLibraryFolderPath'],
      ),
      incomingSongsFolderPath: _trimOrNull(values['incomingSongsFolderPath']),
      customImportOutputFolderPath: _trimOrNull(
        values['customImportOutputFolderPath'],
      ),
      importManifestFolderPath: _trimOrNull(values['importManifestFolderPath']),
      importOutputModeName: _trimOrNull(values['importOutputModeName']),
      savedAtIso8601: _trimOrNull(values['savedAtIso8601']),
    );
  }

  static String? _trimOrNull(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}
