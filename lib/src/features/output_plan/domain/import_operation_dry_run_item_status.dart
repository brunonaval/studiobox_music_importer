enum ImportOperationDryRunItemStatus {
  ready,
  blocked;

  String get label {
    switch (this) {
      case ImportOperationDryRunItemStatus.ready:
        return 'Pronto';
      case ImportOperationDryRunItemStatus.blocked:
        return 'Bloqueado';
    }
  }
}
