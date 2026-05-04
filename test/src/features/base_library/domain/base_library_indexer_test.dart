import 'package:flutter_test/flutter_test.dart';
import 'package:studiobox_music_importer/src/features/base_library/domain/base_library_indexer.dart';
import 'package:studiobox_music_importer/src/features/base_library/domain/base_library_scanned_file.dart';

void main() {
  group('BaseLibraryIndexer.indexFileNames', () {
    final indexer = BaseLibraryIndexer();

    test('indexa arquivos validos', () {
      final result = indexer.indexFileNames([
        'Legiao Urbana - Tempo Perdido - 00001.mp4',
        'Capital Inicial - Primeiros Erros - 00002.mp4',
      ]);

      expect(result.validCount, 2);
      expect(result.invalidCount, 0);
      expect(result.usedCodes, containsAll(<String>{'00001', '00002'}));
      expect(result.maxCodeNumber, 2);
    });

    test('registra arquivos invalidos', () {
      final result = indexer.indexFileNames(['Arquivo Invalido.mp4']);

      expect(result.invalidCount, 1);
      expect(result.invalidFiles.first.reason, isNotEmpty);
    });

    test('detecta codigo duplicado', () {
      final result = indexer.indexFileNames([
        'Artista A - Musica A - 00001.mp4',
        'Artista B - Musica B - 00001.mp4',
      ]);

      expect(result.duplicateCodeCount, 1);
      expect(result.duplicateCodes.first.code, '00001');
      expect(result.duplicateCodes.first.entries.length, 2);
      expect(result.entries.length, 2);
    });

    test('calcula buracos disponiveis', () {
      final result = indexer.indexFileNames([
        'Artista A - Musica A - 00001.mp4',
        'Artista B - Musica B - 00003.mp4',
      ]);

      expect(result.availableCodeGaps, ['00002']);
    });

    test('nao inclui 00000 como buraco', () {
      final result = indexer.indexFileNames([
        'Artista B - Musica B - 00002.mp4',
      ]);

      expect(result.availableCodeGaps, contains('00001'));
      expect(result.availableCodeGaps, isNot(contains('00000')));
    });

    test('coleta artistas conhecidos', () {
      final result = indexer.indexFileNames([
        'Legiao Urbana - Tempo Perdido - 00001.mp4',
        'Legiao Urbana - Faroeste Caboclo - 00002.mp4',
        'Capital Inicial - Primeiros Erros - 00003.mp4',
      ]);

      expect(
        result.knownArtists,
        containsAll(<String>{'Legiao Urbana', 'Capital Inicial'}),
      );
    });

    test('ordena entradas por codigo', () {
      final result = indexer.indexFileNames([
        'Artista C - C - 00003.mp4',
        'Artista A - A - 00001.mp4',
        'Artista B - B - 00002.mp4',
      ]);

      expect(result.entries[0].code, '00001');
      expect(result.entries[1].code, '00002');
      expect(result.entries[2].code, '00003');
    });

    test('maxCodeNumber e null quando nao ha validos', () {
      final result = indexer.indexFileNames(['invalido.mp4']);

      expect(result.maxCodeNumber, isNull);
      expect(result.availableCodeGaps, isEmpty);
    });

    test('aceita artista com hifen via indexador', () {
      final result = indexer.indexFileNames(['A-ha - Take On Me - 01234.mp4']);

      expect(result.validCount, 1);
      expect(result.entries.first.artist, 'A-ha');
      expect(result.entries.first.code, '01234');
    });
  });

  group('BaseLibraryIndexer.indexScannedFiles', () {
    final indexer = BaseLibraryIndexer();

    test('preserva fullPath e relativePath em entries validas', () {
      final result = indexer.indexScannedFiles([
        BaseLibraryScannedFile(
          fileName: 'Legiao Urbana - Tempo Perdido - 00001.mp4',
          fullPath: r'C:\Base\Legiao Urbana - Tempo Perdido - 00001.mp4',
          relativePath: r'Sub\Legiao Urbana - Tempo Perdido - 00001.mp4',
        ),
      ]);

      expect(result.validCount, 1);
      expect(
        result.entries.first.fullPath,
        r'C:\Base\Legiao Urbana - Tempo Perdido - 00001.mp4',
      );
      expect(
        result.entries.first.relativePath,
        r'Sub\Legiao Urbana - Tempo Perdido - 00001.mp4',
      );
    });

    test('preserva fullPath e relativePath em invalidFiles', () {
      final result = indexer.indexScannedFiles([
        BaseLibraryScannedFile(
          fileName: 'Arquivo Invalido.mp4',
          fullPath: r'C:\Base\Sub\Arquivo Invalido.mp4',
          relativePath: r'Sub\Arquivo Invalido.mp4',
        ),
      ]);

      expect(result.invalidCount, 1);
      expect(
        result.invalidFiles.first.fullPath,
        r'C:\Base\Sub\Arquivo Invalido.mp4',
      );
      expect(
        result.invalidFiles.first.relativePath,
        r'Sub\Arquivo Invalido.mp4',
      );
    });

    test('displayPath usa relativePath quando existe', () {
      final result = indexer.indexScannedFiles([
        BaseLibraryScannedFile(
          fileName: 'Artista - Musica - 00001.mp4',
          fullPath: r'C:\Base\Sub\Artista - Musica - 00001.mp4',
          relativePath: r'Sub\Artista - Musica - 00001.mp4',
        ),
        BaseLibraryScannedFile(
          fileName: 'Invalido.mp4',
          fullPath: r'C:\Base\Sub\Invalido.mp4',
          relativePath: r'Sub\Invalido.mp4',
        ),
      ]);

      expect(
        result.entries.first.displayPath,
        r'Sub\Artista - Musica - 00001.mp4',
      );
      expect(result.invalidFiles.first.displayPath, r'Sub\Invalido.mp4');
    });

    test('displayPath usa fallback quando relativePath vazio', () {
      final validResult = indexer.indexScannedFiles([
        BaseLibraryScannedFile(
          fileName: 'Artista - Musica - 00001.mp4',
          fullPath: r'C:\Base\Artista - Musica - 00001.mp4',
          relativePath: '',
        ),
      ]);

      final invalidResult = indexer.indexScannedFiles([
        BaseLibraryScannedFile(
          fileName: 'Invalido.mp4',
          fullPath: r'C:\Base\Invalido.mp4',
          relativePath: '',
        ),
      ]);

      expect(
        validResult.entries.first.displayPath,
        'Artista - Musica - 00001.mp4',
      );
      expect(invalidResult.invalidFiles.first.displayPath, 'Invalido.mp4');
    });
  });
}
