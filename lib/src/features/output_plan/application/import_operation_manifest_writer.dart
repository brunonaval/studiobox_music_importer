import 'dart:io';

import '../domain/output_plan.dart';

class ImportOperationManifestWriter {
  Future<ImportOperationManifestWriteResult> writeJson({
    required ImportOperationManifest manifest,
    required String folderPath,
  }) async {
    final trimmedFolder = folderPath.trim();
    if (trimmedFolder.isEmpty) {
      return const ImportOperationManifestWriteResult(
        success: false,
        filePath: null,
        messages: ['Pasta do manifesto nao informada.'],
      );
    }

    final folder = Directory(trimmedFolder);
    if (!await folder.exists()) {
      return const ImportOperationManifestWriteResult(
        success: false,
        filePath: null,
        messages: ['Pasta do manifesto nao encontrada.'],
      );
    }

    final fileName = '${manifest.id}.json';
    final filePath = _joinPath(trimmedFolder, fileName);
    final file = File(filePath);

    if (await file.exists()) {
      return const ImportOperationManifestWriteResult(
        success: false,
        filePath: null,
        messages: [
          'Arquivo de manifesto ja existe. Salvamento cancelado para evitar sobrescrita.',
        ],
      );
    }

    try {
      final json = ImportOperationManifestJsonSerializer().encodePretty(
        manifest,
      );
      await file.writeAsString(json);
      return ImportOperationManifestWriteResult(
        success: true,
        filePath: filePath,
        messages: const ['Manifesto JSON salvo com sucesso.'],
      );
    } catch (error) {
      return ImportOperationManifestWriteResult(
        success: false,
        filePath: null,
        messages: ['Erro ao salvar manifesto JSON: $error'],
      );
    }
  }

  String _joinPath(String folder, String fileName) {
    final base = folder.trim();
    final leaf = fileName.trim();
    if (base.contains(r'\')) {
      final normalized = base.endsWith(r'\')
          ? base.substring(0, base.length - 1)
          : base;
      return '$normalized\\$leaf';
    }
    final normalized = base.endsWith('/')
        ? base.substring(0, base.length - 1)
        : base;
    return '$normalized/$leaf';
  }
}
