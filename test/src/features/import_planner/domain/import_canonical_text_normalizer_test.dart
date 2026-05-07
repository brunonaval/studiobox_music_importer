import 'package:flutter_test/flutter_test.dart';
import 'package:studiobox_music_importer/src/features/import_planner/domain/import_canonical_text_normalizer.dart';

void main() {
  test('normaliza artista canonico com & e E para mesmo valor', () {
    final a = ImportCanonicalTextNormalizer.canonicalArtist(
      'Guilherme & Benuto e Simone Mendes',
    );
    final b = ImportCanonicalTextNormalizer.canonicalArtist(
      'Guilherme E Benuto E Simone Mendes',
    );

    expect(a, 'guilherme benuto simone mendes');
    expect(a, b);
  });

  test('normaliza titulo canonico ignorando maiusculas', () {
    final a = ImportCanonicalTextNormalizer.canonicalTitle('Manda um Oi');
    final b = ImportCanonicalTextNormalizer.canonicalTitle('Manda Um Oi');

    expect(a, 'manda um oi');
    expect(a, b);
  });

  test('normaliza texto solto removendo prefixo karaoke e extensao', () {
    final normalized = ImportCanonicalTextNormalizer.canonicalLoose(
      'Karaokê - Manda um Oi - Guilherme & Benuto.mp4',
    );

    expect(normalized, 'manda um oi guilherme e benuto');
  });
}
