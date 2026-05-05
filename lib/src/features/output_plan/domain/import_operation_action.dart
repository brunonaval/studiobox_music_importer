import 'import_output_mode.dart';

enum ImportOperationAction {
  rename,
  copy,
  move;

  String get label {
    switch (this) {
      case ImportOperationAction.rename:
        return 'Renomear';
      case ImportOperationAction.copy:
        return 'Copiar';
      case ImportOperationAction.move:
        return 'Mover';
    }
  }

  static ImportOperationAction fromOutputMode(ImportOutputMode mode) {
    switch (mode) {
      case ImportOutputMode.renameInIncomingFolder:
        return ImportOperationAction.rename;
      case ImportOutputMode.copyToOfficialLibrary:
      case ImportOutputMode.copyToCustomFolder:
        return ImportOperationAction.copy;
      case ImportOutputMode.moveToOfficialLibrary:
      case ImportOutputMode.moveToCustomFolder:
        return ImportOperationAction.move;
    }
  }
}
