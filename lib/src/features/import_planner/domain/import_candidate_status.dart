enum ImportCandidateStatus {
  autoApproved,
  needsReview,
  blocked;

  String get label {
    switch (this) {
      case ImportCandidateStatus.autoApproved:
        return 'Aprovado automaticamente';
      case ImportCandidateStatus.needsReview:
        return 'Revisao necessaria';
      case ImportCandidateStatus.blocked:
        return 'Bloqueado';
    }
  }
}
