enum IncomingSongCleaningRuleType {
  removePrefix,
  removeSuffix,
  removeContains;

  String get label => switch (this) {
    IncomingSongCleaningRuleType.removePrefix => 'Remover do início',
    IncomingSongCleaningRuleType.removeSuffix => 'Remover do fim',
    IncomingSongCleaningRuleType.removeContains => 'Remover ocorrência',
  };
}
