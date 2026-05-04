enum InvalidFileRepairItemStatus {
  readyToSuggest,
  needsReview,
  blocked;

  String get label {
    switch (this) {
      case InvalidFileRepairItemStatus.readyToSuggest:
        return 'Sugestão pronta';
      case InvalidFileRepairItemStatus.needsReview:
        return 'Revisão necessária';
      case InvalidFileRepairItemStatus.blocked:
        return 'Bloqueado';
    }
  }
}
