import 'package:flutter_test/flutter_test.dart';
import 'package:studiobox_music_importer/src/features/import_planner/domain/import_planner.dart';
import 'package:studiobox_music_importer/src/features/incoming_songs/domain/incoming_song_name_analysis.dart';
import 'package:studiobox_music_importer/src/features/incoming_songs/domain/incoming_song_parse_confidence.dart';
import 'package:studiobox_music_importer/src/features/output_plan/domain/output_plan.dart';

void main() {
  ImportSuggestionCandidate suggestionCandidate({
    required String name,
    String? code = '00003',
    String? officialName = 'Artista - Musica - 00003.mp4',
    ImportCandidateStatus status = ImportCandidateStatus.autoApproved,
  }) {
    return ImportSuggestionCandidate(
      originalFileName: name,
      analysis: IncomingSongNameAnalysis(
        originalFileName: name,
        cleanedName: name,
        detectedArtist: 'Artista',
        detectedTitle: 'Musica',
        detectedExtra: null,
        confidence: IncomingSongParseConfidence.high,
        warnings: const [],
      ),
      suggestedCode: code,
      suggestedOfficialFileName: officialName,
      status: status,
      duplicateMatch: null,
      warnings: const [],
    );
  }

  ImportCandidateSelectionItem selectionItem({
    required String id,
    required ImportCandidateSelectionStatus status,
    required bool selectable,
  }) {
    return ImportCandidateSelectionItem(
      id: id,
      candidate: suggestionCandidate(name: '$id.mp4'),
      selectionStatus: status,
      selectable: selectable,
      warnings: const [],
    );
  }

  ImportCandidateEditItem editItem({
    required String id,
    required ImportCandidateSelectionItem selection,
    required ImportCandidateEditStatus status,
  }) {
    return ImportCandidateEditItem(
      id: id,
      selectionItem: selection,
      artist: 'Artista',
      title: 'Musica',
      code: '00003',
      officialFileName: 'Artista - Musica - 00003.mp4',
      editStatus: status,
      editable: true,
      warnings: const [],
    );
  }

  ImportOutputConfiguration config({
    ImportOutputMode mode = ImportOutputMode.renameInIncomingFolder,
    String? incoming = 'C:/Novas',
    String? official = 'C:/Biblioteca',
    String? custom = 'C:/Saida',
  }) {
    return ImportOutputConfiguration(
      mode: mode,
      incomingSongsFolderPath: incoming,
      officialLibraryFolderPath: official,
      customOutputFolderPath: custom,
    );
  }

  test('labels do ImportOutputMode', () {
    expect(
      ImportOutputMode.renameInIncomingFolder.label,
      'Renomear na pasta de musicas novas',
    );
    expect(
      ImportOutputMode.copyToOfficialLibrary.label,
      'Copiar para biblioteca oficial',
    );
    expect(
      ImportOutputMode.moveToOfficialLibrary.label,
      'Mover para biblioteca oficial',
    );
    expect(
      ImportOutputMode.copyToCustomFolder.label,
      'Copiar para pasta de saida',
    );
    expect(
      ImportOutputMode.moveToCustomFolder.label,
      'Mover para pasta de saida',
    );
  });

  test('getters de ImportOutputMode', () {
    expect(ImportOutputMode.renameInIncomingFolder.renamesInPlace, isTrue);
    expect(ImportOutputMode.renameInIncomingFolder.copiesFiles, isFalse);
    expect(ImportOutputMode.renameInIncomingFolder.movesFiles, isFalse);
    expect(
      ImportOutputMode.renameInIncomingFolder.targetsOfficialLibrary,
      isFalse,
    );
    expect(
      ImportOutputMode.renameInIncomingFolder.targetsCustomFolder,
      isFalse,
    );

    expect(ImportOutputMode.copyToOfficialLibrary.copiesFiles, isTrue);
    expect(ImportOutputMode.moveToOfficialLibrary.movesFiles, isTrue);
    expect(
      ImportOutputMode.copyToOfficialLibrary.targetsOfficialLibrary,
      isTrue,
    );
    expect(ImportOutputMode.copyToCustomFolder.targetsCustomFolder, isTrue);
  });

  test('targetFolderPath para renameInIncomingFolder', () {
    final configuration = config(mode: ImportOutputMode.renameInIncomingFolder);
    expect(configuration.targetFolderPath, 'C:/Novas');
  });

  test('targetFolderPath para official library', () {
    final configuration = config(mode: ImportOutputMode.copyToOfficialLibrary);
    expect(configuration.targetFolderPath, 'C:/Biblioteca');
  });

  test('targetFolderPath para custom folder', () {
    final configuration = config(mode: ImportOutputMode.moveToCustomFolder);
    expect(configuration.targetFolderPath, 'C:/Saida');
  });

  test('validator falha sem incomingSongsFolderPath', () {
    final selected = selectionItem(
      id: '1',
      status: ImportCandidateSelectionStatus.selected,
      selectable: true,
    );
    final validator = ImportOutputConfigurationValidator();
    final result = validator.validate(
      configuration: config(incoming: ' '),
      selectionPlan: ImportCandidateSelectionPlan(
        items: [selected],
        warnings: const [],
      ),
      editPlan: ImportCandidateEditPlan(
        items: [
          editItem(
            id: '1',
            selection: selected,
            status: ImportCandidateEditStatus.valid,
          ),
        ],
        warnings: const [],
        usedCodes: const {},
      ),
    );
    expect(result.isValid, isFalse);
  });

  test('validator falha sem officialLibraryFolderPath para modo oficial', () {
    final validator = ImportOutputConfigurationValidator();
    final selected = selectionItem(
      id: '1',
      status: ImportCandidateSelectionStatus.selected,
      selectable: true,
    );
    final result = validator.validate(
      configuration: config(
        mode: ImportOutputMode.copyToOfficialLibrary,
        official: '',
      ),
      selectionPlan: ImportCandidateSelectionPlan(
        items: [selected],
        warnings: const [],
      ),
      editPlan: ImportCandidateEditPlan(
        items: [
          editItem(
            id: '1',
            selection: selected,
            status: ImportCandidateEditStatus.valid,
          ),
        ],
        warnings: const [],
        usedCodes: const {},
      ),
    );
    expect(result.isValid, isFalse);
  });

  test('validator falha sem customOutputFolderPath para modo custom', () {
    final validator = ImportOutputConfigurationValidator();
    final selected = selectionItem(
      id: '1',
      status: ImportCandidateSelectionStatus.selected,
      selectable: true,
    );
    final result = validator.validate(
      configuration: config(
        mode: ImportOutputMode.copyToCustomFolder,
        custom: null,
      ),
      selectionPlan: ImportCandidateSelectionPlan(
        items: [selected],
        warnings: const [],
      ),
      editPlan: ImportCandidateEditPlan(
        items: [
          editItem(
            id: '1',
            selection: selected,
            status: ImportCandidateEditStatus.valid,
          ),
        ],
        warnings: const [],
        usedCodes: const {},
      ),
    );
    expect(result.isValid, isFalse);
  });

  test('validator falha sem candidatos selecionados', () {
    final validator = ImportOutputConfigurationValidator();
    final result = validator.validate(
      configuration: config(),
      selectionPlan: ImportCandidateSelectionPlan(
        items: [
          selectionItem(
            id: '1',
            status: ImportCandidateSelectionStatus.notSelected,
            selectable: true,
          ),
        ],
        warnings: const [],
      ),
      editPlan: const ImportCandidateEditPlan(
        items: [],
        warnings: [],
        usedCodes: {},
      ),
    );
    expect(result.isValid, isFalse);
    expect(
      result.errors,
      contains('Nenhum candidato selecionado para importacao.'),
    );
  });

  test('validator falha com selecionado sem edit item correspondente', () {
    final validator = ImportOutputConfigurationValidator();
    final selected = selectionItem(
      id: '1',
      status: ImportCandidateSelectionStatus.selected,
      selectable: true,
    );
    final result = validator.validate(
      configuration: config(),
      selectionPlan: ImportCandidateSelectionPlan(
        items: [selected],
        warnings: const [],
      ),
      editPlan: const ImportCandidateEditPlan(
        items: [],
        warnings: [],
        usedCodes: {},
      ),
    );
    expect(result.isValid, isFalse);
  });

  test('validator falha com candidato selecionado invalid', () {
    final validator = ImportOutputConfigurationValidator();
    final selected = selectionItem(
      id: '1',
      status: ImportCandidateSelectionStatus.selected,
      selectable: true,
    );
    final result = validator.validate(
      configuration: config(),
      selectionPlan: ImportCandidateSelectionPlan(
        items: [selected],
        warnings: const [],
      ),
      editPlan: ImportCandidateEditPlan(
        items: [
          editItem(
            id: '1',
            selection: selected,
            status: ImportCandidateEditStatus.invalid,
          ),
        ],
        warnings: const [],
        usedCodes: const {},
      ),
    );
    expect(result.isValid, isFalse);
    expect(
      result.errors,
      contains('Existem candidatos selecionados com edicao invalida.'),
    );
  });

  test('validator passa com candidato selecionado e edit valid', () {
    final validator = ImportOutputConfigurationValidator();
    final selected = selectionItem(
      id: '1',
      status: ImportCandidateSelectionStatus.selected,
      selectable: true,
    );
    final result = validator.validate(
      configuration: config(),
      selectionPlan: ImportCandidateSelectionPlan(
        items: [selected],
        warnings: const [],
      ),
      editPlan: ImportCandidateEditPlan(
        items: [
          editItem(
            id: '1',
            selection: selected,
            status: ImportCandidateEditStatus.valid,
          ),
        ],
        warnings: const [],
        usedCodes: const {},
      ),
    );
    expect(result.isValid, isTrue);
  });

  test('warnings aparecem para modo move', () {
    final validator = ImportOutputConfigurationValidator();
    final selected = selectionItem(
      id: '1',
      status: ImportCandidateSelectionStatus.selected,
      selectable: true,
    );
    final result = validator.validate(
      configuration: config(mode: ImportOutputMode.moveToOfficialLibrary),
      selectionPlan: ImportCandidateSelectionPlan(
        items: [selected],
        warnings: const [],
      ),
      editPlan: ImportCandidateEditPlan(
        items: [
          editItem(
            id: '1',
            selection: selected,
            status: ImportCandidateEditStatus.valid,
          ),
        ],
        warnings: const [],
        usedCodes: const {},
      ),
    );
    expect(
      result.warnings,
      contains(
        'Modo mover remove arquivos da pasta de origem apos a operacao futura.',
      ),
    );
  });

  test('warnings aparecem para modo official library', () {
    final validator = ImportOutputConfigurationValidator();
    final selected = selectionItem(
      id: '1',
      status: ImportCandidateSelectionStatus.selected,
      selectable: true,
    );
    final result = validator.validate(
      configuration: config(mode: ImportOutputMode.copyToOfficialLibrary),
      selectionPlan: ImportCandidateSelectionPlan(
        items: [selected],
        warnings: const [],
      ),
      editPlan: ImportCandidateEditPlan(
        items: [
          editItem(
            id: '1',
            selection: selected,
            status: ImportCandidateEditStatus.valid,
          ),
        ],
        warnings: const [],
        usedCodes: const {},
      ),
    );
    expect(
      result.warnings,
      contains('A biblioteca oficial sera alterada na operacao futura.'),
    );
  });

  test('warnings aparecem para modo custom folder', () {
    final validator = ImportOutputConfigurationValidator();
    final selected = selectionItem(
      id: '1',
      status: ImportCandidateSelectionStatus.selected,
      selectable: true,
    );
    final result = validator.validate(
      configuration: config(mode: ImportOutputMode.copyToCustomFolder),
      selectionPlan: ImportCandidateSelectionPlan(
        items: [selected],
        warnings: const [],
      ),
      editPlan: ImportCandidateEditPlan(
        items: [
          editItem(
            id: '1',
            selection: selected,
            status: ImportCandidateEditStatus.valid,
          ),
        ],
        warnings: const [],
        usedCodes: const {},
      ),
    );
    expect(
      result.warnings,
      contains('A pasta de saida escolhida sera usada na operacao futura.'),
    );
  });
}
