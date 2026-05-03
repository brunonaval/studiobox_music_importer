import 'package:flutter_test/flutter_test.dart';
import 'package:studiobox_music_importer/src/features/base_library/domain/song_code_allocation_strategy.dart';
import 'package:studiobox_music_importer/src/features/base_library/domain/song_code_allocator.dart';

void main() {
  group('SongCodeAllocator.allocateCodes', () {
    final allocator = SongCodeAllocator();

    test('afterHighestExisting continua apos maior codigo', () {
      final result = allocator.allocateCodes(
        usedCodes: {'00001', '00002'},
        availableCodeGaps: [],
        maxCodeNumber: 2,
        quantity: 3,
        strategy: SongCodeAllocationStrategy.afterHighestExisting,
      );

      expect(result.codes, ['00003', '00004', '00005']);
      expect(result.hasWarnings, isFalse);
    });

    test('afterHighestExisting ignora buracos', () {
      final result = allocator.allocateCodes(
        usedCodes: {'00001', '00003'},
        availableCodeGaps: ['00002'],
        maxCodeNumber: 3,
        quantity: 2,
        strategy: SongCodeAllocationStrategy.afterHighestExisting,
      );

      expect(result.codes, ['00004', '00005']);
    });

    test('fillGapsFirst usa buracos antes de continuar', () {
      final result = allocator.allocateCodes(
        usedCodes: {'00001', '00003'},
        availableCodeGaps: ['00002'],
        maxCodeNumber: 3,
        quantity: 3,
        strategy: SongCodeAllocationStrategy.fillGapsFirst,
      );

      expect(result.codes, ['00002', '00004', '00005']);
    });

    test('fillGapsFirst ignora buraco que aparece em usedCodes', () {
      final result = allocator.allocateCodes(
        usedCodes: {'00001', '00002', '00003'},
        availableCodeGaps: ['00002'],
        maxCodeNumber: 3,
        quantity: 2,
        strategy: SongCodeAllocationStrategy.fillGapsFirst,
      );

      expect(result.codes, ['00004', '00005']);
    });

    test('quantity zero retorna vazio', () {
      final result = allocator.allocateCodes(
        usedCodes: {'00001'},
        availableCodeGaps: ['00002'],
        maxCodeNumber: 2,
        quantity: 0,
        strategy: SongCodeAllocationStrategy.fillGapsFirst,
      );

      expect(result.isEmpty, isTrue);
      expect(result.hasWarnings, isFalse);
    });

    test('quantity negativo retorna vazio', () {
      final result = allocator.allocateCodes(
        usedCodes: {'00001'},
        availableCodeGaps: ['00002'],
        maxCodeNumber: 2,
        quantity: -1,
        strategy: SongCodeAllocationStrategy.fillGapsFirst,
      );

      expect(result.isEmpty, isTrue);
      expect(result.hasWarnings, isFalse);
    });

    test('maxCodeNumber null comeca em 00001', () {
      final result = allocator.allocateCodes(
        usedCodes: {},
        availableCodeGaps: [],
        maxCodeNumber: null,
        quantity: 2,
        strategy: SongCodeAllocationStrategy.afterHighestExisting,
      );

      expect(result.codes, ['00001', '00002']);
    });

    test('nunca gera 00000', () {
      final result = allocator.allocateCodes(
        usedCodes: {'00001'},
        availableCodeGaps: ['00000'],
        maxCodeNumber: 1,
        quantity: 2,
        strategy: SongCodeAllocationStrategy.fillGapsFirst,
      );

      expect(result.codes, isNot(contains('00000')));
    });

    test('nao repete codigo dentro do lote', () {
      final result = allocator.allocateCodes(
        usedCodes: {'00005'},
        availableCodeGaps: ['00002', '00002', '00003'],
        maxCodeNumber: 5,
        quantity: 4,
        strategy: SongCodeAllocationStrategy.fillGapsFirst,
      );

      final unique = result.codes.toSet();
      expect(unique.length, result.codes.length);
    });

    test('respeita limite 99999', () {
      final result = allocator.allocateCodes(
        usedCodes: {},
        availableCodeGaps: [],
        maxCodeNumber: 99998,
        quantity: 3,
        strategy: SongCodeAllocationStrategy.afterHighestExisting,
      );

      expect(result.codes, ['99999']);
      expect(result.hasWarnings, isTrue);
    });

    test('fillGapsFirst usa buracos perto do limite', () {
      final result = allocator.allocateCodes(
        usedCodes: {'99999'},
        availableCodeGaps: ['00001', '00002'],
        maxCodeNumber: 99999,
        quantity: 2,
        strategy: SongCodeAllocationStrategy.fillGapsFirst,
      );

      expect(result.codes, ['00001', '00002']);
      expect(result.hasWarnings, isFalse);
    });

    test('fillGapsFirst avisa se buracos nao bastam e sem espaco apos max', () {
      final result = allocator.allocateCodes(
        usedCodes: {'99999'},
        availableCodeGaps: ['00001'],
        maxCodeNumber: 99999,
        quantity: 2,
        strategy: SongCodeAllocationStrategy.fillGapsFirst,
      );

      expect(result.codes, ['00001']);
      expect(result.hasWarnings, isTrue);
    });

    test('codigos de saida sempre tem 5 digitos', () {
      final result = allocator.allocateCodes(
        usedCodes: {},
        availableCodeGaps: [],
        maxCodeNumber: null,
        quantity: 3,
        strategy: SongCodeAllocationStrategy.afterHighestExisting,
      );

      for (final code in result.codes) {
        expect(code.length, 5);
        expect(RegExp(r'^\d{5}$').hasMatch(code), isTrue);
      }
    });
  });

  group('SongCodeAllocationStrategy.label', () {
    test('retorna labels esperados', () {
      expect(
        SongCodeAllocationStrategy.afterHighestExisting.label,
        'Continuar apos o maior codigo',
      );
      expect(
        SongCodeAllocationStrategy.fillGapsFirst.label,
        'Preencher buracos primeiro',
      );
    });
  });
}
