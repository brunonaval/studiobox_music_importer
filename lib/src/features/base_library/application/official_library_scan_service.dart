import 'dart:io';

import '../domain/base_library.dart';

class OfficialLibraryScanService {
  OfficialLibraryScanService({BaseLibraryIndexer? indexer})
    : _indexer = indexer ?? BaseLibraryIndexer();

  final BaseLibraryIndexer _indexer;

  Future<BaseLibraryIndexResult> scanFolder(String folderPath) async {
    final trimmedPath = folderPath.trim();
    if (trimmedPath.isEmpty) {
      return _indexer.indexFileNames(const []);
    }

    final directory = Directory(trimmedPath);
    if (!await directory.exists()) {
      return _indexer.indexFileNames(const []);
    }

    final fileNames = <String>[];

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
          fileNames.add(name);
        }
      }
    } catch (_) {
      // Mantem comportamento resiliente e retorna index parcial.
    }

    return _indexer.indexFileNames(fileNames);
  }

  String _basename(String path) {
    final normalized = path.replaceAll('\\', '/');
    final separatorIndex = normalized.lastIndexOf('/');
    if (separatorIndex < 0) {
      return normalized;
    }
    return normalized.substring(separatorIndex + 1);
  }
}
