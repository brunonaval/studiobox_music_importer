import 'package:shared_preferences/shared_preferences.dart';

import '../domain/session_cache.dart';

class AppSessionCacheService {
  static const String _officialLibraryFolderPathKey =
      'studiobox.session.officialLibraryFolderPath';
  static const String _incomingSongsFolderPathKey =
      'studiobox.session.incomingSongsFolderPath';
  static const String _customImportOutputFolderPathKey =
      'studiobox.session.customImportOutputFolderPath';
  static const String _importManifestFolderPathKey =
      'studiobox.session.importManifestFolderPath';
  static const String _importOutputModeNameKey =
      'studiobox.session.importOutputModeName';
  static const String _savedAtIso8601Key = 'studiobox.session.savedAtIso8601';

  const AppSessionCacheService();

  Future<AppSessionSnapshot> loadSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSessionSnapshot(
      officialLibraryFolderPath: prefs.getString(_officialLibraryFolderPathKey),
      incomingSongsFolderPath: prefs.getString(_incomingSongsFolderPathKey),
      customImportOutputFolderPath: prefs.getString(
        _customImportOutputFolderPathKey,
      ),
      importManifestFolderPath: prefs.getString(_importManifestFolderPathKey),
      importOutputModeName: prefs.getString(_importOutputModeNameKey),
      savedAtIso8601: prefs.getString(_savedAtIso8601Key),
    );
  }

  Future<void> saveSnapshot(AppSessionSnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    final savedAt = snapshot.savedAtIso8601?.trim().isNotEmpty == true
        ? snapshot.savedAtIso8601
        : DateTime.now().toUtc().toIso8601String();

    await _setOrRemove(
      prefs: prefs,
      key: _officialLibraryFolderPathKey,
      value: snapshot.officialLibraryFolderPath,
    );
    await _setOrRemove(
      prefs: prefs,
      key: _incomingSongsFolderPathKey,
      value: snapshot.incomingSongsFolderPath,
    );
    await _setOrRemove(
      prefs: prefs,
      key: _customImportOutputFolderPathKey,
      value: snapshot.customImportOutputFolderPath,
    );
    await _setOrRemove(
      prefs: prefs,
      key: _importManifestFolderPathKey,
      value: snapshot.importManifestFolderPath,
    );
    await _setOrRemove(
      prefs: prefs,
      key: _importOutputModeNameKey,
      value: snapshot.importOutputModeName,
    );
    await _setOrRemove(prefs: prefs, key: _savedAtIso8601Key, value: savedAt);
  }

  Future<void> clearSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_officialLibraryFolderPathKey);
    await prefs.remove(_incomingSongsFolderPathKey);
    await prefs.remove(_customImportOutputFolderPathKey);
    await prefs.remove(_importManifestFolderPathKey);
    await prefs.remove(_importOutputModeNameKey);
    await prefs.remove(_savedAtIso8601Key);
  }

  Future<void> _setOrRemove({
    required SharedPreferences prefs,
    required String key,
    required String? value,
  }) async {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      await prefs.remove(key);
      return;
    }
    await prefs.setString(key, trimmed);
  }
}
