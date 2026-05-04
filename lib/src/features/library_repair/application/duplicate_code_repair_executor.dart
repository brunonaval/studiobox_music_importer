import 'dart:io';

import '../domain/duplicate_code_repair_execution_item.dart';
import '../domain/duplicate_code_repair_execution_item_status.dart';
import '../domain/duplicate_code_repair_execution_plan.dart';
import '../domain/duplicate_code_repair_execution_result.dart';
import '../domain/duplicate_code_repair_execution_result_item.dart';
import '../domain/duplicate_code_repair_execution_result_item_status.dart';

class DuplicateCodeRepairExecutor {
  Future<DuplicateCodeRepairExecutionResult> execute(
    DuplicateCodeRepairExecutionPlan executionPlan,
  ) async {
    final resultItems = <DuplicateCodeRepairExecutionResultItem>[];

    for (final item in executionPlan.items) {
      if (item.status ==
          DuplicateCodeRepairExecutionItemStatus.skippedKeepOriginal) {
        resultItems.add(
          DuplicateCodeRepairExecutionResultItem(
            artist: item.artist,
            title: item.title,
            originalCode: item.originalCode,
            suggestedCode: item.suggestedCode,
            sourcePath: item.sourcePathPreview,
            destinationPath: null,
            suggestedFileName: item.suggestedFileName,
            status: DuplicateCodeRepairExecutionResultItemStatus.skipped,
            messages: const ['Item ignorado porque mantem o codigo original.'],
          ),
        );
        continue;
      }

      if (item.status == DuplicateCodeRepairExecutionItemStatus.blocked) {
        final messages = item.warnings.isNotEmpty
            ? List<String>.from(item.warnings)
            : <String>['Item bloqueado no dry-run.'];

        resultItems.add(
          DuplicateCodeRepairExecutionResultItem(
            artist: item.artist,
            title: item.title,
            originalCode: item.originalCode,
            suggestedCode: item.suggestedCode,
            sourcePath: item.sourcePathPreview,
            destinationPath: item.destinationPathPreview,
            suggestedFileName: item.suggestedFileName,
            status: DuplicateCodeRepairExecutionResultItemStatus.failed,
            messages: List.unmodifiable(messages),
          ),
        );
        continue;
      }

      resultItems.add(await _executeReadyItem(item));
    }

    return DuplicateCodeRepairExecutionResult(
      items: List.unmodifiable(resultItems),
      warnings: List.unmodifiable(executionPlan.warnings),
    );
  }

  Future<DuplicateCodeRepairExecutionResultItem> _executeReadyItem(
    DuplicateCodeRepairExecutionItem item,
  ) async {
    final sourcePath = item.sourcePathPreview?.trim();
    final destinationPath = item.destinationPathPreview?.trim();

    if (sourcePath == null || sourcePath.isEmpty) {
      return _failed(
        item,
        sourcePath: sourcePath,
        destinationPath: destinationPath,
        message: 'Caminho de origem indisponivel.',
      );
    }

    if (destinationPath == null || destinationPath.isEmpty) {
      return _failed(
        item,
        sourcePath: sourcePath,
        destinationPath: destinationPath,
        message: 'Caminho de destino indisponivel.',
      );
    }

    if (sourcePath == destinationPath) {
      return _failed(
        item,
        sourcePath: sourcePath,
        destinationPath: destinationPath,
        message: 'Origem e destino sao iguais.',
      );
    }

    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        return _failed(
          item,
          sourcePath: sourcePath,
          destinationPath: destinationPath,
          message: 'Arquivo de origem nao encontrado.',
        );
      }

      final destinationFile = File(destinationPath);
      if (await destinationFile.exists()) {
        return _failed(
          item,
          sourcePath: sourcePath,
          destinationPath: destinationPath,
          message:
              'Arquivo de destino ja existe. Renomeio cancelado para evitar sobrescrita.',
        );
      }

      final destinationDirectory = destinationFile.parent;
      if (!await destinationDirectory.exists()) {
        return _failed(
          item,
          sourcePath: sourcePath,
          destinationPath: destinationPath,
          message: 'Diretorio de destino nao encontrado.',
        );
      }

      await sourceFile.rename(destinationPath);

      return DuplicateCodeRepairExecutionResultItem(
        artist: item.artist,
        title: item.title,
        originalCode: item.originalCode,
        suggestedCode: item.suggestedCode,
        sourcePath: sourcePath,
        destinationPath: destinationPath,
        suggestedFileName: item.suggestedFileName,
        status: DuplicateCodeRepairExecutionResultItemStatus.renamed,
        messages: const ['Arquivo renomeado com sucesso.'],
      );
    } catch (error) {
      return _failed(
        item,
        sourcePath: sourcePath,
        destinationPath: destinationPath,
        message: 'Erro ao renomear arquivo: $error',
      );
    }
  }

  DuplicateCodeRepairExecutionResultItem _failed(
    DuplicateCodeRepairExecutionItem item, {
    required String? sourcePath,
    required String? destinationPath,
    required String message,
  }) {
    return DuplicateCodeRepairExecutionResultItem(
      artist: item.artist,
      title: item.title,
      originalCode: item.originalCode,
      suggestedCode: item.suggestedCode,
      sourcePath: sourcePath,
      destinationPath: destinationPath,
      suggestedFileName: item.suggestedFileName,
      status: DuplicateCodeRepairExecutionResultItemStatus.failed,
      messages: [message],
    );
  }
}
