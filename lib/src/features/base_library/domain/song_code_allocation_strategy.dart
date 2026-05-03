enum SongCodeAllocationStrategy {
  afterHighestExisting,
  fillGapsFirst;

  String get label {
    switch (this) {
      case SongCodeAllocationStrategy.afterHighestExisting:
        return 'Continuar apos o maior codigo';
      case SongCodeAllocationStrategy.fillGapsFirst:
        return 'Preencher buracos primeiro';
    }
  }
}
