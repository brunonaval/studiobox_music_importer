enum ImportOperationExecutionResultItemStatus {
  renamed,
  copied,
  moved,
  skipped,
  failed;

  String get label {
    switch (this) {
      case ImportOperationExecutionResultItemStatus.renamed:
        return 'Renomeado';
      case ImportOperationExecutionResultItemStatus.copied:
        return 'Copiado';
      case ImportOperationExecutionResultItemStatus.moved:
        return 'Movido';
      case ImportOperationExecutionResultItemStatus.skipped:
        return 'Ignorado';
      case ImportOperationExecutionResultItemStatus.failed:
        return 'Falhou';
    }
  }
}
