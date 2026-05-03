import 'package:flutter_test/flutter_test.dart';
import 'package:studiobox_music_importer/src/features/folder_selection/domain/selected_folder.dart';

void main() {
  test('path e trimado no construtor', () {
    final folder = SelectedFolder(path: '  C:/Biblioteca  ');

    expect(folder.path, 'C:/Biblioteca');
  });

  test('isEmpty true para path vazio ou espacos', () {
    final empty = SelectedFolder(path: '');
    final spaces = SelectedFolder(path: '   ');

    expect(empty.isEmpty, isTrue);
    expect(spaces.isEmpty, isTrue);
  });

  test('isEmpty false para path valido', () {
    final folder = SelectedFolder(path: 'C:/Biblioteca');

    expect(folder.isEmpty, isFalse);
  });
}
