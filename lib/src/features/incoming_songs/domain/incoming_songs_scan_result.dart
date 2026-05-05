import 'incoming_song_scanned_file.dart';

class IncomingSongsScanResult {
  const IncomingSongsScanResult({required this.files, required this.warnings});

  final List<IncomingSongScannedFile> files;
  final List<String> warnings;

  int get totalCount => files.length;

  bool get hasFiles => files.isNotEmpty;

  bool get hasWarnings => warnings.isNotEmpty;
}
