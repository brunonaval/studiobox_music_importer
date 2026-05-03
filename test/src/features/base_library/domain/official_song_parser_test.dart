import 'package:flutter_test/flutter_test.dart';
import 'package:studiobox_music_importer/src/features/base_library/domain/official_song.dart';
import 'package:studiobox_music_importer/src/features/base_library/domain/official_song_parser.dart';

void main() {
  group('OfficialSongParser.parseFileName', () {
    final parser = OfficialSongParser();

    test('aceita arquivo valido', () {
      final result = parser.parseFileName(
        'Legiao Urbana - Tempo Perdido - 01234.mp4',
      );

      expect(result.isSuccess, isTrue);
      expect(result.song?.artist, 'Legiao Urbana');
      expect(result.song?.title, 'Tempo Perdido');
      expect(result.song?.code, '01234');
    });

    test('preserva zeros a esquerda', () {
      final result = parser.parseFileName(
        'Roberto Carlos - Emocoes - 00001.mp4',
      );

      expect(result.isSuccess, isTrue);
      expect(result.song?.code, '00001');
    });

    test('aceita extensao maiuscula', () {
      final result = parser.parseFileName(
        'Capital Inicial - Primeiros Erros - 12345.MP4',
      );

      expect(result.isSuccess, isTrue);
      expect(result.song?.code, '12345');
    });

    test('rejeita arquivo que nao e mp4', () {
      final result = parser.parseFileName('Artista - Musica - 12345.mkv');

      expect(result.isFailure, isTrue);
      expect(result.reason, 'Arquivo nao e .mp4.');
    });

    test('rejeita codigo com 4 digitos', () {
      final result = parser.parseFileName('Artista - Musica - 1234.mp4');

      expect(result.isFailure, isTrue);
      expect(result.reason, 'Codigo invalido.');
    });

    test('rejeita codigo com 6 digitos', () {
      final result = parser.parseFileName('Artista - Musica - 123456.mp4');

      expect(result.isFailure, isTrue);
      expect(result.reason, 'Codigo invalido.');
    });

    test('rejeita codigo com letras', () {
      final result = parser.parseFileName('Artista - Musica - 12A45.mp4');

      expect(result.isFailure, isTrue);
      expect(result.reason, 'Codigo invalido.');
    });

    test('rejeita nome sem separador com espacos', () {
      final result = parser.parseFileName('Artista-Musica-12345.mp4');

      expect(result.isFailure, isTrue);
      expect(result.reason, 'Nome fora do padrao Autor - Musica - 00000.mp4.');
    });

    test('aceita artista com hifen', () {
      final result = parser.parseFileName('A-ha - Take On Me - 01234.mp4');

      expect(result.isSuccess, isTrue);
      expect(result.song?.artist, 'A-ha');
      expect(result.song?.title, 'Take On Me');
    });

    test('aceita titulo com hifen', () {
      final result = parser.parseFileName(
        'Artista - Musica - Versao Ao Vivo - 01234.mp4',
      );

      expect(result.isSuccess, isTrue);
      expect(result.song?.artist, 'Artista');
      expect(result.song?.title, 'Musica - Versao Ao Vivo');
    });

    test('rejeita autor vazio', () {
      final result = parser.parseFileName(' - Musica - 01234.mp4');

      expect(result.isFailure, isTrue);
      expect(result.reason, 'Autor vazio.');
    });

    test('rejeita musica vazia', () {
      final result = parser.parseFileName('Artista -  - 01234.mp4');

      expect(result.isFailure, isTrue);
      expect(result.reason, 'Musica vazia.');
    });

    test('rejeita nome vazio', () {
      final result = parser.parseFileName('   ');

      expect(result.isFailure, isTrue);
      expect(result.reason, 'Nome vazio.');
    });
  });

  group('OfficialSong getters', () {
    test('officialFileName monta nome correto', () {
      const song = OfficialSong(
        artist: 'Legiao Urbana',
        title: 'Tempo Perdido',
        code: '01234',
        fileName: 'Legiao Urbana - Tempo Perdido - 01234.mp4',
      );

      expect(
        song.officialFileName,
        'Legiao Urbana - Tempo Perdido - 01234.mp4',
      );
    });

    test('catalogKey gera chave lowercase simples', () {
      const song = OfficialSong(
        artist: '  Legiao Urbana  ',
        title: '  Tempo Perdido  ',
        code: '01234',
        fileName: 'Legiao Urbana - Tempo Perdido - 01234.mp4',
      );

      expect(song.catalogKey, 'legiao urbana|tempo perdido');
    });
  });
}
