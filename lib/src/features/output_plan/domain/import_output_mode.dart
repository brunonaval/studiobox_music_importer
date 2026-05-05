enum ImportOutputMode {
  renameInIncomingFolder,
  copyToOfficialLibrary,
  moveToOfficialLibrary,
  copyToCustomFolder,
  moveToCustomFolder;

  String get label {
    switch (this) {
      case ImportOutputMode.renameInIncomingFolder:
        return 'Renomear na pasta de musicas novas';
      case ImportOutputMode.copyToOfficialLibrary:
        return 'Copiar para biblioteca oficial';
      case ImportOutputMode.moveToOfficialLibrary:
        return 'Mover para biblioteca oficial';
      case ImportOutputMode.copyToCustomFolder:
        return 'Copiar para pasta de saida';
      case ImportOutputMode.moveToCustomFolder:
        return 'Mover para pasta de saida';
    }
  }

  bool get renamesInPlace => this == ImportOutputMode.renameInIncomingFolder;

  bool get copiesFiles =>
      this == ImportOutputMode.copyToOfficialLibrary ||
      this == ImportOutputMode.copyToCustomFolder;

  bool get movesFiles =>
      this == ImportOutputMode.moveToOfficialLibrary ||
      this == ImportOutputMode.moveToCustomFolder;

  bool get targetsOfficialLibrary =>
      this == ImportOutputMode.copyToOfficialLibrary ||
      this == ImportOutputMode.moveToOfficialLibrary;

  bool get targetsCustomFolder =>
      this == ImportOutputMode.copyToCustomFolder ||
      this == ImportOutputMode.moveToCustomFolder;
}
