class ImportDuplicateMatch {
  const ImportDuplicateMatch({
    required this.existingCode,
    required this.existingArtist,
    required this.existingTitle,
  });

  final String existingCode;
  final String existingArtist;
  final String existingTitle;

  String get label => '$existingCode - $existingArtist - $existingTitle';
}
