import 'dart:io';

import '../domain/output_plan.dart';

class ImportOperationExecutor {
  Future<ImportOperationExecutionResult> execute(
    ImportOperationDryRunPlan dryRunPlan,
  ) async {
    final resultItems = <ImportOperationExecutionResultItem>[];

    for (final item in dryRunPlan.items) {
      if (item.isBlocked) {
        resultItems.add(
          _buildResultItem(
            dryRunItem: item,
            status: ImportOperationExecutionResultItemStatus.skipped,
            messages: [
              ...item.warnings,
              'Item ignorado porque estava bloqueado no dry-run.',
            ],
          ),
        );
        continue;
      }

      final sourcePath = item.sourcePathPreview;
      final destinationPath = item.destinationPathPreview;

      if (_isBlank(sourcePath)) {
        resultItems.add(
          _buildResultItem(
            dryRunItem: item,
            status: ImportOperationExecutionResultItemStatus.failed,
            messages: ['Caminho de origem indisponivel.'],
          ),
        );
        continue;
      }

      if (_isBlank(destinationPath)) {
        resultItems.add(
          _buildResultItem(
            dryRunItem: item,
            status: ImportOperationExecutionResultItemStatus.failed,
            messages: ['Caminho de destino indisponivel.'],
          ),
        );
        continue;
      }

      if (sourcePath!.trim().toLowerCase() ==
          destinationPath!.trim().toLowerCase()) {
        resultItems.add(
          _buildResultItem(
            dryRunItem: item,
            status: ImportOperationExecutionResultItemStatus.failed,
            messages: ['Origem e destino sao iguais.'],
          ),
        );
        continue;
      }

      final sourceFile = File(sourcePath);
      final destinationFile = File(destinationPath);
      final destinationDirPath = _directoryOf(destinationPath);
      final destinationDir = destinationDirPath == null
          ? null
          : Directory(destinationDirPath);

      if (!await sourceFile.exists()) {
        resultItems.add(
          _buildResultItem(
            dryRunItem: item,
            status: ImportOperationExecutionResultItemStatus.failed,
            messages: ['Arquivo de origem nao encontrado.'],
          ),
        );
        continue;
      }

      if (await destinationFile.exists()) {
        resultItems.add(
          _buildResultItem(
            dryRunItem: item,
            status: ImportOperationExecutionResultItemStatus.failed,
            messages: [
              'Arquivo de destino ja existe. Operacao cancelada para evitar sobrescrita.',
            ],
          ),
        );
        continue;
      }

      if (destinationDir == null || !await destinationDir.exists()) {
        resultItems.add(
          _buildResultItem(
            dryRunItem: item,
            status: ImportOperationExecutionResultItemStatus.failed,
            messages: ['Diretorio de destino nao encontrado.'],
          ),
        );
        continue;
      }

      try {
        switch (item.action) {
          case ImportOperationAction.rename:
            await sourceFile.rename(destinationPath);
            resultItems.add(
              _buildResultItem(
                dryRunItem: item,
                status: ImportOperationExecutionResultItemStatus.renamed,
                messages: ['Arquivo renomeado com sucesso.'],
              ),
            );
            break;
          case ImportOperationAction.copy:
            await sourceFile.copy(destinationPath);
            resultItems.add(
              _buildResultItem(
                dryRunItem: item,
                status: ImportOperationExecutionResultItemStatus.copied,
                messages: ['Arquivo copiado com sucesso.'],
              ),
            );
            break;
          case ImportOperationAction.move:
            await sourceFile.rename(destinationPath);
            resultItems.add(
              _buildResultItem(
                dryRunItem: item,
                status: ImportOperationExecutionResultItemStatus.moved,
                messages: ['Arquivo movido com sucesso.'],
              ),
            );
            break;
        }
      } catch (error) {
        resultItems.add(
          _buildResultItem(
            dryRunItem: item,
            status: ImportOperationExecutionResultItemStatus.failed,
            messages: ['Erro ao executar operacao: $error'],
          ),
        );
      }
    }

    return ImportOperationExecutionResult(
      items: List.unmodifiable(resultItems),
      warnings: List.unmodifiable(dryRunPlan.warnings),
    );
  }

  bool _isBlank(String? value) => value == null || value.trim().isEmpty;

  String? _directoryOf(String path) {
    final trimmed = path.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final slashIndex = trimmed.lastIndexOf('/');
    final backslashIndex = trimmed.lastIndexOf(r'\');
    final index = slashIndex > backslashIndex ? slashIndex : backslashIndex;
    if (index <= 0) {
      return null;
    }
    return trimmed.substring(0, index);
  }

  ImportOperationExecutionResultItem _buildResultItem({
    required ImportOperationDryRunItem dryRunItem,
    required ImportOperationExecutionResultItemStatus status,
    required List<String> messages,
  }) {
    return ImportOperationExecutionResultItem(
      id: dryRunItem.id,
      action: dryRunItem.action,
      status: status,
      originalFileName: dryRunItem.originalFileName,
      officialFileName: dryRunItem.officialFileName,
      sourcePath: dryRunItem.sourcePathPreview,
      destinationPath: dryRunItem.destinationPathPreview,
      messages: List.unmodifiable(messages),
    );
  }
}
