import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:studiobox_music_importer/src/app.dart';
import 'package:studiobox_music_importer/src/features/base_library/application/official_library_scan_service.dart';
import 'package:studiobox_music_importer/src/features/base_library/domain/base_library.dart';
import 'package:studiobox_music_importer/src/features/folder_selection/application/folder_picker_service.dart';
import 'package:studiobox_music_importer/src/features/folder_selection/domain/selected_folder.dart';
import 'package:studiobox_music_importer/src/features/home/presentation/home_screen.dart';

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
        fileName: 'Arquivo Fora Do Padrao.mp4',
        fullPath: r'C:\Biblioteca\Sub\Arquivo Fora Do Padrao.mp4',
        relativePath: r'Sub\Arquivo Fora Do Padrao.mp4',
      ),
    ]);
    final fakeScanService = _FakeOfficialLibraryScanService(fakeResult);

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          folderPickerService: fakePicker,
          officialLibraryScanService: fakeScanService,
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

    expect(find.text('Codigo duplicado: 00001'), findsOneWidget);
    expect(find.textContaining('Artista A'), findsWidgets);
    expect(find.textContaining('Artista B'), findsWidgets);
    expect(
      find.textContaining(r'Arquivo: Sub\Artista A - Musica A - 00001.mp4'),
      findsOneWidget,
    );
    expect(
      find.textContaining(r'Arquivo: Sub\Artista B - Musica B - 00001.mp4'),
      findsOneWidget,
    );
  });
}
