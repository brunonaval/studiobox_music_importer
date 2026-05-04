import 'package:flutter_test/flutter_test.dart';
import 'package:studiobox_music_importer/src/features/base_library/domain/base_library.dart';
import 'package:studiobox_music_importer/src/features/library_repair/domain/library_repair.dart';

void main() {
  BaseLibraryIndexResult buildIndexFromScannedFiles(
    List<BaseLibraryScannedFile> files,
  ) {
    return BaseLibraryIndexer().indexScannedFiles(files);
  }

  BaseLibraryIndexResult buildIndexWithKnownArtists({
    List<BaseLibraryScannedFile> extra = const [],
  }) {
    return buildIndexFromScannedFiles([
      BaseLibraryScannedFile(
        fileName: 'Legião Urbana - Tempo Perdido - 00001.mp4',
        fullPath: r'C:\Lib\Legião Urbana - Tempo Perdido - 00001.mp4',
        relativePath: 'Legião Urbana - Tempo Perdido - 00001.mp4',
      ),
      BaseLibraryScannedFile(
        fileName: 'Capital Inicial - Primeiros Erros - 00002.mp4',
        fullPath: r'C:\Lib\Capital Inicial - Primeiros Erros - 00002.mp4',
        relativePath: 'Capital Inicial - Primeiros Erros - 00002.mp4',
      ),
      BaseLibraryScannedFile(
        fileName: 'Tribalistas - Velha Infância - 00003.mp4',
        fullPath: r'C:\Lib\Tribalistas - Velha Infância - 00003.mp4',
        relativePath: 'Tribalistas - Velha Infância - 00003.mp4',
      ),
      ...extra,
    ]);
  }

  group('InvalidFileRepairPlanner.buildPlan', () {
    final planner = InvalidFileRepairPlanner();

    test('retorna plano vazio quando nao ha invalidFiles', () {
      final baseIndex = buildIndexWithKnownArtists();

      final plan = planner.buildPlan(baseIndex: baseIndex);

      expect(plan.items, isEmpty);
      expect(plan.hasItems, isFalse);
      expect(plan.warnings, isEmpty);
    });

    test('cria item para arquivo invalido com analise usavel', () {
      final baseIndex = buildIndexWithKnownArtists(
        extra: [
          BaseLibraryScannedFile(
            fileName: 'Pais e Filhos - Legião Urbana.mp4',
            fullPath: r'C:\Lib\Pais e Filhos - Legião Urbana.mp4',
            relativePath: 'Pais e Filhos - Legião Urbana.mp4',
          ),
        ],
      );

      final plan = planner.buildPlan(baseIndex: baseIndex);

      expect(plan.items, hasLength(1));
      final item = plan.items.first;
      expect(item.analysis.detectedArtist, 'Legião Urbana');
      expect(item.analysis.detectedTitle, 'Pais e Filhos');
      expect(item.hasSuggestedCode, isTrue);
      expect(
        item.suggestedFileName,
        'Legião Urbana - Pais e Filhos - 00004.mp4',
      );
    });

    test('usa afterHighestExisting por padrao: primeiro codigo apos max', () {
      final baseIndex = buildIndexWithKnownArtists(
        extra: [
          BaseLibraryScannedFile(
            fileName: 'Legião Urbana - Pais e Filhos.mp4',
            fullPath: r'C:\Lib\Legião Urbana - Pais e Filhos.mp4',
            relativePath: 'Legião Urbana - Pais e Filhos.mp4',
          ),
        ],
      );

      final plan = planner.buildPlan(baseIndex: baseIndex);

      expect(plan.items, hasLength(1));
      expect(plan.items.first.suggestedCode, '00004');
    });

    test('usa fillGapsFirst quando informado: usa buraco disponivel', () {
      final baseIndex = buildIndexFromScannedFiles([
        BaseLibraryScannedFile(
          fileName: 'Legião Urbana - Tempo Perdido - 00001.mp4',
          fullPath: r'C:\Lib\Legião Urbana - Tempo Perdido - 00001.mp4',
          relativePath: 'Legião Urbana - Tempo Perdido - 00001.mp4',
        ),
        BaseLibraryScannedFile(
          fileName: 'Capital Inicial - Primeiros Erros - 00003.mp4',
          fullPath: r'C:\Lib\Capital Inicial - Primeiros Erros - 00003.mp4',
          relativePath: 'Capital Inicial - Primeiros Erros - 00003.mp4',
        ),
        BaseLibraryScannedFile(
          fileName: 'Legião Urbana - Pais e Filhos.mp4',
          fullPath: r'C:\Lib\Legião Urbana - Pais e Filhos.mp4',
          relativePath: 'Legião Urbana - Pais e Filhos.mp4',
        ),
      ]);

      final plan = planner.buildPlan(
        baseIndex: baseIndex,
        codeStrategy: SongCodeAllocationStrategy.fillGapsFirst,
      );

      expect(plan.items, hasLength(1));
      expect(plan.items.first.suggestedCode, '00002');
    });

    test('preserva fullPath e relativePath do BaseLibraryInvalidFile', () {
      final baseIndex = buildIndexFromScannedFiles([
        BaseLibraryScannedFile(
          fileName: 'Legião Urbana - Tempo Perdido - 00001.mp4',
          fullPath: r'C:\Lib\Legião Urbana - Tempo Perdido - 00001.mp4',
          relativePath: 'Legião Urbana - Tempo Perdido - 00001.mp4',
        ),
        BaseLibraryScannedFile(
          fileName: 'Pais e Filhos - Legião Urbana.mp4',
          fullPath: r'C:\Lib\Sub\Pais e Filhos - Legião Urbana.mp4',
          relativePath: r'Sub\Pais e Filhos - Legião Urbana.mp4',
        ),
      ]);

      final plan = planner.buildPlan(baseIndex: baseIndex);

      final item = plan.items.first;
      expect(item.fullPath, r'C:\Lib\Sub\Pais e Filhos - Legião Urbana.mp4');
      expect(item.relativePath, r'Sub\Pais e Filhos - Legião Urbana.mp4');
    });

    test('displayPath vem do invalidFile', () {
      final baseIndex = buildIndexFromScannedFiles([
        BaseLibraryScannedFile(
          fileName: 'Legião Urbana - Tempo Perdido - 00001.mp4',
          fullPath: r'C:\Lib\Legião Urbana - Tempo Perdido - 00001.mp4',
          relativePath: 'Legião Urbana - Tempo Perdido - 00001.mp4',
        ),
        BaseLibraryScannedFile(
          fileName: 'ArquivoSemSeparador.mp4',
          fullPath: r'C:\Lib\Sub\ArquivoSemSeparador.mp4',
          relativePath: r'Sub\ArquivoSemSeparador.mp4',
        ),
      ]);

      final plan = planner.buildPlan(baseIndex: baseIndex);

      expect(plan.items.first.displayPath, r'Sub\ArquivoSemSeparador.mp4');
    });

    test('analise failed vira blocked', () {
      final baseIndex = buildIndexWithKnownArtists(
        extra: [
          BaseLibraryScannedFile(
            fileName: 'ArquivoSemSeparador.mp4',
            fullPath: r'C:\Lib\ArquivoSemSeparador.mp4',
            relativePath: 'ArquivoSemSeparador.mp4',
          ),
        ],
      );

      final plan = planner.buildPlan(baseIndex: baseIndex);

      expect(plan.items, hasLength(1));
      final item = plan.items.first;
      expect(item.isBlocked, isTrue);
      expect(item.hasSuggestedCode, isFalse);
      expect(item.hasSuggestedFileName, isFalse);
      expect(
        item.warnings.any(
          (w) => w.contains('Não foi possível detectar artista e música.'),
        ),
        isTrue,
      );
    });

    test('analise com warning vira needsReview', () {
      final baseIndex = buildIndexWithKnownArtists(
        extra: [
          BaseLibraryScannedFile(
            fileName: 'Pais e Filhos - Legião Urbana.mp4',
            fullPath: r'C:\Lib\Pais e Filhos - Legião Urbana.mp4',
            relativePath: 'Pais e Filhos - Legião Urbana.mp4',
          ),
        ],
      );

      final plan = planner.buildPlan(baseIndex: baseIndex);

      final item = plan.items.first;
      expect(item.needsReview, isTrue);
      expect(
        item.warnings.any(
          (w) => w.contains('Ordem Música - Autor detectada e invertida.'),
        ),
        isTrue,
      );
    });

    test('detectedExtra gera needsReview e warning de extra', () {
      final baseIndex = buildIndexWithKnownArtists(
        extra: [
          BaseLibraryScannedFile(
            fileName: 'Tribalistas - Velha Infância - Marisa Monte.mp4',
            fullPath: r'C:\Lib\Tribalistas - Velha Infância - Marisa Monte.mp4',
            relativePath: 'Tribalistas - Velha Infância - Marisa Monte.mp4',
          ),
        ],
      );

      final plan = planner.buildPlan(baseIndex: baseIndex);

      final item = plan.items.first;
      expect(item.needsReview, isTrue);
      expect(item.analysis.hasExtra, isTrue);
      expect(
        item.warnings.any((w) => w.contains('Informação extra detectada')),
        isTrue,
      );
    });

    test('arquivo Autor - Musica conhecido gera readyToSuggest', () {
      final baseIndex = buildIndexWithKnownArtists(
        extra: [
          BaseLibraryScannedFile(
            fileName: 'Legião Urbana - Pais e Filhos.mp4',
            fullPath: r'C:\Lib\Legião Urbana - Pais e Filhos.mp4',
            relativePath: 'Legião Urbana - Pais e Filhos.mp4',
          ),
        ],
      );

      final plan = planner.buildPlan(baseIndex: baseIndex);

      final item = plan.items.first;
      expect(item.isReadyToSuggest, isTrue);
      expect(item.hasSuggestedCode, isTrue);
      expect(item.hasSuggestedFileName, isTrue);
      expect(
        item.suggestedFileName,
        'Legião Urbana - Pais e Filhos - 00004.mp4',
      );
    });

    test('codigo indisponivel gera blocked', () {
      final baseIndex = BaseLibraryIndexResult(
        entries: const [],
        invalidFiles: [
          const BaseLibraryInvalidFile(
            fileName: 'Legião Urbana - Pais e Filhos.mp4',
            reason: 'Fora do padrão',
          ),
        ],
        duplicateCodes: const [],
        usedCodes: const {'99999'},
        availableCodeGaps: const [],
        maxCodeNumber: 99999,
        knownArtists: const {'Legião Urbana'},
      );

      final plan = planner.buildPlan(baseIndex: baseIndex);

      expect(plan.items, hasLength(1));
      final item = plan.items.first;
      expect(item.isBlocked, isTrue);
      expect(item.hasSuggestedCode, isFalse);
      expect(
        item.warnings.any(
          (w) =>
              w.contains('Código novo indisponível para reparar este arquivo.'),
        ),
        isTrue,
      );
    });

    test('warnings do allocator entram no plan', () {
      final baseIndex = BaseLibraryIndexResult(
        entries: const [],
        invalidFiles: [
          const BaseLibraryInvalidFile(
            fileName: 'Legião Urbana - Pais e Filhos.mp4',
            reason: 'Fora do padrão',
          ),
        ],
        duplicateCodes: const [],
        usedCodes: const {'99999'},
        availableCodeGaps: const [],
        maxCodeNumber: 99999,
        knownArtists: const {'Legião Urbana'},
      );

      final plan = planner.buildPlan(baseIndex: baseIndex);

      expect(
        plan.warnings.any(
          (w) =>
              w.contains('Nao ha codigos disponiveis suficientes ate 99999.'),
        ),
        isTrue,
      );
    });

    test('plan counts funcionam corretamente', () {
      final baseIndex = buildIndexWithKnownArtists(
        extra: [
          BaseLibraryScannedFile(
            fileName: 'Legião Urbana - Pais e Filhos.mp4',
            fullPath: r'C:\Lib\Legião Urbana - Pais e Filhos.mp4',
            relativePath: 'Legião Urbana - Pais e Filhos.mp4',
          ),
          BaseLibraryScannedFile(
            fileName: 'Pais e Filhos - Legião Urbana.mp4',
            fullPath: r'C:\Lib\Pais e Filhos - Legião Urbana.mp4',
            relativePath: 'Pais e Filhos - Legião Urbana.mp4',
          ),
          BaseLibraryScannedFile(
            fileName: 'ArquivoSemSeparador.mp4',
            fullPath: r'C:\Lib\ArquivoSemSeparador.mp4',
            relativePath: 'ArquivoSemSeparador.mp4',
          ),
        ],
      );

      final plan = planner.buildPlan(baseIndex: baseIndex);

      expect(plan.totalCount, 3);
      expect(plan.readyToSuggestCount, 1);
      expect(plan.needsReviewCount, 1);
      expect(plan.blockedCount, 1);
      expect(plan.hasItems, isTrue);
      expect(plan.hasBlockedItems, isTrue);
      expect(plan.hasReviewItems, isTrue);
    });

    test('labels do enum retornam textos esperados', () {
      expect(
        InvalidFileRepairItemStatus.readyToSuggest.label,
        'Sugestão pronta',
      );
      expect(
        InvalidFileRepairItemStatus.needsReview.label,
        'Revisão necessária',
      );
      expect(InvalidFileRepairItemStatus.blocked.label, 'Bloqueado');
    });

    test('plano nao altera baseIndex.usedCodes', () {
      final baseIndex = buildIndexWithKnownArtists(
        extra: [
          BaseLibraryScannedFile(
            fileName: 'Legião Urbana - Pais e Filhos.mp4',
            fullPath: r'C:\Lib\Legião Urbana - Pais e Filhos.mp4',
            relativePath: 'Legião Urbana - Pais e Filhos.mp4',
          ),
        ],
      );
      final usedCodesBefore = Set<String>.from(baseIndex.usedCodes);

      planner.buildPlan(baseIndex: baseIndex);

      expect(baseIndex.usedCodes, equals(usedCodesBefore));
    });
  });
}
