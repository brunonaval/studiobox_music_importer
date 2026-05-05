import '../../import_planner/domain/import_planner.dart';
import '../../incoming_songs/domain/incoming_songs.dart';
import 'import_operation_action.dart';
import 'import_operation_dry_run_item.dart';
import 'import_operation_dry_run_item_status.dart';
import 'import_operation_dry_run_plan.dart';
import 'import_output_configuration_validation_result.dart';
import 'import_output_mode.dart';

class ImportOperationDryRunPlanner {
  ImportOperationDryRunPlan buildDryRun({
    required ImportOutputConfigurationValidationResult outputValidationResult,
    required ImportCandidateSelectionPlan selectionPlan,
    required ImportCandidateEditPlan editPlan,
    required IncomingSongCleaningPreviewPlan cleaningPlan,
  }) {
    final selectedItems = selectionPlan.items
        .where((item) => item.isSelected)
        .toList();
    final dryRunItems = <ImportOperationDryRunItem>[];

    for (final selected in selectedItems) {
      final itemWarnings = <String>[...selected.warnings];
      final editItem = _findEditItem(editPlan: editPlan, id: selected.id);
      final cleaningItem = _findCleaningItem(
        cleaningPlan: cleaningPlan,
        selected: selected,
      );

      if (!outputValidationResult.isValid) {
        itemWarnings.add('Configuracao de saida invalida.');
      }
      if (editItem == null) {
        itemWarnings.add('Edicao do candidato nao encontrada.');
      } else if (!editItem.isValid) {
        itemWarnings.add('Edicao do candidato invalida.');
      }
      if (cleaningItem == null) {
        itemWarnings.add(
          'Arquivo de origem nao encontrado no plano de pre-limpeza.',
        );
      }

      final sourcePath = cleaningItem?.scannedFile.fullPath;
      if (sourcePath == null || sourcePath.trim().isEmpty) {
        itemWarnings.add('Caminho de origem indisponivel.');
      }

      final action = ImportOperationAction.fromOutputMode(
        outputValidationResult.configuration.mode,
      );
      final officialFileName = editItem?.officialFileName ?? '';
      var destinationPath = _buildDestinationPath(
        mode: outputValidationResult.configuration.mode,
        sourcePathPreview: sourcePath,
        officialFileName: officialFileName,
        officialLibraryFolderPath:
            outputValidationResult.configuration.officialLibraryFolderPath,
        customOutputFolderPath:
            outputValidationResult.configuration.customOutputFolderPath,
      );

      if (destinationPath == null || destinationPath.trim().isEmpty) {
        itemWarnings.add('Destino indisponivel.');
      }

      if (sourcePath != null &&
          destinationPath != null &&
          _samePath(sourcePath, destinationPath)) {
        itemWarnings.add('Origem e destino sao iguais.');
      }

      dryRunItems.add(
        ImportOperationDryRunItem(
          id: selected.id,
          action: action,
          status: itemWarnings.isEmpty
              ? ImportOperationDryRunItemStatus.ready
              : ImportOperationDryRunItemStatus.blocked,
          originalFileName:
              cleaningItem?.originalFileName ??
              selected.candidate.originalFileName,
          cleanedFileName:
              cleaningItem?.cleanedFileName ??
              selected.candidate.analysis.cleanedName,
          displayPath:
              cleaningItem?.displayPath ?? selected.candidate.originalFileName,
          sourcePathPreview: sourcePath,
          destinationPathPreview: destinationPath,
          officialFileName: officialFileName,
          artist: editItem?.artist,
          title: editItem?.title,
          code: editItem?.code,
          warnings: List.unmodifiable(itemWarnings),
        ),
      );
    }

    final blockedIdsByDestination = <String, List<String>>{};
    for (final item in dryRunItems.where(
      (i) => i.isReady && i.hasDestination,
    )) {
      final key = item.destinationPathPreview!.toLowerCase();
      blockedIdsByDestination.putIfAbsent(key, () => <String>[]).add(item.id);
    }

    final duplicatedIds = <String>{};
    for (final ids in blockedIdsByDestination.values) {
      if (ids.length > 1) {
        duplicatedIds.addAll(ids);
      }
    }

    final finalItems = dryRunItems
        .map((item) {
          if (!duplicatedIds.contains(item.id)) {
            return item;
          }
          final warnings = <String>[
            ...item.warnings,
            'Destino duplicado dentro do dry-run.',
          ];
          return item.copyWith(
            status: ImportOperationDryRunItemStatus.blocked,
            warnings: List.unmodifiable(warnings),
          );
        })
        .toList(growable: false);

    final planWarnings = <String>[
      ...outputValidationResult.warnings,
      if (!outputValidationResult.isValid) ...outputValidationResult.errors,
    ];

    if (finalItems.any((item) => item.isBlocked)) {
      planWarnings.add('Existem itens bloqueados no dry-run da importacao.');
    }
    if (duplicatedIds.isNotEmpty) {
      planWarnings.add('Foram detectados destinos duplicados no dry-run.');
    }

    return ImportOperationDryRunPlan(
      items: List.unmodifiable(finalItems),
      warnings: List.unmodifiable(planWarnings),
    );
  }

  ImportCandidateEditItem? _findEditItem({
    required ImportCandidateEditPlan editPlan,
    required String id,
  }) {
    for (final item in editPlan.items) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  IncomingSongCleaningPreviewItem? _findCleaningItem({
    required IncomingSongCleaningPreviewPlan cleaningPlan,
    required ImportCandidateSelectionItem selected,
  }) {
    final candidate = selected.candidate;
    for (final item in cleaningPlan.items) {
      if (item.originalFileName == candidate.originalFileName) {
        return item;
      }
    }
    for (final item in cleaningPlan.items) {
      if (item.cleanedFileName == candidate.analysis.cleanedName ||
          item.cleanedFileName == candidate.originalFileName) {
        return item;
      }
    }
    return null;
  }

  String? _buildDestinationPath({
    required ImportOutputMode mode,
    required String? sourcePathPreview,
    required String officialFileName,
    required String? officialLibraryFolderPath,
    required String? customOutputFolderPath,
  }) {
    if (officialFileName.trim().isEmpty) {
      return null;
    }
    switch (mode) {
      case ImportOutputMode.renameInIncomingFolder:
        if (sourcePathPreview == null || sourcePathPreview.trim().isEmpty) {
          return null;
        }
        final dir = _directoryOf(sourcePathPreview);
        if (dir == null || dir.isEmpty) {
          return null;
        }
        return _joinPath(dir, officialFileName);
      case ImportOutputMode.copyToOfficialLibrary:
      case ImportOutputMode.moveToOfficialLibrary:
        if (officialLibraryFolderPath == null ||
            officialLibraryFolderPath.trim().isEmpty) {
          return null;
        }
        return _joinPath(officialLibraryFolderPath, officialFileName);
      case ImportOutputMode.copyToCustomFolder:
      case ImportOutputMode.moveToCustomFolder:
        if (customOutputFolderPath == null ||
            customOutputFolderPath.trim().isEmpty) {
          return null;
        }
        return _joinPath(customOutputFolderPath, officialFileName);
    }
  }

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

  bool _samePath(String a, String b) {
    return a.trim().toLowerCase() == b.trim().toLowerCase();
  }
}
