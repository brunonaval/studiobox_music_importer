enum InvalidFileRepairExecutionItemStatus {
  readyToRename,
  skippedNeedsReview,
  blocked;

  String get label {
    switch (this) {
      case InvalidFileRepairExecutionItemStatus.readyToRename:
        return 'Pronto para renomear';
      case InvalidFileRepairExecutionItemStatus.skippedNeedsReview:
        return 'Ignorado: revisão necessária';
      case InvalidFileRepairExecutionItemStatus.blocked:
        return 'Bloqueado';
    }
  }
}
