import 'incoming_song_cleaning_rule_type.dart';

class IncomingSongCleaningRule {
  IncomingSongCleaningRule({
    required this.type,
    required String pattern,
    this.enabled = true,
    this.description = '',
  }) : pattern = pattern.trim();

  final IncomingSongCleaningRuleType type;
  final String pattern;
  final bool enabled;
  final String description;

  static List<IncomingSongCleaningRule> defaultRules() => [
    IncomingSongCleaningRule(
      type: IncomingSongCleaningRuleType.removePrefix,
      pattern: 'Karaokê - ',
      description: 'Karaokê - ',
    ),
    IncomingSongCleaningRule(
      type: IncomingSongCleaningRuleType.removePrefix,
      pattern: 'Karaoke - ',
      description: 'Karaoke - ',
    ),
    IncomingSongCleaningRule(
      type: IncomingSongCleaningRuleType.removePrefix,
      pattern: 'Playback - ',
      description: 'Playback - ',
    ),
    IncomingSongCleaningRule(
      type: IncomingSongCleaningRuleType.removeSuffix,
      pattern: ' - Karaokê',
      description: ' - Karaokê',
    ),
    IncomingSongCleaningRule(
      type: IncomingSongCleaningRuleType.removeSuffix,
      pattern: ' - Karaoke',
      description: ' - Karaoke',
    ),
    IncomingSongCleaningRule(
      type: IncomingSongCleaningRuleType.removeSuffix,
      pattern: ' - Playback',
      description: ' - Playback',
    ),
    IncomingSongCleaningRule(
      type: IncomingSongCleaningRuleType.removeSuffix,
      pattern: ' (Karaokê)',
      description: ' (Karaokê)',
    ),
    IncomingSongCleaningRule(
      type: IncomingSongCleaningRuleType.removeSuffix,
      pattern: ' (Karaoke)',
      description: ' (Karaoke)',
    ),
    IncomingSongCleaningRule(
      type: IncomingSongCleaningRuleType.removeSuffix,
      pattern: ' [Karaokê]',
      description: ' [Karaokê]',
    ),
    IncomingSongCleaningRule(
      type: IncomingSongCleaningRuleType.removeSuffix,
      pattern: ' [Karaoke]',
      description: ' [Karaoke]',
    ),
  ];
}
