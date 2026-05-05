import 'dart:io';

import '../domain/incoming_song_scanned_file.dart';
import '../domain/incoming_songs_scan_result.dart';

class IncomingSongsScanService {
  Future<IncomingSongsScanResult> scanFolder(String folderPath) async {
    final trimmedPath = folderPath.trim();
    if (trimmedPath.isEmpty) {
      return const IncomingSongsScanResult(
        files: [],
        warnings: ['Pasta de músicas novas não informada.'],
      );
    }

    final directory = Directory(trimmedPath);
    if (!await directory.exists()) {
      return const IncomingSongsScanResult(
        files: [],
        warnings: ['Pasta de músicas novas não encontrada.'],
      );
    }

    final scannedFiles = <IncomingSongScannedFile>[];
    final warnings = <String>[];

    try {
      await for (final entity in directory.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is! File) {
          continue;
        }

        final name = _baseName(entity.path);
        if (name.toLowerCase().endsWith('.mp4')) {
          scannedFiles.add(
            IncomingSongScannedFile(
              fileName: name,
              fullPath: entity.path,
              relativePath: _relativePath(trimmedPath, entity.path),
            ),
          );
        }
      }
    } catch (_) {
      warnings.add('Falha ao escanear algumas músicas novas.');
    }

    scannedFiles.sort((a, b) => a.displayPath.compareTo(b.displayPath));

    return IncomingSongsScanResult(files: scannedFiles, warnings: warnings);
  }

  String _baseName(String path) {
    final normalized = path.replaceAll('\\', '/');
    final index = normalized.lastIndexOf('/');
    return index < 0 ? normalized : normalized.substring(index + 1);
  }

  String _relativePath(String baseFolder, String fullPath) {
    final normalizedBase = _normalizePath(baseFolder);
    final normalizedFile = _normalizePath(fullPath);

    if (normalizedBase.isEmpty || normalizedFile.isEmpty) {
      return _baseName(fullPath);
    }

    final prefix = '$normalizedBase/';
    if (!normalizedFile.startsWith(prefix)) {
      return _baseName(fullPath);
    }

    final relative = normalizedFile.substring(prefix.length).trim();
    if (relative.isEmpty) {
      return _baseName(fullPath);
    }

    return relative.replaceAll('/', r'\');
  }

  String _normalizePath(String path) {
    var normalized = path.replaceAll('\\', '/').trim();
    while (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    return normalized;
  }
}
