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
import 'package:studiobox_music_importer/src/features/output_plan/application/output_plan_application.dart';
import 'package:studiobox_music_importer/src/features/output_plan/domain/output_plan.dart';
import 'package:studiobox_music_importer/src/features/session_cache/application/session_cache_application.dart';
import 'package:studiobox_music_importer/src/features/session_cache/domain/session_cache.dart';

class _FakeFolderPickerService extends FolderPickerService {
  _FakeFolderPickerService(
    List<SelectedFolder?> officialResponses, {
    List<SelectedFolder?> incomingResponses = const [],
    List<SelectedFolder?> outputResponses = const [],
    List<SelectedFolder?> manifestResponses = const [],
  }) : _officialResponses = officialResponses,
       _incomingResponses = incomingResponses,
       _outputResponses = outputResponses,
       _manifestResponses = manifestResponses;

  final List<SelectedFolder?> _officialResponses;
  final List<SelectedFolder?> _incomingResponses;
  final List<SelectedFolder?> _outputResponses;
  final List<SelectedFolder?> _manifestResponses;
  int _officialIndex = 0;
  int _incomingIndex = 0;
  int _outputIndex = 0;
  int _manifestIndex = 0;

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

  @override
  Future<SelectedFolder?> pickImportOutputFolder() async {
    if (_outputIndex >= _outputResponses.length) {
      return null;
    }
    final response = _outputResponses[_outputIndex];
    _outputIndex++;
    return response;
  }

  @override
  Future<SelectedFolder?> pickImportManifestFolder() async {
    if (_manifestIndex >= _manifestResponses.length) {
      return null;
    }
    final response = _manifestResponses[_manifestIndex];
    _manifestIndex++;
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

class _FakeImportOperationExecutor extends ImportOperationExecutor {
  _FakeImportOperationExecutor(this.result);

  final ImportOperationExecutionResult result;
  int callCount = 0;

  @override
  Future<ImportOperationExecutionResult> execute(
    ImportOperationDryRunPlan dryRunPlan,
  ) async {
    callCount++;
    return result;
  }
}

class _FakeImportOperationManifestWriter extends ImportOperationManifestWriter {
  _FakeImportOperationManifestWriter(this.result);

  final ImportOperationManifestWriteResult result;
  int callCount = 0;

  @override
  Future<ImportOperationManifestWriteResult> writeJson({
    required ImportOperationManifest manifest,
    required String folderPath,
  }) async {
    callCount++;
    return result;
  }
}

class _FakeAppSessionCacheService extends AppSessionCacheService {
  _FakeAppSessionCacheService({required AppSessionSnapshot initialSnapshot})
    : _snapshot = initialSnapshot;

  AppSessionSnapshot _snapshot;
  int saveCount = 0;
  int clearCount = 0;
  AppSessionSnapshot? lastSavedSnapshot;

  @override
  Future<AppSessionSnapshot> loadSnapshot() async => _snapshot;

  @override
  Future<void> saveSnapshot(AppSessionSnapshot snapshot) async {
    saveCount++;
    lastSavedSnapshot = snapshot;
    _snapshot = snapshot.copyWith(
      savedAtIso8601: snapshot.savedAtIso8601 ?? '2026-05-05T12:00:00.000Z',
    );
  }

  @override
  Future<void> clearSnapshot() async {
    clearCount++;
    _snapshot = AppSessionSnapshot(
      officialLibraryFolderPath: null,
      incomingSongsFolderPath: null,
      customImportOutputFolderPath: null,
      importManifestFolderPath: null,
      importOutputModeName: null,
      savedAtIso8601: null,
    );
  }
}

Future<void> tapFirstTextContaining(WidgetTester tester, String text) async {
  final finder = find.textContaining(text);
  expect(finder, findsAtLeastNWidgets(1));
  await tester.ensureVisible(finder.first);
  await tester.pumpAndSettle();
  await tester.tap(finder.first);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders StudioBox Music Importer shell', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const StudioBoxMusicImporterApp());

    expect(find.text('StudioBox Music Importer'), findsWidgets);
    expect(
      find.text('Prepare novas musicas para o padrao do Karaoke StudioBox.'),
      findsAtLeastNWidgets(1),
    );
    expect(find.textContaining('Biblioteca oficial'), findsAtLeastNWidgets(1));
    expect(find.text('Novas musicas'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Revisao'), findsAtLeastNWidgets(1));
    expect(find.text('Saida'), findsAtLeastNWidgets(1));
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

  testWidgets('mostra dashboard redesenhado da Home', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const StudioBoxMusicImporterApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('StudioBox Music Importer'), findsWidgets);
    expect(find.textContaining('Round 35D10B'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Fluxo seguro'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Dashboard'), findsAtLeastNWidgets(1));
    expect(
      find.textContaining('1. Biblioteca oficial'),
      findsAtLeastNWidgets(1),
    );
    expect(
      find.textContaining('Biblioteca oficial selecionada:'),
      findsAtLeastNWidgets(1),
    );
    expect(
      find.textContaining('Selecionar biblioteca oficial'),
      findsAtLeastNWidgets(1),
    );
    expect(
      find.textContaining('Indexar biblioteca oficial'),
      findsAtLeastNWidgets(1),
    );
    expect(find.textContaining('Musicas validas'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Arquivos invalidos'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Duplicados'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Maior codigo'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Buracos disponiveis'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Artistas conhecidos'), findsAtLeastNWidgets(1));
    expect(find.textContaining('2. Musicas novas'), findsAtLeastNWidgets(1));
    expect(
      find.textContaining('Pasta de musicas novas selecionada:'),
      findsAtLeastNWidgets(1),
    );
    expect(
      find.textContaining('Selecionar pasta de musicas novas'),
      findsAtLeastNWidgets(1),
    );
    expect(find.textContaining('Escanear musicas novas'), findsNothing);
    expect(find.textContaining('Arquivos escaneados'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Avisos'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Pre-limpeza'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Sugestoes'), findsAtLeastNWidgets(1));
    expect(find.textContaining('2. Musicas novas'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Resumo da sessao'), findsAtLeastNWidgets(1));
    expect(
      find.textContaining('Cache local da sessao'),
      findsAtLeastNWidgets(1),
    );
    expect(find.textContaining('Motor e status'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Status do projeto'), findsAtLeastNWidgets(1));
    expect(
      find.textContaining('1. Biblioteca oficial'),
      findsAtLeastNWidgets(1),
    );
    expect(find.textContaining('2. Musicas novas'), findsAtLeastNWidgets(1));
    expect(
      find.textContaining('1 Biblioteca oficial 2 Musicas novas'),
      findsNothing,
    );
  });

  testWidgets('mostra fundacao visual do dashboard', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const StudioBoxMusicImporterApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('StudioBox Music Importer'), findsWidgets);
    expect(find.textContaining('Round 35'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Fluxo seguro'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Dashboard'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Biblioteca'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Novas musicas'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Revisao'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Saida'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Execucao'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Manifesto'), findsAtLeastNWidgets(1));
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

      expect(find.text('C:/Biblioteca Oficial'), findsWidgets);
      expect(find.text('Biblioteca oficial selecionada.'), findsOneWidget);

      await tester.ensureVisible(buttonFinder);
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      expect(find.text('C:/Biblioteca Oficial'), findsWidgets);
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
    expect(find.textContaining('Musicas validas'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Arquivos invalidos'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Maior codigo'), findsAtLeastNWidgets(1));
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
      BaseLibraryScannedFile(
        fileName: 'Pais e Filhos - Legiao Urbana.mp4',
        fullPath: r'C:\Biblioteca\Pais e Filhos - Legiao Urbana.mp4',
        relativePath: 'Pais e Filhos - Legiao Urbana.mp4',
      ),
      BaseLibraryScannedFile(
        fileName: 'Tribalistas - Velha Infancia - Marisa Monte.mp4',
        fullPath:
            r'C:\Biblioteca\Tribalistas - Velha Infancia - Marisa Monte.mp4',
        relativePath: 'Tribalistas - Velha Infancia - Marisa Monte.mp4',
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
    expect(find.textContaining('Bloquead'), findsAtLeastNWidgets(1));

    expect(find.text('Arquivo atual:'), findsWidgets);
    expect(find.text('Motivo original:'), findsWidgets);
    expect(find.textContaining('Status: Revis'), findsWidgets);
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
        fileName: 'Legiao Urbana - Tempo Perdido - 00001.mp4',
        fullPath: r'C:\Musicas\Legiao Urbana - Tempo Perdido - 00001.mp4',
        relativePath: 'Legiao Urbana - Tempo Perdido - 00001.mp4',
      ),
      BaseLibraryScannedFile(
        fileName: 'Capital Inicial - Primeiros Erros - 00002.mp4',
        fullPath: r'C:\Musicas\Capital Inicial - Primeiros Erros - 00002.mp4',
        relativePath: 'Capital Inicial - Primeiros Erros - 00002.mp4',
      ),
      BaseLibraryScannedFile(
        fileName: 'Legiao Urbana - Pais e Filhos.mp4',
        fullPath: r'C:\Musicas\Legiao Urbana - Pais e Filhos.mp4',
        relativePath: 'Legiao Urbana - Pais e Filhos.mp4',
      ),
      BaseLibraryScannedFile(
        fileName: 'Pais e Filhos - Legiao Urbana.mp4',
        fullPath: r'C:\Musicas\Pais e Filhos - Legiao Urbana.mp4',
        relativePath: 'Pais e Filhos - Legiao Urbana.mp4',
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
        fileName: 'Legiao Urbana - Tempo Perdido - 00001.mp4',
        fullPath: r'C:\Musicas\Legiao Urbana - Tempo Perdido - 00001.mp4',
        relativePath: 'Legiao Urbana - Tempo Perdido - 00001.mp4',
      ),
      BaseLibraryScannedFile(
        fileName: 'Capital Inicial - Primeiros Erros - 00002.mp4',
        fullPath: r'C:\Musicas\Capital Inicial - Primeiros Erros - 00002.mp4',
        relativePath: 'Capital Inicial - Primeiros Erros - 00002.mp4',
      ),
      BaseLibraryScannedFile(
        fileName: 'Legiao Urbana - Pais e Filhos.mp4',
        fullPath: r'C:\Musicas\Legiao Urbana - Pais e Filhos.mp4',
        relativePath: 'Legiao Urbana - Pais e Filhos.mp4',
      ),
      BaseLibraryScannedFile(
        fileName: 'Pais e Filhos - Legiao Urbana.mp4',
        fullPath: r'C:\Musicas\Pais e Filhos - Legiao Urbana.mp4',
        relativePath: 'Pais e Filhos - Legiao Urbana.mp4',
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
            originalFileName: 'Legiao Urbana - Pais e Filhos.mp4',
            originalReason: 'Fora do padrao',
            detectedArtist: 'Legiao Urbana',
            detectedTitle: 'Pais e Filhos',
            suggestedCode: '00003',
            sourcePath: r'C:\Musicas\Legiao Urbana - Pais e Filhos.mp4',
            destinationPath:
                r'C:\Musicas\Legiao Urbana - Pais e Filhos - 00003.mp4',
            suggestedFileName: 'Legiao Urbana - Pais e Filhos - 00003.mp4',
            status: InvalidFileRepairExecutionResultItemStatus.renamed,
            messages: const ['Arquivo renomeado com sucesso.'],
          ),
          InvalidFileRepairExecutionResultItem(
            originalFileName: 'Pais e Filhos - Legiao Urbana.mp4',
            originalReason: 'Fora do padrao',
            detectedArtist: 'Legiao Urbana',
            detectedTitle: 'Pais e Filhos',
            suggestedCode: null,
            sourcePath: r'C:\Musicas\Pais e Filhos - Legiao Urbana.mp4',
            destinationPath: null,
            suggestedFileName: null,
            status: InvalidFileRepairExecutionResultItemStatus.skipped,
            messages: const ['Item ignorado porque precisa de revisao manual.'],
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
          fileName: 'Legiao Urbana - Tempo Perdido - 00001.mp4',
          fullPath: r'C:\Musicas\Legiao Urbana - Tempo Perdido - 00001.mp4',
          relativePath: 'Legiao Urbana - Tempo Perdido - 00001.mp4',
        ),
        BaseLibraryScannedFile(
          fileName: 'Legiao Urbana - Pais e Filhos.mp4',
          fullPath: r'C:\Musicas\Legiao Urbana - Pais e Filhos.mp4',
          relativePath: 'Legiao Urbana - Pais e Filhos.mp4',
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
      findsAtLeastNWidgets(1),
    );

    final buttonFinder = find.text('Selecionar pasta de musicas novas');
    await tester.ensureVisible(buttonFinder.first);
    await tester.tap(buttonFinder.first);
    await tester.pumpAndSettle();

    expect(find.text('C:/Novas Musicas'), findsWidgets);
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
            fullPath: r'C:\fake\incoming\Artista A - Musica A.mp4',
            relativePath: 'Artista A - Musica A.mp4',
          ),
          IncomingSongScannedFile(
            fileName: 'Artista B - Musica B.mp4',
            fullPath: r'C:\fake\incoming\Artista B - Musica B.mp4',
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

    expect(find.text('C:/Novas Musicas'), findsWidgets);

    await tapFirstTextContaining(tester, 'Escanear musicas novas');

    expect(find.textContaining('escaneada'), findsAtLeastNWidgets(1));
    expect(find.textContaining('encontradas: 2'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Arquivos escaneados'), findsAtLeastNWidgets(1));
  });

  testWidgets(
    'botao escanear nao aparece sem pasta de musicas novas selecionada',
    (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: HomeScreen()));

      expect(
        find.text('Nenhuma pasta de musicas novas selecionada.'),
        findsAtLeastNWidgets(1),
      );
      expect(find.textContaining('Escanear'), findsNothing);
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

    await tester.ensureVisible(buttonFinder.first);
    await tester.tap(buttonFinder.first);
    await tester.pumpAndSettle();

    expect(find.text('C:/Novas Musicas'), findsWidgets);

    await tester.ensureVisible(buttonFinder.first);
    await tester.tap(buttonFinder.first);
    await tester.pumpAndSettle();

    expect(find.text('C:/Novas Musicas'), findsWidgets);
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
            fileName: 'Karaoke - Chifre nao e asa - Guto Lima.mp4',
            fullPath:
                r'C:\Novas Musicas\Karaoke - Chifre nao e asa - Guto Lima.mp4',
            relativePath: 'Karaoke - Chifre nao e asa - Guto Lima.mp4',
          ),
          IncomingSongScannedFile(
            fileName: 'Chifre nao e asa - Guto Lima - Karaoke.mp4',
            fullPath:
                r'C:\Novas Musicas\Chifre nao e asa - Guto Lima - Karaoke.mp4',
            relativePath: 'Chifre nao e asa - Guto Lima - Karaoke.mp4',
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
    await tester.ensureVisible(selectButton.first);
    await tester.tap(selectButton.first);
    await tester.pumpAndSettle();

    await tapFirstTextContaining(tester, 'Escanear');

    final cleanButton = find.textContaining('limpeza');
    expect(cleanButton, findsAtLeastNWidgets(1));
    await tester.ensureVisible(cleanButton.first);
    await tester.tap(cleanButton.first);
    await tester.pumpAndSettle();

    expect(find.textContaining('Pre-limpeza'), findsAtLeastNWidgets(1));
    expect(
      find.textContaining('Gerar sugestoes de importacao'),
      findsAtLeastNWidgets(1),
    );
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
            fileName: 'Karaoke - Pais e Filhos - Legiao Urbana.mp4',
            fullPath: r'C:\Novas\Karaoke - Pais e Filhos - Legiao Urbana.mp4',
            relativePath: 'Karaoke - Pais e Filhos - Legiao Urbana.mp4',
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
    await tester.ensureVisible(selectIncomingButton.first);
    await tester.tap(selectIncomingButton.first);
    await tester.pumpAndSettle();

    await tapFirstTextContaining(tester, 'Escanear musicas novas');

    final cleanButton = find.textContaining('limpeza');
    expect(cleanButton, findsAtLeastNWidgets(1));
    await tester.ensureVisible(cleanButton.first);
    await tester.tap(cleanButton.first);
    await tester.pumpAndSettle();

    await tapFirstTextContaining(tester, 'Gerar sugestoes de importacao');

    expect(find.textContaining('geradas.'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Sugest'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Total'), findsAtLeastNWidgets(1));
    expect(find.textContaining('necess'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Pais e Filhos -'), findsWidgets);
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

    await tester.ensureVisible(
      find.text('Selecionar pasta de musicas novas').first,
    );
    await tester.tap(find.text('Selecionar pasta de musicas novas').first);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.textContaining('Escanear'));
    await tester.tap(find.textContaining('Escanear'));
    await tester.pumpAndSettle();

    await tapFirstTextContaining(tester, 'Gerar pre-limpeza dos nomes');

    await tapFirstTextContaining(tester, 'Gerar sugestoes de importacao');

    expect(find.textContaining('candidatos'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Prontos'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Revisao'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Bloquead'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Duplicad'), findsAtLeastNWidgets(1));

    expect(find.textContaining('Selecionar'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Status'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Arquivo'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Artista'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Musica'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Nome oficial'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Avisos'), findsAtLeastNWidgets(1));
    expect(
      find.textContaining('Legiao Urbana - Musica Nova'),
      findsAtLeastNWidgets(1),
    );
    expect(
      find.textContaining('Capital Inicial - Primeiros Erros'),
      findsAtLeastNWidgets(1),
    );
    expect(find.textContaining('invertida'), findsAtLeastNWidgets(1));
  });

  testWidgets('edicao manual dos candidatos em memoria', (
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

    await tapFirstTextContaining(tester, 'Selecionar biblioteca oficial');
    await tapFirstTextContaining(tester, 'Indexar biblioteca oficial');
    await tapFirstTextContaining(tester, 'Selecionar pasta de musicas novas');
    await tapFirstTextContaining(tester, 'Escanear musicas novas');
    await tapFirstTextContaining(tester, 'Gerar pre-limpeza dos nomes');
    await tapFirstTextContaining(tester, 'Gerar sugestoes de importacao');

    expect(
      find.textContaining('Mostrar Edicao manual'),
      findsAtLeastNWidgets(1),
    );

    await tapFirstTextContaining(tester, 'Mostrar Edicao manual');

    expect(find.textContaining('Edicao manual'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Valid'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Invalid'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Nome oficial'), findsAtLeastNWidgets(1));

    await tester.ensureVisible(
      find.byKey(const ValueKey('import-edit-artist-0')),
    );
    await tester.enterText(
      find.byKey(const ValueKey('import-edit-artist-0')),
      'Novo Artista',
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Novo Artista -'), findsAtLeastNWidgets(1));

    await tester.ensureVisible(
      find.byKey(const ValueKey('import-edit-code-0')),
    );
    await tester.enterText(
      find.byKey(const ValueKey('import-edit-code-0')),
      '12A45',
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Invalido'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Codigo invalido'), findsAtLeastNWidgets(1));
  });

  testWidgets('modo de saida da importacao em memoria', (
    WidgetTester tester,
  ) async {
    final fakePicker = _FakeFolderPickerService(
      [SelectedFolder(path: 'C:/Biblioteca Oficial')],
      incomingResponses: [SelectedFolder(path: 'C:/Novas Musicas')],
      outputResponses: [SelectedFolder(path: 'C:/Saida Importacao')],
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

    await tapFirstTextContaining(tester, 'Selecionar biblioteca oficial');
    await tapFirstTextContaining(tester, 'Indexar biblioteca oficial');
    await tapFirstTextContaining(tester, 'Selecionar pasta de musicas novas');
    await tapFirstTextContaining(tester, 'Escanear musicas novas');
    await tapFirstTextContaining(tester, 'Gerar pre-limpeza dos nomes');
    await tapFirstTextContaining(tester, 'Gerar sugestoes de importacao');
    await tapFirstTextContaining(tester, 'Selecionar todos os prontos');

    expect(find.textContaining('Modo de saida da importacao'), findsWidgets);
    expect(
      find.textContaining('Renomear na pasta de musicas novas'),
      findsWidgets,
    );
    expect(
      find.textContaining('Validar configuracao de saida'),
      findsAtLeastNWidgets(1),
    );
    final modeDropdown = find.byType(DropdownButtonFormField<ImportOutputMode>);
    await tester.ensureVisible(modeDropdown);
    await tester.tap(modeDropdown);
    await tester.pumpAndSettle();
    expect(find.textContaining('Copiar para biblioteca oficial'), findsWidgets);
    expect(find.textContaining('Mover para biblioteca oficial'), findsWidgets);
    expect(find.textContaining('Copiar para pasta de saida'), findsWidgets);
    expect(find.textContaining('Mover para pasta de saida'), findsWidgets);
    await tester.tap(find.text('Copiar para pasta de saida').last);
    await tester.pumpAndSettle();

    expect(find.textContaining('Selecionar pasta de saida'), findsWidgets);
    await tapFirstTextContaining(tester, 'Selecionar pasta de saida');
    expect(find.textContaining('Pasta de saida selecionada.'), findsWidgets);
    expect(find.textContaining('C:/Saida Importacao'), findsWidgets);

    final selectionCheckbox = find.byType(Checkbox).first;
    await tester.ensureVisible(selectionCheckbox);
    final checkboxBefore = tester.widget<Checkbox>(selectionCheckbox);
    if (checkboxBefore.value != true) {
      await tester.tap(selectionCheckbox, warnIfMissed: false);
      await tester.pumpAndSettle();
    }

    await tapFirstTextContaining(tester, 'Validar configuracao de saida');
    expect(
      find.textContaining('Configuracao de saida validada.'),
      findsWidgets,
    );
    expect(
      find.textContaining('Configuracao de saida valida.'),
      findsAtLeastNWidgets(1),
    );
  });

  testWidgets('gera dry-run da importacao com destino customizado', (
    WidgetTester tester,
  ) async {
    final fakePicker = _FakeFolderPickerService(
      [SelectedFolder(path: 'C:/Biblioteca Oficial')],
      incomingResponses: [SelectedFolder(path: 'C:/Novas Musicas')],
      outputResponses: [SelectedFolder(path: 'C:/Saida Importacao')],
    );
    final fakeIndexResult = BaseLibraryIndexer().indexScannedFiles([
      BaseLibraryScannedFile(
        fileName: 'Legiao Urbana - Tempo Perdido - 00001.mp4',
        fullPath: r'C:\Biblioteca\Legiao Urbana - Tempo Perdido - 00001.mp4',
        relativePath: 'Legiao Urbana - Tempo Perdido - 00001.mp4',
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

    await tapFirstTextContaining(tester, 'Selecionar biblioteca oficial');
    await tapFirstTextContaining(tester, 'Indexar biblioteca oficial');
    await tapFirstTextContaining(tester, 'Selecionar pasta de musicas novas');
    await tapFirstTextContaining(tester, 'Escanear musicas novas');
    await tapFirstTextContaining(tester, 'Gerar pre-limpeza dos nomes');
    await tapFirstTextContaining(tester, 'Gerar sugestoes de importacao');
    await tapFirstTextContaining(tester, 'Selecionar todos os prontos');

    final modeDropdown = find.byType(DropdownButtonFormField<ImportOutputMode>);
    await tester.ensureVisible(modeDropdown);
    await tester.tap(modeDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Copiar para pasta de saida').last);
    await tester.pumpAndSettle();

    await tapFirstTextContaining(tester, 'Selecionar pasta de saida');
    await tapFirstTextContaining(tester, 'Validar configuracao de saida');
    await tapFirstTextContaining(tester, 'Gerar dry-run da importacao');

    expect(
      find.textContaining('Dry-run da operacao de importacao'),
      findsAtLeastNWidgets(1),
    );
    expect(find.textContaining('Total de operacoes:'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Prontas:'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Bloqueadas:'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Acao:'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Origem:'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Destino:'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Nome oficial:'), findsAtLeastNWidgets(1));
    expect(find.textContaining('C:/Saida Importacao'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Dry-run da importacao gerado.'), findsWidgets);
  });

  testWidgets('executa importacao real com confirmacao forte', (
    WidgetTester tester,
  ) async {
    final fakePicker = _FakeFolderPickerService(
      [SelectedFolder(path: 'C:/Biblioteca Oficial')],
      incomingResponses: [SelectedFolder(path: 'C:/Novas Musicas')],
      outputResponses: [SelectedFolder(path: 'C:/Saida Importacao')],
    );
    final fakeIndexResult = BaseLibraryIndexer().indexScannedFiles([
      BaseLibraryScannedFile(
        fileName: 'Legiao Urbana - Tempo Perdido - 00001.mp4',
        fullPath: r'C:\Biblioteca\Legiao Urbana - Tempo Perdido - 00001.mp4',
        relativePath: 'Legiao Urbana - Tempo Perdido - 00001.mp4',
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
        ],
        warnings: const [],
      ),
    );
    final fakeImportExecutor = _FakeImportOperationExecutor(
      ImportOperationExecutionResult(
        items: [
          ImportOperationExecutionResultItem(
            id: 'item-1',
            action: ImportOperationAction.copy,
            status: ImportOperationExecutionResultItemStatus.copied,
            originalFileName: 'Legiao Urbana - Musica Nova.mp4',
            officialFileName: 'Legiao Urbana - Musica Nova - 00002.mp4',
            sourcePath: r'C:\Novas\Legiao Urbana - Musica Nova.mp4',
            destinationPath:
                'C:/Saida Importacao/Legiao Urbana - Musica Nova - 00002.mp4',
            messages: const ['Arquivo copiado com sucesso.'],
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
          importOperationExecutor: fakeImportExecutor,
        ),
      ),
    );

    await tapFirstTextContaining(tester, 'Selecionar biblioteca oficial');
    await tapFirstTextContaining(tester, 'Indexar biblioteca oficial');
    await tapFirstTextContaining(tester, 'Selecionar pasta de musicas novas');
    await tapFirstTextContaining(tester, 'Escanear musicas novas');
    await tapFirstTextContaining(tester, 'Gerar pre-limpeza dos nomes');
    await tapFirstTextContaining(tester, 'Gerar sugestoes de importacao');
    await tapFirstTextContaining(tester, 'Selecionar todos os prontos');
    await tapFirstTextContaining(tester, 'Validar configuracao de saida');
    await tapFirstTextContaining(tester, 'Gerar dry-run da importacao');

    expect(
      find.textContaining(
        'Confirmacao obrigatoria para executar importacao real',
      ),
      findsAtLeastNWidgets(1),
    );

    final confirmCheckbox = find.byType(Checkbox).last;
    await tester.ensureVisible(confirmCheckbox);
    await tester.tap(confirmCheckbox, warnIfMissed: false);
    await tester.pumpAndSettle();

    final confirmField = find.widgetWithText(
      TextField,
      'Digite IMPORTAR para liberar a execucao',
    );
    await tester.ensureVisible(confirmField);
    await tester.enterText(confirmField, 'IMPORTAR');
    await tester.pumpAndSettle();

    await tapFirstTextContaining(tester, 'Executar importacao real');
    expect(find.textContaining('Confirmar importacao real'), findsOneWidget);
    await tester.tap(find.text('Executar importacao real').last);
    await tester.pumpAndSettle();

    expect(fakeImportExecutor.callCount, 1);
    expect(
      find.textContaining('Resultado da execucao da importacao'),
      findsAtLeastNWidgets(1),
    );
    expect(find.textContaining('Copiados: 1'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Falhas: 0'), findsAtLeastNWidgets(1));
    expect(
      find.textContaining('Reindexe a biblioteca oficial'),
      findsAtLeastNWidgets(1),
    );
  });

  testWidgets('sem IMPORTAR botao de execucao fica desabilitado', (
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
          importOperationExecutor: _FakeImportOperationExecutor(
            const ImportOperationExecutionResult(items: [], warnings: []),
          ),
        ),
      ),
    );

    await tapFirstTextContaining(tester, 'Selecionar biblioteca oficial');
    await tapFirstTextContaining(tester, 'Indexar biblioteca oficial');
    await tapFirstTextContaining(tester, 'Selecionar pasta de musicas novas');
    await tapFirstTextContaining(tester, 'Escanear musicas novas');
    await tapFirstTextContaining(tester, 'Gerar pre-limpeza dos nomes');
    await tapFirstTextContaining(tester, 'Gerar sugestoes de importacao');
    await tapFirstTextContaining(tester, 'Selecionar todos os prontos');
    await tapFirstTextContaining(tester, 'Gerar dry-run da importacao');

    final confirmCheckbox = find.byType(Checkbox).last;
    await tester.ensureVisible(confirmCheckbox);
    await tester.tap(confirmCheckbox, warnIfMissed: false);
    await tester.pumpAndSettle();

    final executeButton = find.widgetWithText(
      FilledButton,
      'Executar importacao real',
    );
    final button = tester.widget<FilledButton>(executeButton);
    expect(button.onPressed, isNull);
  });

  testWidgets('gera e salva manifesto da importacao com writer fake', (
    WidgetTester tester,
  ) async {
    final fakePicker = _FakeFolderPickerService(
      [SelectedFolder(path: 'C:/Biblioteca Oficial')],
      incomingResponses: [SelectedFolder(path: 'C:/Novas Musicas')],
      manifestResponses: [SelectedFolder(path: 'C:/Manifestos')],
    );
    final fakeIndexResult = BaseLibraryIndexer().indexScannedFiles([
      BaseLibraryScannedFile(
        fileName: 'Legiao Urbana - Tempo Perdido - 00001.mp4',
        fullPath: r'C:\Biblioteca\Legiao Urbana - Tempo Perdido - 00001.mp4',
        relativePath: 'Legiao Urbana - Tempo Perdido - 00001.mp4',
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
        ],
        warnings: const [],
      ),
    );
    final fakeImportExecutor = _FakeImportOperationExecutor(
      ImportOperationExecutionResult(
        items: [
          ImportOperationExecutionResultItem(
            id: 'item-1',
            action: ImportOperationAction.copy,
            status: ImportOperationExecutionResultItemStatus.copied,
            originalFileName: 'Legiao Urbana - Musica Nova.mp4',
            officialFileName: 'Legiao Urbana - Musica Nova - 00002.mp4',
            sourcePath: r'C:\Novas\Legiao Urbana - Musica Nova.mp4',
            destinationPath:
                r'C:\Biblioteca\Legiao Urbana - Musica Nova - 00002.mp4',
            messages: const ['Arquivo copiado com sucesso.'],
          ),
        ],
        warnings: const [],
      ),
    );
    final fakeManifestWriter = _FakeImportOperationManifestWriter(
      const ImportOperationManifestWriteResult(
        success: true,
        filePath: 'C:/Manifestos/import-manifest-test.json',
        messages: ['Manifesto JSON salvo com sucesso.'],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          folderPickerService: fakePicker,
          officialLibraryScanService: fakeOfficialScanService,
          incomingSongsScanService: fakeIncomingScanService,
          importOperationExecutor: fakeImportExecutor,
          importOperationManifestWriter: fakeManifestWriter,
        ),
      ),
    );

    await tapFirstTextContaining(tester, 'Selecionar biblioteca oficial');
    await tapFirstTextContaining(tester, 'Indexar biblioteca oficial');
    await tapFirstTextContaining(tester, 'Selecionar pasta de musicas novas');
    await tapFirstTextContaining(tester, 'Escanear musicas novas');
    await tapFirstTextContaining(tester, 'Gerar pre-limpeza dos nomes');
    await tapFirstTextContaining(tester, 'Gerar sugestoes de importacao');
    await tapFirstTextContaining(tester, 'Validar configuracao de saida');
    await tapFirstTextContaining(tester, 'Gerar dry-run da importacao');

    final confirmCheckbox = find.byType(Checkbox).last;
    await tester.ensureVisible(confirmCheckbox);
    await tester.tap(confirmCheckbox, warnIfMissed: false);
    await tester.pumpAndSettle();

    final confirmField = find.widgetWithText(
      TextField,
      'Digite IMPORTAR para liberar a execucao',
    );
    await tester.ensureVisible(confirmField);
    await tester.enterText(confirmField, 'IMPORTAR');
    await tester.pumpAndSettle();

    await tapFirstTextContaining(tester, 'Executar importacao real');
    await tester.tap(find.text('Executar importacao real').last);
    await tester.pumpAndSettle();

    await tapFirstTextContaining(tester, 'Gerar manifesto da importacao');

    expect(find.textContaining('Manifesto da importacao'), findsWidgets);
    expect(find.textContaining('ID:'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Modo de saida:'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Total:'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Sucessos:'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Falhas:'), findsAtLeastNWidgets(1));

    await tapFirstTextContaining(tester, 'Selecionar pasta do manifesto');
    await tapFirstTextContaining(tester, 'Salvar manifesto JSON');

    expect(
      find.textContaining('Manifesto JSON salvo.'),
      findsAtLeastNWidgets(1),
    );
    expect(
      find.textContaining('Resultado do salvamento do manifesto'),
      findsAtLeastNWidgets(1),
    );
    expect(
      find.textContaining('C:/Manifestos/import-manifest-test.json'),
      findsAtLeastNWidgets(1),
    );
    expect(fakeManifestWriter.callCount, 1);
  });

  testWidgets('botao salvar manifesto json desabilitado sem pasta', (
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
          importOperationExecutor: _FakeImportOperationExecutor(
            ImportOperationExecutionResult(
              items: [
                ImportOperationExecutionResultItem(
                  id: 'item-1',
                  action: ImportOperationAction.copy,
                  status: ImportOperationExecutionResultItemStatus.copied,
                  originalFileName: 'Legiao Urbana - Musica Nova.mp4',
                  officialFileName: 'Legiao Urbana - Musica Nova - 00002.mp4',
                  sourcePath: r'C:\Novas\Legiao Urbana - Musica Nova.mp4',
                  destinationPath:
                      r'C:\Biblioteca\Legiao Urbana - Musica Nova - 00002.mp4',
                  messages: const ['Arquivo copiado com sucesso.'],
                ),
              ],
              warnings: const [],
            ),
          ),
          importOperationManifestWriter: _FakeImportOperationManifestWriter(
            const ImportOperationManifestWriteResult(
              success: true,
              filePath: 'x',
              messages: ['ok'],
            ),
          ),
        ),
      ),
    );

    await tapFirstTextContaining(tester, 'Selecionar biblioteca oficial');
    await tapFirstTextContaining(tester, 'Indexar biblioteca oficial');
    await tapFirstTextContaining(tester, 'Selecionar pasta de musicas novas');
    await tapFirstTextContaining(tester, 'Escanear');
    await tapFirstTextContaining(tester, 'Gerar pre-limpeza dos nomes');
    await tapFirstTextContaining(tester, 'Gerar sugestoes de importacao');
    await tapFirstTextContaining(tester, 'Gerar dry-run da importacao');

    final confirmCheckbox = find.byType(Checkbox).last;
    await tester.ensureVisible(confirmCheckbox);
    await tester.tap(confirmCheckbox, warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Digite IMPORTAR para liberar a execucao'),
      'IMPORTAR',
    );
    await tester.pumpAndSettle();
    await tapFirstTextContaining(tester, 'Executar importacao real');
    await tester.tap(find.text('Executar importacao real').last);
    await tester.pumpAndSettle();
    await tapFirstTextContaining(tester, 'Gerar manifesto da importacao');

    final saveButton = find.widgetWithText(
      OutlinedButton,
      'Salvar manifesto JSON',
    );
    final button = tester.widget<OutlinedButton>(saveButton);
    expect(button.onPressed, isNull);
  });

  testWidgets('restaura cache local da sessao ao abrir home', (
    WidgetTester tester,
  ) async {
    final fakeCache = _FakeAppSessionCacheService(
      initialSnapshot: AppSessionSnapshot(
        officialLibraryFolderPath: 'C:/Biblioteca Oficial',
        incomingSongsFolderPath: 'C:/Novas Musicas',
        customImportOutputFolderPath: 'C:/Saida Importacao',
        importManifestFolderPath: 'C:/Manifestos',
        importOutputModeName: 'copyToCustomFolder',
        savedAtIso8601: '2026-05-05T12:00:00.000Z',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(sessionCacheService: fakeCache)),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Cache local da sessao carregado.'),
      findsAtLeastNWidgets(1),
    );
    expect(find.textContaining('C:/Biblioteca Oficial'), findsWidgets);
    expect(find.textContaining('C:/Novas Musicas'), findsWidgets);
    expect(find.textContaining('C:/Saida Importacao'), findsWidgets);
    expect(find.textContaining('C:/Manifestos'), findsWidgets);
  });

  testWidgets('salvar sessao agora chama servico e mostra mensagem', (
    WidgetTester tester,
  ) async {
    final fakeCache = _FakeAppSessionCacheService(
      initialSnapshot: AppSessionSnapshot(
        officialLibraryFolderPath: null,
        incomingSongsFolderPath: null,
        customImportOutputFolderPath: null,
        importManifestFolderPath: null,
        importOutputModeName: null,
        savedAtIso8601: null,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(sessionCacheService: fakeCache)),
    );
    await tester.pumpAndSettle();

    await tapFirstTextContaining(tester, 'Salvar sessao agora');

    expect(fakeCache.saveCount, greaterThanOrEqualTo(1));
    expect(fakeCache.lastSavedSnapshot, isNotNull);
    expect(
      find.textContaining('Cache local da sessao salvo.'),
      findsAtLeastNWidgets(1),
    );
  });

  testWidgets('limpar cache local chama servico e mostra mensagem', (
    WidgetTester tester,
  ) async {
    final fakeCache = _FakeAppSessionCacheService(
      initialSnapshot: AppSessionSnapshot(
        officialLibraryFolderPath: 'C:/Biblioteca Oficial',
        incomingSongsFolderPath: null,
        customImportOutputFolderPath: null,
        importManifestFolderPath: null,
        importOutputModeName: null,
        savedAtIso8601: '2026-05-05T12:00:00.000Z',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(sessionCacheService: fakeCache)),
    );
    await tester.pumpAndSettle();

    await tapFirstTextContaining(tester, 'Limpar cache local');

    expect(fakeCache.clearCount, 1);
    expect(
      find.textContaining('Cache local da sessao limpo.'),
      findsAtLeastNWidgets(1),
    );
  });
}
