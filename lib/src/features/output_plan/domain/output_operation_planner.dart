import '../../import_planner/domain/import_candidate_status.dart';
import '../../import_planner/domain/import_suggestion_plan.dart';
import 'output_operation_item.dart';
import 'output_operation_item_status.dart';
import 'output_operation_mode.dart';
import 'output_operation_plan.dart';
import 'output_transfer_action.dart';

class OutputOperationPlanner {
  OutputOperationPlan buildPlan({
    required ImportSuggestionPlan suggestionPlan,
    required OutputOperationMode mode,
    required OutputTransferAction transferAction,
    String? sourceFolderPath,
    String? officialLibraryFolderPath,
    String? customOutputFolderPath,
    bool includeNeedsReview = false,
  }) {
    final planWarnings = <String>[];

    final invalidModeAction = !_isValidModeAction(mode, transferAction);
    if (invalidModeAction) {
      planWarnings.add('Combinacao de modo e acao invalida.');
    }

    final destinationRequired =
        mode == OutputOperationMode.officialLibrary ||
        mode == OutputOperationMode.customOutputFolder;
    final destinationFromMode = _resolveDestinationFolderPath(
      mode: mode,
      sourceFolderPath: sourceFolderPath,
      officialLibraryFolderPath: officialLibraryFolderPath,
      customOutputFolderPath: customOutputFolderPath,
    );

    final missingDestination =
        destinationRequired &&
        (destinationFromMode == null || destinationFromMode.trim().isEmpty);
    if (missingDestination) {
      planWarnings.add('Pasta de destino nao informada.');
    }

    final items = <OutputOperationItem>[];

    for (final candidate in suggestionPlan.candidates) {
      final itemWarnings = <String>[...candidate.warnings];
      final sourcePreview = _buildSourcePathPreview(
        sourceFolderPath: sourceFolderPath,
        originalFileName: candidate.originalFileName,
      );

      final suggestedName = candidate.suggestedOfficialFileName;
      var status = OutputOperationItemStatus.ready;
      OutputTransferAction? action = transferAction;
      String? destinationFolderPath = destinationFromMode;
      String? destinationPreview;

      if (candidate.status == ImportCandidateStatus.blocked) {
        status = OutputOperationItemStatus.blocked;
        action = null;
        itemWarnings.add('Item bloqueado no plano de importacao.');
      } else if (candidate.status == ImportCandidateStatus.needsReview &&
          !includeNeedsReview) {
        status = OutputOperationItemStatus.skipped;
        action = null;
        itemWarnings.add('Item precisa de revisao antes da execucao.');
      }

      if (suggestedName == null || suggestedName.trim().isEmpty) {
        status = OutputOperationItemStatus.blocked;
        action = null;
        itemWarnings.add('Nome oficial sugerido indisponivel.');
      }

      if (invalidModeAction) {
        status = OutputOperationItemStatus.blocked;
        action = null;
        itemWarnings.add('Combinacao de modo e acao invalida.');
      }

      if (status == OutputOperationItemStatus.ready) {
        if (destinationRequired &&
            (destinationFolderPath == null ||
                destinationFolderPath.trim().isEmpty)) {
          status = OutputOperationItemStatus.blocked;
          action = null;
          itemWarnings.add('Pasta de destino nao informada.');
        }
      }

      if (mode == OutputOperationMode.renameInPlace) {
        destinationFolderPath = sourceFolderPath;
      }

      if (status == OutputOperationItemStatus.ready && suggestedName != null) {
        if (destinationFolderPath != null &&
            destinationFolderPath.trim().isNotEmpty) {
          destinationPreview = '$destinationFolderPath/$suggestedName';
        } else if (mode == OutputOperationMode.renameInPlace) {
          destinationPreview = suggestedName;
        } else {
          status = OutputOperationItemStatus.blocked;
          action = null;
          itemWarnings.add('Pasta de destino nao informada.');
        }
      }

      items.add(
        OutputOperationItem(
          originalFileName: candidate.originalFileName,
          sourceFolderPath: sourceFolderPath,
          destinationFolderPath: destinationFolderPath,
          sourcePathPreview: sourcePreview,
          destinationPathPreview: destinationPreview,
          suggestedOfficialFileName: suggestedName,
          action: action,
          status: status,
          warnings: List.unmodifiable(itemWarnings),
        ),
      );
    }

    if (items.any((item) => item.isSkipped)) {
      planWarnings.add('Existem itens aguardando revisao.');
    }

    if (items.any((item) => item.isBlocked)) {
      planWarnings.add('Existem itens bloqueados.');
    }

    return OutputOperationPlan(
      mode: mode,
      transferAction: transferAction,
      items: List.unmodifiable(items),
      warnings: List.unmodifiable(planWarnings),
    );
  }

  bool _isValidModeAction(
    OutputOperationMode mode,
    OutputTransferAction action,
  ) {
    switch (mode) {
      case OutputOperationMode.renameInPlace:
        return action == OutputTransferAction.rename;
      case OutputOperationMode.officialLibrary:
      case OutputOperationMode.customOutputFolder:
        return action == OutputTransferAction.copy ||
            action == OutputTransferAction.move;
    }
  }

  String _buildSourcePathPreview({
    required String? sourceFolderPath,
    required String originalFileName,
  }) {
    if (sourceFolderPath == null || sourceFolderPath.trim().isEmpty) {
      return originalFileName;
    }

    return '$sourceFolderPath/$originalFileName';
  }

  String? _resolveDestinationFolderPath({
    required OutputOperationMode mode,
    required String? sourceFolderPath,
    required String? officialLibraryFolderPath,
    required String? customOutputFolderPath,
  }) {
    switch (mode) {
      case OutputOperationMode.renameInPlace:
        return sourceFolderPath;
      case OutputOperationMode.officialLibrary:
        return officialLibraryFolderPath;
      case OutputOperationMode.customOutputFolder:
        return customOutputFolderPath;
    }
  }
}
