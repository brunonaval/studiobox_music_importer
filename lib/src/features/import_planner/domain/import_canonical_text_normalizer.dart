class ImportCanonicalTextNormalizer {
  const ImportCanonicalTextNormalizer._();

  static String canonicalArtist(String value) {
    final normalized = _normalizeCommon(value);
    final tokens = normalized
        .split(' ')
        .where((token) => token.isNotEmpty && token != 'e')
        .toList(growable: false);
    return tokens.join(' ');
  }

  static String canonicalTitle(String value) {
    return _normalizeCommon(value);
  }

  static String canonicalLoose(String value) {
    return _normalizeCommon(value);
  }

  static String _normalizeCommon(String value) {
    var text = value.toLowerCase();
    text = _removeAccents(text);
    text = text.replaceAll('&', ' e ');
    text = text.replaceAll(RegExp(r'\.[a-z0-9]{2,5}$'), '');
    text = text.replaceAll(RegExp(r'\s*-\s*\d{5}\s*$'), '');
    text = text.replaceAll(
      RegExp(r'^\s*karaoke\s+backing\s+vocal\s*[-: ]*\s*'),
      '',
    );
    text = text.replaceAll(RegExp(r'^\s*karaoke\s*[-: ]*\s*'), '');
    text = text.replaceAll(RegExp(r'[^a-z0-9]+'), ' ');
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return text;
  }

  static String _removeAccents(String value) {
    const replacements = <String, String>{
      'á': 'a',
      'à': 'a',
      'â': 'a',
      'ã': 'a',
      'ä': 'a',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'í': 'i',
      'ì': 'i',
      'î': 'i',
      'ï': 'i',
      'ó': 'o',
      'ò': 'o',
      'ô': 'o',
      'õ': 'o',
      'ö': 'o',
      'ú': 'u',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'ç': 'c',
      'ñ': 'n',
    };
    final buffer = StringBuffer();
    for (final rune in value.runes) {
      final char = String.fromCharCode(rune);
      buffer.write(replacements[char] ?? char);
    }
    return buffer.toString();
  }
}
