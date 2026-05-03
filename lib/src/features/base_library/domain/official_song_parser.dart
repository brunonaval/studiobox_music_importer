import 'official_song.dart';
import 'official_song_parse_result.dart';

class OfficialSongParser {
  static final RegExp _codePattern = RegExp(r'^\d{5}$');

  OfficialSongParseResult parseFileName(String fileName) {
    if (fileName.trim().isEmpty) {
      return OfficialSongParseResult.failure('Nome vazio.');
    }

    final extensionSeparatorIndex = fileName.lastIndexOf('.');
    if (extensionSeparatorIndex == -1 ||
        extensionSeparatorIndex == fileName.length - 1) {
      return OfficialSongParseResult.failure('Arquivo nao e .mp4.');
    }

    final extension = fileName.substring(extensionSeparatorIndex + 1);
    if (extension.toLowerCase() != 'mp4') {
      return OfficialSongParseResult.failure('Arquivo nao e .mp4.');
    }

    final nameWithoutExtension = fileName.substring(0, extensionSeparatorIndex);

    final codeSeparatorIndex = nameWithoutExtension.lastIndexOf(' - ');
    if (codeSeparatorIndex == -1) {
      return OfficialSongParseResult.failure(
        'Nome fora do padrao Autor - Musica - 00000.mp4.',
      );
    }

    final code = nameWithoutExtension.substring(codeSeparatorIndex + 3).trim();
    if (!_codePattern.hasMatch(code)) {
      return OfficialSongParseResult.failure('Codigo invalido.');
    }

    final artistAndTitle = nameWithoutExtension.substring(
      0,
      codeSeparatorIndex,
    );
    final artistSeparatorIndex = artistAndTitle.indexOf(' - ');
    if (artistSeparatorIndex == -1) {
      return OfficialSongParseResult.failure(
        'Nome fora do padrao Autor - Musica - 00000.mp4.',
      );
    }

    final artist = artistAndTitle.substring(0, artistSeparatorIndex).trim();
    if (artist.isEmpty) {
      return OfficialSongParseResult.failure('Autor vazio.');
    }

    final title = artistAndTitle.substring(artistSeparatorIndex + 3).trim();
    if (title.isEmpty) {
      return OfficialSongParseResult.failure('Musica vazia.');
    }

    return OfficialSongParseResult.success(
      OfficialSong(
        artist: artist,
        title: title,
        code: code,
        fileName: fileName,
      ),
    );
  }
}
