import 'official_song.dart';

class OfficialSongParseResult {
  const OfficialSongParseResult._({this.song, this.reason});

  factory OfficialSongParseResult.success(OfficialSong song) {
    return OfficialSongParseResult._(song: song);
  }

  factory OfficialSongParseResult.failure(String reason) {
    return OfficialSongParseResult._(reason: reason);
  }

  final OfficialSong? song;
  final String? reason;

  bool get isSuccess => song != null;

  bool get isFailure => !isSuccess;
}
