import 'dart:io';

import '../domain/base_library.dart';

class OfficialLibraryScanService {
  OfficialLibraryScanService({BaseLibraryIndexer? indexer})
    : _indexer = indexer ?? BaseLibraryIndexer();

  final BaseLibraryIndexer _indexer;

  Future<BaseLibraryIndexResult> scanFolder(String folderPath) async {
    final trimmedPath = folderPath.trim();
    if (trimmedPath.isEmpty) {
      return _indexer.indexScannedFiles(const []);
    }

    final directory = Directory(trimmedPath);
    if (!await directory.exists()) {
      return _indexer.indexScannedFiles(const []);
    }

    final scannedFiles = <BaseLibraryScannedFile>[];

    try {
      await for (final entity in directory.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is! File) {
          continue;
        }

        final name = _basename(entity.path);
        if (name.toLowerCase().endsWith('.mp4')) {
          scannedFiles.add(
            BaseLibraryScannedFile(
              fileName: name,
              fullPath: entity.path,
              relativePath: _relativePath(
                baseFolderPath: trimmedPath,
                filePath: entity.path,
                fallbackFileName: name,
              ),
            ),
          );
        }
      }
    } catch (_) {
      // Mantem comportamento resiliente e retorna index parcial.
    }

    return _indexer.indexScannedFiles(scannedFiles);
  }

  String _basename(String path) {
    final normalized = path.replaceAll('\\', '/');
    final separatorIndex = normalized.lastIndexOf('/');
    if (separatorIndex < 0) {
      return normalized;
    }
    return normalized.substring(separatorIndex + 1);
  }

  String _relativePath({
    required String baseFolderPath,
    required String filePath,
    required String fallbackFileName,
  }) {
    final normalizedBase = _normalizePath(baseFolderPath);
    final normalizedFile = _normalizePath(filePath);

    if (normalizedBase.isEmpty || normalizedFile.isEmpty) {
      return fallbackFileName;
    }

    final baseWithSeparator = '$normalizedBase/';
    if (!normalizedFile.startsWith(baseWithSeparator)) {
      return fallbackFileName;
    }

    final relative = normalizedFile.substring(baseWithSeparator.length).trim();
    if (relative.isEmpty) {
      return fallbackFileName;
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
