import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:studiobox_music_importer/src/app.dart';
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
}
