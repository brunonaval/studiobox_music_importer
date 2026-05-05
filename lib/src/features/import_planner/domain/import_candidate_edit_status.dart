enum ImportCandidateEditStatus {
  valid,
  invalid,
  blocked;

  String get label {
    switch (this) {
      case ImportCandidateEditStatus.valid:
        return 'Valido';
      case ImportCandidateEditStatus.invalid:
        return 'Invalido';
      case ImportCandidateEditStatus.blocked:
        return 'Bloqueado';
    }
  }
}
