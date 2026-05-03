enum OutputOperationItemStatus {
  ready,
  skipped,
  blocked;

  String get label {
    switch (this) {
      case OutputOperationItemStatus.ready:
        return 'Pronto';
      case OutputOperationItemStatus.skipped:
        return 'Ignorado';
      case OutputOperationItemStatus.blocked:
        return 'Bloqueado';
    }
  }
}
