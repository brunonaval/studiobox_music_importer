import 'package:flutter_test/flutter_test.dart';
import 'package:studiobox_music_importer/src/features/incoming_songs/domain/incoming_songs.dart';

IncomingSongScannedFile _file(String fileName) => IncomingSongScannedFile(
  fileName: fileName,
  fullPath: '/pasta/$fileName',
  relativePath: fileName,
);

IncomingSongsScanResult _scan(List<String> fileNames) =>
    IncomingSongsScanResult(
      files: fileNames.map(_file).toList(),
      warnings: const [],
    );

IncomingSongCleaningRule _prefix(String pattern) => IncomingSongCleaningRule(
  type: IncomingSongCleaningRuleType.removePrefix,
  pattern: pattern,
  description: pattern,
);

IncomingSongCleaningRule _suffix(String pattern) => IncomingSongCleaningRule(
  type: IncomingSongCleaningRuleType.removeSuffix,
  pattern: pattern,
  description: pattern,
);

IncomingSongCleaningRule _contains(String pattern) => IncomingSongCleaningRule(
  type: IncomingSongCleaningRuleType.removeContains,
  pattern: pattern,
  description: pattern,
);

void main() {
  group('IncomingSongNameCleaner.buildPreview', () {
    late IncomingSongNameCleaner cleaner;

    setUp(() {
      cleaner = IncomingSongNameCleaner();
    });

    test('remove prefixo Karaokê - ', () {
      final plan = cleaner.buildPreview(
        scanResult: _scan(['Karaokê - Chifre não é asa - Guto Lima.mp4']),
        rules: [_prefix('Karaokê - ')],
      );

      expect(
        plan.items.first.cleanedFileName,
        'Chifre não é asa - Guto Lima.mp4',
      );
    });

    test('remove prefixo Karaoke - ', () {
      final plan = cleaner.buildPreview(
        scanResult: _scan(['Karaoke - Nome da Musica - Artista.mp4']),
        rules: [_prefix('Karaoke - ')],
      );

      expect(plan.items.first.cleanedFileName, 'Nome da Musica - Artista.mp4');
    });

    test('remove sufixo - Karaokê', () {
      final plan = cleaner.buildPreview(
        scanResult: _scan(['Chifre não é asa - Guto Lima - Karaokê.mp4']),
        rules: [_suffix(' - Karaokê')],
      );

      expect(
        plan.items.first.cleanedFileName,
        'Chifre não é asa - Guto Lima.mp4',
      );
    });

    test('remove sufixo - Karaoke', () {
      final plan = cleaner.buildPreview(
        scanResult: _scan(['Musica - Artista - Karaoke.mp4']),
        rules: [_suffix(' - Karaoke')],
      );

      expect(plan.items.first.cleanedFileName, 'Musica - Artista.mp4');
    });

    test('remove sufixo (Karaokê)', () {
      final plan = cleaner.buildPreview(
        scanResult: _scan(['Musica - Artista (Karaokê).mp4']),
        rules: [_suffix(' (Karaokê)')],
      );

      expect(plan.items.first.cleanedFileName, 'Musica - Artista.mp4');
    });

    test('preserva extensao .MP4 maiuscula', () {
      final plan = cleaner.buildPreview(
        scanResult: _scan(['Karaoke - Nome - Artista.MP4']),
        rules: [_prefix('Karaoke - ')],
      );

      expect(plan.items.first.cleanedFileName, 'Nome - Artista.MP4');
    });

    test('regra disabled nao altera nome', () {
      final rule = IncomingSongCleaningRule(
        type: IncomingSongCleaningRuleType.removePrefix,
        pattern: 'Karaoke - ',
        enabled: false,
      );
      final plan = cleaner.buildPreview(
        scanResult: _scan(['Karaoke - Nome - Artista.mp4']),
        rules: [rule],
      );

      expect(plan.items.first.cleanedFileName, 'Karaoke - Nome - Artista.mp4');
    });

    test('pattern vazio nao altera nome', () {
      final rule = IncomingSongCleaningRule(
        type: IncomingSongCleaningRuleType.removePrefix,
        pattern: '   ',
      );
      final plan = cleaner.buildPreview(
        scanResult: _scan(['Karaoke - Nome.mp4']),
        rules: [rule],
      );

      expect(plan.items.first.cleanedFileName, 'Karaoke - Nome.mp4');
    });

    test('removeContains remove ocorrencia em qualquer posicao', () {
      final plan = cleaner.buildPreview(
        scanResult: _scan(['Musica Cover - Artista.mp4']),
        rules: [_contains('Cover')],
      );

      expect(plan.items.first.cleanedFileName, 'Musica - Artista.mp4');
    });

    test('removeContains com pattern curto gera warning e nao aplica', () {
      final plan = cleaner.buildPreview(
        scanResult: _scan(['Nome HD Artista.mp4']),
        rules: [_contains('HD')],
      );

      expect(plan.items.first.cleanedFileName, 'Nome HD Artista.mp4');
      expect(
        plan.items.first.warnings.any((w) => w.contains('muito curto')),
        isTrue,
      );
    });

    test('limpeza que deixaria nome vazio e ignorada com warning', () {
      final plan = cleaner.buildPreview(
        scanResult: _scan(['Karaoke - .mp4']),
        rules: [_prefix('Karaoke - ')],
      );

      expect(plan.items.first.cleanedFileName, 'Karaoke - .mp4');
      expect(
        plan.items.first.warnings.any((w) => w.contains('nome vazio')),
        isTrue,
      );
    });

    test('appliedRules registra regra aplicada', () {
      final plan = cleaner.buildPreview(
        scanResult: _scan(['Karaoke - Nome - Artista.mp4']),
        rules: [_prefix('Karaoke - ')],
      );

      expect(plan.items.first.appliedRules, contains('Karaoke - '));
    });

    test('changedCount e unchangedCount funcionam', () {
      final plan = cleaner.buildPreview(
        scanResult: _scan([
          'Karaoke - Nome - Artista.mp4',
          'Nome Normal - Artista.mp4',
        ]),
        rules: [_prefix('Karaoke - ')],
      );

      expect(plan.changedCount, 1);
      expect(plan.unchangedCount, 1);
    });

    test('warnings do scanResult entram no plano', () {
      final scanResult = IncomingSongsScanResult(
        files: [_file('Musica.mp4')],
        warnings: ['Falha parcial no scan.'],
      );
      final plan = cleaner.buildPreview(scanResult: scanResult, rules: []);

      expect(plan.warnings, contains('Falha parcial no scan.'));
    });

    test('labels do enum retornam textos esperados', () {
      expect(
        IncomingSongCleaningRuleType.removePrefix.label,
        'Remover do início',
      );
      expect(IncomingSongCleaningRuleType.removeSuffix.label, 'Remover do fim');
      expect(
        IncomingSongCleaningRuleType.removeContains.label,
        'Remover ocorrência',
      );
    });
  });
}
