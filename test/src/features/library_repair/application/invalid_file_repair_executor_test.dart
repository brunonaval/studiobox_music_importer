import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:studiobox_music_importer/src/features/library_repair/application/invalid_file_repair_executor.dart';
import 'package:studiobox_music_importer/src/features/library_repair/domain/library_repair.dart';

void main() {
  InvalidFileRepairExecutionItem executionItem({
    required InvalidFileRepairExecutionItemStatus status,
    String? sourcePath,
    String? destinationPath,
    String? suggestedFileName,
    String originalFileName = 'Artista - Musica.mp4',
    List<String> warnings = const [],
  }) {
    return InvalidFileRepairExecutionItem(
      originalFileName: originalFileName,
      originalReason: 'Fora do padrão',
      displayPath: originalFileName,
      fullPath: sourcePath,
      sourcePathPreview: sourcePath,
      destinationPathPreview: destinationPath,
      suggestedFileName: suggestedFileName,
      detectedArtist: 'Artista',
      detectedTitle: 'Musica',
      suggestedCode: '00002',
      status: status,
      warnings: warnings,
    );
  }

  InvalidFileRepairExecutionPlan executionPlan(
    List<InvalidFileRepairExecutionItem> items,
  ) {
    return InvalidFileRepairExecutionPlan(items: items, warnings: const []);
  }

  group('InvalidFileRepairExecutor.execute', () {
    late InvalidFileRepairExecutor executor;

    setUp(() {
      executor = InvalidFileRepairExecutor();
    });

    test('renomeia item readyToRename com sucesso', () async {
      final tempDir = await Directory.systemTemp.createTemp('inv_exec_ok_');
      addTearDown(() => tempDir.delete(recursive: true));

      final sep = Platform.pathSeparator;
      final source = File('${tempDir.path}${sep}Artista - Musica.mp4');
      await source.writeAsString('');
      final destPath = '${tempDir.path}${sep}Artista - Musica - 00002.mp4';

      final plan = executionPlan([
        executionItem(
          status: InvalidFileRepairExecutionItemStatus.readyToRename,
          sourcePath: source.path,
          destinationPath: destPath,
          suggestedFileName: 'Artista - Musica - 00002.mp4',
        ),
      ]);

      final result = await executor.execute(plan);

      expect(result.renamedCount, 1);
      expect(result.failedCount, 0);
      expect(await source.exists(), isFalse);
      expect(await File(destPath).exists(), isTrue);
      expect(result.items.first.isRenamed, isTrue);
    });

    test('nao sobrescreve destino existente', () async {
      final tempDir = await Directory.systemTemp.createTemp('inv_exec_noov_');
      addTearDown(() => tempDir.delete(recursive: true));

      final sep = Platform.pathSeparator;
      final source = File('${tempDir.path}${sep}Artista - Musica.mp4');
      await source.writeAsString('');
      final dest = File('${tempDir.path}${sep}Artista - Musica - 00002.mp4');
      await dest.writeAsString('');

      final plan = executionPlan([
        executionItem(
          status: InvalidFileRepairExecutionItemStatus.readyToRename,
          sourcePath: source.path,
          destinationPath: dest.path,
        ),
      ]);

      final result = await executor.execute(plan);

      expect(result.failedCount, 1);
      expect(await source.exists(), isTrue);
      expect(await dest.exists(), isTrue);
      expect(
        result.items.first.messages.any((m) => m.contains('já existe')),
        isTrue,
      );
    });

    test('falha quando origem nao existe', () async {
      final tempDir = await Directory.systemTemp.createTemp('inv_exec_nosrc_');
      addTearDown(() => tempDir.delete(recursive: true));

      final sep = Platform.pathSeparator;
      final plan = executionPlan([
        executionItem(
          status: InvalidFileRepairExecutionItemStatus.readyToRename,
          sourcePath: '${tempDir.path}${sep}nao_existe.mp4',
          destinationPath: '${tempDir.path}${sep}Artista - Musica - 00002.mp4',
        ),
      ]);

      final result = await executor.execute(plan);

      expect(result.failedCount, 1);
      expect(
        result.items.first.messages.any((m) => m.contains('origem')),
        isTrue,
      );
    });

    test('falha quando diretorio de destino nao existe', () async {
      final tempDir = await Directory.systemTemp.createTemp('inv_exec_nodir_');
      addTearDown(() => tempDir.delete(recursive: true));

      final sep = Platform.pathSeparator;
      final source = File('${tempDir.path}${sep}Artista - Musica.mp4');
      await source.writeAsString('');

      final plan = executionPlan([
        executionItem(
          status: InvalidFileRepairExecutionItemStatus.readyToRename,
          sourcePath: source.path,
          destinationPath:
              '${tempDir.path}${sep}sub_inexistente${sep}Artista - Musica - 00002.mp4',
        ),
      ]);

      final result = await executor.execute(plan);

      expect(result.failedCount, 1);
      expect(
        result.items.first.messages.any(
          (m) =>
              m.contains('diretório diferente') ||
              m.contains('Diretório de destino'),
        ),
        isTrue,
      );
    });

    test(
      'falha quando destino esta em diretorio diferente do source',
      () async {
        final tempDir = await Directory.systemTemp.createTemp('inv_exec_diff_');
        addTearDown(() => tempDir.delete(recursive: true));

        final sep = Platform.pathSeparator;
        final subDir = Directory('${tempDir.path}${sep}sub');
        await subDir.create();

        final source = File('${tempDir.path}${sep}Artista - Musica.mp4');
        await source.writeAsString('');

        final destPath = '${subDir.path}${sep}Artista - Musica - 00002.mp4';

        final plan = executionPlan([
          executionItem(
            status: InvalidFileRepairExecutionItemStatus.readyToRename,
            sourcePath: source.path,
            destinationPath: destPath,
          ),
        ]);

        final result = await executor.execute(plan);

        expect(result.failedCount, 1);
        expect(
          result.items.first.messages.any(
            (m) => m.contains('diretório diferente'),
          ),
          isTrue,
        );
      },
    );

    test('item skippedNeedsReview nao faz rename e retorna skipped', () async {
      final tempDir = await Directory.systemTemp.createTemp('inv_exec_skip_');
      addTearDown(() => tempDir.delete(recursive: true));

      final sep = Platform.pathSeparator;
      final source = File('${tempDir.path}${sep}Arquivo.mp4');
      await source.writeAsString('');

      final plan = executionPlan([
        executionItem(
          status: InvalidFileRepairExecutionItemStatus.skippedNeedsReview,
          sourcePath: source.path,
          destinationPath: '${tempDir.path}${sep}Arquivo - 00002.mp4',
        ),
      ]);

      final result = await executor.execute(plan);

      expect(result.skippedCount, 1);
      expect(result.renamedCount, 0);
      expect(await source.exists(), isTrue);
      expect(result.items.first.isSkipped, isTrue);
    });

    test('item blocked retorna failed sem fazer I/O', () async {
      final plan = executionPlan([
        executionItem(
          status: InvalidFileRepairExecutionItemStatus.blocked,
          warnings: const ['Item bloqueado: sem dados.'],
        ),
      ]);

      final result = await executor.execute(plan);

      expect(result.failedCount, 1);
      expect(result.items.first.isFailed, isTrue);
    });

    test('source igual a destination retorna failed', () async {
      final tempDir = await Directory.systemTemp.createTemp('inv_exec_same_');
      addTearDown(() => tempDir.delete(recursive: true));

      final sep = Platform.pathSeparator;
      final path = '${tempDir.path}${sep}Artista - Musica.mp4';

      final plan = executionPlan([
        executionItem(
          status: InvalidFileRepairExecutionItemStatus.readyToRename,
          sourcePath: path,
          destinationPath: path,
        ),
      ]);

      final result = await executor.execute(plan);

      expect(result.failedCount, 1);
      expect(
        result.items.first.messages.any((m) => m.contains('iguais')),
        isTrue,
      );
    });

    test('counts do result funcionam corretamente', () async {
      final tempDir = await Directory.systemTemp.createTemp('inv_exec_cnt_');
      addTearDown(() => tempDir.delete(recursive: true));

      final sep = Platform.pathSeparator;
      final source = File('${tempDir.path}${sep}Artista - Musica.mp4');
      await source.writeAsString('');
      final destPath = '${tempDir.path}${sep}Artista - Musica - 00002.mp4';

      final plan = executionPlan([
        executionItem(
          status: InvalidFileRepairExecutionItemStatus.readyToRename,
          sourcePath: source.path,
          destinationPath: destPath,
          suggestedFileName: 'Artista - Musica - 00002.mp4',
        ),
        executionItem(
          status: InvalidFileRepairExecutionItemStatus.skippedNeedsReview,
          originalFileName: 'Pais e Filhos - Artista.mp4',
        ),
        executionItem(
          status: InvalidFileRepairExecutionItemStatus.blocked,
          originalFileName: 'SemSeparador.mp4',
          warnings: const ['Bloqueado.'],
        ),
      ]);

      final result = await executor.execute(plan);

      expect(result.renamedCount, 1);
      expect(result.skippedCount, 1);
      expect(result.failedCount, 1);
      expect(result.totalCount, 3);
    });

    test('labels do enum retornam textos esperados', () {
      expect(
        InvalidFileRepairExecutionResultItemStatus.renamed.label,
        'Renomeado',
      );
      expect(
        InvalidFileRepairExecutionResultItemStatus.skipped.label,
        'Ignorado',
      );
      expect(InvalidFileRepairExecutionResultItemStatus.failed.label, 'Falhou');
    });
  });
}
