class OfficialSong {
  const OfficialSong({
    required this.artist,
    required this.title,
    required this.code,
    required this.fileName,
  });

  final String artist;
  final String title;
  final String code;
  final String fileName;

  String get officialFileName => '$artist - $title - $code.mp4';

  String get catalogKey =>
      '${artist.trim().toLowerCase()}|${title.trim().toLowerCase()}';
}
