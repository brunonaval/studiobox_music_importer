import 'package:flutter_test/flutter_test.dart';
import 'package:studiobox_music_importer/src/features/base_library/domain/base_library_index_entry.dart';
import 'package:studiobox_music_importer/src/features/base_library/domain/base_library_index_result.dart';
import 'package:studiobox_music_importer/src/features/base_library/domain/base_library_indexer.dart';
import 'package:studiobox_music_importer/src/features/base_library/domain/base_library_invalid_file.dart';
import 'package:studiobox_music_importer/src/features/base_library/domain/base_library_duplicate_code.dart';
import 'package:studiobox_music_importer/src/features/base_library/domain/official_song.dart';
import 'package:studiobox_music_importer/src/features/base_library/domain/song_code_allocation_strategy.dart';
import 'package:studiobox_music_importer/src/features/import_planner/domain/import_candidate_status.dart';
import 'package:studiobox_music_importer/src/features/import_planner/domain/import_suggestion_planner.dart';

void main() {
  final planner = ImportSuggestionPlanner();

  BaseLibraryIndexResult buildBaseIndex() {
    final indexer = BaseLibraryIndexer();
    return indexer.indexFileNames([
      'Legiao Urbana - Tempo Perdido - 00001.mp4',
      'Capital Inicial - Primeiros Erros - 00002.mp4',
      'Tribalistas - Velha Infancia - 00003.mp4',
      'A-ha - Take On Me - 00005.mp4',
    ]);
  }

  test('cria candidato com codigo sugerido usando afterHighestExisting', () {
    final baseIndex = buildBaseIndex();

    final plan = planner.buildPlan(
      incomingFileNames: ['Pais e Filhos - Legiao Urbana.mp4'],
      baseIndex: baseIndex,
      codeStrategy: SongCodeAllocationStrategy.afterHighestExisting,
    );

    expect(plan.candidates.first.suggestedCode, '00006');
    expect(
      plan.candidates.first.suggestedOfficialFileName,
      'Legiao Urbana - Pais e Filhos - 00006.mp4',
    );
  });

  test('usa fillGapsFirst quando ha buraco', () {
    final baseIndex = BaseLibraryIndexer().indexFileNames([
      'Legiao Urbana - Tempo Perdido - 00001.mp4',
      'Capital Inicial - Primeiros Erros - 00003.mp4',
    ]);

    final plan = planner.buildPlan(
      incomingFileNames: ['Musica Nova - Legiao Urbana.mp4'],
      baseIndex: baseIndex,
      codeStrategy: SongCodeAllocationStrategy.fillGapsFirst,
    );

    expect(plan.candidates.first.suggestedCode, '00002');
  });

  test('nao gera codigo para analise failed', () {
    final baseIndex = buildBaseIndex();

    final plan = planner.buildPlan(
      incomingFileNames: ['Arquivo Sem Separador.mp4'],
      baseIndex: baseIndex,
      codeStrategy: SongCodeAllocationStrategy.afterHighestExisting,
    );

    expect(plan.candidates.first.status, ImportCandidateStatus.blocked);
    expect(plan.candidates.first.suggestedCode, isNull);
  });

  test('marca needsReview quando parser tem warning de ordem invertida', () {
    final baseIndex = buildBaseIndex();

    final plan = planner.buildPlan(
      incomingFileNames: ['Pais e Filhos - Legiao Urbana.mp4'],
      baseIndex: baseIndex,
      codeStrategy: SongCodeAllocationStrategy.afterHighestExisting,
    );

    expect(plan.candidates.first.status, ImportCandidateStatus.needsReview);
  });

  test('autoApproved quando Autor - Musica e high sem warnings', () {
    final baseIndex = buildBaseIndex();

    final plan = planner.buildPlan(
      incomingFileNames: ['Legiao Urbana - Pais e Filhos.mp4'],
      baseIndex: baseIndex,
      codeStrategy: SongCodeAllocationStrategy.afterHighestExisting,
    );

    expect(plan.candidates.first.status, ImportCandidateStatus.autoApproved);
  });

  test('detecta duplicidade com biblioteca base', () {
    final baseIndex = buildBaseIndex();

    final plan = planner.buildPlan(
      incomingFileNames: ['Tempo Perdido - Legiao Urbana.mp4'],
      baseIndex: baseIndex,
      codeStrategy: SongCodeAllocationStrategy.afterHighestExisting,
    );

    final candidate = plan.candidates.first;
    expect(candidate.hasDuplicate, isTrue);
    expect(
      candidate.warnings,
      contains(
        'Possivel duplicado na biblioteca: Legiao Urbana - Tempo Perdido - 00001.mp4',
      ),
    );
    expect(candidate.warnings, contains('Codigo existente: 00001'));
    expect(candidate.warnings, contains('Codigo sugerido: 00006'));
    expect(candidate.status, ImportCandidateStatus.needsReview);
  });

  test(
    'detecta duplicidade canonica por artista e musica mesmo com & e caixa',
    () {
      final baseIndex = BaseLibraryIndexer().indexFileNames([
        'Guilherme E Benuto E Simone Mendes - Manda Um Oi - 05180.mp4',
        'Outro Artista - Outra Musica - 13330.mp4',
      ]);

      final plan = planner.buildPlan(
        incomingFileNames: [
          'Guilherme & Benuto e Simone Mendes - Manda um Oi.mp4',
        ],
        baseIndex: baseIndex,
        codeStrategy: SongCodeAllocationStrategy.afterHighestExisting,
      );

      final candidate = plan.candidates.first;
      expect(candidate.hasDuplicate, isTrue);
      expect(candidate.status, ImportCandidateStatus.needsReview);
      expect(
        candidate.warnings.any((w) => w.contains('Possivel duplicado')),
        isTrue,
      );
      expect(candidate.warnings.any((w) => w.contains('05180')), isTrue);
      expect(candidate.warnings.any((w) => w.contains('13331')), isTrue);
    },
  );

  test('plano conta autoApproved, needsReview e blocked corretamente', () {
    final baseIndex = buildBaseIndex();

    final plan = planner.buildPlan(
      incomingFileNames: [
        'Legiao Urbana - Pais e Filhos.mp4',
        'Pais e Filhos - Legiao Urbana.mp4',
        'ArquivoSemSeparador.mp4',
      ],
      baseIndex: baseIndex,
      codeStrategy: SongCodeAllocationStrategy.afterHighestExisting,
    );

    expect(plan.totalCount, 3);
    expect(plan.autoApprovedCount, 1);
    expect(plan.needsReviewCount, 1);
    expect(plan.blockedCount, 1);
  });

  test('quando faltam codigos, item usavel sem codigo fica blocked', () {
    const baseIndex = BaseLibraryIndexResult(
      entries: [
        BaseLibraryIndexEntry(
          song: OfficialSong(
            artist: 'Legiao Urbana',
            title: 'Tempo Perdido',
            code: '99999',
            fileName: 'Legiao Urbana - Tempo Perdido - 99999.mp4',
          ),
          originalFileName: 'Legiao Urbana - Tempo Perdido - 99999.mp4',
        ),
      ],
      invalidFiles: <BaseLibraryInvalidFile>[],
      duplicateCodes: <BaseLibraryDuplicateCode>[],
      usedCodes: {'99999'},
      availableCodeGaps: <String>[],
      maxCodeNumber: 99999,
      knownArtists: {'Legiao Urbana'},
    );

    final plan = planner.buildPlan(
      incomingFileNames: ['Legiao Urbana - Musica Nova.mp4'],
      baseIndex: baseIndex,
      codeStrategy: SongCodeAllocationStrategy.afterHighestExisting,
    );

    final candidate = plan.candidates.first;
    expect(candidate.status, ImportCandidateStatus.blocked);
    expect(
      candidate.warnings,
      contains('Codigo nao disponivel para este item.'),
    );
    expect(plan.hasWarnings, isTrue);
  });

  test('warnings do allocator aparecem no plan.warnings', () {
    const baseIndex = BaseLibraryIndexResult(
      entries: [
        BaseLibraryIndexEntry(
          song: OfficialSong(
            artist: 'Legiao Urbana',
            title: 'Tempo Perdido',
            code: '99999',
            fileName: 'Legiao Urbana - Tempo Perdido - 99999.mp4',
          ),
          originalFileName: 'Legiao Urbana - Tempo Perdido - 99999.mp4',
        ),
      ],
      invalidFiles: <BaseLibraryInvalidFile>[],
      duplicateCodes: <BaseLibraryDuplicateCode>[],
      usedCodes: {'99999'},
      availableCodeGaps: <String>[],
      maxCodeNumber: 99999,
      knownArtists: {'Legiao Urbana'},
    );

    final plan = planner.buildPlan(
      incomingFileNames: ['Legiao Urbana - Musica Nova.mp4'],
      baseIndex: baseIndex,
      codeStrategy: SongCodeAllocationStrategy.afterHighestExisting,
    );

    expect(
      plan.warnings,
      contains('Nao ha codigos disponiveis suficientes ate 99999.'),
    );
  });

  test('extra detectado nao entra no suggestedOfficialFileName', () {
    final baseIndex = buildBaseIndex();

    final plan = planner.buildPlan(
      incomingFileNames: ['Tribalistas - Velha Infancia - Marisa Monte.mp4'],
      baseIndex: baseIndex,
      codeStrategy: SongCodeAllocationStrategy.afterHighestExisting,
    );

    final candidate = plan.candidates.first;
    expect(
      candidate.suggestedOfficialFileName,
      'Tribalistas - Velha Infancia - 00006.mp4',
    );
    expect(
      candidate.warnings,
      contains('Informação extra detectada; revise se deve entrar no título.'),
    );
  });

  test('mantem ordem dos candidatos igual a entrada', () {
    final baseIndex = buildBaseIndex();
    final input = [
      'Legiao Urbana - Pais e Filhos.mp4',
      'Pais e Filhos - Legiao Urbana.mp4',
      'ArquivoSemSeparador.mp4',
    ];

    final plan = planner.buildPlan(
      incomingFileNames: input,
      baseIndex: baseIndex,
      codeStrategy: SongCodeAllocationStrategy.afterHighestExisting,
    );

    expect(plan.candidates[0].originalFileName, input[0]);
    expect(plan.candidates[1].originalFileName, input[1]);
    expect(plan.candidates[2].originalFileName, input[2]);
  });

  test('nao altera baseIndex.usedCodes', () {
    final baseIndex = buildBaseIndex();
    final before = Set<String>.from(baseIndex.usedCodes);

    planner.buildPlan(
      incomingFileNames: ['Legiao Urbana - Pais e Filhos.mp4'],
      baseIndex: baseIndex,
      codeStrategy: SongCodeAllocationStrategy.afterHighestExisting,
    );

    expect(baseIndex.usedCodes, before);
  });
}
