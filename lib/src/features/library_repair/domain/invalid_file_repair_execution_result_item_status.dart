enum InvalidFileRepairExecutionResultItemStatus {
  renamed,
  skipped,
  failed;

  String get label {
    switch (this) {
      case InvalidFileRepairExecutionResultItemStatus.renamed:
        return 'Renomeado';
      case InvalidFileRepairExecutionResultItemStatus.skipped:
        return 'Ignorado';
      case InvalidFileRepairExecutionResultItemStatus.failed:
        return 'Falhou';
    }
  }
}
