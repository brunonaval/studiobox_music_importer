import '../../base_library/domain/base_library_index_result.dart';
import 'import_candidate_edit_item.dart';
import 'import_candidate_edit_plan.dart';
import 'import_candidate_edit_status.dart';
import 'import_candidate_selection_plan.dart';

class ImportCandidateEditPlanner {
  ImportCandidateEditPlan buildInitialPlan({
    required BaseLibraryIndexResult baseIndex,
    required ImportCandidateSelectionPlan selectionPlan,
  }) {
    final rawItems = selectionPlan.items
        .map((selectionItem) {
          final candidate = selectionItem.candidate;
          return ImportCandidateEditItem(
            id: selectionItem.id,
            selectionItem: selectionItem,
            artist: candidate.analysis.detectedArtist ?? '',
            title: candidate.analysis.detectedTitle ?? '',
            code: candidate.suggestedCode ?? '',
            officialFileName: candidate.suggestedOfficialFileName ?? '',
            editStatus: ImportCandidateEditStatus.invalid,
            editable: selectionItem.selectable,
            warnings: const [],
          );
        })
        .toList(growable: false);

    return revalidatePlan(items: rawItems, usedCodes: baseIndex.usedCodes);
  }

  static ImportCandidateEditPlan revalidatePlan({
    required List<ImportCandidateEditItem> items,
    required Set<String> usedCodes,
  }) {
    final editableCodeCounts = <String, int>{};
    for (final item in items) {
      if (!item.editable) {
        continue;
      }
      final trimmedCode = item.code.trim();
      if (_isFiveDigits(trimmedCode)) {
        editableCodeCounts.update(
          trimmedCode,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
      }
    }

    final validatedItems = items
        .map((item) {
          final inheritedWarnings = <String>[...item.selectionItem.warnings];
          if (!item.editable || item.selectionItem.isBlocked) {
            inheritedWarnings.add(
              'Candidato bloqueado nao pode ser editado nesta etapa.',
            );
            return ImportCandidateEditItem(
              id: item.id,
              selectionItem: item.selectionItem,
              artist: item.artist,
              title: item.title,
              code: item.code,
              officialFileName: _buildOfficialFileName(
                artist: item.artist,
                title: item.title,
                code: item.code,
              ),
              editStatus: ImportCandidateEditStatus.blocked,
              editable: false,
              warnings: List.unmodifiable(inheritedWarnings),
            );
          }

          final warnings = <String>[...inheritedWarnings];
          final trimmedArtist = item.artist.trim();
          final trimmedTitle = item.title.trim();
          final trimmedCode = item.code.trim();

          if (trimmedArtist.isEmpty) {
            warnings.add('Artista obrigatorio.');
          }
          if (trimmedTitle.isEmpty) {
            warnings.add('Musica obrigatoria.');
          }
          if (!_isFiveDigits(trimmedCode)) {
            warnings.add('Codigo invalido: use exatamente 5 digitos.');
          } else {
            if (trimmedCode == '00000') {
              warnings.add('Codigo invalido: 00000 nao e permitido.');
            }
            if (usedCodes.contains(trimmedCode)) {
              warnings.add('Codigo ja utilizado na biblioteca oficial.');
            }
            if ((editableCodeCounts[trimmedCode] ?? 0) > 1) {
              warnings.add('Codigo duplicado entre candidatos editaveis.');
            }
          }

          final isValid = warnings.isEmpty;
          return ImportCandidateEditItem(
            id: item.id,
            selectionItem: item.selectionItem,
            artist: item.artist,
            title: item.title,
            code: item.code,
            officialFileName: isValid
                ? _buildOfficialFileName(
                    artist: trimmedArtist,
                    title: trimmedTitle,
                    code: trimmedCode,
                  )
                : _buildOfficialFileName(
                    artist: item.artist,
                    title: item.title,
                    code: item.code,
                  ),
            editStatus: isValid
                ? ImportCandidateEditStatus.valid
                : ImportCandidateEditStatus.invalid,
            editable: true,
            warnings: List.unmodifiable(warnings),
          );
        })
        .toList(growable: false);

    final planWarnings = <String>[];
    if (validatedItems.any((item) => item.isInvalid)) {
      planWarnings.add('Existem candidatos com edicao invalida.');
    }
    if (validatedItems.any((item) => item.isBlocked)) {
      planWarnings.add('Existem candidatos bloqueados para edicao.');
    }

    return ImportCandidateEditPlan(
      items: List.unmodifiable(validatedItems),
      warnings: List.unmodifiable(planWarnings),
      usedCodes: Set.unmodifiable(usedCodes),
    );
  }

  static bool _isFiveDigits(String code) {
    return RegExp(r'^[0-9]{5}$').hasMatch(code);
  }

  static String _buildOfficialFileName({
    required String artist,
    required String title,
    required String code,
  }) {
    final trimmedArtist = artist.trim();
    final trimmedTitle = title.trim();
    final trimmedCode = code.trim();
    if (trimmedArtist.isEmpty || trimmedTitle.isEmpty || trimmedCode.isEmpty) {
      return '';
    }
    return '$trimmedArtist - $trimmedTitle - $trimmedCode.mp4';
  }
}
