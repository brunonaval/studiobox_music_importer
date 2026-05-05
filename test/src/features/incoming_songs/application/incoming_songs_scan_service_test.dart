import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:studiobox_music_importer/src/features/incoming_songs/application/incoming_songs_scan_service.dart';

void main() {
  group('IncomingSongsScanService.scanFolder', () {
    late IncomingSongsScanService service;

    setUp(() {
      service = IncomingSongsScanService();
    });

    test('retorna warning quando folderPath vazio', () async {
      final result = await service.scanFolder('');

      expect(result.files, isEmpty);
      expect(result.hasWarnings, isTrue);
      expect(result.warnings.any((w) => w.contains('não informada')), isTrue);
    });

    test('retorna warning quando pasta nao existe', () async {
      final result = await service.scanFolder(
        r'C:\PastaTotalmenteInexistente\XYZ_9999',
      );

      expect(result.files, isEmpty);
      expect(result.hasWarnings, isTrue);
      expect(result.warnings.any((w) => w.contains('não encontrada')), isTrue);
    });

    test('lista .mp4 de pasta temporaria', () async {
      final tempDir = await Directory.systemTemp.createTemp('inc_scan_ok_');
      addTearDown(() => tempDir.delete(recursive: true));

      final sep = Platform.pathSeparator;
      await File('${tempDir.path}${sep}Artista - Musica.mp4').writeAsString('');
      await File('${tempDir.path}${sep}Outro - Song.mp4').writeAsString('');

      final result = await service.scanFolder(tempDir.path);

      expect(result.totalCount, 2);
      expect(result.hasWarnings, isFalse);
    });

    test('ignora arquivos nao .mp4', () async {
      final tempDir = await Directory.systemTemp.createTemp('inc_scan_ignore_');
      addTearDown(() => tempDir.delete(recursive: true));

      final sep = Platform.pathSeparator;
      await File('${tempDir.path}${sep}Artista - Musica.mp4').writeAsString('');
      await File('${tempDir.path}${sep}readme.txt').writeAsString('');
      await File('${tempDir.path}${sep}thumb.jpg').writeAsString('');

      final result = await service.scanFolder(tempDir.path);

      expect(result.totalCount, 1);
      expect(result.files.first.fileName, 'Artista - Musica.mp4');
    });

    test('suporta extensao .MP4 maiuscula', () async {
      final tempDir = await Directory.systemTemp.createTemp('inc_scan_upper_');
      addTearDown(() => tempDir.delete(recursive: true));

      final sep = Platform.pathSeparator;
      await File('${tempDir.path}${sep}Artista - Musica.MP4').writeAsString('');

      final result = await service.scanFolder(tempDir.path);

      expect(result.totalCount, 1);
    });

    test('scan recursivo preserva relativePath com subpasta', () async {
      final tempDir = await Directory.systemTemp.createTemp('inc_scan_rec_');
      addTearDown(() => tempDir.delete(recursive: true));

      final sep = Platform.pathSeparator;
      final subDir = Directory('${tempDir.path}${sep}sub');
      await subDir.create();
      await File('${subDir.path}${sep}Artista - Musica.mp4').writeAsString('');

      final result = await service.scanFolder(tempDir.path);

      expect(result.totalCount, 1);
      final file = result.files.first;
      expect(file.relativePath, contains('sub'));
      expect(file.relativePath, contains('Artista - Musica.mp4'));
    });

    test('fullPath nao fica vazio', () async {
      final tempDir = await Directory.systemTemp.createTemp('inc_scan_full_');
      addTearDown(() => tempDir.delete(recursive: true));

      final sep = Platform.pathSeparator;
      await File('${tempDir.path}${sep}Artista - Musica.mp4').writeAsString('');

      final result = await service.scanFolder(tempDir.path);

      expect(result.files.first.hasFullPath, isTrue);
      expect(result.files.first.fullPath, isNotEmpty);
    });

    test('ordena arquivos por displayPath', () async {
      final tempDir = await Directory.systemTemp.createTemp('inc_scan_sort_');
      addTearDown(() => tempDir.delete(recursive: true));

      final sep = Platform.pathSeparator;
      await File('${tempDir.path}${sep}Z - Zebra.mp4').writeAsString('');
      await File('${tempDir.path}${sep}A - Abacate.mp4').writeAsString('');
      await File('${tempDir.path}${sep}M - Manga.mp4').writeAsString('');

      final result = await service.scanFolder(tempDir.path);

      expect(result.totalCount, 3);
      final paths = result.files.map((f) => f.displayPath).toList();
      expect(paths, orderedEquals(paths.toList()..sort()));
    });
  });
}
