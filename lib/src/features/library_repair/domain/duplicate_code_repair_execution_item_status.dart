enum DuplicateCodeRepairExecutionItemStatus {
  readyToRename,
  skippedKeepOriginal,
  blocked;

  String get label {
    switch (this) {
      case DuplicateCodeRepairExecutionItemStatus.readyToRename:
        return 'Pronto para renomear';
      case DuplicateCodeRepairExecutionItemStatus.skippedKeepOriginal:
        return 'Ignorado: mantem codigo original';
      case DuplicateCodeRepairExecutionItemStatus.blocked:
        return 'Bloqueado';
    }
  }
}
