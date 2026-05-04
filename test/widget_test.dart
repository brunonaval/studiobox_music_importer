import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:studiobox_music_importer/src/app.dart';
import 'package:studiobox_music_importer/src/features/base_library/application/official_library_scan_service.dart';
import 'package:studiobox_music_importer/src/features/base_library/domain/base_library.dart';
import 'package:studiobox_music_importer/src/features/folder_selection/application/folder_picker_service.dart';
import 'package:studiobox_music_importer/src/features/folder_selection/domain/selected_folder.dart';
import 'package:studiobox_music_importer/src/features/home/presentation/home_screen.dart';
import 'package:studiobox_music_importer/src/features/library_repair/application/duplicate_code_repair_executor.dart';
import 'package:studiobox_music_importer/src/features/library_repair/domain/library_repair.dart';

class _FakeFolderPickerService extends FolderPickerService {
  _FakeFolderPickerService(this._responses);

  final List<SelectedFolder?> _responses;
  int _index = 0;

  @override
  Future<SelectedFolder?> pickOfficialLibraryFolder() async {
    if (_index >= _responses.length) {
      return null;
    }

    final response = _responses[_index];
    _index++;
    return response;
  }
}

class _FakeOfficialLibraryScanService extends OfficialLibraryScanService {
  _FakeOfficialLibraryScanService(this.result);

  final BaseLibraryIndexResult result;

  @override
  Future<BaseLibraryIndexResult> scanFolder(String folderPath) async => result;
}

class _FakeDuplicateCodeRepairExecutor extends DuplicateCodeRepairExecutor {
  _FakeDuplicateCodeRepairExecutor(this.result);

  final DuplicateCodeRepairExecutionResult result;
  int callCount = 0;

  @override
  Future<DuplicateCodeRepairExecutionResult> execute(
    DuplicateCodeRepairExecutionPlan executionPlan,
  ) async {
    callCount++;
    return result;
  }
}

void main() {
  testWidgets('renders StudioBox Music Importer shell', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const StudioBoxMusicImporterApp());

    expect(find.text('StudioBox Music Importer'), findsOneWidget);
    expect(
      find.text('Prepare novas musicas para o padrao do Karaoke StudioBox.'),
      findsOneWidget,
    );
    expect(find.text('Biblioteca oficial'), findsOneWidget);
    expect(find.text('Novas musicas'), findsOneWidget);
    expect(find.text('Revisao segura'), findsOneWidget);
    expect(find.text('Saida'), findsOneWidget);
    expect(find.text('Motor preparado'), findsOneWidget);
    expect(find.text('Selecionar biblioteca oficial'), findsOneWidget);
    expect(find.text('Indexar biblioteca oficial'), findsOneWidget);
    expect(find.text('Nenhuma pasta selecionada.'), findsOneWidget);
  });

  testWidgets(
    'updates selected official folder path and preserves it on cancel',
    (WidgetTester tester) async {
      final fakeService = _FakeFolderPickerService([
        SelectedFolder(path: 'C:/Biblioteca Oficial'),
        null,
      ]);

      await tester.pumpWidget(
        MaterialApp(home: HomeScreen(folderPickerService: fakeService)),
      );

      final buttonFinder = find.text('Selecionar biblioteca oficial');

      await tester.ensureVisible(buttonFinder);
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      expect(find.text('C:/Biblioteca Oficial'), findsOneWidget);
      expect(find.text('Biblioteca oficial selecionada.'), findsOneWidget);

      await tester.ensureVisible(buttonFinder);
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      expect(find.text('C:/Biblioteca Oficial'), findsOneWidget);
      expect(find.text('Selecao cancelada.'), findsOneWidget);
    },
  );

  testWidgets('indexes selected folder and shows stats', (
    WidgetTester tester,
  ) async {
    final fakePicker = _FakeFolderPickerService([
      SelectedFolder(path: 'C:/Biblioteca Oficial'),
    ]);
    final fakeResult = BaseLibraryIndexer().indexScannedFiles([
      BaseLibraryScannedFile(
        fileName: 'Artista A - Musica A - 00001.mp4',
        fullPath: r'C:\Biblioteca\Sub\Artista A - Musica A - 00001.mp4',
        relativePath: r'Sub\Artista A - Musica A - 00001.mp4',
      ),
      BaseLibraryScannedFile(
        fileName: 'Artista B - Musica B - 00001.mp4',
        fullPath: r'C:\Biblioteca\Sub\Artista B - Musica B - 00001.mp4',
        relativePath: r'Sub\Artista B - Musica B - 00001.mp4',
      ),
      BaseLibraryScannedFile(
        fileName: 'Artista C - Musica C - 00003.mp4',
        fullPath: r'C:\Biblioteca\Sub\Artista C - Musica C - 00003.mp4',
        relativePath: r'Sub\Artista C - Musica C - 00003.mp4',
      ),
      BaseLibraryScannedFile(
        fileName: 'Arquivo Fora Do Padrao.mp4',
        fullPath: r'C:\Biblioteca\Sub\Arquivo Fora Do Padrao.mp4',
        relativePath: r'Sub\Arquivo Fora Do Padrao.mp4',
      ),
    ]);
    final fakeScanService = _FakeOfficialLibraryScanService(fakeResult);
    final fakeExecutor = _FakeDuplicateCodeRepairExecutor(
      DuplicateCodeRepairExecutionResult(
        items: [
          DuplicateCodeRepairExecutionResultItem(
            artist: 'Artista B',
            title: 'Musica B',
            originalCode: '00001',
            suggestedCode: '00004',
            sourcePath: r'C:\Biblioteca\Sub\Artista B - Musica B - 00001.mp4',
            destinationPath:
                r'C:\Biblioteca\Sub\Artista B - Musica B - 00004.mp4',
            suggestedFileName: 'Artista B - Musica B - 00004.mp4',
            status: DuplicateCodeRepairExecutionResultItemStatus.renamed,
            messages: const ['Arquivo renomeado com sucesso.'],
          ),
          DuplicateCodeRepairExecutionResultItem(
            artist: 'Artista A',
            title: 'Musica A',
            originalCode: '00001',
            suggestedCode: null,
            sourcePath: r'C:\Biblioteca\Sub\Artista A - Musica A - 00001.mp4',
            destinationPath: null,
            suggestedFileName: null,
            status: DuplicateCodeRepairExecutionResultItemStatus.skipped,
            messages: const ['Item ignorado porque mantem o codigo original.'],
          ),
        ],
        warnings: const [],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          folderPickerService: fakePicker,
          officialLibraryScanService: fakeScanService,
          duplicateCodeRepairExecutor: fakeExecutor,
        ),
      ),
    );

    final selectButton = find.text('Selecionar biblioteca oficial');
    final indexButton = find.text('Indexar biblioteca oficial');

    await tester.ensureVisible(selectButton);
    await tester.tap(selectButton);
    await tester.pumpAndSettle();

    await tester.ensureVisible(indexButton);
    await tester.tap(indexButton);
    await tester.pumpAndSettle();

    expect(find.text('Biblioteca oficial indexada.'), findsOneWidget);
    expect(find.textContaining('Musicas validas:'), findsOneWidget);
    expect(find.textContaining('Arquivos invalidos:'), findsWidgets);
    expect(find.textContaining('Maior codigo:'), findsOneWidget);
    expect(find.text('Auditoria da biblioteca oficial'), findsOneWidget);
    expect(find.text('Arquivos invalidos: 1'), findsWidgets);
    expect(find.text('Codigos duplicados: 1'), findsWidgets);
    expect(
      find.text('Atencao: revise os problemas encontrados na auditoria.'),
      findsOneWidget,
    );

    final repairButton = find.text('Gerar plano de reparo de duplicados');
    await tester.ensureVisible(repairButton);
    await tester.tap(repairButton);
    await tester.pumpAndSettle();

    expect(find.text('Plano de reparo de duplicados gerado.'), findsOneWidget);
    expect(find.text('Plano de reparo de duplicados'), findsOneWidget);
    expect(find.text('Grupos duplicados: 1'), findsOneWidget);
    expect(
      find.textContaining('Itens que manterao codigo original:'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Itens que receberao novo codigo:'),
      findsOneWidget,
    );
    expect(find.text('Manter codigo original:'), findsOneWidget);
    expect(find.text('Atribuir novo codigo:'), findsOneWidget);
    expect(find.textContaining('Novo nome sugerido:'), findsOneWidget);
    expect(find.textContaining('00004'), findsWidgets);

    final invalidToggle = find.text('Mostrar arquivos invalidos');
    await tester.ensureVisible(invalidToggle);
    await tester.tap(invalidToggle);
    await tester.pumpAndSettle();

    expect(find.text(r'Sub\Arquivo Fora Do Padrao.mp4'), findsOneWidget);
    expect(find.text('Motivo:'), findsWidgets);

    final duplicateToggle = find.text('Mostrar codigos duplicados');
    await tester.ensureVisible(duplicateToggle);
    await tester.tap(duplicateToggle);
    await tester.pumpAndSettle();

    expect(find.text('Codigo duplicado: 00001'), findsWidgets);
    expect(find.textContaining('Artista A'), findsWidgets);
    expect(find.textContaining('Artista B'), findsWidgets);
    expect(
      find.textContaining(r'Arquivo: Sub\Artista A - Musica A - 00001.mp4'),
      findsWidgets,
    );
    expect(
      find.textContaining(r'Arquivo: Sub\Artista B - Musica B - 00001.mp4'),
      findsWidgets,
    );

    final hidePlanButton = find.text('Ocultar plano de reparo');
    await tester.ensureVisible(hidePlanButton);
    await tester.tap(hidePlanButton);
    await tester.pumpAndSettle();
    expect(find.text('Mostrar plano de reparo'), findsOneWidget);

    final dryRunButton = find.text('Validar execucao do reparo');
    await tester.ensureVisible(dryRunButton);
    await tester.tap(dryRunButton);
    await tester.pumpAndSettle();

    expect(find.text('Dry-run do reparo gerado.'), findsOneWidget);
    expect(find.text('Dry-run da execucao'), findsOneWidget);
    expect(find.textContaining('Prontos para renomear:'), findsOneWidget);
    expect(find.textContaining('Ignorados:'), findsOneWidget);
    expect(find.textContaining('Bloqueados:'), findsOneWidget);
    expect(find.textContaining('Origem:'), findsWidgets);
    expect(find.textContaining('Destino:'), findsWidgets);
    expect(find.textContaining('00004'), findsWidgets);

    expect(
      find.text('Confirmacao obrigatoria para renomear arquivos reais'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Esta acao ira renomear arquivos reais na biblioteca oficial selecionada.',
      ),
      findsOneWidget,
    );
    expect(find.text('Pasta que sera alterada:'), findsOneWidget);
    expect(find.text('C:/Biblioteca Oficial'), findsWidgets);
    expect(
      find.textContaining('Arquivos prontos para renomear:'),
      findsOneWidget,
    );
    expect(
      find.text('Esta acao nao possui desfazer automatico nesta fase.'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Recomendado: teste primeiro em uma copia da biblioteca antes de executar na pasta oficial.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Revisei o dry-run e confirmo que desejo renomear os arquivos prontos.',
      ),
      findsOneWidget,
    );

    final executeButtonFinder = find.widgetWithText(
      FilledButton,
      'Renomear arquivos reais nesta pasta',
    );
    expect(
      tester.widget<FilledButton>(executeButtonFinder),
      isA<FilledButton>(),
    );

    expect(tester.widget<FilledButton>(executeButtonFinder).onPressed, isNull);

    final checkboxFinder = find.byType(Checkbox).first;
    await tester.ensureVisible(checkboxFinder);
    await tester.tap(checkboxFinder, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(tester.widget<FilledButton>(executeButtonFinder).onPressed, isNull);

    final textFieldFinder = find.byType(TextField);
    await tester.ensureVisible(textFieldFinder);
    await tester.enterText(textFieldFinder, 'RENOMEAR');
    await tester.pumpAndSettle();

    expect(
      tester.widget<FilledButton>(executeButtonFinder).onPressed,
      isNotNull,
    );

    await tester.ensureVisible(executeButtonFinder);
    await tester.tap(executeButtonFinder);
    await tester.pumpAndSettle();

    expect(find.text('Confirmar renomeio real'), findsOneWidget);
    expect(find.textContaining('Voce esta prestes a renomear'), findsOneWidget);
    expect(
      find.textContaining('Esta acao altera arquivos reais'),
      findsOneWidget,
    );
    await tester.tap(find.text('Renomear arquivos reais'));
    await tester.pumpAndSettle();

    expect(fakeExecutor.callCount, 1);
    expect(find.text('Resultado da execucao'), findsOneWidget);
    expect(find.text('Renomeados: 1'), findsOneWidget);
    expect(find.text('Ignorados: 1'), findsWidgets);
    expect(find.text('Falhas: 0'), findsOneWidget);
    expect(find.textContaining('Reindexe a biblioteca oficial'), findsWidgets);
  });

  testWidgets('keeps execute button disabled with wrong confirmation text', (
    WidgetTester tester,
  ) async {
    final fakePicker = _FakeFolderPickerService([
      SelectedFolder(path: 'C:/Biblioteca Oficial'),
    ]);
    final fakeResult = BaseLibraryIndexer().indexScannedFiles([
      BaseLibraryScannedFile(
        fileName: 'Artista A - Musica A - 00001.mp4',
        fullPath: r'C:\Biblioteca\Artista A - Musica A - 00001.mp4',
        relativePath: r'Artista A - Musica A - 00001.mp4',
      ),
      BaseLibraryScannedFile(
        fileName: 'Artista B - Musica B - 00001.mp4',
        fullPath: r'C:\Biblioteca\Artista B - Musica B - 00001.mp4',
        relativePath: r'Artista B - Musica B - 00001.mp4',
      ),
    ]);
    final fakeScanService = _FakeOfficialLibraryScanService(fakeResult);
    final fakeExecutor = _FakeDuplicateCodeRepairExecutor(
      const DuplicateCodeRepairExecutionResult(items: [], warnings: []),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          folderPickerService: fakePicker,
          officialLibraryScanService: fakeScanService,
          duplicateCodeRepairExecutor: fakeExecutor,
        ),
      ),
    );

    await tester.ensureVisible(find.text('Selecionar biblioteca oficial'));
    await tester.tap(find.text('Selecionar biblioteca oficial'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Indexar biblioteca oficial'));
    await tester.tap(find.text('Indexar biblioteca oficial'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.text('Gerar plano de reparo de duplicados'),
    );
    await tester.tap(find.text('Gerar plano de reparo de duplicados'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Validar execucao do reparo'));
    await tester.tap(find.text('Validar execucao do reparo'));
    await tester.pumpAndSettle();

    final executeButtonFinder = find.widgetWithText(
      FilledButton,
      'Renomear arquivos reais nesta pasta',
    );

    final checkboxFinder = find.byType(Checkbox).first;
    await tester.ensureVisible(checkboxFinder);
    await tester.tap(checkboxFinder, warnIfMissed: false);
    await tester.pumpAndSettle();

    final textFieldFinder = find.byType(TextField);
    await tester.ensureVisible(textFieldFinder);
    await tester.enterText(textFieldFinder, 'renomea');
    await tester.pumpAndSettle();

    expect(tester.widget<FilledButton>(executeButtonFinder).onPressed, isNull);
    expect(fakeExecutor.callCount, 0);
  });

  testWidgets(
    'canceling confirmation dialog shows execution canceled message',
    (WidgetTester tester) async {
      final fakePicker = _FakeFolderPickerService([
        SelectedFolder(path: 'C:/Biblioteca Oficial'),
      ]);
      final fakeResult = BaseLibraryIndexer().indexScannedFiles([
        BaseLibraryScannedFile(
          fileName: 'Artista A - Musica A - 00001.mp4',
          fullPath: r'C:\Biblioteca\Artista A - Musica A - 00001.mp4',
          relativePath: r'Artista A - Musica A - 00001.mp4',
        ),
        BaseLibraryScannedFile(
          fileName: 'Artista B - Musica B - 00001.mp4',
          fullPath: r'C:\Biblioteca\Artista B - Musica B - 00001.mp4',
          relativePath: r'Artista B - Musica B - 00001.mp4',
        ),
      ]);
      final fakeScanService = _FakeOfficialLibraryScanService(fakeResult);
      final fakeExecutor = _FakeDuplicateCodeRepairExecutor(
        const DuplicateCodeRepairExecutionResult(items: [], warnings: []),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            folderPickerService: fakePicker,
            officialLibraryScanService: fakeScanService,
            duplicateCodeRepairExecutor: fakeExecutor,
          ),
        ),
      );

      await tester.ensureVisible(find.text('Selecionar biblioteca oficial'));
      await tester.tap(find.text('Selecionar biblioteca oficial'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Indexar biblioteca oficial'));
      await tester.tap(find.text('Indexar biblioteca oficial'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.text('Gerar plano de reparo de duplicados'),
      );
      await tester.tap(find.text('Gerar plano de reparo de duplicados'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Validar execucao do reparo'));
      await tester.tap(find.text('Validar execucao do reparo'));
      await tester.pumpAndSettle();

      final checkboxFinder = find.byType(Checkbox).first;
      await tester.ensureVisible(checkboxFinder);
      await tester.tap(checkboxFinder, warnIfMissed: false);
      await tester.pumpAndSettle();

      final textFieldFinder = find.byType(TextField);
      await tester.ensureVisible(textFieldFinder);
      await tester.enterText(textFieldFinder, 'RENOMEAR');
      await tester.pumpAndSettle();

      final executeButtonFinder = find.widgetWithText(
        FilledButton,
        'Renomear arquivos reais nesta pasta',
      );
      await tester.ensureVisible(executeButtonFinder);
      await tester.tap(executeButtonFinder);
      await tester.pumpAndSettle();

      expect(find.text('Confirmar renomeio real'), findsOneWidget);
      expect(find.text('Renomear arquivos reais'), findsWidgets);

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.text('Execucao cancelada.'), findsOneWidget);
      expect(fakeExecutor.callCount, 0);
    },
  );

  testWidgets('gera e exibe previa do plano de reparo de invalidos', (
    WidgetTester tester,
  ) async {
    final fakePicker = _FakeFolderPickerService([
      SelectedFolder(path: 'C:/Biblioteca Oficial'),
    ]);
    final fakeResult = BaseLibraryIndexer().indexScannedFiles([
      BaseLibraryScannedFile(
        fileName: 'Legião Urbana - Tempo Perdido - 00001.mp4',
        fullPath: r'C:\Biblioteca\Legião Urbana - Tempo Perdido - 00001.mp4',
        relativePath: 'Legião Urbana - Tempo Perdido - 00001.mp4',
      ),
      BaseLibraryScannedFile(
        fileName: 'Capital Inicial - Primeiros Erros - 00002.mp4',
        fullPath:
            r'C:\Biblioteca\Capital Inicial - Primeiros Erros - 00002.mp4',
        relativePath: 'Capital Inicial - Primeiros Erros - 00002.mp4',
      ),
      BaseLibraryScannedFile(
        fileName: 'Pais e Filhos - Legião Urbana.mp4',
        fullPath: r'C:\Biblioteca\Pais e Filhos - Legião Urbana.mp4',
        relativePath: 'Pais e Filhos - Legião Urbana.mp4',
      ),
      BaseLibraryScannedFile(
        fileName: 'Tribalistas - Velha Infância - Marisa Monte.mp4',
        fullPath:
            r'C:\Biblioteca\Tribalistas - Velha Infância - Marisa Monte.mp4',
        relativePath: 'Tribalistas - Velha Infância - Marisa Monte.mp4',
      ),
      BaseLibraryScannedFile(
        fileName: 'ArquivoSemSeparador.mp4',
        fullPath: r'C:\Biblioteca\ArquivoSemSeparador.mp4',
        relativePath: 'ArquivoSemSeparador.mp4',
      ),
    ]);
    final fakeScanService = _FakeOfficialLibraryScanService(fakeResult);
    final fakeExecutor = _FakeDuplicateCodeRepairExecutor(
      const DuplicateCodeRepairExecutionResult(items: [], warnings: []),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          folderPickerService: fakePicker,
          officialLibraryScanService: fakeScanService,
          duplicateCodeRepairExecutor: fakeExecutor,
        ),
      ),
    );

    await tester.ensureVisible(find.text('Selecionar biblioteca oficial'));
    await tester.tap(find.text('Selecionar biblioteca oficial'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Indexar biblioteca oficial'));
    await tester.tap(find.text('Indexar biblioteca oficial'));
    await tester.pumpAndSettle();

    final generateButton = find.text('Gerar plano de reparo de invalidos');
    await tester.ensureVisible(generateButton);
    await tester.tap(generateButton);
    await tester.pumpAndSettle();

    expect(find.text('Plano de reparo de invalidos gerado.'), findsOneWidget);
    expect(find.text('Plano de reparo de arquivos invalidos'), findsOneWidget);
    expect(find.text('Total: 3'), findsOneWidget);
    expect(find.text('Sugestoes prontas: 0'), findsOneWidget);
    expect(find.text('Revisao necessaria: 2'), findsOneWidget);
    expect(find.text('Bloqueados: 1'), findsOneWidget);

    expect(find.text('Arquivo atual:'), findsWidgets);
    expect(find.text('Motivo original:'), findsWidgets);
    expect(find.text('Status: Revisão necessária'), findsWidgets);
    expect(find.text('Status: Bloqueado'), findsOneWidget);

    final toggleButton = find.text('Ocultar plano de invalidos');
    await tester.ensureVisible(toggleButton);
    await tester.tap(toggleButton);
    await tester.pumpAndSettle();

    expect(find.text('Mostrar plano de invalidos'), findsOneWidget);
    expect(find.text('Plano de reparo de arquivos invalidos'), findsNothing);
  });

  testWidgets('does not execute repair without confirmation checkbox', (
    WidgetTester tester,
  ) async {
    final fakePicker = _FakeFolderPickerService([
      SelectedFolder(path: 'C:/Biblioteca Oficial'),
    ]);
    final fakeResult = BaseLibraryIndexer().indexScannedFiles([
      BaseLibraryScannedFile(
        fileName: 'Artista A - Musica A - 00001.mp4',
        fullPath: r'C:\Biblioteca\Sub\Artista A - Musica A - 00001.mp4',
        relativePath: r'Sub\Artista A - Musica A - 00001.mp4',
      ),
      BaseLibraryScannedFile(
        fileName: 'Artista B - Musica B - 00001.mp4',
        fullPath: r'C:\Biblioteca\Sub\Artista B - Musica B - 00001.mp4',
        relativePath: r'Sub\Artista B - Musica B - 00001.mp4',
      ),
      BaseLibraryScannedFile(
        fileName: 'Artista C - Musica C - 00003.mp4',
        fullPath: r'C:\Biblioteca\Sub\Artista C - Musica C - 00003.mp4',
        relativePath: r'Sub\Artista C - Musica C - 00003.mp4',
      ),
    ]);
    final fakeScanService = _FakeOfficialLibraryScanService(fakeResult);
    final fakeExecutor = _FakeDuplicateCodeRepairExecutor(
      const DuplicateCodeRepairExecutionResult(items: [], warnings: []),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          folderPickerService: fakePicker,
          officialLibraryScanService: fakeScanService,
          duplicateCodeRepairExecutor: fakeExecutor,
        ),
      ),
    );

    final selectButton = find.text('Selecionar biblioteca oficial');
    await tester.ensureVisible(selectButton);
    await tester.tap(selectButton);
    await tester.pumpAndSettle();
    final indexButton = find.text('Indexar biblioteca oficial');
    await tester.ensureVisible(indexButton);
    await tester.tap(indexButton);
    await tester.pumpAndSettle();
    final generatePlanButton = find.text('Gerar plano de reparo de duplicados');
    await tester.ensureVisible(generatePlanButton);
    await tester.tap(generatePlanButton);
    await tester.pumpAndSettle();
    final dryRunButton = find.text('Validar execucao do reparo');
    await tester.ensureVisible(dryRunButton);
    await tester.tap(dryRunButton);
    await tester.pumpAndSettle();

    final executeButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Renomear arquivos reais nesta pasta'),
    );
    expect(executeButton.onPressed, isNull);
    expect(fakeExecutor.callCount, 0);
  });
}
