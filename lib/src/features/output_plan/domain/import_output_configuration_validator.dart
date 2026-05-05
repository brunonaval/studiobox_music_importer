import '../../import_planner/domain/import_planner.dart';
import 'import_output_configuration.dart';
import 'import_output_configuration_validation_result.dart';

class ImportOutputConfigurationValidator {
  ImportOutputConfigurationValidationResult validate({
    required ImportOutputConfiguration configuration,
    required ImportCandidateSelectionPlan selectionPlan,
    required ImportCandidateEditPlan editPlan,
  }) {
    final errors = <String>[];
    final warnings = <String>[];

    if (_isBlank(configuration.incomingSongsFolderPath)) {
      errors.add('Pasta de musicas novas obrigatoria.');
    }

    if (configuration.requiresOfficialLibraryFolder &&
        _isBlank(configuration.officialLibraryFolderPath)) {
      errors.add('Pasta da biblioteca oficial obrigatoria para este modo.');
    }

    if (configuration.requiresCustomOutputFolder &&
        _isBlank(configuration.customOutputFolderPath)) {
      errors.add('Pasta de saida obrigatoria para este modo.');
    }

    final selectedItems = selectionPlan.items
        .where((item) => item.isSelected)
        .toList();
    if (selectedItems.isEmpty) {
      errors.add('Nenhum candidato selecionado para importacao.');
    }

    var hasMissingEditItem = false;
    var hasInvalidSelected = false;
    var hasBlockedSelected = false;

    for (final selectedItem in selectedItems) {
      ImportCandidateEditItem? editItem;
      for (final current in editPlan.items) {
        if (current.id == selectedItem.id) {
          editItem = current;
          break;
        }
      }

      if (editItem == null) {
        hasMissingEditItem = true;
        continue;
      }

      if (editItem.isInvalid) {
        hasInvalidSelected = true;
      }

      if (editItem.isBlocked) {
        hasBlockedSelected = true;
      }
    }

    if (hasMissingEditItem) {
      errors.add(
        'Existem candidatos selecionados sem item de edicao correspondente.',
      );
    }
    if (hasInvalidSelected) {
      errors.add('Existem candidatos selecionados com edicao invalida.');
    }
    if (hasBlockedSelected) {
      errors.add('Existem candidatos selecionados bloqueados.');
    }

    if (configuration.mode.movesFiles) {
      warnings.add(
        'Modo mover remove arquivos da pasta de origem apos a operacao futura.',
      );
    }
    if (configuration.mode.targetsOfficialLibrary) {
      warnings.add('A biblioteca oficial sera alterada na operacao futura.');
    }
    if (configuration.mode.targetsCustomFolder) {
      warnings.add('A pasta de saida escolhida sera usada na operacao futura.');
    }

    return ImportOutputConfigurationValidationResult(
      configuration: configuration,
      isValid: errors.isEmpty,
      errors: List.unmodifiable(errors),
      warnings: List.unmodifiable(warnings),
    );
  }

  bool _isBlank(String? value) => value == null || value.trim().isEmpty;
}
