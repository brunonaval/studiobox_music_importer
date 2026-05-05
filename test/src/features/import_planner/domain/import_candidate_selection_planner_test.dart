import 'package:flutter_test/flutter_test.dart';
import 'package:studiobox_music_importer/src/features/import_planner/domain/import_planner.dart';
import 'package:studiobox_music_importer/src/features/incoming_songs/domain/incoming_song_name_analysis.dart';
import 'package:studiobox_music_importer/src/features/incoming_songs/domain/incoming_song_parse_confidence.dart';

void main() {
  ImportSuggestionCandidate candidate({
    required String name,
    required ImportCandidateStatus status,
    String? code,
    String? officialName,
    ImportDuplicateMatch? duplicate,
    List<String> warnings = const [],
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
      duplicateMatch: duplicate,
      warnings: warnings,
    );
  }

  test('autoApproved sem duplicado fica selected por padrao', () {
    final plan = ImportCandidateSelectionPlanner().buildInitialPlan(
      ImportSuggestionPlan(
        candidates: [
          candidate(
            name: 'A - B.mp4',
            status: ImportCandidateStatus.autoApproved,
            code: '00001',
            officialName: 'A - B - 00001.mp4',
          ),
        ],
        warnings: const [],
      ),
    );

    expect(plan.items.single.isSelected, isTrue);
  });

  test('needsReview fica notSelected por padrao e selectable', () {
    final plan = ImportCandidateSelectionPlanner().buildInitialPlan(
      ImportSuggestionPlan(
        candidates: [
          candidate(
            name: 'A - B.mp4',
            status: ImportCandidateStatus.needsReview,
          ),
        ],
        warnings: const [],
      ),
    );

    final item = plan.items.single;
    expect(item.isNotSelected, isTrue);
    expect(item.selectable, isTrue);
  });

  test('blocked fica blocked e nao selectable', () {
    final plan = ImportCandidateSelectionPlanner().buildInitialPlan(
      ImportSuggestionPlan(
        candidates: [
          candidate(name: 'A.mp4', status: ImportCandidateStatus.blocked),
        ],
        warnings: const [],
      ),
    );

    final item = plan.items.single;
    expect(item.isBlocked, isTrue);
    expect(item.selectable, isFalse);
  });

  test('autoApproved com duplicate fica notSelected com warning', () {
    final plan = ImportCandidateSelectionPlanner().buildInitialPlan(
      ImportSuggestionPlan(
        candidates: [
          candidate(
            name: 'A - B.mp4',
            status: ImportCandidateStatus.autoApproved,
            duplicate: const ImportDuplicateMatch(
              existingCode: '00007',
              existingArtist: 'A',
              existingTitle: 'B',
            ),
          ),
        ],
        warnings: const [],
      ),
    );

    final item = plan.items.single;
    expect(item.isNotSelected, isTrue);
    expect(item.selectable, isTrue);
    expect(
      item.warnings,
      contains('Possivel duplicado; revise antes de selecionar.'),
    );
  });

  test('contadores selected notSelected blocked selectable funcionam', () {
    final plan = ImportCandidateSelectionPlanner().buildInitialPlan(
      ImportSuggestionPlan(
        candidates: [
          candidate(
            name: 'ready.mp4',
            status: ImportCandidateStatus.autoApproved,
            code: '00001',
            officialName: 'A - B - 00001.mp4',
          ),
          candidate(
            name: 'review.mp4',
            status: ImportCandidateStatus.needsReview,
          ),
          candidate(name: 'blocked.mp4', status: ImportCandidateStatus.blocked),
        ],
        warnings: const [],
      ),
    );

    expect(plan.selectedCount, 1);
    expect(plan.notSelectedCount, 1);
    expect(plan.blockedCount, 1);
    expect(plan.selectableCount, 2);
  });

  test('withCandidateSelection seleciona item selectable', () {
    final initial = ImportCandidateSelectionPlanner().buildInitialPlan(
      ImportSuggestionPlan(
        candidates: [
          candidate(
            name: 'review.mp4',
            status: ImportCandidateStatus.needsReview,
          ),
        ],
        warnings: const [],
      ),
    );

    final updated = initial.withCandidateSelection(
      initial.items.single.id,
      true,
    );
    expect(updated.items.single.isSelected, isTrue);
  });

  test('withCandidateSelection desmarca item selectable', () {
    final initial = ImportCandidateSelectionPlanner().buildInitialPlan(
      ImportSuggestionPlan(
        candidates: [
          candidate(
            name: 'ready.mp4',
            status: ImportCandidateStatus.autoApproved,
            code: '00001',
            officialName: 'A - B - 00001.mp4',
          ),
        ],
        warnings: const [],
      ),
    );

    final updated = initial.withCandidateSelection(
      initial.items.single.id,
      false,
    );
    expect(updated.items.single.isNotSelected, isTrue);
  });

  test('withCandidateSelection nao altera item blocked', () {
    final initial = ImportCandidateSelectionPlanner().buildInitialPlan(
      ImportSuggestionPlan(
        candidates: [
          candidate(name: 'blocked.mp4', status: ImportCandidateStatus.blocked),
        ],
        warnings: const [],
      ),
    );

    final updated = initial.withCandidateSelection(
      initial.items.single.id,
      true,
    );
    expect(identical(updated, initial), isTrue);
  });

  test('selectAllReady seleciona apenas autoApproved sem duplicate', () {
    final initial = ImportCandidateSelectionPlanner()
        .buildInitialPlan(
          ImportSuggestionPlan(
            candidates: [
              candidate(
                name: 'ready.mp4',
                status: ImportCandidateStatus.autoApproved,
                code: '00001',
                officialName: 'A - B - 00001.mp4',
              ),
              candidate(
                name: 'review.mp4',
                status: ImportCandidateStatus.needsReview,
              ),
              candidate(
                name: 'dup.mp4',
                status: ImportCandidateStatus.autoApproved,
                duplicate: const ImportDuplicateMatch(
                  existingCode: '00010',
                  existingArtist: 'X',
                  existingTitle: 'Y',
                ),
              ),
            ],
            warnings: const [],
          ),
        )
        .clearSelection();

    final updated = initial.selectAllReady();

    expect(updated.items[0].isSelected, isTrue);
    expect(updated.items[1].isNotSelected, isTrue);
    expect(updated.items[2].isNotSelected, isTrue);
  });

  test('clearSelection remove selecao de todos selectable', () {
    final initial = ImportCandidateSelectionPlanner().buildInitialPlan(
      ImportSuggestionPlan(
        candidates: [
          candidate(
            name: 'ready.mp4',
            status: ImportCandidateStatus.autoApproved,
            code: '00001',
            officialName: 'A - B - 00001.mp4',
          ),
          candidate(name: 'blocked.mp4', status: ImportCandidateStatus.blocked),
        ],
        warnings: const [],
      ),
    );

    final updated = initial.clearSelection();
    expect(updated.items[0].isNotSelected, isTrue);
    expect(updated.items[1].isBlocked, isTrue);
  });

  test('warnings do plano indicam blocked review e duplicados', () {
    final plan = ImportCandidateSelectionPlanner().buildInitialPlan(
      ImportSuggestionPlan(
        candidates: [
          candidate(
            name: 'review.mp4',
            status: ImportCandidateStatus.needsReview,
          ),
          candidate(name: 'blocked.mp4', status: ImportCandidateStatus.blocked),
          candidate(
            name: 'dup.mp4',
            status: ImportCandidateStatus.needsReview,
            duplicate: const ImportDuplicateMatch(
              existingCode: '00003',
              existingArtist: 'A',
              existingTitle: 'B',
            ),
          ),
        ],
        warnings: const [],
      ),
    );

    expect(plan.warnings, contains('Existem candidatos bloqueados.'));
    expect(plan.warnings, contains('Existem candidatos aguardando revisao.'));
    expect(plan.warnings, contains('Existem possiveis duplicados.'));
  });

  test('labels do enum retornam textos esperados', () {
    expect(ImportCandidateSelectionStatus.selected.label, 'Selecionado');
    expect(ImportCandidateSelectionStatus.notSelected.label, 'Nao selecionado');
    expect(ImportCandidateSelectionStatus.blocked.label, 'Bloqueado');
  });

  test('planner nao altera suggestionPlan', () {
    final suggestionPlan = ImportSuggestionPlan(
      candidates: [
        candidate(
          name: 'ready.mp4',
          status: ImportCandidateStatus.autoApproved,
          code: '00001',
          officialName: 'A - B - 00001.mp4',
        ),
      ],
      warnings: const [],
    );

    final beforeStatus = suggestionPlan.candidates.first.status;

    ImportCandidateSelectionPlanner().buildInitialPlan(suggestionPlan);

    expect(suggestionPlan.candidates.first.status, beforeStatus);
    expect(suggestionPlan.candidates.length, 1);
  });
}
