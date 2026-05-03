import 'incoming_song_name_analysis.dart';
import 'incoming_song_parse_confidence.dart';

class IncomingSongNameParser {
  IncomingSongNameAnalysis analyzeFileName({
    required String fileName,
    required Set<String> knownArtists,
  }) {
    if (!_isMp4(fileName)) {
      return IncomingSongNameAnalysis(
        originalFileName: fileName,
        cleanedName: fileName,
        detectedArtist: null,
        detectedTitle: null,
        detectedExtra: null,
        confidence: IncomingSongParseConfidence.failed,
        warnings: const ['Arquivo não é .mp4.'],
      );
    }

    final rawName = _removeExtension(fileName);
    final cleanedName = _cleanNoiseTerms(rawName);
    final parts = _splitParts(cleanedName);

    if (parts.length < 2) {
      return IncomingSongNameAnalysis(
        originalFileName: fileName,
        cleanedName: cleanedName,
        detectedArtist: null,
        detectedTitle: null,
        detectedExtra: null,
        confidence: IncomingSongParseConfidence.failed,
        warnings: const [
          'Nome não possui partes suficientes para detectar artista e música.',
        ],
      );
    }

    if (parts.length > 3) {
      final artist = parts.first;
      final extra = parts.last;
      final title = parts.sublist(1, parts.length - 1).join(' - ');
      final warnings = <String>[
        'Nome possui muitas partes; revise manualmente.',
      ];

      if (!_isKnownArtist(artist, knownArtists)) {
        warnings.add('Artista não reconhecido; revise manualmente.');
      }

      return IncomingSongNameAnalysis(
        originalFileName: fileName,
        cleanedName: cleanedName,
        detectedArtist: artist,
        detectedTitle: title,
        detectedExtra: extra,
        confidence: _isKnownArtist(artist, knownArtists)
            ? IncomingSongParseConfidence.medium
            : IncomingSongParseConfidence.low,
        warnings: List.unmodifiable(warnings),
      );
    }

    if (parts.length == 2) {
      return _analyzeTwoParts(fileName, cleanedName, parts, knownArtists);
    }

    return _analyzeThreeParts(fileName, cleanedName, parts, knownArtists);
  }

  IncomingSongNameAnalysis _analyzeTwoParts(
    String originalFileName,
    String cleanedName,
    List<String> parts,
    Set<String> knownArtists,
  ) {
    final partA = parts[0];
    final partB = parts[1];
    final partAKnown = _isKnownArtist(partA, knownArtists);
    final partBKnown = _isKnownArtist(partB, knownArtists);
    final warnings = <String>[];

    String artist;
    String title;
    IncomingSongParseConfidence confidence;

    if (partAKnown && !partBKnown) {
      artist = partA;
      title = partB;
      confidence = IncomingSongParseConfidence.high;
    } else if (partBKnown && !partAKnown) {
      artist = partB;
      title = partA;
      confidence = IncomingSongParseConfidence.high;
      warnings.add('Ordem Música - Autor detectada e invertida.');
    } else if (partAKnown && partBKnown) {
      artist = partA;
      title = partB;
      confidence = IncomingSongParseConfidence.medium;
      warnings.add(
        'Ambas as partes parecem artistas conhecidos; revise manualmente.',
      );
    } else {
      artist = partA;
      title = partB;
      confidence = IncomingSongParseConfidence.low;
      warnings.add('Artista não reconhecido; revise manualmente.');
    }

    return IncomingSongNameAnalysis(
      originalFileName: originalFileName,
      cleanedName: cleanedName,
      detectedArtist: artist,
      detectedTitle: title,
      detectedExtra: null,
      confidence: confidence,
      warnings: List.unmodifiable(warnings),
    );
  }

  IncomingSongNameAnalysis _analyzeThreeParts(
    String originalFileName,
    String cleanedName,
    List<String> parts,
    Set<String> knownArtists,
  ) {
    final partA = parts[0];
    final partB = parts[1];
    final partC = parts[2];
    final warnings = <String>[];

    if (_isFiveDigitCode(partC)) {
      final artistKnown = _isKnownArtist(partA, knownArtists);

      if (!artistKnown) {
        warnings.add(
          'Arquivo parece estar no padrão oficial, mas o artista não foi reconhecido.',
        );
      }

      return IncomingSongNameAnalysis(
        originalFileName: originalFileName,
        cleanedName: cleanedName,
        detectedArtist: partA,
        detectedTitle: partB,
        detectedExtra: null,
        confidence: artistKnown
            ? IncomingSongParseConfidence.high
            : IncomingSongParseConfidence.medium,
        warnings: List.unmodifiable(warnings),
      );
    }

    final partAKnown = _isKnownArtist(partA, knownArtists);
    final partBKnown = _isKnownArtist(partB, knownArtists);

    String artist;
    String title;

    if (partAKnown) {
      artist = partA;
      title = partB;
      warnings.add(
        'Informação extra detectada; revise se deve entrar no título.',
      );

      return IncomingSongNameAnalysis(
        originalFileName: originalFileName,
        cleanedName: cleanedName,
        detectedArtist: artist,
        detectedTitle: title,
        detectedExtra: partC,
        confidence: IncomingSongParseConfidence.medium,
        warnings: List.unmodifiable(warnings),
      );
    }

    if (partBKnown && !partAKnown) {
      artist = partB;
      title = partA;
      warnings.add('Ordem Música - Autor detectada e invertida.');
      warnings.add(
        'Informação extra detectada; revise se deve entrar no título.',
      );

      return IncomingSongNameAnalysis(
        originalFileName: originalFileName,
        cleanedName: cleanedName,
        detectedArtist: artist,
        detectedTitle: title,
        detectedExtra: partC,
        confidence: IncomingSongParseConfidence.medium,
        warnings: List.unmodifiable(warnings),
      );
    }

    artist = partA;
    title = partB;
    warnings.add('Artista não reconhecido; revise manualmente.');
    warnings.add(
      'Informação extra detectada; revise se deve entrar no título.',
    );

    return IncomingSongNameAnalysis(
      originalFileName: originalFileName,
      cleanedName: cleanedName,
      detectedArtist: artist,
      detectedTitle: title,
      detectedExtra: partC,
      confidence: IncomingSongParseConfidence.low,
      warnings: List.unmodifiable(warnings),
    );
  }

  bool _isMp4(String fileName) {
    final trimmed = fileName.trim();
    return trimmed.toLowerCase().endsWith('.mp4');
  }

  String _removeExtension(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex <= 0) {
      return fileName.trim();
    }
    return fileName.substring(0, dotIndex).trim();
  }

  String _cleanNoiseTerms(String value) {
    const noiseTerms = <String>[
      '(karaokê)',
      '(karaoke)',
      '(karaokê version)',
      '(karaoke version)',
      '(versão karaokê)',
      '(versao karaoke)',
      '[karaokê]',
      '[karaoke]',
      '(instrumental)',
      '(com letra)',
      '(sem voz)',
      '(lyrics)',
      '(letra)',
      '(official video)',
      '(clipe oficial)',
      '(hd)',
      '(4k)',
    ];

    var cleaned = value;
    for (final term in noiseTerms) {
      final pattern = RegExp(RegExp.escape(term), caseSensitive: false);
      cleaned = cleaned.replaceAll(pattern, ' ');
    }

    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    return cleaned;
  }

  List<String> _splitParts(String cleanedName) {
    return cleanedName
        .split(' - ')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
  }

  bool _isKnownArtist(String value, Set<String> knownArtists) {
    final normalizedValue = _normalizeForCompare(value);

    for (final artist in knownArtists) {
      if (_normalizeForCompare(artist) == normalizedValue) {
        return true;
      }
    }

    return false;
  }

  bool _isFiveDigitCode(String value) {
    return RegExp(r'^\d{5}$').hasMatch(value.trim());
  }

  String _normalizeForCompare(String value) {
    return value.trim().toLowerCase();
  }
}
