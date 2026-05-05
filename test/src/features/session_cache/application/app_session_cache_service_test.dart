import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studiobox_music_importer/src/features/session_cache/application/session_cache_application.dart';
import 'package:studiobox_music_importer/src/features/session_cache/domain/session_cache.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('loadSnapshot com cache vazio retorna snapshot vazio', () async {
    final service = AppSessionCacheService();
    final snapshot = await service.loadSnapshot();
    expect(snapshot.isEmpty, isTrue);
  });

  test('saveSnapshot salva e loadSnapshot recupera caminhos', () async {
    final service = AppSessionCacheService();
    await service.saveSnapshot(
      AppSessionSnapshot(
        officialLibraryFolderPath: 'C:/Biblioteca',
        incomingSongsFolderPath: 'C:/Novas',
        customImportOutputFolderPath: 'C:/Saida',
        importManifestFolderPath: 'C:/Manifestos',
        importOutputModeName: 'copyToCustomFolder',
        savedAtIso8601: '2026-05-05T12:00:00.000Z',
      ),
    );

    final snapshot = await service.loadSnapshot();
    expect(snapshot.officialLibraryFolderPath, 'C:/Biblioteca');
    expect(snapshot.incomingSongsFolderPath, 'C:/Novas');
    expect(snapshot.customImportOutputFolderPath, 'C:/Saida');
    expect(snapshot.importManifestFolderPath, 'C:/Manifestos');
    expect(snapshot.importOutputModeName, 'copyToCustomFolder');
    expect(snapshot.savedAtIso8601, '2026-05-05T12:00:00.000Z');
  });

  test('saveSnapshot trim valores e remove campo vazio', () async {
    final service = AppSessionCacheService();
    await service.saveSnapshot(
      AppSessionSnapshot(
        officialLibraryFolderPath: '  C:/Biblioteca  ',
        incomingSongsFolderPath: '   ',
        customImportOutputFolderPath: null,
        importManifestFolderPath: '',
        importOutputModeName: '  renameInIncomingFolder ',
        savedAtIso8601: null,
      ),
    );

    final snapshot = await service.loadSnapshot();
    expect(snapshot.officialLibraryFolderPath, 'C:/Biblioteca');
    expect(snapshot.incomingSongsFolderPath, isNull);
    expect(snapshot.customImportOutputFolderPath, isNull);
    expect(snapshot.importManifestFolderPath, isNull);
    expect(snapshot.importOutputModeName, 'renameInIncomingFolder');
  });

  test('clearSnapshot limpa cache', () async {
    final service = AppSessionCacheService();
    await service.saveSnapshot(
      AppSessionSnapshot(
        officialLibraryFolderPath: 'C:/Biblioteca',
        incomingSongsFolderPath: 'C:/Novas',
        customImportOutputFolderPath: 'C:/Saida',
        importManifestFolderPath: 'C:/Manifestos',
        importOutputModeName: 'copyToCustomFolder',
        savedAtIso8601: '2026-05-05T12:00:00.000Z',
      ),
    );
    await service.clearSnapshot();
    final snapshot = await service.loadSnapshot();
    expect(snapshot.isEmpty, isTrue);
  });

  test('savedAtIso8601 e preenchido quando vazio', () async {
    final service = AppSessionCacheService();
    await service.saveSnapshot(
      AppSessionSnapshot(
        officialLibraryFolderPath: 'C:/Biblioteca',
        incomingSongsFolderPath: null,
        customImportOutputFolderPath: null,
        importManifestFolderPath: null,
        importOutputModeName: null,
        savedAtIso8601: null,
      ),
    );
    final snapshot = await service.loadSnapshot();
    expect(snapshot.hasSavedAt, isTrue);
  });

  test('toStringMap omite campos null e fromStringMap aceita vazio', () {
    final snapshot = AppSessionSnapshot(
      officialLibraryFolderPath: 'C:/Biblioteca',
      incomingSongsFolderPath: null,
      customImportOutputFolderPath: null,
      importManifestFolderPath: null,
      importOutputModeName: null,
      savedAtIso8601: null,
    );
    final map = snapshot.toStringMap();
    expect(map.containsKey('officialLibraryFolderPath'), isTrue);
    expect(map.containsKey('incomingSongsFolderPath'), isFalse);

    final empty = AppSessionSnapshot.fromStringMap({});
    expect(empty.isEmpty, isTrue);
  });

  test('isEmpty e isNotEmpty funcionam', () {
    final empty = AppSessionSnapshot(
      officialLibraryFolderPath: null,
      incomingSongsFolderPath: null,
      customImportOutputFolderPath: null,
      importManifestFolderPath: null,
      importOutputModeName: null,
      savedAtIso8601: null,
    );
    expect(empty.isEmpty, isTrue);
    expect(empty.isNotEmpty, isFalse);

    final filled = empty.copyWith(officialLibraryFolderPath: 'C:/Biblioteca');
    expect(filled.isEmpty, isFalse);
    expect(filled.isNotEmpty, isTrue);
  });
}
