import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:studiobox_music_importer/src/features/base_library/application/official_library_scan_service.dart';

void main() {
  group('OfficialLibraryScanService.scanFolder', () {
    Future<Directory> createTempDir() {
      return Directory.systemTemp.createTemp('studiobox_scan_test_');
    }

    test('indexa arquivos .mp4 validos de pasta temporaria', () async {
      final tempDir = await createTempDir();
      addTearDown(() => tempDir.delete(recursive: true));

      await File(
        '${tempDir.path}/Legiao Urbana - Tempo Perdido - 00001.mp4',
      ).writeAsString('');
      await File(
        '${tempDir.path}/Capital Inicial - Primeiros Erros - 00002.mp4',
      ).writeAsString('');

      final service = OfficialLibraryScanService();
      final result = await service.scanFolder(tempDir.path);

      expect(result.validCount, 2);
      expect(result.invalidCount, 0);
    });

    test('ignora arquivos que nao sao .mp4', () async {
      final tempDir = await createTempDir();
      addTearDown(() => tempDir.delete(recursive: true));

      await File('${tempDir.path}/nao_considerar.txt').writeAsString('');
      await File('${tempDir.path}/video.mkv').writeAsString('');
      await File(
        '${tempDir.path}/Legiao Urbana - Tempo Perdido - 00001.mp4',
      ).writeAsString('');

      final service = OfficialLibraryScanService();
      final result = await service.scanFolder(tempDir.path);

      expect(result.validCount, 1);
      expect(result.invalidCount, 0);
    });

    test('registra mp4 invalido via BaseLibraryIndexer', () async {
      final tempDir = await createTempDir();
      addTearDown(() => tempDir.delete(recursive: true));

      await File('${tempDir.path}/Arquivo Invalido.mp4').writeAsString('');

      final service = OfficialLibraryScanService();
      final result = await service.scanFolder(tempDir.path);

      expect(result.validCount, 0);
      expect(result.invalidCount, 1);
    });

    test('detecta duplicidade por codigo', () async {
      final tempDir = await createTempDir();
      addTearDown(() => tempDir.delete(recursive: true));

      await File(
        '${tempDir.path}/Artista A - Musica A - 00001.mp4',
      ).writeAsString('');
      await File(
        '${tempDir.path}/Artista B - Musica B - 00001.mp4',
      ).writeAsString('');

      final service = OfficialLibraryScanService();
      final result = await service.scanFolder(tempDir.path);

      expect(result.duplicateCodeCount, 1);
    });

    test('retorna indice vazio para pasta inexistente', () async {
      final service = OfficialLibraryScanService();
      final result = await service.scanFolder(
        'C:/pasta/que/nao/deve/existir/studiobox_round_11',
      );

      expect(result.validCount, 0);
      expect(result.invalidCount, 0);
      expect(result.maxCodeNumber, isNull);
    });

    test('aceita extensao .MP4 maiuscula', () async {
      final tempDir = await createTempDir();
      addTearDown(() => tempDir.delete(recursive: true));

      await File(
        '${tempDir.path}/A-ha - Take On Me - 01234.MP4',
      ).writeAsString('');

      final service = OfficialLibraryScanService();
      final result = await service.scanFolder(tempDir.path);

      expect(result.validCount, 1);
      expect(result.invalidCount, 0);
    });
  });
}
