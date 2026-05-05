import 'package:flutter_test/flutter_test.dart';
import 'package:studiobox_music_importer/src/features/import_planner/domain/import_planner.dart';
import 'package:studiobox_music_importer/src/features/incoming_songs/domain/incoming_songs.dart';
import 'package:studiobox_music_importer/src/features/output_plan/domain/output_plan.dart';

void main() {
  ImportSuggestionCandidate candidate({
    required String name,
    String code = '00003',
    String officialName = 'Artista - Musica - 00003.mp4',
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
      status: ImportCandidateStatus.autoApproved,
      duplicateMatch: null,
      warnings: const [],
    );
  }

  ImportCandidateSelectionItem selectedItem(String id, String name) {
    return ImportCandidateSelectionItem(
      id: id,
      candidate: candidate(name: name),
      selectionStatus: ImportCandidateSelectionStatus.selected,
      selectable: true,
      warnings: const [],
    );
  }

  ImportCandidateEditItem validEdit(ImportCandidateSelectionItem selection) {
    return ImportCandidateEditItem(
      id: selection.id,
      selectionItem: selection,
      artist: 'Artista',
      title: 'Musica',
      code: '00003',
      officialFileName: 'Artista - Musica - 00003.mp4',
      editStatus: ImportCandidateEditStatus.valid,
      editable: true,
      warnings: const [],
    );
  }

  IncomingSongCleaningPreviewItem cleaningItem({
    required String fileName,
    required String fullPath,
  }) {
    return IncomingSongCleaningPreviewItem(
      scannedFile: IncomingSongScannedFile(
        fileName: fileName,
        fullPath: fullPath,
        relativePath: fileName,
      ),
      originalFileName: fileName,
      cleanedFileName: fileName,
      appliedRules: const [],
      warnings: const [],
    );
  }

  ImportOutputConfigurationValidationResult validOutput({
    required ImportOutputMode mode,
    String incoming = 'C:/Novas',
    String official = 'C:/Biblioteca',
    String custom = 'C:/Saida',
  }) {
    return ImportOutputConfigurationValidationResult(
      configuration: ImportOutputConfiguration(
        mode: mode,
        incomingSongsFolderPath: incoming,
        officialLibraryFolderPath: official,
        customOutputFolderPath: custom,
      ),
      isValid: true,
      errors: const [],
      warnings: const [],
    );
  }

  test('gera item ready com selecionado edit valido e config valida', () {
    final selected = selectedItem('1', 'A.mp4');
    final plan = ImportOperationDryRunPlanner().buildDryRun(
      outputValidationResult: validOutput(
        mode: ImportOutputMode.copyToOfficialLibrary,
      ),
      selectionPlan: ImportCandidateSelectionPlan(
        items: [selected],
        warnings: const [],
      ),
      editPlan: ImportCandidateEditPlan(
        items: [validEdit(selected)],
        warnings: const [],
        usedCodes: const {},
      ),
      cleaningPlan: IncomingSongCleaningPreviewPlan(
        items: [cleaningItem(fileName: 'A.mp4', fullPath: r'C:\Novas\A.mp4')],
        warnings: const [],
      ),
    );

    expect(plan.totalCount, 1);
    expect(plan.items.single.isReady, isTrue);
  });

  test('action rename para renameInIncomingFolder', () {
    final selected = selectedItem('1', 'A.mp4');
    final plan = ImportOperationDryRunPlanner().buildDryRun(
      outputValidationResult: validOutput(
        mode: ImportOutputMode.renameInIncomingFolder,
      ),
      selectionPlan: ImportCandidateSelectionPlan(
        items: [selected],
        warnings: const [],
      ),
      editPlan: ImportCandidateEditPlan(
        items: [validEdit(selected)],
        warnings: const [],
        usedCodes: const {},
      ),
      cleaningPlan: IncomingSongCleaningPreviewPlan(
        items: [cleaningItem(fileName: 'A.mp4', fullPath: r'C:\Novas\A.mp4')],
        warnings: const [],
      ),
    );
    expect(plan.items.single.action, ImportOperationAction.rename);
  });

  test('action copy para modos copy', () {
    expect(
      ImportOperationAction.fromOutputMode(
        ImportOutputMode.copyToOfficialLibrary,
      ),
      ImportOperationAction.copy,
    );
    expect(
      ImportOperationAction.fromOutputMode(ImportOutputMode.copyToCustomFolder),
      ImportOperationAction.copy,
    );
  });

  test('action move para modos move', () {
    expect(
      ImportOperationAction.fromOutputMode(
        ImportOutputMode.moveToOfficialLibrary,
      ),
      ImportOperationAction.move,
    );
    expect(
      ImportOperationAction.fromOutputMode(ImportOutputMode.moveToCustomFolder),
      ImportOperationAction.move,
    );
  });

  test('rename monta destino no mesmo diretorio da origem', () {
    final selected = selectedItem('1', 'A.mp4');
    final plan = ImportOperationDryRunPlanner().buildDryRun(
      outputValidationResult: validOutput(
        mode: ImportOutputMode.renameInIncomingFolder,
      ),
      selectionPlan: ImportCandidateSelectionPlan(
        items: [selected],
        warnings: const [],
      ),
      editPlan: ImportCandidateEditPlan(
        items: [validEdit(selected)],
        warnings: const [],
        usedCodes: const {},
      ),
      cleaningPlan: IncomingSongCleaningPreviewPlan(
        items: [cleaningItem(fileName: 'A.mp4', fullPath: r'C:\Novas\A.mp4')],
        warnings: const [],
      ),
    );
    expect(
      plan.items.single.destinationPathPreview,
      r'C:\Novas\Artista - Musica - 00003.mp4',
    );
  });

  test('copy official monta destino na biblioteca oficial', () {
    final selected = selectedItem('1', 'A.mp4');
    final plan = ImportOperationDryRunPlanner().buildDryRun(
      outputValidationResult: validOutput(
        mode: ImportOutputMode.copyToOfficialLibrary,
        official: 'C:/Biblioteca',
      ),
      selectionPlan: ImportCandidateSelectionPlan(
        items: [selected],
        warnings: const [],
      ),
      editPlan: ImportCandidateEditPlan(
        items: [validEdit(selected)],
        warnings: const [],
        usedCodes: const {},
      ),
      cleaningPlan: IncomingSongCleaningPreviewPlan(
        items: [cleaningItem(fileName: 'A.mp4', fullPath: r'C:\Novas\A.mp4')],
        warnings: const [],
      ),
    );
    expect(
      plan.items.single.destinationPathPreview,
      'C:/Biblioteca/Artista - Musica - 00003.mp4',
    );
  });

  test('copy custom monta destino na pasta custom', () {
    final selected = selectedItem('1', 'A.mp4');
    final plan = ImportOperationDryRunPlanner().buildDryRun(
      outputValidationResult: validOutput(
        mode: ImportOutputMode.copyToCustomFolder,
        custom: 'C:/Saida',
      ),
      selectionPlan: ImportCandidateSelectionPlan(
        items: [selected],
        warnings: const [],
      ),
      editPlan: ImportCandidateEditPlan(
        items: [validEdit(selected)],
        warnings: const [],
        usedCodes: const {},
      ),
      cleaningPlan: IncomingSongCleaningPreviewPlan(
        items: [cleaningItem(fileName: 'A.mp4', fullPath: r'C:\Novas\A.mp4')],
        warnings: const [],
      ),
    );
    expect(
      plan.items.single.destinationPathPreview,
      'C:/Saida/Artista - Musica - 00003.mp4',
    );
  });

  test('bloqueia quando output validation invalida', () {
    final selected = selectedItem('1', 'A.mp4');
    final invalid = ImportOutputConfigurationValidationResult(
      configuration: const ImportOutputConfiguration(
        mode: ImportOutputMode.copyToOfficialLibrary,
        incomingSongsFolderPath: 'C:/Novas',
        officialLibraryFolderPath: '',
        customOutputFolderPath: null,
      ),
      isValid: false,
      errors: const ['erro'],
      warnings: const [],
    );
    final plan = ImportOperationDryRunPlanner().buildDryRun(
      outputValidationResult: invalid,
      selectionPlan: ImportCandidateSelectionPlan(
        items: [selected],
        warnings: const [],
      ),
      editPlan: ImportCandidateEditPlan(
        items: [validEdit(selected)],
        warnings: const [],
        usedCodes: const {},
      ),
      cleaningPlan: IncomingSongCleaningPreviewPlan(
        items: [cleaningItem(fileName: 'A.mp4', fullPath: r'C:\Novas\A.mp4')],
        warnings: const [],
      ),
    );
    expect(plan.items.single.isBlocked, isTrue);
  });

  test('bloqueia sem edit item', () {
    final selected = selectedItem('1', 'A.mp4');
    final plan = ImportOperationDryRunPlanner().buildDryRun(
      outputValidationResult: validOutput(
        mode: ImportOutputMode.copyToOfficialLibrary,
      ),
      selectionPlan: ImportCandidateSelectionPlan(
        items: [selected],
        warnings: const [],
      ),
      editPlan: const ImportCandidateEditPlan(
        items: [],
        warnings: [],
        usedCodes: {},
      ),
      cleaningPlan: IncomingSongCleaningPreviewPlan(
        items: [cleaningItem(fileName: 'A.mp4', fullPath: r'C:\Novas\A.mp4')],
        warnings: const [],
      ),
    );
    expect(plan.items.single.isBlocked, isTrue);
  });

  test('bloqueia com edit invalida', () {
    final selected = selectedItem('1', 'A.mp4');
    final invalidEdit = validEdit(selected).copyWith();
    final plan = ImportOperationDryRunPlanner().buildDryRun(
      outputValidationResult: validOutput(
        mode: ImportOutputMode.copyToOfficialLibrary,
      ),
      selectionPlan: ImportCandidateSelectionPlan(
        items: [selected],
        warnings: const [],
      ),
      editPlan: ImportCandidateEditPlan(
        items: [
          ImportCandidateEditItem(
            id: invalidEdit.id,
            selectionItem: invalidEdit.selectionItem,
            artist: invalidEdit.artist,
            title: invalidEdit.title,
            code: invalidEdit.code,
            officialFileName: invalidEdit.officialFileName,
            editStatus: ImportCandidateEditStatus.invalid,
            editable: invalidEdit.editable,
            warnings: const [],
          ),
        ],
        warnings: const [],
        usedCodes: const {},
      ),
      cleaningPlan: IncomingSongCleaningPreviewPlan(
        items: [cleaningItem(fileName: 'A.mp4', fullPath: r'C:\Novas\A.mp4')],
        warnings: const [],
      ),
    );
    expect(plan.items.single.isBlocked, isTrue);
  });

  test('bloqueia sem cleaning item', () {
    final selected = selectedItem('1', 'A.mp4');
    final plan = ImportOperationDryRunPlanner().buildDryRun(
      outputValidationResult: validOutput(
        mode: ImportOutputMode.copyToOfficialLibrary,
      ),
      selectionPlan: ImportCandidateSelectionPlan(
        items: [selected],
        warnings: const [],
      ),
      editPlan: ImportCandidateEditPlan(
        items: [validEdit(selected)],
        warnings: const [],
        usedCodes: const {},
      ),
      cleaningPlan: const IncomingSongCleaningPreviewPlan(
        items: [],
        warnings: [],
      ),
    );
    expect(plan.items.single.isBlocked, isTrue);
  });

  test('bloqueia source path vazio', () {
    final selected = selectedItem('1', 'A.mp4');
    final plan = ImportOperationDryRunPlanner().buildDryRun(
      outputValidationResult: validOutput(
        mode: ImportOutputMode.copyToOfficialLibrary,
      ),
      selectionPlan: ImportCandidateSelectionPlan(
        items: [selected],
        warnings: const [],
      ),
      editPlan: ImportCandidateEditPlan(
        items: [validEdit(selected)],
        warnings: const [],
        usedCodes: const {},
      ),
      cleaningPlan: IncomingSongCleaningPreviewPlan(
        items: [cleaningItem(fileName: 'A.mp4', fullPath: '')],
        warnings: const [],
      ),
    );
    expect(plan.items.single.isBlocked, isTrue);
  });

  test('bloqueia quando origem e destino sao iguais', () {
    final selected = selectedItem('1', 'A.mp4');
    final plan = ImportOperationDryRunPlanner().buildDryRun(
      outputValidationResult: validOutput(
        mode: ImportOutputMode.renameInIncomingFolder,
      ),
      selectionPlan: ImportCandidateSelectionPlan(
        items: [selected],
        warnings: const [],
      ),
      editPlan: ImportCandidateEditPlan(
        items: [
          ImportCandidateEditItem(
            id: selected.id,
            selectionItem: selected,
            artist: 'Artista',
            title: 'Musica',
            code: '00003',
            officialFileName: 'A.mp4',
            editStatus: ImportCandidateEditStatus.valid,
            editable: true,
            warnings: const [],
          ),
        ],
        warnings: const [],
        usedCodes: const {},
      ),
      cleaningPlan: IncomingSongCleaningPreviewPlan(
        items: [cleaningItem(fileName: 'A.mp4', fullPath: r'C:\Novas\A.mp4')],
        warnings: const [],
      ),
    );
    expect(plan.items.single.isBlocked, isTrue);
  });

  test('detecta destino duplicado no dry-run', () {
    final selected1 = selectedItem('1', 'A.mp4');
    final selected2 = selectedItem('2', 'B.mp4');
    final plan = ImportOperationDryRunPlanner().buildDryRun(
      outputValidationResult: validOutput(
        mode: ImportOutputMode.copyToOfficialLibrary,
      ),
      selectionPlan: ImportCandidateSelectionPlan(
        items: [selected1, selected2],
        warnings: const [],
      ),
      editPlan: ImportCandidateEditPlan(
        items: [
          validEdit(selected1),
          ImportCandidateEditItem(
            id: selected2.id,
            selectionItem: selected2,
            artist: 'Artista',
            title: 'Musica',
            code: '00004',
            officialFileName: 'Artista - Musica - 00003.mp4',
            editStatus: ImportCandidateEditStatus.valid,
            editable: true,
            warnings: const [],
          ),
        ],
        warnings: const [],
        usedCodes: const {},
      ),
      cleaningPlan: IncomingSongCleaningPreviewPlan(
        items: [
          cleaningItem(fileName: 'A.mp4', fullPath: r'C:\Novas\A.mp4'),
          cleaningItem(fileName: 'B.mp4', fullPath: r'C:\Novas\B.mp4'),
        ],
        warnings: const [],
      ),
    );
    expect(plan.items[0].isBlocked, isTrue);
    expect(plan.items[1].isBlocked, isTrue);
    expect(
      plan.warnings,
      contains('Foram detectados destinos duplicados no dry-run.'),
    );
  });

  test('counts funcionam', () {
    final selected1 = selectedItem('1', 'A.mp4');
    final selected2 = selectedItem('2', 'B.mp4');
    final plan = ImportOperationDryRunPlanner().buildDryRun(
      outputValidationResult: validOutput(
        mode: ImportOutputMode.copyToOfficialLibrary,
      ),
      selectionPlan: ImportCandidateSelectionPlan(
        items: [selected1, selected2],
        warnings: const [],
      ),
      editPlan: ImportCandidateEditPlan(
        items: [validEdit(selected1)],
        warnings: const [],
        usedCodes: const {},
      ),
      cleaningPlan: IncomingSongCleaningPreviewPlan(
        items: [cleaningItem(fileName: 'A.mp4', fullPath: r'C:\Novas\A.mp4')],
        warnings: const [],
      ),
    );
    expect(plan.totalCount, 2);
    expect(plan.blockedCount, greaterThanOrEqualTo(1));
    expect(plan.readyCount, greaterThanOrEqualTo(0));
  });

  test('labels dos enums retornam textos esperados', () {
    expect(ImportOperationAction.rename.label, 'Renomear');
    expect(ImportOperationAction.copy.label, 'Copiar');
    expect(ImportOperationAction.move.label, 'Mover');
    expect(ImportOperationDryRunItemStatus.ready.label, 'Pronto');
    expect(ImportOperationDryRunItemStatus.blocked.label, 'Bloqueado');
  });

  test('nao altera selection edit e cleaning plan', () {
    final selected = selectedItem('1', 'A.mp4');
    final selectionPlan = ImportCandidateSelectionPlan(
      items: [selected],
      warnings: const [],
    );
    final editPlan = ImportCandidateEditPlan(
      items: [validEdit(selected)],
      warnings: const [],
      usedCodes: const {},
    );
    final cleaningPlan = IncomingSongCleaningPreviewPlan(
      items: [cleaningItem(fileName: 'A.mp4', fullPath: r'C:\Novas\A.mp4')],
      warnings: const [],
    );

    ImportOperationDryRunPlanner().buildDryRun(
      outputValidationResult: validOutput(
        mode: ImportOutputMode.copyToOfficialLibrary,
      ),
      selectionPlan: selectionPlan,
      editPlan: editPlan,
      cleaningPlan: cleaningPlan,
    );

    expect(selectionPlan.items.length, 1);
    expect(editPlan.items.length, 1);
    expect(cleaningPlan.items.length, 1);
  });
}
