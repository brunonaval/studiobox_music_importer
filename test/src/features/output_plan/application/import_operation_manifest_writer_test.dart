import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:studiobox_music_importer/src/features/output_plan/application/output_plan_application.dart';
import 'package:studiobox_music_importer/src/features/output_plan/domain/output_plan.dart';

void main() {
  ImportOperationManifest sampleManifest({String id = 'import-manifest-test'}) {
    return ImportOperationManifest(
      id: id,
      generatedAtIso8601: DateTime.utc(
        2026,
        5,
        5,
        14,
        30,
        12,
      ).toIso8601String(),
      appName: 'StudioBox Music Importer',
      manifestVersion: '1.0',
      outputMode: 'Copiar para pasta de saida',
      incomingSongsFolderPath: 'C:/Novas',
      officialLibraryFolderPath: 'C:/Biblioteca',
      customOutputFolderPath: 'C:/Saida',
      summary: const ImportOperationManifestSummary(
        totalCount: 1,
        renamedCount: 0,
        copiedCount: 1,
        movedCount: 0,
        skippedCount: 0,
        failedCount: 0,
        successCount: 1,
      ),
      items: const [
        ImportOperationManifestItem(
          id: '1',
          action: 'Copiar',
          status: 'Copiado',
          originalFileName: 'A.mp4',
          officialFileName: 'Artista - Musica - 00001.mp4',
          sourcePath: r'C:\Novas\A.mp4',
          destinationPath: r'C:\Saida\Artista - Musica - 00001.mp4',
          messages: ['Arquivo copiado com sucesso.'],
        ),
      ],
      warnings: const [],
    );
  }

  test('salva JSON com sucesso e arquivo existe', () async {
    final dir = await Directory.systemTemp.createTemp('manifest-writer-ok-');
    try {
      final result = await ImportOperationManifestWriter().writeJson(
        manifest: sampleManifest(),
        folderPath: dir.path,
      );
      expect(result.success, isTrue);
      expect(result.filePath, isNotNull);
      final file = File(result.filePath!);
      expect(await file.exists(), isTrue);
      final parsed =
          jsonDecode(await file.readAsString()) as Map<String, Object?>;
      expect(parsed['id'], 'import-manifest-test');
    } finally {
      await dir.delete(recursive: true);
    }
  });

  test('nao sobrescreve manifesto existente', () async {
    final dir = await Directory.systemTemp.createTemp('manifest-writer-nos-');
    try {
      final existing = File('${dir.path}/import-manifest-test.json');
      await existing.writeAsString('keep');
      final result = await ImportOperationManifestWriter().writeJson(
        manifest: sampleManifest(),
        folderPath: dir.path,
      );
      expect(result.success, isFalse);
      expect(result.messages.join(' '), contains('ja existe'));
      expect(await existing.readAsString(), 'keep');
    } finally {
      await dir.delete(recursive: true);
    }
  });

  test('falha com folderPath vazio', () async {
    final result = await ImportOperationManifestWriter().writeJson(
      manifest: sampleManifest(),
      folderPath: '   ',
    );
    expect(result.success, isFalse);
    expect(result.messages.join(' '), contains('nao informada'));
  });

  test('falha com pasta inexistente', () async {
    final result = await ImportOperationManifestWriter().writeJson(
      manifest: sampleManifest(),
      folderPath: 'C:/caminho/inexistente/manifestos',
    );
    expect(result.success, isFalse);
    expect(result.messages.join(' '), contains('nao encontrada'));
  });

  test('messages funcionam', () async {
    final ok = const ImportOperationManifestWriteResult(
      success: true,
      filePath: 'C:/Manifestos/a.json',
      messages: ['ok'],
    );
    expect(ok.hasMessages, isTrue);
  });
}
