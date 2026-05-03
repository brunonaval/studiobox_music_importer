enum OutputOperationMode {
  renameInPlace,
  officialLibrary,
  customOutputFolder;

  String get label {
    switch (this) {
      case OutputOperationMode.renameInPlace:
        return 'Renomear na propria pasta';
      case OutputOperationMode.officialLibrary:
        return 'Copiar/mover para biblioteca oficial';
      case OutputOperationMode.customOutputFolder:
        return 'Escolher pasta de saida';
    }
  }
}
