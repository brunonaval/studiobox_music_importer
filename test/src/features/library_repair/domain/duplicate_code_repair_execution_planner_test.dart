import 'package:flutter_test/flutter_test.dart';
import 'package:studiobox_music_importer/src/features/library_repair/domain/library_repair.dart';

void main() {
  DuplicateCodeRepairItem baseRepairItem({
    required DuplicateCodeRepairItemStatus status,
    String? suggestedCode,
    String? suggestedFileName,
    String? fullPath,
    String displayPath = 'Sub\\Arquivo.mp4',
    List<String> warnings = const [],
    String artist = 'Artista A',
    String title = 'Musica A',
    String originalFileName = 'Artista A - Musica A - 00001.mp4',
  }) {
    return DuplicateCodeRepairItem(
      originalCode: '00001',
      suggestedCode: suggestedCode,
      artist: artist,
      title: title,
      originalFileName: originalFileName,
      fullPath: fullPath,
      relativePath: displayPath,
      displayPath: displayPath,
      suggestedFileName: suggestedFileName,
      status: status,
      warnings: warnings,
    );
  }

  group('DuplicateCodeRepairExecutionPlanner.buildDryRun', () {
    final planner = DuplicateCodeRepairExecutionPlanner();

    test('keepOriginalCode vira skippedKeepOriginal', () {
      final repairPlan = DuplicateCodeRepairPlan(
        groups: [
          DuplicateCodeRepairGroup(
            duplicatedCode: '00001',
            items: [
              baseRepairItem(
                status: DuplicateCodeRepairItemStatus.keepOriginalCode,
                fullPath: r'C:\Musicas\A.mp4',
              ),
            ],
            warnings: const [],
          ),
        ],
        warnings: const [],
      );

      final execution = planner.buildDryRun(repairPlan);
      expect(
        execution.items.first.status,
        DuplicateCodeRepairExecutionItemStatus.skippedKeepOriginal,
      );
    });

    test(
      'assignNewCode com fullPath e suggestedFileName vira readyToRename',
      () {
        final repairPlan = DuplicateCodeRepairPlan(
          groups: [
            DuplicateCodeRepairGroup(
              duplicatedCode: '00001',
              items: [
                baseRepairItem(
                  status: DuplicateCodeRepairItemStatus.assignNewCode,
                  suggestedCode: '00004',
                  suggestedFileName: 'Artista A - Musica A - 00004.mp4',
                  fullPath: r'C:\Musicas\Artista A - Musica A - 00001.mp4',
                ),
              ],
              warnings: const [],
            ),
          ],
          warnings: const [],
        );

        final execution = planner.buildDryRun(repairPlan);
        expect(
          execution.items.first.status,
          DuplicateCodeRepairExecutionItemStatus.readyToRename,
        );
      },
    );

    test('monta destination com barra invertida', () {
      final repairPlan = DuplicateCodeRepairPlan(
        groups: [
          DuplicateCodeRepairGroup(
            duplicatedCode: '00001',
            items: [
              baseRepairItem(
                status: DuplicateCodeRepairItemStatus.assignNewCode,
                suggestedCode: '00004',
                suggestedFileName: 'Artista B - Musica B - 00004.mp4',
                fullPath: r'C:\Musicas\Artista B - Musica B - 00001.mp4',
                artist: 'Artista B',
                title: 'Musica B',
              ),
            ],
            warnings: const [],
          ),
        ],
        warnings: const [],
      );

      final execution = planner.buildDryRun(repairPlan);
      expect(
        execution.items.first.destinationPathPreview,
        r'C:\Musicas\Artista B - Musica B - 00004.mp4',
      );
    });

    test('monta destination com barra normal', () {
      final repairPlan = DuplicateCodeRepairPlan(
        groups: [
          DuplicateCodeRepairGroup(
            duplicatedCode: '00001',
            items: [
              baseRepairItem(
                status: DuplicateCodeRepairItemStatus.assignNewCode,
                suggestedCode: '00004',
                suggestedFileName: 'Artista B - Musica B - 00004.mp4',
                fullPath: '/musicas/Artista B - Musica B - 00001.mp4',
                artist: 'Artista B',
                title: 'Musica B',
              ),
            ],
            warnings: const [],
          ),
        ],
        warnings: const [],
      );

      final execution = planner.buildDryRun(repairPlan);
      expect(
        execution.items.first.destinationPathPreview,
        '/musicas/Artista B - Musica B - 00004.mp4',
      );
    });

    test('assignNewCode sem fullPath fica blocked', () {
      final repairPlan = DuplicateCodeRepairPlan(
        groups: [
          DuplicateCodeRepairGroup(
            duplicatedCode: '00001',
            items: [
              baseRepairItem(
                status: DuplicateCodeRepairItemStatus.assignNewCode,
                suggestedCode: '00004',
                suggestedFileName: 'Artista B - Musica B - 00004.mp4',
              ),
            ],
            warnings: const [],
          ),
        ],
        warnings: const [],
      );

      final execution = planner.buildDryRun(repairPlan);
      expect(
        execution.items.first.status,
        DuplicateCodeRepairExecutionItemStatus.blocked,
      );
    });

    test('assignNewCode sem suggestedFileName fica blocked', () {
      final repairPlan = DuplicateCodeRepairPlan(
        groups: [
          DuplicateCodeRepairGroup(
            duplicatedCode: '00001',
            items: [
              baseRepairItem(
                status: DuplicateCodeRepairItemStatus.assignNewCode,
                suggestedCode: '00004',
                fullPath: r'C:\Musicas\Arquivo.mp4',
              ),
            ],
            warnings: const [],
          ),
        ],
        warnings: const [],
      );

      final execution = planner.buildDryRun(repairPlan);
      expect(
        execution.items.first.status,
        DuplicateCodeRepairExecutionItemStatus.blocked,
      );
    });

    test('item blocked permanece blocked', () {
      final repairPlan = DuplicateCodeRepairPlan(
        groups: [
          DuplicateCodeRepairGroup(
            duplicatedCode: '00001',
            items: [
              baseRepairItem(
                status: DuplicateCodeRepairItemStatus.blocked,
                warnings: const ['Erro original'],
              ),
            ],
            warnings: const [],
          ),
        ],
        warnings: const [],
      );

      final execution = planner.buildDryRun(repairPlan);
      expect(
        execution.items.first.status,
        DuplicateCodeRepairExecutionItemStatus.blocked,
      );
      expect(execution.items.first.warnings, contains('Erro original'));
    });

    test('colisao de destino bloqueia itens envolvidos', () {
      final repairPlan = DuplicateCodeRepairPlan(
        groups: [
          DuplicateCodeRepairGroup(
            duplicatedCode: '00001',
            items: [
              baseRepairItem(
                status: DuplicateCodeRepairItemStatus.assignNewCode,
                suggestedCode: '00004',
                suggestedFileName: 'Mesmo Nome - 00004.mp4',
                fullPath: r'C:\Musicas\Arquivo1.mp4',
              ),
              baseRepairItem(
                status: DuplicateCodeRepairItemStatus.assignNewCode,
                suggestedCode: '00005',
                suggestedFileName: 'Mesmo Nome - 00004.mp4',
                fullPath: r'C:\Musicas\Arquivo2.mp4',
              ),
            ],
            warnings: const [],
          ),
        ],
        warnings: const [],
      );

      final execution = planner.buildDryRun(repairPlan);
      expect(execution.items.where((item) => item.isBlocked).length, 2);
    });

    test('source igual a destination bloqueia item', () {
      final repairPlan = DuplicateCodeRepairPlan(
        groups: [
          DuplicateCodeRepairGroup(
            duplicatedCode: '00001',
            items: [
              baseRepairItem(
                status: DuplicateCodeRepairItemStatus.assignNewCode,
                suggestedCode: '00004',
                suggestedFileName: 'Arquivo.mp4',
                fullPath: r'C:\Musicas\Arquivo.mp4',
              ),
            ],
            warnings: const [],
          ),
        ],
        warnings: const [],
      );

      final execution = planner.buildDryRun(repairPlan);
      expect(execution.items.first.isBlocked, isTrue);
      expect(
        execution.items.first.warnings,
        contains('Origem e destino sao iguais.'),
      );
    });

    test('warnings do repairPlan entram no executionPlan', () {
      final repairPlan = DuplicateCodeRepairPlan(
        groups: const [],
        warnings: const ['Warning original'],
      );

      final execution = planner.buildDryRun(repairPlan);
      expect(execution.warnings, contains('Warning original'));
    });

    test('counts do executionPlan funcionam', () {
      final repairPlan = DuplicateCodeRepairPlan(
        groups: [
          DuplicateCodeRepairGroup(
            duplicatedCode: '00001',
            items: [
              baseRepairItem(
                status: DuplicateCodeRepairItemStatus.keepOriginalCode,
                fullPath: r'C:\Musicas\A.mp4',
              ),
              baseRepairItem(
                status: DuplicateCodeRepairItemStatus.assignNewCode,
                suggestedCode: '00004',
                suggestedFileName: 'Artista A - Musica A - 00004.mp4',
                fullPath: r'C:\Musicas\B.mp4',
              ),
              baseRepairItem(
                status: DuplicateCodeRepairItemStatus.blocked,
                warnings: const ['Erro'],
              ),
            ],
            warnings: const [],
          ),
        ],
        warnings: const [],
      );

      final execution = planner.buildDryRun(repairPlan);
      expect(execution.totalCount, 3);
      expect(execution.readyToRenameCount, 1);
      expect(execution.skippedCount, 1);
      expect(execution.blockedCount, 1);
    });

    test('nao altera repairPlan', () {
      final repairItem = baseRepairItem(
        status: DuplicateCodeRepairItemStatus.assignNewCode,
        suggestedCode: '00004',
        suggestedFileName: 'Artista A - Musica A - 00004.mp4',
        fullPath: r'C:\Musicas\A.mp4',
      );
      final repairPlan = DuplicateCodeRepairPlan(
        groups: [
          DuplicateCodeRepairGroup(
            duplicatedCode: '00001',
            items: [repairItem],
            warnings: const [],
          ),
        ],
        warnings: const [],
      );

      planner.buildDryRun(repairPlan);

      expect(
        repairPlan.groups.first.items.first.status,
        DuplicateCodeRepairItemStatus.assignNewCode,
      );
    });
  });

  group('DuplicateCodeRepairExecutionItemStatus.label', () {
    test('retorna labels esperados', () {
      expect(
        DuplicateCodeRepairExecutionItemStatus.readyToRename.label,
        'Pronto para renomear',
      );
      expect(
        DuplicateCodeRepairExecutionItemStatus.skippedKeepOriginal.label,
        'Ignorado: mantem codigo original',
      );
      expect(DuplicateCodeRepairExecutionItemStatus.blocked.label, 'Bloqueado');
    });
  });
}
