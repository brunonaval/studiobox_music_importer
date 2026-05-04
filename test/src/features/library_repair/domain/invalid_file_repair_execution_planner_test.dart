import 'package:flutter_test/flutter_test.dart';
import 'package:studiobox_music_importer/src/features/base_library/domain/base_library.dart';
import 'package:studiobox_music_importer/src/features/incoming_songs/domain/incoming_song_name_analysis.dart';
import 'package:studiobox_music_importer/src/features/incoming_songs/domain/incoming_song_parse_confidence.dart';
import 'package:studiobox_music_importer/src/features/library_repair/domain/library_repair.dart';

void main() {
  InvalidFileRepairItem buildItem({
    required InvalidFileRepairItemStatus status,
    String? fullPath,
    String? suggestedFileName,
    String? suggestedCode,
    String displayPath = 'Arquivo.mp4',
    String originalFileName = 'Arquivo.mp4',
    List<String> warnings = const [],
    String? detectedArtist = 'Artista A',
    String? detectedTitle = 'Musica A',
  }) {
    return InvalidFileRepairItem(
      originalFileName: originalFileName,
      originalReason: 'Fora do padrão',
      displayPath: displayPath,
      fullPath: fullPath,
      relativePath: null,
      analysis: IncomingSongNameAnalysis(
        originalFileName: originalFileName,
        cleanedName: originalFileName,
        detectedArtist: detectedArtist,
        detectedTitle: detectedTitle,
        detectedExtra: null,
        confidence: IncomingSongParseConfidence.high,
        warnings: const [],
      ),
      suggestedCode: suggestedCode ?? '00002',
      suggestedFileName: suggestedFileName,
      status: status,
      warnings: warnings,
    );
  }

  BaseLibraryIndexResult buildIndexFromScannedFiles(
    List<BaseLibraryScannedFile> files,
  ) {
    return BaseLibraryIndexer().indexScannedFiles(files);
  }

  group('InvalidFileRepairExecutionPlanner.buildDryRun', () {
    final planner = InvalidFileRepairExecutionPlanner();

    test(
      'readyToSuggest com fullPath e suggestedFileName vira readyToRename',
      () {
        final repairPlan = InvalidFileRepairPlan(
          items: [
            buildItem(
              status: InvalidFileRepairItemStatus.readyToSuggest,
              fullPath: r'C:\Musicas\Legião Urbana - Pais e Filhos.mp4',
              suggestedFileName: 'Legião Urbana - Pais e Filhos - 00002.mp4',
            ),
          ],
          warnings: const [],
        );

        final execution = planner.buildDryRun(repairPlan);

        expect(execution.items.first.isReadyToRename, isTrue);
      },
    );

    test('readyToRename monta sourcePathPreview com fullPath', () {
      final repairPlan = InvalidFileRepairPlan(
        items: [
          buildItem(
            status: InvalidFileRepairItemStatus.readyToSuggest,
            fullPath: r'C:\Musicas\Legião Urbana - Pais e Filhos.mp4',
            suggestedFileName: 'Legião Urbana - Pais e Filhos - 00002.mp4',
          ),
        ],
        warnings: const [],
      );

      final execution = planner.buildDryRun(repairPlan);

      expect(
        execution.items.first.sourcePathPreview,
        r'C:\Musicas\Legião Urbana - Pais e Filhos.mp4',
      );
    });

    test('readyToRename monta destinationPathPreview com barra invertida', () {
      final repairPlan = InvalidFileRepairPlan(
        items: [
          buildItem(
            status: InvalidFileRepairItemStatus.readyToSuggest,
            fullPath: r'C:\Musicas\Legião Urbana - Pais e Filhos.mp4',
            suggestedFileName: 'Legião Urbana - Pais e Filhos - 00004.mp4',
          ),
        ],
        warnings: const [],
      );

      final execution = planner.buildDryRun(repairPlan);

      expect(
        execution.items.first.destinationPathPreview,
        r'C:\Musicas\Legião Urbana - Pais e Filhos - 00004.mp4',
      );
    });

    test('readyToRename monta destinationPathPreview com barra normal', () {
      final repairPlan = InvalidFileRepairPlan(
        items: [
          buildItem(
            status: InvalidFileRepairItemStatus.readyToSuggest,
            fullPath: 'C:/Musicas/Legião Urbana - Pais e Filhos.mp4',
            suggestedFileName: 'Legião Urbana - Pais e Filhos - 00004.mp4',
          ),
        ],
        warnings: const [],
      );

      final execution = planner.buildDryRun(repairPlan);

      expect(
        execution.items.first.destinationPathPreview,
        'C:/Musicas/Legião Urbana - Pais e Filhos - 00004.mp4',
      );
    });

    test('readyToSuggest sem fullPath fica blocked', () {
      final repairPlan = InvalidFileRepairPlan(
        items: [
          buildItem(
            status: InvalidFileRepairItemStatus.readyToSuggest,
            fullPath: null,
            suggestedFileName: 'Artista A - Musica A - 00002.mp4',
          ),
        ],
        warnings: const [],
      );

      final execution = planner.buildDryRun(repairPlan);

      expect(execution.items.first.isBlocked, isTrue);
      expect(
        execution.items.first.warnings.any(
          (w) =>
              w.contains('Caminho completo indisponível para renomeio seguro.'),
        ),
        isTrue,
      );
    });

    test('readyToSuggest sem suggestedFileName fica blocked', () {
      final repairPlan = InvalidFileRepairPlan(
        items: [
          buildItem(
            status: InvalidFileRepairItemStatus.readyToSuggest,
            fullPath: r'C:\Musicas\Artista A - Musica A.mp4',
            suggestedFileName: null,
          ),
        ],
        warnings: const [],
      );

      final execution = planner.buildDryRun(repairPlan);

      expect(execution.items.first.isBlocked, isTrue);
      expect(
        execution.items.first.warnings.any(
          (w) => w.contains('Nome sugerido indisponível.'),
        ),
        isTrue,
      );
    });

    test('needsReview vira skippedNeedsReview', () {
      final repairPlan = InvalidFileRepairPlan(
        items: [
          buildItem(
            status: InvalidFileRepairItemStatus.needsReview,
            fullPath: r'C:\Musicas\Pais e Filhos - Legião Urbana.mp4',
            suggestedFileName: 'Legião Urbana - Pais e Filhos - 00002.mp4',
          ),
        ],
        warnings: const [],
      );

      final execution = planner.buildDryRun(repairPlan);

      expect(execution.items.first.isSkipped, isTrue);
    });

    test(
      'needsReview preserva warnings e adiciona aviso de revisao manual',
      () {
        final repairPlan = InvalidFileRepairPlan(
          items: [
            buildItem(
              status: InvalidFileRepairItemStatus.needsReview,
              fullPath: r'C:\Musicas\Pais e Filhos - Legião Urbana.mp4',
              suggestedFileName: 'Legião Urbana - Pais e Filhos - 00002.mp4',
              warnings: const ['Ordem Música - Autor detectada e invertida.'],
            ),
          ],
          warnings: const [],
        );

        final execution = planner.buildDryRun(repairPlan);

        final item = execution.items.first;
        expect(
          item.warnings.any(
            (w) => w.contains('Ordem Música - Autor detectada e invertida.'),
          ),
          isTrue,
        );
        expect(
          item.warnings.any(
            (w) =>
                w.contains('Item precisa de revisão manual antes do renomeio.'),
          ),
          isTrue,
        );
      },
    );

    test('blocked do repairPlan continua blocked', () {
      final repairPlan = InvalidFileRepairPlan(
        items: [
          buildItem(
            status: InvalidFileRepairItemStatus.blocked,
            fullPath: null,
            suggestedFileName: null,
            warnings: const ['Não foi possível detectar artista e música.'],
          ),
        ],
        warnings: const [],
      );

      final execution = planner.buildDryRun(repairPlan);

      expect(execution.items.first.isBlocked, isTrue);
    });

    test('colisao de destinationPathPreview bloqueia itens envolvidos', () {
      final sharedDestination = r'C:\Musicas\Artista A - Musica A - 00002.mp4';
      final repairPlan = InvalidFileRepairPlan(
        items: [
          buildItem(
            status: InvalidFileRepairItemStatus.readyToSuggest,
            fullPath: r'C:\Musicas\Artista A - Musica A.mp4',
            suggestedFileName: 'Artista A - Musica A - 00002.mp4',
            originalFileName: 'Artista A - Musica A.mp4',
            displayPath: 'Artista A - Musica A.mp4',
          ),
          buildItem(
            status: InvalidFileRepairItemStatus.readyToSuggest,
            fullPath: r'C:\Musicas\Musica A - Artista A.mp4',
            suggestedFileName: 'Artista A - Musica A - 00002.mp4',
            originalFileName: 'Musica A - Artista A.mp4',
            displayPath: 'Musica A - Artista A.mp4',
          ),
        ],
        warnings: const [],
      );

      final execution = planner.buildDryRun(repairPlan);

      expect(execution.items.every((item) => item.isBlocked), isTrue);
      expect(
        execution.items.every(
          (item) => item.warnings.any(
            (w) => w.contains('Destino duplicado dentro do plano de execução.'),
          ),
        ),
        isTrue,
      );

      expect(
        execution.warnings.any(
          (w) => w.contains('Foram detectados destinos duplicados no dry-run.'),
        ),
        isTrue,
      );

      // silence unused variable warning
      expect(sharedDestination.isNotEmpty, isTrue);
    });

    test('source igual a destination bloqueia item', () {
      final path = r'C:\Musicas\Artista A - Musica A - 00002.mp4';
      final repairPlan = InvalidFileRepairPlan(
        items: [
          buildItem(
            status: InvalidFileRepairItemStatus.readyToSuggest,
            fullPath: path,
            suggestedFileName: 'Artista A - Musica A - 00002.mp4',
          ),
        ],
        warnings: const [],
      );

      final execution = planner.buildDryRun(repairPlan);

      expect(execution.items.first.isBlocked, isTrue);
      expect(
        execution.items.first.warnings.any(
          (w) => w.contains('Origem e destino são iguais.'),
        ),
        isTrue,
      );
    });

    test('warnings do repairPlan entram no executionPlan.warnings', () {
      final repairPlan = InvalidFileRepairPlan(
        items: [],
        warnings: const ['Aviso do plano anterior.'],
      );

      final execution = planner.buildDryRun(repairPlan);

      expect(
        execution.warnings.any((w) => w.contains('Aviso do plano anterior.')),
        isTrue,
      );
    });

    test('executionPlan counts funcionam corretamente', () {
      final baseIndex = buildIndexFromScannedFiles([
        BaseLibraryScannedFile(
          fileName: 'Legião Urbana - Tempo Perdido - 00001.mp4',
          fullPath: r'C:\Musicas\Legião Urbana - Tempo Perdido - 00001.mp4',
          relativePath: 'Legião Urbana - Tempo Perdido - 00001.mp4',
        ),
        BaseLibraryScannedFile(
          fileName: 'Capital Inicial - Primeiros Erros - 00002.mp4',
          fullPath: r'C:\Musicas\Capital Inicial - Primeiros Erros - 00002.mp4',
          relativePath: 'Capital Inicial - Primeiros Erros - 00002.mp4',
        ),
        BaseLibraryScannedFile(
          fileName: 'Legião Urbana - Pais e Filhos.mp4',
          fullPath: r'C:\Musicas\Legião Urbana - Pais e Filhos.mp4',
          relativePath: 'Legião Urbana - Pais e Filhos.mp4',
        ),
        BaseLibraryScannedFile(
          fileName: 'Pais e Filhos - Legião Urbana.mp4',
          fullPath: r'C:\Musicas\Pais e Filhos - Legião Urbana.mp4',
          relativePath: 'Pais e Filhos - Legião Urbana.mp4',
        ),
        BaseLibraryScannedFile(
          fileName: 'ArquivoSemSeparador.mp4',
          fullPath: r'C:\Musicas\ArquivoSemSeparador.mp4',
          relativePath: 'ArquivoSemSeparador.mp4',
        ),
      ]);

      final repairPlan = InvalidFileRepairPlanner().buildPlan(
        baseIndex: baseIndex,
      );
      final execution = planner.buildDryRun(repairPlan);

      expect(execution.totalCount, 3);
      expect(execution.readyToRenameCount, 1);
      expect(execution.skippedCount, 1);
      expect(execution.blockedCount, 1);
      expect(execution.hasReadyItems, isTrue);
      expect(execution.hasSkippedItems, isTrue);
      expect(execution.hasBlockedItems, isTrue);
    });

    test('nao altera repairPlan', () {
      final repairPlan = InvalidFileRepairPlan(
        items: [
          buildItem(
            status: InvalidFileRepairItemStatus.readyToSuggest,
            fullPath: r'C:\Musicas\Artista A - Musica A.mp4',
            suggestedFileName: 'Artista A - Musica A - 00002.mp4',
          ),
        ],
        warnings: const [],
      );

      final itemsBefore = List<InvalidFileRepairItem>.from(repairPlan.items);

      planner.buildDryRun(repairPlan);

      expect(repairPlan.items.length, itemsBefore.length);
    });

    test('labels do enum retornam textos esperados', () {
      expect(
        InvalidFileRepairExecutionItemStatus.readyToRename.label,
        'Pronto para renomear',
      );
      expect(
        InvalidFileRepairExecutionItemStatus.skippedNeedsReview.label,
        'Ignorado: revisão necessária',
      );
      expect(InvalidFileRepairExecutionItemStatus.blocked.label, 'Bloqueado');
    });
  });
}
