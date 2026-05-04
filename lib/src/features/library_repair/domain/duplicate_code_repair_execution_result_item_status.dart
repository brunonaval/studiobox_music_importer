enum DuplicateCodeRepairExecutionResultItemStatus {
  renamed,
  skipped,
  failed;

  String get label {
    switch (this) {
      case DuplicateCodeRepairExecutionResultItemStatus.renamed:
        return 'Renomeado';
      case DuplicateCodeRepairExecutionResultItemStatus.skipped:
        return 'Ignorado';
      case DuplicateCodeRepairExecutionResultItemStatus.failed:
        return 'Falhou';
    }
  }
}
