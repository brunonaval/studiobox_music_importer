import 'package:flutter_test/flutter_test.dart';
import 'package:studiobox_music_importer/src/features/base_library/domain/base_library.dart';
import 'package:studiobox_music_importer/src/features/library_repair/domain/library_repair.dart';

void main() {
  BaseLibraryIndexResult buildIndexFromFileNames(List<String> fileNames) {
    return BaseLibraryIndexer().indexFileNames(fileNames);
  }

  group('DuplicateCodeRepairPlanner.buildPlan', () {
    final planner = DuplicateCodeRepairPlanner();

    test('retorna plano vazio quando nao ha duplicados', () {
      final baseIndex = buildIndexFromFileNames([
        'Artista A - Musica A - 00001.mp4',
        'Artista B - Musica B - 00002.mp4',
      ]);

      final plan = planner.buildPlan(baseIndex: baseIndex);

      expect(plan.groups, isEmpty);
      expect(plan.hasGroups, isFalse);
    });

    test('cria grupo para codigo duplicado', () {
      final baseIndex = buildIndexFromFileNames([
        'Artista A - Musica A - 00001.mp4',
        'Artista B - Musica B - 00001.mp4',
      ]);

      final plan = planner.buildPlan(baseIndex: baseIndex);

      expect(plan.totalGroups, 1);
      expect(plan.groups.first.duplicatedCode, '00001');
      expect(plan.groups.first.items.length, 2);
    });

    test('mantem uma entrada com codigo original', () {
      final baseIndex = buildIndexFromFileNames([
        'Artista A - Musica A - 00001.mp4',
        'Artista B - Musica B - 00001.mp4',
      ]);

      final plan = planner.buildPlan(baseIndex: baseIndex);
      final group = plan.groups.first;

      expect(group.keepOriginalCount, 1);
      expect(
        group.items
            .where(
              (item) =>
                  item.status == DuplicateCodeRepairItemStatus.keepOriginalCode,
            )
            .length,
        1,
      );
    });

    test('sugere novo codigo com afterHighestExisting', () {
      final baseIndex = buildIndexFromFileNames([
        'Artista A - Musica A - 00001.mp4',
        'Artista B - Musica B - 00001.mp4',
        'Artista C - Musica C - 00003.mp4',
      ]);

      final plan = planner.buildPlan(
        baseIndex: baseIndex,
        codeStrategy: SongCodeAllocationStrategy.afterHighestExisting,
      );

      final repairedItem = plan.groups.first.items.firstWhere(
        (item) => item.assignsNewCode,
      );
      expect(repairedItem.suggestedCode, '00004');
    });

    test('monta suggestedFileName com artista titulo e codigo novo', () {
      final baseIndex = buildIndexFromFileNames([
        'Artista A - Musica A - 00001.mp4',
        'Artista B - Musica B - 00001.mp4',
        'Artista C - Musica C - 00003.mp4',
      ]);

      final plan = planner.buildPlan(baseIndex: baseIndex);

      final repairedItem = plan.groups.first.items.firstWhere(
        (item) => item.assignsNewCode,
      );
      expect(
        repairedItem.suggestedFileName,
        'Artista B - Musica B - 00004.mp4',
      );
    });

    test(
      'preserva fullPath e relativePath quando base vem de indexScannedFiles',
      () {
        final baseIndex = BaseLibraryIndexer().indexScannedFiles([
          BaseLibraryScannedFile(
            fileName: 'Artista A - Musica A - 00001.mp4',
            fullPath: r'C:\Base\Sub\Artista A - Musica A - 00001.mp4',
            relativePath: r'Sub\Artista A - Musica A - 00001.mp4',
          ),
          BaseLibraryScannedFile(
            fileName: 'Artista B - Musica B - 00001.mp4',
            fullPath: r'C:\Base\Sub\Artista B - Musica B - 00001.mp4',
            relativePath: r'Sub\Artista B - Musica B - 00001.mp4',
          ),
        ]);

        final plan = planner.buildPlan(baseIndex: baseIndex);
        final item = plan.groups.first.items.firstWhere(
          (it) => it.assignsNewCode,
        );

        expect(item.fullPath, isNotNull);
        expect(item.relativePath, isNotNull);
      },
    );

    test('displayPath vem da entrada', () {
      final baseIndex = BaseLibraryIndexer().indexScannedFiles([
        BaseLibraryScannedFile(
          fileName: 'Artista A - Musica A - 00001.mp4',
          fullPath: r'C:\Base\Sub\Artista A - Musica A - 00001.mp4',
          relativePath: r'Sub\Artista A - Musica A - 00001.mp4',
        ),
        BaseLibraryScannedFile(
          fileName: 'Artista B - Musica B - 00001.mp4',
          fullPath: r'C:\Base\Sub\Artista B - Musica B - 00001.mp4',
          relativePath: r'Sub\Artista B - Musica B - 00001.mp4',
        ),
      ]);

      final plan = planner.buildPlan(baseIndex: baseIndex);
      final item = plan.groups.first.items.firstWhere(
        (it) => it.assignsNewCode,
      );

      expect(item.displayPath, r'Sub\Artista B - Musica B - 00001.mp4');
    });

    test('fillGapsFirst usa buracos disponiveis', () {
      final baseIndex = buildIndexFromFileNames([
        'Artista A - Musica A - 00001.mp4',
        'Artista B - Musica B - 00001.mp4',
        'Artista C - Musica C - 00003.mp4',
      ]);

      final plan = planner.buildPlan(
        baseIndex: baseIndex,
        codeStrategy: SongCodeAllocationStrategy.fillGapsFirst,
      );

      final repairedItem = plan.groups.first.items.firstWhere(
        (item) => item.assignsNewCode,
      );
      expect(repairedItem.suggestedCode, '00002');
    });

    test('grupo com mais de 2 entradas gera multiplos novos codigos', () {
      final baseIndex = buildIndexFromFileNames([
        'Artista A - Musica A - 00001.mp4',
        'Artista B - Musica B - 00001.mp4',
        'Artista C - Musica C - 00001.mp4',
        'Artista D - Musica D - 00004.mp4',
      ]);

      final plan = planner.buildPlan(baseIndex: baseIndex);
      final group = plan.groups.first;

      expect(group.keepOriginalCount, 1);
      expect(group.assignNewCodeCount, 2);
    });

    test('quando faltam codigos item fica blocked', () {
      final duplicatedEntries = [
        const BaseLibraryIndexEntry(
          song: OfficialSong(
            artist: 'Artista A',
            title: 'Musica A',
            code: '99999',
            fileName: 'Artista A - Musica A - 99999.mp4',
          ),
          originalFileName: 'Artista A - Musica A - 99999.mp4',
        ),
        const BaseLibraryIndexEntry(
          song: OfficialSong(
            artist: 'Artista B',
            title: 'Musica B',
            code: '99999',
            fileName: 'Artista B - Musica B - 99999.mp4',
          ),
          originalFileName: 'Artista B - Musica B - 99999.mp4',
        ),
      ];

      final baseIndex = BaseLibraryIndexResult(
        entries: duplicatedEntries,
        invalidFiles: const [],
        duplicateCodes: [
          BaseLibraryDuplicateCode(code: '99999', entries: duplicatedEntries),
        ],
        usedCodes: const {'99999'},
        availableCodeGaps: const [],
        maxCodeNumber: 99999,
        knownArtists: const {'Artista A', 'Artista B'},
      );

      final plan = planner.buildPlan(baseIndex: baseIndex);

      expect(plan.totalBlocked, greaterThan(0));
      expect(plan.hasBlockedItems, isTrue);
      expect(
        plan.warnings,
        contains(
          'Existem reparos bloqueados por falta de codigos disponiveis.',
        ),
      );
    });

    test('warnings do allocator aparecem no plan', () {
      final duplicatedEntries = [
        const BaseLibraryIndexEntry(
          song: OfficialSong(
            artist: 'Artista A',
            title: 'Musica A',
            code: '99999',
            fileName: 'Artista A - Musica A - 99999.mp4',
          ),
          originalFileName: 'Artista A - Musica A - 99999.mp4',
        ),
        const BaseLibraryIndexEntry(
          song: OfficialSong(
            artist: 'Artista B',
            title: 'Musica B',
            code: '99999',
            fileName: 'Artista B - Musica B - 99999.mp4',
          ),
          originalFileName: 'Artista B - Musica B - 99999.mp4',
        ),
      ];

      final baseIndex = BaseLibraryIndexResult(
        entries: duplicatedEntries,
        invalidFiles: const [],
        duplicateCodes: [
          BaseLibraryDuplicateCode(code: '99999', entries: duplicatedEntries),
        ],
        usedCodes: const {'99999'},
        availableCodeGaps: const [],
        maxCodeNumber: 99999,
        knownArtists: const {'Artista A', 'Artista B'},
      );

      final plan = planner.buildPlan(baseIndex: baseIndex);

      expect(
        plan.warnings,
        contains('Nao ha codigos disponiveis suficientes ate 99999.'),
      );
    });

    test('plano nao altera baseIndex.usedCodes', () {
      final baseIndex = buildIndexFromFileNames([
        'Artista A - Musica A - 00001.mp4',
        'Artista B - Musica B - 00001.mp4',
      ]);
      final originalUsedCodes = Set<String>.from(baseIndex.usedCodes);

      planner.buildPlan(baseIndex: baseIndex);

      expect(baseIndex.usedCodes, originalUsedCodes);
    });

    test('counts totais do plan funcionam', () {
      final baseIndex = buildIndexFromFileNames([
        'Artista A - Musica A - 00001.mp4',
        'Artista B - Musica B - 00001.mp4',
        'Artista C - Musica C - 00002.mp4',
        'Artista D - Musica D - 00002.mp4',
      ]);

      final plan = planner.buildPlan(baseIndex: baseIndex);

      expect(plan.totalGroups, 2);
      expect(plan.totalItems, 4);
      expect(plan.totalKeepOriginal, 2);
      expect(plan.totalAssignNewCode, 2);
      expect(plan.totalBlocked, 0);
    });
  });

  group('DuplicateCodeRepairItemStatus.label', () {
    test('retorna labels esperados', () {
      expect(
        DuplicateCodeRepairItemStatus.keepOriginalCode.label,
        'Manter codigo original',
      );
      expect(
        DuplicateCodeRepairItemStatus.assignNewCode.label,
        'Atribuir novo codigo',
      );
      expect(DuplicateCodeRepairItemStatus.blocked.label, 'Bloqueado');
    });
  });
}
