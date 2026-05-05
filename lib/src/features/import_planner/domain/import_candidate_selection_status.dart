enum ImportCandidateSelectionStatus {
  selected,
  notSelected,
  blocked;

  String get label {
    switch (this) {
      case ImportCandidateSelectionStatus.selected:
        return 'Selecionado';
      case ImportCandidateSelectionStatus.notSelected:
        return 'Nao selecionado';
      case ImportCandidateSelectionStatus.blocked:
        return 'Bloqueado';
    }
  }
}
