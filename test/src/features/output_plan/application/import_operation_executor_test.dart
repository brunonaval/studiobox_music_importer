import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:studiobox_music_importer/src/features/output_plan/application/output_plan_application.dart';
import 'package:studiobox_music_importer/src/features/output_plan/domain/output_plan.dart';

void main() {
  ImportOperationDryRunItem dryRunItem({
    required ImportOperationAction action,
    required ImportOperationDryRunItemStatus status,
    required String source,
    required String destination,
    String id = '1',
  }) {
    return ImportOperationDryRunItem(
      id: id,
      action: action,
      status: status,
      originalFileName: 'A.mp4',
      cleanedFileName: 'A.mp4',
      displayPath: 'A.mp4',
      sourcePathPreview: source,
      destinationPathPreview: destination,
      officialFileName: 'Artista - Musica - 00003.mp4',
      artist: 'Artista',
      title: 'Musica',
      code: '00003',
      warnings: const [],
    );
  }

  test('rename executa com sucesso', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'import-exec-rename-',
    );
    try {
      final source = File('${tempDir.path}/origem.mp4');
      await source.writeAsString('data');
      final destination = '${tempDir.path}/destino.mp4';
      final result = await ImportOperationExecutor().execute(
        ImportOperationDryRunPlan(
          items: [
            dryRunItem(
              action: ImportOperationAction.rename,
              status: ImportOperationDryRunItemStatus.ready,
              source: source.path,
              destination: destination,
            ),
          ],
          warnings: const [],
        ),
      );

      expect(result.renamedCount, 1);
      expect(await source.exists(), isFalse);
      expect(await File(destination).exists(), isTrue);
    } finally {
      await tempDir.delete(recursive: true);
    }
  });

  test('copy executa com sucesso', () async {
    final tempDir = await Directory.systemTemp.createTemp('import-exec-copy-');
    try {
      final source = File('${tempDir.path}/origem.mp4');
      await source.writeAsString('data');
      final destination = '${tempDir.path}/destino.mp4';
      final result = await ImportOperationExecutor().execute(
        ImportOperationDryRunPlan(
          items: [
            dryRunItem(
              action: ImportOperationAction.copy,
              status: ImportOperationDryRunItemStatus.ready,
              source: source.path,
              destination: destination,
            ),
          ],
          warnings: const [],
        ),
      );

      expect(result.copiedCount, 1);
      expect(await source.exists(), isTrue);
      expect(await File(destination).exists(), isTrue);
    } finally {
      await tempDir.delete(recursive: true);
    }
  });

  test('move executa com sucesso', () async {
    final tempDir = await Directory.systemTemp.createTemp('import-exec-move-');
    try {
      final source = File('${tempDir.path}/origem.mp4');
      await source.writeAsString('data');
      final destination = '${tempDir.path}/destino.mp4';
      final result = await ImportOperationExecutor().execute(
        ImportOperationDryRunPlan(
          items: [
            dryRunItem(
              action: ImportOperationAction.move,
              status: ImportOperationDryRunItemStatus.ready,
              source: source.path,
              destination: destination,
            ),
          ],
          warnings: const [],
        ),
      );

      expect(result.movedCount, 1);
      expect(await source.exists(), isFalse);
      expect(await File(destination).exists(), isTrue);
    } finally {
      await tempDir.delete(recursive: true);
    }
  });

  test('nao sobrescreve destino existente', () async {
    final tempDir = await Directory.systemTemp.createTemp('import-exec-nos-');
    try {
      final source = File('${tempDir.path}/origem.mp4');
      final destinationFile = File('${tempDir.path}/destino.mp4');
      await source.writeAsString('data');
      await destinationFile.writeAsString('keep');
      final result = await ImportOperationExecutor().execute(
        ImportOperationDryRunPlan(
          items: [
            dryRunItem(
              action: ImportOperationAction.copy,
              status: ImportOperationDryRunItemStatus.ready,
              source: source.path,
              destination: destinationFile.path,
            ),
          ],
          warnings: const [],
        ),
      );
      expect(result.failedCount, 1);
      expect(await source.exists(), isTrue);
      expect(await destinationFile.exists(), isTrue);
    } finally {
      await tempDir.delete(recursive: true);
    }
  });

  test('falha quando origem nao existe', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'import-exec-no-src-',
    );
    try {
      final destination = '${tempDir.path}/destino.mp4';
      final result = await ImportOperationExecutor().execute(
        ImportOperationDryRunPlan(
          items: [
            dryRunItem(
              action: ImportOperationAction.copy,
              status: ImportOperationDryRunItemStatus.ready,
              source: '${tempDir.path}/inexistente.mp4',
              destination: destination,
            ),
          ],
          warnings: const [],
        ),
      );
      expect(result.failedCount, 1);
    } finally {
      await tempDir.delete(recursive: true);
    }
  });

  test('falha quando diretorio pai de destino nao existe', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'import-exec-no-dir-',
    );
    try {
      final source = File('${tempDir.path}/origem.mp4');
      await source.writeAsString('data');
      final destination = '${tempDir.path}/nao_existe/destino.mp4';
      final result = await ImportOperationExecutor().execute(
        ImportOperationDryRunPlan(
          items: [
            dryRunItem(
              action: ImportOperationAction.copy,
              status: ImportOperationDryRunItemStatus.ready,
              source: source.path,
              destination: destination,
            ),
          ],
          warnings: const [],
        ),
      );
      expect(result.failedCount, 1);
    } finally {
      await tempDir.delete(recursive: true);
    }
  });

  test('falha quando origem e destino sao iguais', () async {
    final tempDir = await Directory.systemTemp.createTemp('import-exec-same-');
    try {
      final source = File('${tempDir.path}/origem.mp4');
      await source.writeAsString('data');
      final result = await ImportOperationExecutor().execute(
        ImportOperationDryRunPlan(
          items: [
            dryRunItem(
              action: ImportOperationAction.rename,
              status: ImportOperationDryRunItemStatus.ready,
              source: source.path,
              destination: source.path,
            ),
          ],
          warnings: const [],
        ),
      );
      expect(result.failedCount, 1);
      expect(await source.exists(), isTrue);
    } finally {
      await tempDir.delete(recursive: true);
    }
  });

  test('item blocked vira skipped e nao faz io', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'import-exec-blocked-',
    );
    try {
      final source = File('${tempDir.path}/origem.mp4');
      await source.writeAsString('data');
      final destination = '${tempDir.path}/destino.mp4';
      final result = await ImportOperationExecutor().execute(
        ImportOperationDryRunPlan(
          items: [
            dryRunItem(
              action: ImportOperationAction.copy,
              status: ImportOperationDryRunItemStatus.blocked,
              source: source.path,
              destination: destination,
            ),
          ],
          warnings: const [],
        ),
      );
      expect(result.skippedCount, 1);
      expect(await source.exists(), isTrue);
      expect(await File(destination).exists(), isFalse);
    } finally {
      await tempDir.delete(recursive: true);
    }
  });

  test('counts e labels funcionam', () async {
    final result = ImportOperationExecutionResult(
      items: [
        ImportOperationExecutionResultItem(
          id: '1',
          action: ImportOperationAction.rename,
          status: ImportOperationExecutionResultItemStatus.renamed,
          originalFileName: 'A.mp4',
          officialFileName: 'A.mp4',
          sourcePath: 'a',
          destinationPath: 'b',
          messages: const ['ok'],
        ),
        ImportOperationExecutionResultItem(
          id: '2',
          action: ImportOperationAction.copy,
          status: ImportOperationExecutionResultItemStatus.copied,
          originalFileName: 'B.mp4',
          officialFileName: 'B.mp4',
          sourcePath: 'a',
          destinationPath: 'b',
          messages: const ['ok'],
        ),
        ImportOperationExecutionResultItem(
          id: '3',
          action: ImportOperationAction.move,
          status: ImportOperationExecutionResultItemStatus.failed,
          originalFileName: 'C.mp4',
          officialFileName: 'C.mp4',
          sourcePath: 'a',
          destinationPath: 'b',
          messages: const ['erro'],
        ),
        ImportOperationExecutionResultItem(
          id: '4',
          action: ImportOperationAction.move,
          status: ImportOperationExecutionResultItemStatus.skipped,
          originalFileName: 'D.mp4',
          officialFileName: 'D.mp4',
          sourcePath: 'a',
          destinationPath: 'b',
          messages: const ['skip'],
        ),
      ],
      warnings: const [],
    );

    expect(result.totalCount, 4);
    expect(result.renamedCount, 1);
    expect(result.copiedCount, 1);
    expect(result.movedCount, 0);
    expect(result.skippedCount, 1);
    expect(result.failedCount, 1);
    expect(result.successCount, 2);
    expect(ImportOperationExecutionResultItemStatus.renamed.label, 'Renomeado');
    expect(ImportOperationExecutionResultItemStatus.copied.label, 'Copiado');
    expect(ImportOperationExecutionResultItemStatus.moved.label, 'Movido');
    expect(ImportOperationExecutionResultItemStatus.skipped.label, 'Ignorado');
    expect(ImportOperationExecutionResultItemStatus.failed.label, 'Falhou');
  });
}
