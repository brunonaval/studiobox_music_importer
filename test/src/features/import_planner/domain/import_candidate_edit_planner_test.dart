import 'package:flutter_test/flutter_test.dart';
import 'package:studiobox_music_importer/src/features/base_library/domain/base_library.dart';
import 'package:studiobox_music_importer/src/features/import_planner/domain/import_planner.dart';
import 'package:studiobox_music_importer/src/features/incoming_songs/domain/incoming_song_name_analysis.dart';
import 'package:studiobox_music_importer/src/features/incoming_songs/domain/incoming_song_parse_confidence.dart';

void main() {
  BaseLibraryIndexResult baseIndex({Set<String> usedCodes = const {}}) {
    return BaseLibraryIndexResult(
      entries: const [],
      invalidFiles: const [],
      duplicateCodes: const [],
      usedCodes: usedCodes,
      availableCodeGaps: const [],
      maxCodeNumber: null,
      knownArtists: const {},
    );
  }

  ImportSuggestionCandidate candidate({
    required String fileName,
    required ImportCandidateStatus status,
    String artist = 'Artista',
    String title = 'Musica',
    String? code = '00004',
    String? officialFileName = 'Artista - Musica - 00004.mp4',
  }) {
    return ImportSuggestionCandidate(
      originalFileName: fileName,
      analysis: IncomingSongNameAnalysis(
        originalFileName: fileName,
        cleanedName: fileName,
        detectedArtist: artist,
        detectedTitle: title,
        detectedExtra: null,
        confidence: IncomingSongParseConfidence.high,
        warnings: const [],
      ),
      suggestedCode: code,
      suggestedOfficialFileName: officialFileName,
      status: status,
      duplicateMatch: null,
      warnings: const [],
    );
  }

  ImportCandidateSelectionPlan selectionPlanFrom(
    List<ImportSuggestionCandidate> candidates,
  ) {
    final suggestionPlan = ImportSuggestionPlan(
      candidates: candidates,
      warnings: const [],
    );
    return ImportCandidateSelectionPlanner().buildInitialPlan(suggestionPlan);
  }

  test('buildInitialPlan cria item editavel para candidato selecionavel', () {
    final plan = ImportCandidateEditPlanner().buildInitialPlan(
      baseIndex: baseIndex(),
      selectionPlan: selectionPlanFrom([
        candidate(
          fileName: 'A.mp4',
          status: ImportCandidateStatus.autoApproved,
        ),
      ]),
    );

    expect(plan.items.single.editable, isTrue);
  });

  test('usa artista titulo e codigo sugeridos como valores iniciais', () {
    final plan = ImportCandidateEditPlanner().buildInitialPlan(
      baseIndex: baseIndex(),
      selectionPlan: selectionPlanFrom([
        candidate(
          fileName: 'A.mp4',
          status: ImportCandidateStatus.autoApproved,
          artist: 'Legiao Urbana',
          title: 'Pais e Filhos',
          code: '00004',
        ),
      ]),
    );

    final item = plan.items.single;
    expect(item.artist, 'Legiao Urbana');
    expect(item.title, 'Pais e Filhos');
    expect(item.code, '00004');
  });

  test('monta officialFileName no padrao esperado', () {
    final plan = ImportCandidateEditPlanner().buildInitialPlan(
      baseIndex: baseIndex(),
      selectionPlan: selectionPlanFrom([
        candidate(
          fileName: 'A.mp4',
          status: ImportCandidateStatus.autoApproved,
          artist: 'Artista',
          title: 'Musica',
          code: '00004',
        ),
      ]),
    );

    expect(plan.items.single.officialFileName, 'Artista - Musica - 00004.mp4');
  });

  test('candidato blocked vira blocked e editable false', () {
    final plan = ImportCandidateEditPlanner().buildInitialPlan(
      baseIndex: baseIndex(),
      selectionPlan: selectionPlanFrom([
        candidate(fileName: 'A.mp4', status: ImportCandidateStatus.blocked),
      ]),
    );

    final item = plan.items.single;
    expect(item.editable, isFalse);
    expect(item.editStatus, ImportCandidateEditStatus.blocked);
  });

  test('artist vazio gera invalid', () {
    final initial = ImportCandidateEditPlanner().buildInitialPlan(
      baseIndex: baseIndex(),
      selectionPlan: selectionPlanFrom([
        candidate(
          fileName: 'A.mp4',
          status: ImportCandidateStatus.autoApproved,
        ),
      ]),
    );
    final updated = initial.withManualEdit(
      id: initial.items.single.id,
      artist: ' ',
    );
    expect(updated.items.single.isInvalid, isTrue);
  });

  test('title vazio gera invalid', () {
    final initial = ImportCandidateEditPlanner().buildInitialPlan(
      baseIndex: baseIndex(),
      selectionPlan: selectionPlanFrom([
        candidate(
          fileName: 'A.mp4',
          status: ImportCandidateStatus.autoApproved,
        ),
      ]),
    );
    final updated = initial.withManualEdit(
      id: initial.items.single.id,
      title: '',
    );
    expect(updated.items.single.isInvalid, isTrue);
  });

  test('code com menos de 5 digitos gera invalid', () {
    final initial = ImportCandidateEditPlanner().buildInitialPlan(
      baseIndex: baseIndex(),
      selectionPlan: selectionPlanFrom([
        candidate(
          fileName: 'A.mp4',
          status: ImportCandidateStatus.autoApproved,
        ),
      ]),
    );
    final updated = initial.withManualEdit(
      id: initial.items.single.id,
      code: '1234',
    );
    expect(updated.items.single.isInvalid, isTrue);
  });

  test('code com letra gera invalid', () {
    final initial = ImportCandidateEditPlanner().buildInitialPlan(
      baseIndex: baseIndex(),
      selectionPlan: selectionPlanFrom([
        candidate(
          fileName: 'A.mp4',
          status: ImportCandidateStatus.autoApproved,
        ),
      ]),
    );
    final updated = initial.withManualEdit(
      id: initial.items.single.id,
      code: '12A45',
    );
    expect(updated.items.single.isInvalid, isTrue);
  });

  test('code 00000 gera invalid', () {
    final initial = ImportCandidateEditPlanner().buildInitialPlan(
      baseIndex: baseIndex(),
      selectionPlan: selectionPlanFrom([
        candidate(
          fileName: 'A.mp4',
          status: ImportCandidateStatus.autoApproved,
        ),
      ]),
    );
    final updated = initial.withManualEdit(
      id: initial.items.single.id,
      code: '00000',
    );
    expect(updated.items.single.isInvalid, isTrue);
  });

  test('code ja usado em usedCodes gera invalid', () {
    final plan = ImportCandidateEditPlanner().buildInitialPlan(
      baseIndex: baseIndex(usedCodes: const {'00004'}),
      selectionPlan: selectionPlanFrom([
        candidate(
          fileName: 'A.mp4',
          status: ImportCandidateStatus.autoApproved,
        ),
      ]),
    );
    expect(plan.items.single.isInvalid, isTrue);
  });

  test('codes duplicados entre editaveis geram invalid', () {
    final initial = ImportCandidateEditPlanner().buildInitialPlan(
      baseIndex: baseIndex(),
      selectionPlan: selectionPlanFrom([
        candidate(
          fileName: 'A.mp4',
          status: ImportCandidateStatus.autoApproved,
          code: '00004',
        ),
        candidate(
          fileName: 'B.mp4',
          status: ImportCandidateStatus.autoApproved,
          code: '00005',
        ),
      ]),
    );
    final updated = initial.withManualEdit(
      id: initial.items[1].id,
      code: '00004',
    );

    expect(updated.items[0].isInvalid, isTrue);
    expect(updated.items[1].isInvalid, isTrue);
  });

  test('withManualEdit altera campos e recalcula officialFileName', () {
    final initial = ImportCandidateEditPlanner().buildInitialPlan(
      baseIndex: baseIndex(),
      selectionPlan: selectionPlanFrom([
        candidate(
          fileName: 'A.mp4',
          status: ImportCandidateStatus.autoApproved,
        ),
      ]),
    );
    final updated = initial.withManualEdit(
      id: initial.items.single.id,
      artist: 'Novo Artista',
      title: 'Nova Musica',
      code: '00009',
    );

    final item = updated.items.single;
    expect(item.isValid, isTrue);
    expect(item.officialFileName, 'Novo Artista - Nova Musica - 00009.mp4');
  });

  test('withManualEdit nao altera item blocked', () {
    final initial = ImportCandidateEditPlanner().buildInitialPlan(
      baseIndex: baseIndex(),
      selectionPlan: selectionPlanFrom([
        candidate(fileName: 'A.mp4', status: ImportCandidateStatus.blocked),
      ]),
    );
    final updated = initial.withManualEdit(
      id: initial.items.single.id,
      artist: 'Novo Artista',
    );
    expect(identical(updated, initial), isTrue);
  });

  test('resetCandidate restaura valores sugeridos', () {
    final initial = ImportCandidateEditPlanner().buildInitialPlan(
      baseIndex: baseIndex(),
      selectionPlan: selectionPlanFrom([
        candidate(
          fileName: 'A.mp4',
          status: ImportCandidateStatus.autoApproved,
          artist: 'Artista',
          title: 'Musica',
          code: '00004',
        ),
      ]),
    );
    final edited = initial.withManualEdit(
      id: initial.items.single.id,
      artist: 'Outro',
      title: 'Outro',
      code: '00008',
    );
    final reset = edited.resetCandidate(initial.items.single.id);
    final item = reset.items.single;
    expect(item.artist, 'Artista');
    expect(item.title, 'Musica');
    expect(item.code, '00004');
  });

  test('counts funcionam', () {
    final plan = ImportCandidateEditPlanner().buildInitialPlan(
      baseIndex: baseIndex(usedCodes: const {'00004'}),
      selectionPlan: selectionPlanFrom([
        candidate(
          fileName: 'A.mp4',
          status: ImportCandidateStatus.autoApproved,
        ),
        candidate(
          fileName: 'B.mp4',
          status: ImportCandidateStatus.needsReview,
          code: '00005',
        ),
        candidate(fileName: 'C.mp4', status: ImportCandidateStatus.blocked),
      ]),
    );

    expect(plan.totalCount, 3);
    expect(plan.editableCount, 2);
    expect(plan.blockedCount, 1);
    expect(plan.invalidCount, greaterThanOrEqualTo(1));
  });

  test('labels do enum retornam textos esperados', () {
    expect(ImportCandidateEditStatus.valid.label, 'Valido');
    expect(ImportCandidateEditStatus.invalid.label, 'Invalido');
    expect(ImportCandidateEditStatus.blocked.label, 'Bloqueado');
  });

  test('planner nao altera baseIndex nem selectionPlan', () {
    final index = baseIndex(usedCodes: const {'00001'});
    final selectionPlan = selectionPlanFrom([
      candidate(fileName: 'A.mp4', status: ImportCandidateStatus.autoApproved),
    ]);

    ImportCandidateEditPlanner().buildInitialPlan(
      baseIndex: index,
      selectionPlan: selectionPlan,
    );

    expect(index.usedCodes, contains('00001'));
    expect(selectionPlan.items.length, 1);
  });
}
