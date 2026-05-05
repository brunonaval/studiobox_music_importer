import 'dart:io';

import '../domain/invalid_file_repair_execution_item.dart';
import '../domain/invalid_file_repair_execution_item_status.dart';
import '../domain/invalid_file_repair_execution_plan.dart';
import '../domain/invalid_file_repair_execution_result.dart';
import '../domain/invalid_file_repair_execution_result_item.dart';
import '../domain/invalid_file_repair_execution_result_item_status.dart';

class InvalidFileRepairExecutor {
  Future<InvalidFileRepairExecutionResult> execute(
    InvalidFileRepairExecutionPlan executionPlan,
  ) async {
    final resultItems = <InvalidFileRepairExecutionResultItem>[];

    for (final item in executionPlan.items) {
      if (item.status ==
          InvalidFileRepairExecutionItemStatus.skippedNeedsReview) {
        resultItems.add(
          _buildResultItem(
            item,
            status: InvalidFileRepairExecutionResultItemStatus.skipped,
            messages: const ['Item ignorado porque precisa de revisão manual.'],
          ),
        );
        continue;
      }

      if (item.status == InvalidFileRepairExecutionItemStatus.blocked) {
        final messages = item.warnings.isNotEmpty
            ? List<String>.from(item.warnings)
            : <String>['Item bloqueado no dry-run.'];

        resultItems.add(
          _buildResultItem(
            item,
            status: InvalidFileRepairExecutionResultItemStatus.failed,
            messages: List.unmodifiable(messages),
          ),
        );
        continue;
      }

      resultItems.add(await _executeReadyItem(item));
    }

    return InvalidFileRepairExecutionResult(
      items: List.unmodifiable(resultItems),
      warnings: List.unmodifiable(executionPlan.warnings),
    );
  }

  Future<InvalidFileRepairExecutionResultItem> _executeReadyItem(
    InvalidFileRepairExecutionItem item,
  ) async {
    final sourcePath = item.sourcePathPreview?.trim();
    final destinationPath = item.destinationPathPreview?.trim();

    if (_isBlank(sourcePath)) {
      return _buildResultItem(
        item,
        sourcePath: sourcePath,
        destinationPath: destinationPath,
        status: InvalidFileRepairExecutionResultItemStatus.failed,
        messages: const ['Caminho de origem indisponível.'],
      );
    }

    if (_isBlank(destinationPath)) {
      return _buildResultItem(
        item,
        sourcePath: sourcePath,
        destinationPath: destinationPath,
        status: InvalidFileRepairExecutionResultItemStatus.failed,
        messages: const ['Caminho de destino indisponível.'],
      );
    }

    if (sourcePath == destinationPath) {
      return _buildResultItem(
        item,
        sourcePath: sourcePath,
        destinationPath: destinationPath,
        status: InvalidFileRepairExecutionResultItemStatus.failed,
        messages: const ['Origem e destino são iguais.'],
      );
    }

    final sourceDir = _directoryOf(sourcePath!);
    final destinationDir = _directoryOf(destinationPath!);

    if (sourceDir != destinationDir) {
      return _buildResultItem(
        item,
        sourcePath: sourcePath,
        destinationPath: destinationPath,
        status: InvalidFileRepairExecutionResultItemStatus.failed,
        messages: const [
          'Destino está em diretório diferente. Renomeio cancelado para evitar movimentação.',
        ],
      );
    }

    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        return _buildResultItem(
          item,
          sourcePath: sourcePath,
          destinationPath: destinationPath,
          status: InvalidFileRepairExecutionResultItemStatus.failed,
          messages: const ['Arquivo de origem não encontrado.'],
        );
      }

      final destinationFile = File(destinationPath);
      if (await destinationFile.exists()) {
        return _buildResultItem(
          item,
          sourcePath: sourcePath,
          destinationPath: destinationPath,
          status: InvalidFileRepairExecutionResultItemStatus.failed,
          messages: const [
            'Arquivo de destino já existe. Renomeio cancelado para evitar sobrescrita.',
          ],
        );
      }

      final destinationDirectory = destinationFile.parent;
      if (!await destinationDirectory.exists()) {
        return _buildResultItem(
          item,
          sourcePath: sourcePath,
          destinationPath: destinationPath,
          status: InvalidFileRepairExecutionResultItemStatus.failed,
          messages: const ['Diretório de destino não encontrado.'],
        );
      }

      await sourceFile.rename(destinationPath);

      return _buildResultItem(
        item,
        sourcePath: sourcePath,
        destinationPath: destinationPath,
        status: InvalidFileRepairExecutionResultItemStatus.renamed,
        messages: const ['Arquivo renomeado com sucesso.'],
      );
    } catch (error) {
      return _buildResultItem(
        item,
        sourcePath: sourcePath,
        destinationPath: destinationPath,
        status: InvalidFileRepairExecutionResultItemStatus.failed,
        messages: ['Erro ao renomear arquivo: $error'],
      );
    }
  }

  InvalidFileRepairExecutionResultItem _buildResultItem(
    InvalidFileRepairExecutionItem item, {
    String? sourcePath,
    String? destinationPath,
    required InvalidFileRepairExecutionResultItemStatus status,
    required List<String> messages,
  }) {
    return InvalidFileRepairExecutionResultItem(
      originalFileName: item.originalFileName,
      originalReason: item.originalReason,
      detectedArtist: item.detectedArtist,
      detectedTitle: item.detectedTitle,
      suggestedCode: item.suggestedCode,
      sourcePath: sourcePath ?? item.sourcePathPreview,
      destinationPath: destinationPath ?? item.destinationPathPreview,
      suggestedFileName: item.suggestedFileName,
      status: status,
      messages: messages,
    );
  }

  String _directoryOf(String path) {
    final useBackslash = path.contains('\\');
    final separator = useBackslash ? '\\' : '/';
    final lastSeparator = path.lastIndexOf(separator);
    if (lastSeparator < 0) return '';
    return path.substring(0, lastSeparator);
  }

  bool _isBlank(String? value) {
    return value == null || value.trim().isEmpty;
  }
}
