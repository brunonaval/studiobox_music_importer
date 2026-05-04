enum DuplicateCodeRepairItemStatus {
  keepOriginalCode,
  assignNewCode,
  blocked;

  String get label {
    switch (this) {
      case DuplicateCodeRepairItemStatus.keepOriginalCode:
        return 'Manter codigo original';
      case DuplicateCodeRepairItemStatus.assignNewCode:
        return 'Atribuir novo codigo';
      case DuplicateCodeRepairItemStatus.blocked:
        return 'Bloqueado';
    }
  }
}
