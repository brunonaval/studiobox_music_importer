enum OutputTransferAction {
  rename,
  copy,
  move;

  String get label {
    switch (this) {
      case OutputTransferAction.rename:
        return 'Renomear';
      case OutputTransferAction.copy:
        return 'Copiar';
      case OutputTransferAction.move:
        return 'Mover';
    }
  }
}
