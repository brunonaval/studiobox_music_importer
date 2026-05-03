enum IncomingSongParseConfidence {
  high,
  medium,
  low,
  failed;

  String get label {
    switch (this) {
      case IncomingSongParseConfidence.high:
        return 'Alta';
      case IncomingSongParseConfidence.medium:
        return 'Média';
      case IncomingSongParseConfidence.low:
        return 'Baixa';
      case IncomingSongParseConfidence.failed:
        return 'Falhou';
    }
  }
}
