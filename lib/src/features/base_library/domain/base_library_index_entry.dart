import 'official_song.dart';

class BaseLibraryIndexEntry {
  const BaseLibraryIndexEntry({
    required this.song,
    required this.originalFileName,
  });

  final OfficialSong song;
  final String originalFileName;

  String get code => song.code;

  String get artist => song.artist;

  String get title => song.title;
}
