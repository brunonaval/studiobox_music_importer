import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:studiobox_music_importer/src/features/library_repair/application/duplicate_code_repair_executor.dart';
import 'package:studiobox_music_importer/src/features/library_repair/domain/library_repair.dart';

void main() {
  DuplicateCodeRepairExecutionItem executionItem({
    required DuplicateCodeRepairExecutionItemStatus status,
    String? sourcePath,
    String? destinationPath,
    String? suggestedFileName,
    String? suggestedCode,
    List<String> warnings = const [],
  }) {
    return DuplicateCodeRepairExecutionItem(
      originalCode: '00001',
      suggestedCode: suggestedCode,
      artist: 'Artista A',
      title: 'Musica A',
      originalFileName: 'Artista A - Musica A - 00001.mp4',
      displayPath: 'Sub/Artista A - Musica A - 00001.mp4',
      sourcePathPreview: sourcePath,
      destinationPathPreview: destinationPath,
      suggestedFileName: suggestedFileName,
      status: status,
      warnings: warnings,
    );
  }

  DuplicateCodeRepairExecutionPlan executionPlan(
    List<DuplicateCodeRepairExecutionItem> items,
  ) {
    return DuplicateCodeRepairExecutionPlan(items: items, warnings: const []);
  }

  group('DuplicateCodeRepairExecutor.execute', () {
    late DuplicateCodeRepairExecutor executor;

    setUp(() {
      executor = DuplicateCodeRepairExecutor();
    });

    test('renomeia item readyToRename com sucesso', () async {
      final tempDir = await Directory.systemTemp.createTemp('repair_exec_ok_');
      addTearDown(() => tempDir.delete(recursive: true));

      final source = File('${tempDir.path}${Platform.pathSeparator}a.mp4');
      await source.writeAsString('');
      final destinationPath =
          '${tempDir.path}${Platform.pathSeparator}a-renamed.mp4';

      final result = await executor.execute(
        executionPlan([
          executionItem(
            status: DuplicateCodeRepairExecutionItemStatus.readyToRename,
            sourcePath: source.path,
            destinationPath: destinationPath,
            suggestedFileName: 'a-renamed.mp4',
            suggestedCode: '00002',
          ),
        ]),
      );

      expect(await source.exists(), isFalse);
      expect(await File(destinationPath).exists(), isTrue);
      expect(result.renamedCount, 1);
      expect(result.failedCount, 0);
    });

    test('nao sobrescreve destino existente', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'repair_exec_no_overwrite_',
      );
      addTearDown(() => tempDir.delete(recursive: true));

      final source = File('${tempDir.path}${Platform.pathSeparator}a.mp4');
      final destination = File('${tempDir.path}${Platform.pathSeparator}b.mp4');
      await source.writeAsString('source');
      await destination.writeAsString('dest');

      final result = await executor.execute(
        executionPlan([
          executionItem(
            status: DuplicateCodeRepairExecutionItemStatus.readyToRename,
            sourcePath: source.path,
            destinationPath: destination.path,
            suggestedFileName: 'b.mp4',
            suggestedCode: '00002',
          ),
        ]),
      );

      expect(await source.exists(), isTrue);
      expect(await destination.exists(), isTrue);
      expect(result.failedCount, 1);
      expect(
        result.items.first.messages.first,
        contains('Arquivo de destino ja existe'),
      );
    });

    test('falha quando origem nao existe', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'repair_exec_source_missing_',
      );
      addTearDown(() => tempDir.delete(recursive: true));

      final sourcePath = '${tempDir.path}${Platform.pathSeparator}missing.mp4';
      final destinationPath =
          '${tempDir.path}${Platform.pathSeparator}renamed.mp4';

      final result = await executor.execute(
        executionPlan([
          executionItem(
            status: DuplicateCodeRepairExecutionItemStatus.readyToRename,
            sourcePath: sourcePath,
            destinationPath: destinationPath,
            suggestedFileName: 'renamed.mp4',
            suggestedCode: '00002',
          ),
        ]),
      );

      expect(result.failedCount, 1);
      expect(
        result.items.first.messages.first,
        'Arquivo de origem nao encontrado.',
      );
    });

    test('falha quando diretorio de destino nao existe', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'repair_exec_missing_dir_',
      );
      addTearDown(() => tempDir.delete(recursive: true));

      final source = File('${tempDir.path}${Platform.pathSeparator}a.mp4');
      await source.writeAsString('');

      final destinationPath =
          '${tempDir.path}${Platform.pathSeparator}nao_existe${Platform.pathSeparator}b.mp4';

      final result = await executor.execute(
        executionPlan([
          executionItem(
            status: DuplicateCodeRepairExecutionItemStatus.readyToRename,
            sourcePath: source.path,
            destinationPath: destinationPath,
            suggestedFileName: 'b.mp4',
            suggestedCode: '00002',
          ),
        ]),
      );

      expect(result.failedCount, 1);
      expect(
        result.items.first.messages.first,
        'Diretorio de destino nao encontrado.',
      );
      expect(await source.exists(), isTrue);
    });

    test('item skippedKeepOriginal retorna skipped', () async {
      final result = await executor.execute(
        executionPlan([
          executionItem(
            status: DuplicateCodeRepairExecutionItemStatus.skippedKeepOriginal,
            sourcePath: 'C:/x.mp4',
          ),
        ]),
      );

      expect(result.skippedCount, 1);
      expect(result.items.first.isSkipped, isTrue);
    });

    test('item blocked retorna failed sem tentar rename', () async {
      final result = await executor.execute(
        executionPlan([
          executionItem(
            status: DuplicateCodeRepairExecutionItemStatus.blocked,
            sourcePath: 'C:/x.mp4',
            warnings: const ['Bloqueado por teste'],
          ),
        ]),
      );

      expect(result.failedCount, 1);
      expect(result.items.first.isFailed, isTrue);
      expect(result.items.first.messages, contains('Bloqueado por teste'));
    });

    test('source igual a destination retorna failed', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'repair_exec_same_path_',
      );
      addTearDown(() => tempDir.delete(recursive: true));

      final path = '${tempDir.path}${Platform.pathSeparator}a.mp4';
      final file = File(path);
      await file.writeAsString('');

      final result = await executor.execute(
        executionPlan([
          executionItem(
            status: DuplicateCodeRepairExecutionItemStatus.readyToRename,
            sourcePath: path,
            destinationPath: path,
            suggestedFileName: 'a.mp4',
            suggestedCode: '00002',
          ),
        ]),
      );

      expect(result.failedCount, 1);
      expect(result.items.first.messages.first, 'Origem e destino sao iguais.');
      expect(await file.exists(), isTrue);
    });

    test('counts do result funcionam', () async {
      final tempDir = await Directory.systemTemp.createTemp('repair_counts_');
      addTearDown(() => tempDir.delete(recursive: true));

      final source = File('${tempDir.path}${Platform.pathSeparator}a.mp4');
      await source.writeAsString('');
      final destinationPath =
          '${tempDir.path}${Platform.pathSeparator}a-renamed.mp4';

      final result = await executor.execute(
        executionPlan([
          executionItem(
            status: DuplicateCodeRepairExecutionItemStatus.readyToRename,
            sourcePath: source.path,
            destinationPath: destinationPath,
            suggestedFileName: 'a-renamed.mp4',
            suggestedCode: '00002',
          ),
          executionItem(
            status: DuplicateCodeRepairExecutionItemStatus.skippedKeepOriginal,
            sourcePath: 'C:/x.mp4',
          ),
          executionItem(
            status: DuplicateCodeRepairExecutionItemStatus.blocked,
            sourcePath: 'C:/y.mp4',
            warnings: const ['Bloqueado'],
          ),
        ]),
      );

      expect(result.totalCount, 3);
      expect(result.renamedCount, 1);
      expect(result.skippedCount, 1);
      expect(result.failedCount, 1);
      expect(result.hasRenamedItems, isTrue);
      expect(result.hasSkippedItems, isTrue);
      expect(result.hasFailedItems, isTrue);
    });
  });

  group('DuplicateCodeRepairExecutionResultItemStatus.label', () {
    test('retorna labels esperados', () {
      expect(
        DuplicateCodeRepairExecutionResultItemStatus.renamed.label,
        'Renomeado',
      );
      expect(
        DuplicateCodeRepairExecutionResultItemStatus.skipped.label,
        'Ignorado',
      );
      expect(
        DuplicateCodeRepairExecutionResultItemStatus.failed.label,
        'Falhou',
      );
    });
  });
}
