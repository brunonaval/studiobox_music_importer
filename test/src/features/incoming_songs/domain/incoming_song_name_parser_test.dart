import 'package:flutter_test/flutter_test.dart';
import 'package:studiobox_music_importer/src/features/incoming_songs/domain/incoming_song_name_parser.dart';
import 'package:studiobox_music_importer/src/features/incoming_songs/domain/incoming_song_parse_confidence.dart';

void main() {
  const knownArtists = <String>{
    'Legião Urbana',
    'Capital Inicial',
    'Tribalistas',
    'Marisa Monte',
    'A-ha',
  };

  final parser = IncomingSongNameParser();

  test('detecta Música - Autor e inverte', () {
    final result = parser.analyzeFileName(
      fileName: 'Tempo Perdido - Legião Urbana (Karaokê Version).mp4',
      knownArtists: knownArtists,
    );

    expect(result.detectedArtist, 'Legião Urbana');
    expect(result.detectedTitle, 'Tempo Perdido');
    expect(result.confidence, IncomingSongParseConfidence.high);
    expect(
      result.warnings,
      contains('Ordem Música - Autor detectada e invertida.'),
    );
  });

  test('detecta Música - Autor simples', () {
    final result = parser.analyzeFileName(
      fileName: 'Primeiros Erros - Capital Inicial.mp4',
      knownArtists: knownArtists,
    );

    expect(result.detectedArtist, 'Capital Inicial');
    expect(result.detectedTitle, 'Primeiros Erros');
    expect(result.confidence, IncomingSongParseConfidence.high);
  });

  test('detecta Autor - Música', () {
    final result = parser.analyzeFileName(
      fileName: 'Tribalistas - Velha Infância.mp4',
      knownArtists: knownArtists,
    );

    expect(result.detectedArtist, 'Tribalistas');
    expect(result.detectedTitle, 'Velha Infância');
    expect(result.confidence, IncomingSongParseConfidence.high);
  });

  test('detecta Autor - Música - Extra', () {
    final result = parser.analyzeFileName(
      fileName: 'Tribalistas - Velha Infância - Marisa Monte.mp4',
      knownArtists: knownArtists,
    );

    expect(result.detectedArtist, 'Tribalistas');
    expect(result.detectedTitle, 'Velha Infância');
    expect(result.detectedExtra, 'Marisa Monte');
    expect(result.confidence, IncomingSongParseConfidence.medium);
    expect(
      result.warnings,
      contains('Informação extra detectada; revise se deve entrar no título.'),
    );
  });

  test('detecta arquivo já no padrão oficial', () {
    final result = parser.analyzeFileName(
      fileName: 'Legião Urbana - Tempo Perdido - 01234.mp4',
      knownArtists: knownArtists,
    );

    expect(result.detectedArtist, 'Legião Urbana');
    expect(result.detectedTitle, 'Tempo Perdido');
    expect(result.detectedExtra, isNull);
    expect(result.confidence, IncomingSongParseConfidence.high);
  });

  test('aceita artista com hífen', () {
    final result = parser.analyzeFileName(
      fileName: 'A-ha - Take On Me.mp4',
      knownArtists: knownArtists,
    );

    expect(result.detectedArtist, 'A-ha');
    expect(result.detectedTitle, 'Take On Me');
    expect(result.confidence, IncomingSongParseConfidence.high);
  });

  test('limpa termo [Karaoke]', () {
    final result = parser.analyzeFileName(
      fileName: 'Tempo Perdido - Legião Urbana [Karaoke].mp4',
      knownArtists: knownArtists,
    );

    expect(result.cleanedName, 'Tempo Perdido - Legião Urbana');
  });

  test('limpa termo (HD)', () {
    final result = parser.analyzeFileName(
      fileName: 'Tempo Perdido - Legião Urbana (HD).mp4',
      knownArtists: knownArtists,
    );

    expect(result.cleanedName, 'Tempo Perdido - Legião Urbana');
  });

  test('rejeita não mp4', () {
    final result = parser.analyzeFileName(
      fileName: 'Tempo Perdido - Legião Urbana.mkv',
      knownArtists: knownArtists,
    );

    expect(result.confidence, IncomingSongParseConfidence.failed);
    expect(result.warnings, contains('Arquivo não é .mp4.'));
    expect(result.isUsable, isFalse);
  });

  test('falha quando não há separador suficiente', () {
    final result = parser.analyzeFileName(
      fileName: 'Tempo Perdido.mp4',
      knownArtists: knownArtists,
    );

    expect(result.confidence, IncomingSongParseConfidence.failed);
    expect(
      result.warnings,
      contains(
        'Nome não possui partes suficientes para detectar artista e música.',
      ),
    );
  });

  test('baixa confiança quando artista não é conhecido', () {
    final result = parser.analyzeFileName(
      fileName: 'Artista Novo - Música Nova.mp4',
      knownArtists: knownArtists,
    );

    expect(result.confidence, IncomingSongParseConfidence.low);
    expect(
      result.warnings,
      contains('Artista não reconhecido; revise manualmente.'),
    );
  });

  test('medium quando ambas as partes são artistas conhecidos', () {
    final result = parser.analyzeFileName(
      fileName: 'Legião Urbana - Capital Inicial.mp4',
      knownArtists: knownArtists,
    );

    expect(result.confidence, IncomingSongParseConfidence.medium);
    expect(
      result.warnings,
      contains(
        'Ambas as partes parecem artistas conhecidos; revise manualmente.',
      ),
    );
  });

  test('muitas partes gera warning', () {
    final result = parser.analyzeFileName(
      fileName: 'Artista - Música - Versão - Extra.mp4',
      knownArtists: knownArtists,
    );

    expect(
      result.warnings,
      contains('Nome possui muitas partes; revise manualmente.'),
    );
    expect(result.detectedArtist, 'Artista');
    expect(result.detectedTitle, 'Música - Versão');
    expect(result.detectedExtra, 'Extra');
  });

  test('isUsable true para análise válida', () {
    final result = parser.analyzeFileName(
      fileName: 'Tribalistas - Velha Infância.mp4',
      knownArtists: knownArtists,
    );

    expect(result.isUsable, isTrue);
  });

  test('isUsable false para failed', () {
    final result = parser.analyzeFileName(
      fileName: 'ArquivoSemPadrao.mp4',
      knownArtists: knownArtists,
    );

    expect(result.isUsable, isFalse);
  });
}
