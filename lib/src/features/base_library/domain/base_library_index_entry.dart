import 'official_song.dart';

class BaseLibraryIndexEntry {
  const BaseLibraryIndexEntry({
    required this.song,
    required this.originalFileName,
    this.fullPath,
    this.relativePath,
  });

  final OfficialSong song;
  final String originalFileName;
  final String? fullPath;
  final String? relativePath;

  String get code => song.code;

  String get artist => song.artist;

  String get title => song.title;

  String get displayPath {
    final trimmedRelative = relativePath?.trim();
    if (trimmedRelative != null && trimmedRelative.isNotEmpty) {
      return trimmedRelative;
    }
    return originalFileName;
  }
}
