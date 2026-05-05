import 'package:file_picker/file_picker.dart';

import '../domain/selected_folder.dart';

class FolderPickerService {
  const FolderPickerService();

  Future<SelectedFolder?> pickOfficialLibraryFolder() async {
    final selectedPath = await FilePicker.getDirectoryPath(
      dialogTitle: 'Selecione a biblioteca oficial',
    );

    if (selectedPath == null || selectedPath.trim().isEmpty) {
      return null;
    }

    final selectedFolder = SelectedFolder(path: selectedPath);
    if (selectedFolder.isEmpty) {
      return null;
    }

    return selectedFolder;
  }

  Future<SelectedFolder?> pickIncomingSongsFolder() async {
    final selectedPath = await FilePicker.getDirectoryPath(
      dialogTitle: 'Selecione a pasta de musicas novas',
    );

    if (selectedPath == null || selectedPath.trim().isEmpty) {
      return null;
    }

    final selectedFolder = SelectedFolder(path: selectedPath);
    if (selectedFolder.isEmpty) {
      return null;
    }

    return selectedFolder;
  }

  Future<SelectedFolder?> pickImportOutputFolder() async {
    final selectedPath = await FilePicker.getDirectoryPath(
      dialogTitle: 'Selecione a pasta de saida da importacao',
    );

    if (selectedPath == null || selectedPath.trim().isEmpty) {
      return null;
    }

    final selectedFolder = SelectedFolder(path: selectedPath);
    if (selectedFolder.isEmpty) {
      return null;
    }

    return selectedFolder;
  }

  Future<SelectedFolder?> pickImportManifestFolder() async {
    final selectedPath = await FilePicker.getDirectoryPath(
      dialogTitle: 'Selecione a pasta para salvar o manifesto',
    );

    if (selectedPath == null || selectedPath.trim().isEmpty) {
      return null;
    }

    final selectedFolder = SelectedFolder(path: selectedPath);
    if (selectedFolder.isEmpty) {
      return null;
    }

    return selectedFolder;
  }
}
