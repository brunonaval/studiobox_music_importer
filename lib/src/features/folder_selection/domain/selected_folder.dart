class SelectedFolder {
  SelectedFolder({required String path}) : path = path.trim();

  final String path;

  bool get isEmpty => path.trim().isEmpty;
}
