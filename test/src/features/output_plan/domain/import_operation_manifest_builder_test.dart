import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:studiobox_music_importer/src/features/output_plan/domain/output_plan.dart';

void main() {
  ImportOperationExecutionResult sampleExecutionResult() {
    return ImportOperationExecutionResult(
      items: [
        ImportOperationExecutionResultItem(
          id: '1',
          action: ImportOperationAction.copy,
          status: ImportOperationExecutionResultItemStatus.copied,
          originalFileName: 'A.mp4',
          officialFileName: 'Artista - Musica - 00001.mp4',
          sourcePath: r'C:\Novas\A.mp4',
          destinationPath: r'C:\Saida\Artista - Musica - 00001.mp4',
          messages: const ['Arquivo copiado com sucesso.'],
        ),
        ImportOperationExecutionResultItem(
          id: '2',
          action: ImportOperationAction.move,
          status: ImportOperationExecutionResultItemStatus.failed,
          originalFileName: 'B.mp4',
          officialFileName: 'Artista - Musica - 00002.mp4',
          sourcePath: r'C:\Novas\B.mp4',
          destinationPath: r'C:\Saida\Artista - Musica - 00002.mp4',
          messages: const ['Arquivo de origem nao encontrado.'],
        ),
      ],
      warnings: const ['Ha itens com falha.'],
    );
  }

  ImportOutputConfiguration sampleConfiguration() {
    return const ImportOutputConfiguration(
      mode: ImportOutputMode.copyToCustomFolder,
      incomingSongsFolderPath: 'C:/Novas',
      officialLibraryFolderPath: 'C:/Biblioteca',
      customOutputFolderPath: 'C:/Saida',
    );
  }

  test('builder cria manifesto com id baseado em generatedAt', () {
    final generatedAt = DateTime.utc(2026, 5, 5, 14, 30, 12);
    final manifest = ImportOperationManifestBuilder().build(
      configuration: sampleConfiguration(),
      executionResult: sampleExecutionResult(),
      generatedAt: generatedAt,
    );

    expect(manifest.id, 'import-manifest-20260505T143012Z');
  });

  test('generatedAtIso8601 fica em UTC', () {
    final generatedAt = DateTime.utc(2026, 5, 5, 14, 30, 12);
    final manifest = ImportOperationManifestBuilder().build(
      configuration: sampleConfiguration(),
      executionResult: sampleExecutionResult(),
      generatedAt: generatedAt,
    );

    expect(manifest.generatedAtIso8601.endsWith('Z'), isTrue);
    expect(DateTime.parse(manifest.generatedAtIso8601).isUtc, isTrue);
  });

  test('summary reflete executionResult', () {
    final manifest = ImportOperationManifestBuilder().build(
      configuration: sampleConfiguration(),
      executionResult: sampleExecutionResult(),
      generatedAt: DateTime.utc(2026, 5, 5, 14, 30, 12),
    );
    expect(manifest.summary.totalCount, 2);
    expect(manifest.summary.copiedCount, 1);
    expect(manifest.summary.failedCount, 1);
    expect(manifest.summary.successCount, 1);
  });

  test('items preservam ordem e labels', () {
    final manifest = ImportOperationManifestBuilder().build(
      configuration: sampleConfiguration(),
      executionResult: sampleExecutionResult(),
      generatedAt: DateTime.utc(2026, 5, 5, 14, 30, 12),
    );
    expect(manifest.items[0].id, '1');
    expect(manifest.items[1].id, '2');
    expect(manifest.items[0].action, 'Copiar');
    expect(manifest.items[0].status, 'Copiado');
  });

  test('outputMode e folders sao preservados', () {
    final manifest = ImportOperationManifestBuilder().build(
      configuration: sampleConfiguration(),
      executionResult: sampleExecutionResult(),
      generatedAt: DateTime.utc(2026, 5, 5, 14, 30, 12),
    );
    expect(manifest.outputMode, 'Copiar para pasta de saida');
    expect(manifest.incomingSongsFolderPath, 'C:/Novas');
    expect(manifest.officialLibraryFolderPath, 'C:/Biblioteca');
    expect(manifest.customOutputFolderPath, 'C:/Saida');
  });

  test('warnings do executionResult entram no manifesto', () {
    final manifest = ImportOperationManifestBuilder().build(
      configuration: sampleConfiguration(),
      executionResult: sampleExecutionResult(),
      generatedAt: DateTime.utc(2026, 5, 5, 14, 30, 12),
    );
    expect(manifest.warnings, contains('Ha itens com falha.'));
  });

  test('serializer gera map e json parseavel', () {
    final manifest = ImportOperationManifestBuilder().build(
      configuration: sampleConfiguration(),
      executionResult: sampleExecutionResult(),
      generatedAt: DateTime.utc(2026, 5, 5, 14, 30, 12),
    );
    final serializer = ImportOperationManifestJsonSerializer();
    final jsonMap = serializer.toJson(manifest);
    expect(jsonMap.containsKey('summary'), isTrue);
    expect(jsonMap.containsKey('items'), isTrue);
    expect(jsonMap.containsKey('warnings'), isTrue);

    final encoded = serializer.encodePretty(manifest);
    final parsed = jsonDecode(encoded) as Map<String, Object?>;
    expect(parsed['id'], manifest.id);
    expect(parsed['summary'], isA<Map<String, Object?>>());
    expect(parsed['items'], isA<List<Object?>>());
    expect(parsed['warnings'], isA<List<Object?>>());
  });
}
