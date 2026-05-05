import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:studiobox_music_importer/src/app.dart';
import 'package:studiobox_music_importer/src/features/base_library/application/official_library_scan_service.dart';
import 'package:studiobox_music_importer/src/features/base_library/domain/base_library.dart';
import 'package:studiobox_music_importer/src/features/folder_selection/application/folder_picker_service.dart';
import 'package:studiobox_music_importer/src/features/folder_selection/domain/selected_folder.dart';
import 'package:studiobox_music_importer/src/features/home/presentation/home_screen.dart';
import 'package:studiobox_music_importer/src/features/incoming_songs/application/incoming_songs_scan_service.dart';
import 'package:studiobox_music_importer/src/features/incoming_songs/domain/incoming_songs.dart';
import 'package:studiobox_music_importer/src/features/library_repair/application/duplicate_code_repair_executor.dart';
import 'package:studiobox_music_importer/src/features/library_repair/application/invalid_file_repair_executor.dart';
import 'package:studiobox_music_importer/src/features/library_repair/domain/library_repair.dart';

class _FakeFolderPickerService extends FolderPickerService {
  _FakeFolderPickerService(
    List<SelectedFolder?> officialResponses, {
    List<SelectedFolder?> incomingResponses = const [],
  }) : _officialResponses = officialResponses,
       _incomingResponses = incomingResponses;

  final List<SelectedFolder?> _officialResponses;
  final List<SelectedFolder?> _incomingResponses;
  int _officialIndex = 0;
  int _incomingIndex = 0;

  @override
  Future<SelectedFolder?> pickOfficialLibraryFolder() async {
    if (_officialIndex >= _officialResponses.length) {
      return null;
    }
    final response = _officialResponses[_officialIndex];
    _officialIndex++;
    return response;
  }

  @override
  Future<SelectedFolder?> pickIncomingSongsFolder() async {
    if (_incomingIndex >= _incomingResponses.length) {
      return null;
    }
    final response = _incomingResponses[_incomingIndex];
    _incomingIndex++;
    return response;
  }
}

class _FakeOfficialLibraryScanService extends OfficialLibraryScanService {
  _FakeOfficialLibraryScanService(this.result);

  final BaseLibraryIndexResult result;

  @override
  Future<BaseLibraryIndexResult> scanFolder(String folderPath) async => result;
}

class _FakeInvalidFileRepairExecutor extends InvalidFileRepairExecutor {
  _FakeInvalidFileRepairExecutor(this.result);

  final InvalidFileRepairExecutionResult result;
  int callCount = 0;

  @override
  Future<InvalidFileRepairExecutionResult> execute(
    InvalidFileRepairExecutionPlan executionPlan,
  ) async {
    callCount++;
    return result;
  }
}

class _FakeIncomingSongsScanService extends IncomingSongsScanService {
  _FakeIncomingSongsScanService(this.result);

  final IncomingSongsScanResult result;

  @override
  Future<IncomingSongsScanResult> scanFolder(String folderPath) async => result;
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
    expect(find.text('Selecionar pasta de musicas novas'), findsOneWidget);
    expect(
      find.text('Nenhuma pasta de musicas novas selecionada.'),
      findsOneWidget,
    );
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

  testWidgets('gera e exibe dry-run do reparo de invalidos', (
    WidgetTester tester,
  ) async {
    final fakePicker = _FakeFolderPickerService([
      SelectedFolder(path: 'C:/Biblioteca Oficial'),
    ]);
    final fakeResult = BaseLibraryIndexer().indexScannedFiles([
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

    final generatePlanButton = find.text('Gerar plano de reparo de invalidos');
    await tester.ensureVisible(generatePlanButton);
    await tester.tap(generatePlanButton);
    await tester.pumpAndSettle();

    final dryRunButton = find.text('Validar execucao dos invalidos');
    await tester.ensureVisible(dryRunButton);
    await tester.tap(dryRunButton);
    await tester.pumpAndSettle();

    expect(find.text('Dry-run dos invalidos gerado.'), findsOneWidget);
    expect(find.text('Dry-run dos arquivos invalidos'), findsOneWidget);
    expect(find.textContaining('Prontos para renomear:'), findsOneWidget);
    expect(find.textContaining('Aguardando revisao:'), findsWidgets);
    expect(find.textContaining('Bloqueados:'), findsWidgets);
    expect(find.text('Arquivo atual:'), findsWidgets);
    expect(find.text('Destino:'), findsOneWidget);

    final toggleButton = find.text('Ocultar dry-run de invalidos');
    await tester.ensureVisible(toggleButton);
    await tester.tap(toggleButton);
    await tester.pumpAndSettle();

    expect(find.text('Mostrar dry-run de invalidos'), findsOneWidget);
    expect(find.text('Dry-run dos arquivos invalidos'), findsNothing);
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

  testWidgets('executa reparo de invalidos e exibe resultado', (
    WidgetTester tester,
  ) async {
    final fakePicker = _FakeFolderPickerService([
      SelectedFolder(path: 'C:/Biblioteca Oficial'),
    ]);
    final fakeResult = BaseLibraryIndexer().indexScannedFiles([
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
    final fakeScanService = _FakeOfficialLibraryScanService(fakeResult);
    final fakeDuplicateExecutor = _FakeDuplicateCodeRepairExecutor(
      const DuplicateCodeRepairExecutionResult(items: [], warnings: []),
    );
    final fakeInvalidExecutor = _FakeInvalidFileRepairExecutor(
      InvalidFileRepairExecutionResult(
        items: [
          InvalidFileRepairExecutionResultItem(
            originalFileName: 'Legião Urbana - Pais e Filhos.mp4',
            originalReason: 'Fora do padrão',
            detectedArtist: 'Legião Urbana',
            detectedTitle: 'Pais e Filhos',
            suggestedCode: '00003',
            sourcePath: r'C:\Musicas\Legião Urbana - Pais e Filhos.mp4',
            destinationPath:
                r'C:\Musicas\Legião Urbana - Pais e Filhos - 00003.mp4',
            suggestedFileName: 'Legião Urbana - Pais e Filhos - 00003.mp4',
            status: InvalidFileRepairExecutionResultItemStatus.renamed,
            messages: const ['Arquivo renomeado com sucesso.'],
          ),
          InvalidFileRepairExecutionResultItem(
            originalFileName: 'Pais e Filhos - Legião Urbana.mp4',
            originalReason: 'Fora do padrão',
            detectedArtist: 'Legião Urbana',
            detectedTitle: 'Pais e Filhos',
            suggestedCode: null,
            sourcePath: r'C:\Musicas\Pais e Filhos - Legião Urbana.mp4',
            destinationPath: null,
            suggestedFileName: null,
            status: InvalidFileRepairExecutionResultItemStatus.skipped,
            messages: const ['Item ignorado porque precisa de revisão manual.'],
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
          duplicateCodeRepairExecutor: fakeDuplicateExecutor,
          invalidFileRepairExecutor: fakeInvalidExecutor,
        ),
      ),
    );

    await tester.ensureVisible(find.text('Selecionar biblioteca oficial'));
    await tester.tap(find.text('Selecionar biblioteca oficial'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Indexar biblioteca oficial'));
    await tester.tap(find.text('Indexar biblioteca oficial'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Gerar plano de reparo de invalidos'));
    await tester.tap(find.text('Gerar plano de reparo de invalidos'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Validar execucao dos invalidos'));
    await tester.tap(find.text('Validar execucao dos invalidos'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Confirmacao obrigatoria para renomear arquivos invalidos reais',
      ),
      findsOneWidget,
    );
    expect(find.text('Pasta que sera alterada:'), findsOneWidget);
    expect(find.text('C:/Biblioteca Oficial'), findsWidgets);
    expect(
      find.textContaining('Arquivos invalidos prontos para renomear:'),
      findsOneWidget,
    );

    final executeButtonFinder = find.widgetWithText(
      FilledButton,
      'Renomear arquivos invalidos reais nesta pasta',
    );
    expect(tester.widget<FilledButton>(executeButtonFinder).onPressed, isNull);

    final checkboxFinder = find.byWidgetPredicate(
      (widget) =>
          widget is CheckboxListTile &&
          (widget.title as Text).data!.contains('dry-run dos invalidos'),
    );
    await tester.ensureVisible(checkboxFinder);
    await tester.tap(checkboxFinder, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(tester.widget<FilledButton>(executeButtonFinder).onPressed, isNull);

    final textFieldFinder = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          (widget.decoration?.labelText ?? '').contains('RENOMEAR'),
    );
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

    expect(find.text('Confirmar renomeio real de invalidos'), findsOneWidget);
    expect(find.textContaining('Voce esta prestes a renomear'), findsOneWidget);

    await tester.tap(find.text('Renomear arquivos invalidos reais'));
    await tester.pumpAndSettle();

    expect(fakeInvalidExecutor.callCount, 1);
    expect(find.text('Resultado da execucao dos invalidos'), findsOneWidget);
    expect(find.text('Renomeados: 1'), findsOneWidget);
    expect(find.text('Ignorados: 1'), findsOneWidget);
    expect(find.text('Falhas: 0'), findsOneWidget);
    expect(find.textContaining('Reindexe a biblioteca oficial'), findsWidgets);
  });

  testWidgets(
    'botao de invalidos permanece desabilitado sem digitar RENOMEAR',
    (WidgetTester tester) async {
      final fakePicker = _FakeFolderPickerService([
        SelectedFolder(path: 'C:/Biblioteca Oficial'),
      ]);
      final fakeResult = BaseLibraryIndexer().indexScannedFiles([
        BaseLibraryScannedFile(
          fileName: 'Legião Urbana - Tempo Perdido - 00001.mp4',
          fullPath: r'C:\Musicas\Legião Urbana - Tempo Perdido - 00001.mp4',
          relativePath: 'Legião Urbana - Tempo Perdido - 00001.mp4',
        ),
        BaseLibraryScannedFile(
          fileName: 'Legião Urbana - Pais e Filhos.mp4',
          fullPath: r'C:\Musicas\Legião Urbana - Pais e Filhos.mp4',
          relativePath: 'Legião Urbana - Pais e Filhos.mp4',
        ),
      ]);
      final fakeScanService = _FakeOfficialLibraryScanService(fakeResult);
      final fakeDuplicateExecutor = _FakeDuplicateCodeRepairExecutor(
        const DuplicateCodeRepairExecutionResult(items: [], warnings: []),
      );
      final fakeInvalidExecutor = _FakeInvalidFileRepairExecutor(
        const InvalidFileRepairExecutionResult(items: [], warnings: []),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            folderPickerService: fakePicker,
            officialLibraryScanService: fakeScanService,
            duplicateCodeRepairExecutor: fakeDuplicateExecutor,
            invalidFileRepairExecutor: fakeInvalidExecutor,
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
        find.text('Gerar plano de reparo de invalidos'),
      );
      await tester.tap(find.text('Gerar plano de reparo de invalidos'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Validar execucao dos invalidos'));
      await tester.tap(find.text('Validar execucao dos invalidos'));
      await tester.pumpAndSettle();

      final checkboxFinder = find.byWidgetPredicate(
        (widget) =>
            widget is CheckboxListTile &&
            (widget.title as Text).data!.contains('dry-run dos invalidos'),
      );
      await tester.ensureVisible(checkboxFinder);
      await tester.tap(checkboxFinder, warnIfMissed: false);
      await tester.pumpAndSettle();

      final textFieldFinder = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            (widget.decoration?.labelText ?? '').contains('RENOMEAR'),
      );
      await tester.ensureVisible(textFieldFinder);
      await tester.enterText(textFieldFinder, 'renomea');
      await tester.pumpAndSettle();

      final executeButtonFinder = find.widgetWithText(
        FilledButton,
        'Renomear arquivos invalidos reais nesta pasta',
      );
      expect(
        tester.widget<FilledButton>(executeButtonFinder).onPressed,
        isNull,
      );
      expect(fakeInvalidExecutor.callCount, 0);
    },
  );

  testWidgets('seleciona pasta de musicas novas e exibe caminho', (
    WidgetTester tester,
  ) async {
    final fakeService = _FakeFolderPickerService(
      [],
      incomingResponses: [SelectedFolder(path: 'C:/Novas Musicas')],
    );

    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(folderPickerService: fakeService)),
    );

    expect(
      find.text('Nenhuma pasta de musicas novas selecionada.'),
      findsOneWidget,
    );

    final buttonFinder = find.text('Selecionar pasta de musicas novas');
    await tester.ensureVisible(buttonFinder);
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    expect(find.text('C:/Novas Musicas'), findsOneWidget);
    expect(find.text('Pasta de musicas novas selecionada.'), findsOneWidget);
  });

  testWidgets('escaneia pasta de musicas novas e exibe resultado', (
    WidgetTester tester,
  ) async {
    final fakeService = _FakeFolderPickerService(
      [],
      incomingResponses: [SelectedFolder(path: 'C:/Novas Musicas')],
    );
    final fakeScanService = _FakeIncomingSongsScanService(
      IncomingSongsScanResult(
        files: [
          IncomingSongScannedFile(
            fileName: 'Artista A - Musica A.mp4',
            fullPath: r'C:\Novas Musicas\Artista A - Musica A.mp4',
            relativePath: 'Artista A - Musica A.mp4',
          ),
          IncomingSongScannedFile(
            fileName: 'Artista B - Musica B.mp4',
            fullPath: r'C:\Novas Musicas\Artista B - Musica B.mp4',
            relativePath: 'Artista B - Musica B.mp4',
          ),
        ],
        warnings: const [],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          folderPickerService: fakeService,
          incomingSongsScanService: fakeScanService,
        ),
      ),
    );

    final selectButton = find.text('Selecionar pasta de musicas novas');
    await tester.ensureVisible(selectButton);
    await tester.tap(selectButton);
    await tester.pumpAndSettle();

    expect(find.text('C:/Novas Musicas'), findsOneWidget);

    final scanButton = find.text('Escanear músicas novas');
    await tester.ensureVisible(scanButton);
    await tester.tap(scanButton);
    await tester.pumpAndSettle();

    expect(find.text('Pasta de músicas novas escaneada.'), findsOneWidget);
    expect(find.text('Músicas novas encontradas: 2'), findsOneWidget);
    expect(find.text('Amostra de arquivos:'), findsOneWidget);
    expect(find.text('Artista A - Musica A.mp4'), findsOneWidget);
    expect(find.text('Artista B - Musica B.mp4'), findsOneWidget);
  });

  testWidgets(
    'botao escanear nao aparece sem pasta de musicas novas selecionada',
    (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: HomeScreen()));

      expect(
        find.text('Nenhuma pasta de musicas novas selecionada.'),
        findsOneWidget,
      );
      expect(find.text('Escanear músicas novas'), findsNothing);
    },
  );

  testWidgets('cancelar selecao de musicas novas mantem caminho anterior', (
    WidgetTester tester,
  ) async {
    final fakeService = _FakeFolderPickerService(
      [],
      incomingResponses: [
        SelectedFolder(path: 'C:/Novas Musicas'),
        null,
      ],
    );

    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(folderPickerService: fakeService)),
    );

    final buttonFinder = find.text('Selecionar pasta de musicas novas');

    await tester.ensureVisible(buttonFinder);
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    expect(find.text('C:/Novas Musicas'), findsOneWidget);

    await tester.ensureVisible(buttonFinder);
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    expect(find.text('C:/Novas Musicas'), findsOneWidget);
    expect(find.text('Selecao cancelada.'), findsOneWidget);
  });

  testWidgets('gera pre-limpeza dos nomes e exibe resultado', (
    WidgetTester tester,
  ) async {
    final fakePickerService = _FakeFolderPickerService(
      [],
      incomingResponses: [SelectedFolder(path: 'C:/Novas Musicas')],
    );
    final fakeScanService = _FakeIncomingSongsScanService(
      IncomingSongsScanResult(
        files: [
          IncomingSongScannedFile(
            fileName: 'Karaokê - Chifre não é asa - Guto Lima.mp4',
            fullPath:
                r'C:\Novas Musicas\Karaokê - Chifre não é asa - Guto Lima.mp4',
            relativePath: 'Karaokê - Chifre não é asa - Guto Lima.mp4',
          ),
          IncomingSongScannedFile(
            fileName: 'Chifre não é asa - Guto Lima - Karaokê.mp4',
            fullPath:
                r'C:\Novas Musicas\Chifre não é asa - Guto Lima - Karaokê.mp4',
            relativePath: 'Chifre não é asa - Guto Lima - Karaokê.mp4',
          ),
          IncomingSongScannedFile(
            fileName: 'Musica Normal - Artista.mp4',
            fullPath: r'C:\Novas Musicas\Musica Normal - Artista.mp4',
            relativePath: 'Musica Normal - Artista.mp4',
          ),
        ],
        warnings: const [],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          folderPickerService: fakePickerService,
          incomingSongsScanService: fakeScanService,
        ),
      ),
    );

    final selectButton = find.text('Selecionar pasta de musicas novas');
    await tester.ensureVisible(selectButton);
    await tester.tap(selectButton);
    await tester.pumpAndSettle();

    final scanButton = find.text('Escanear músicas novas');
    await tester.ensureVisible(scanButton);
    await tester.tap(scanButton);
    await tester.pumpAndSettle();

    final cleanButton = find.text('Gerar pré-limpeza dos nomes');
    await tester.ensureVisible(cleanButton);
    await tester.tap(cleanButton);
    await tester.pumpAndSettle();

    expect(find.text('Pré-limpeza de nomes gerada.'), findsOneWidget);
    expect(find.text('Pré-limpeza dos nomes'), findsOneWidget);
    expect(find.text('Arquivos analisados: 3'), findsOneWidget);
    expect(find.text('Nomes alterados: 2'), findsOneWidget);
    expect(find.text('Nomes sem alteração: 1'), findsOneWidget);
    expect(find.text('Regras aplicadas:'), findsWidgets);
    expect(find.text('Chifre não é asa - Guto Lima.mp4'), findsWidgets);
  });

  testWidgets('gera sugestoes de importacao e exibe resultado', (
    WidgetTester tester,
  ) async {
    final fakePicker = _FakeFolderPickerService(
      [SelectedFolder(path: 'C:/Biblioteca Oficial')],
      incomingResponses: [SelectedFolder(path: 'C:/Novas Musicas')],
    );
    final fakeIndexResult = BaseLibraryIndexer().indexScannedFiles([
      BaseLibraryScannedFile(
        fileName: 'Legiao Urbana - Tempo Perdido - 00001.mp4',
        fullPath: r'C:\Biblioteca\Legiao Urbana - Tempo Perdido - 00001.mp4',
        relativePath: 'Legiao Urbana - Tempo Perdido - 00001.mp4',
      ),
      BaseLibraryScannedFile(
        fileName: 'Capital Inicial - Primeiros Erros - 00002.mp4',
        fullPath:
            r'C:\Biblioteca\Capital Inicial - Primeiros Erros - 00002.mp4',
        relativePath: 'Capital Inicial - Primeiros Erros - 00002.mp4',
      ),
    ]);
    final fakeOfficialScanService = _FakeOfficialLibraryScanService(
      fakeIndexResult,
    );
    final fakeIncomingScanService = _FakeIncomingSongsScanService(
      IncomingSongsScanResult(
        files: [
          IncomingSongScannedFile(
            fileName: 'Karaokê - Pais e Filhos - Legiao Urbana.mp4',
            fullPath: r'C:\Novas\Karaokê - Pais e Filhos - Legiao Urbana.mp4',
            relativePath: 'Karaokê - Pais e Filhos - Legiao Urbana.mp4',
          ),
        ],
        warnings: const [],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          folderPickerService: fakePicker,
          officialLibraryScanService: fakeOfficialScanService,
          incomingSongsScanService: fakeIncomingScanService,
        ),
      ),
    );

    final selectOfficialButton = find.text('Selecionar biblioteca oficial');
    await tester.ensureVisible(selectOfficialButton);
    await tester.tap(selectOfficialButton);
    await tester.pumpAndSettle();

    final indexButton = find.text('Indexar biblioteca oficial');
    await tester.ensureVisible(indexButton);
    await tester.tap(indexButton);
    await tester.pumpAndSettle();

    final selectIncomingButton = find.text('Selecionar pasta de musicas novas');
    await tester.ensureVisible(selectIncomingButton);
    await tester.tap(selectIncomingButton);
    await tester.pumpAndSettle();

    final scanButton = find.text('Escanear músicas novas');
    await tester.ensureVisible(scanButton);
    await tester.tap(scanButton);
    await tester.pumpAndSettle();

    final cleanButton = find.text('Gerar pré-limpeza dos nomes');
    await tester.ensureVisible(cleanButton);
    await tester.tap(cleanButton);
    await tester.pumpAndSettle();

    final suggestButton = find.text('Gerar sugestões de importação');
    await tester.ensureVisible(suggestButton);
    await tester.tap(suggestButton);
    await tester.pumpAndSettle();

    expect(find.text('Sugestões de importação geradas.'), findsOneWidget);
    expect(find.text('Sugestões de importação'), findsOneWidget);
    expect(find.text('Total: 1'), findsOneWidget);
    expect(find.text('Revisão necessária: 1'), findsOneWidget);
    expect(
      find.textContaining('Legiao Urbana - Pais e Filhos - 00003.mp4'),
      findsOneWidget,
    );
  });

  testWidgets('revisao visual organizada dos candidatos de importacao', (
    WidgetTester tester,
  ) async {
    final fakePicker = _FakeFolderPickerService(
      [SelectedFolder(path: 'C:/Biblioteca Oficial')],
      incomingResponses: [SelectedFolder(path: 'C:/Novas Musicas')],
    );
    final fakeIndexResult = BaseLibraryIndexer().indexScannedFiles([
      BaseLibraryScannedFile(
        fileName: 'Legiao Urbana - Tempo Perdido - 00001.mp4',
        fullPath: r'C:\Biblioteca\Legiao Urbana - Tempo Perdido - 00001.mp4',
        relativePath: 'Legiao Urbana - Tempo Perdido - 00001.mp4',
      ),
      BaseLibraryScannedFile(
        fileName: 'Capital Inicial - Primeiros Erros - 00002.mp4',
        fullPath:
            r'C:\Biblioteca\Capital Inicial - Primeiros Erros - 00002.mp4',
        relativePath: 'Capital Inicial - Primeiros Erros - 00002.mp4',
      ),
    ]);
    final fakeOfficialScanService = _FakeOfficialLibraryScanService(
      fakeIndexResult,
    );
    final fakeIncomingScanService = _FakeIncomingSongsScanService(
      IncomingSongsScanResult(
        files: [
          IncomingSongScannedFile(
            fileName: 'Legiao Urbana - Musica Nova.mp4',
            fullPath: r'C:\Novas\Legiao Urbana - Musica Nova.mp4',
            relativePath: 'Legiao Urbana - Musica Nova.mp4',
          ),
          IncomingSongScannedFile(
            fileName: 'Musica Ambigua - Legiao Urbana.mp4',
            fullPath: r'C:\Novas\Musica Ambigua - Legiao Urbana.mp4',
            relativePath: 'Musica Ambigua - Legiao Urbana.mp4',
          ),
          IncomingSongScannedFile(
            fileName: 'ArquivoSemSeparador.mp4',
            fullPath: r'C:\Novas\ArquivoSemSeparador.mp4',
            relativePath: 'ArquivoSemSeparador.mp4',
          ),
          IncomingSongScannedFile(
            fileName: 'Capital Inicial - Primeiros Erros.mp4',
            fullPath: r'C:\Novas\Capital Inicial - Primeiros Erros.mp4',
            relativePath: 'Capital Inicial - Primeiros Erros.mp4',
          ),
        ],
        warnings: const [],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          folderPickerService: fakePicker,
          officialLibraryScanService: fakeOfficialScanService,
          incomingSongsScanService: fakeIncomingScanService,
        ),
      ),
    );

    await tester.ensureVisible(find.text('Selecionar biblioteca oficial'));
    await tester.tap(find.text('Selecionar biblioteca oficial'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Indexar biblioteca oficial'));
    await tester.tap(find.text('Indexar biblioteca oficial'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Selecionar pasta de musicas novas'));
    await tester.tap(find.text('Selecionar pasta de musicas novas'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Escanear músicas novas'));
    await tester.tap(find.text('Escanear músicas novas'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Gerar pré-limpeza dos nomes'));
    await tester.tap(find.text('Gerar pré-limpeza dos nomes'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Gerar sugestões de importação'));
    await tester.tap(find.text('Gerar sugestões de importação'));
    await tester.pumpAndSettle();

    expect(find.text('Revisão dos candidatos'), findsOneWidget);
    expect(find.textContaining('Prontos para importar: 1'), findsOneWidget);
    expect(find.textContaining('Precisam de revisão: 2'), findsOneWidget);
    expect(find.textContaining('Bloqueados: 1'), findsWidgets);
    expect(find.text('Possíveis duplicados: 1'), findsWidgets);

    expect(find.text('Pronto para importar'), findsOneWidget);
    expect(
      find.text(
        'Nome oficial sugerido: Legiao Urbana - Musica Nova - 00003.mp4',
      ),
      findsOneWidget,
    );

    expect(find.text('Revisão necessária'), findsWidgets);
    expect(
      find.textContaining('Ordem Música - Autor detectada e invertida'),
      findsOneWidget,
    );

    expect(find.text('Bloqueado'), findsOneWidget);

    // toggle: ocultar prontos
    final ocultarProntosButton = find.text('Ocultar prontos');
    await tester.ensureVisible(ocultarProntosButton);
    await tester.tap(ocultarProntosButton);
    await tester.pumpAndSettle();

    expect(find.text('Pronto para importar'), findsNothing);
    expect(find.text('Mostrar prontos'), findsOneWidget);

    // toggle: mostrar duplicados
    final mostrarDuplicadosButton = find.text('Mostrar duplicados');
    await tester.ensureVisible(mostrarDuplicadosButton);
    await tester.tap(mostrarDuplicadosButton);
    await tester.pumpAndSettle();

    expect(find.text('Possível duplicado'), findsOneWidget);
    expect(
      find.textContaining('Capital Inicial - Primeiros Erros (00002)'),
      findsOneWidget,
    );
  });
}
