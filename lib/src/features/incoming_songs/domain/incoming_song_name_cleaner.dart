import 'incoming_song_cleaning_preview_item.dart';
import 'incoming_song_cleaning_preview_plan.dart';
import 'incoming_song_cleaning_rule.dart';
import 'incoming_song_cleaning_rule_type.dart';
import 'incoming_songs_scan_result.dart';

class IncomingSongNameCleaner {
  IncomingSongCleaningPreviewPlan buildPreview({
    required IncomingSongsScanResult scanResult,
    required List<IncomingSongCleaningRule> rules,
  }) {
    final items = <IncomingSongCleaningPreviewItem>[];
    final planWarnings = <String>[...scanResult.warnings];

    for (final file in scanResult.files) {
      final (baseName, extension) = _splitFileName(file.fileName);
      var currentBase = baseName;
      final appliedRules = <String>[];
      final itemWarnings = <String>[];

      for (final rule in rules) {
        if (!rule.enabled || rule.pattern.isEmpty) {
          continue;
        }

        final result = _applyRule(baseName: currentBase, rule: rule);

        if (result.warning != null) {
          itemWarnings.add(result.warning!);
          continue;
        }

        if (result.changed) {
          final normalized = _normalizeBaseName(result.value);
          if (normalized.isEmpty) {
            itemWarnings.add(
              'Limpeza deixaria nome vazio; alteração ignorada.',
            );
          } else {
            currentBase = normalized;
            appliedRules.add(
              rule.description.isNotEmpty ? rule.description : rule.pattern,
            );
          }
        }
      }

      final cleanedFileName = '$currentBase$extension';

      items.add(
        IncomingSongCleaningPreviewItem(
          scannedFile: file,
          originalFileName: file.fileName,
          cleanedFileName: cleanedFileName,
          appliedRules: appliedRules,
          warnings: itemWarnings,
        ),
      );
    }

    if (items.any((i) => i.hasWarnings)) {
      planWarnings.add('Existem avisos na pré-limpeza de nomes.');
    }

    return IncomingSongCleaningPreviewPlan(
      items: items,
      warnings: planWarnings,
    );
  }

  ({bool changed, String value, String? warning}) _applyRule({
    required String baseName,
    required IncomingSongCleaningRule rule,
  }) {
    final pattern = rule.pattern;
    final lowerBase = baseName.toLowerCase();
    final lowerPattern = pattern.toLowerCase();

    switch (rule.type) {
      case IncomingSongCleaningRuleType.removePrefix:
        if (lowerBase.startsWith(lowerPattern)) {
          final newBase = baseName.substring(pattern.length);
          return (changed: true, value: newBase, warning: null);
        }
        return (changed: false, value: baseName, warning: null);

      case IncomingSongCleaningRuleType.removeSuffix:
        if (lowerBase.endsWith(lowerPattern)) {
          final newBase = baseName.substring(
            0,
            baseName.length - pattern.length,
          );
          return (changed: true, value: newBase, warning: null);
        }
        return (changed: false, value: baseName, warning: null);

      case IncomingSongCleaningRuleType.removeContains:
        if (pattern.length < 3) {
          return (
            changed: false,
            value: baseName,
            warning: 'Regra ignorada por padrão muito curto.',
          );
        }
        if (lowerBase.contains(lowerPattern)) {
          final buffer = StringBuffer();
          var remaining = baseName;
          var lowerRemaining = remaining.toLowerCase();
          while (lowerRemaining.contains(lowerPattern)) {
            final idx = lowerRemaining.indexOf(lowerPattern);
            buffer.write(remaining.substring(0, idx));
            remaining = remaining.substring(idx + pattern.length);
            lowerRemaining = remaining.toLowerCase();
          }
          buffer.write(remaining);
          return (changed: true, value: buffer.toString(), warning: null);
        }
        return (changed: false, value: baseName, warning: null);
    }
  }

  (String, String) _splitFileName(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex < 0) {
      return (fileName, '');
    }
    return (fileName.substring(0, dotIndex), fileName.substring(dotIndex));
  }

  String _normalizeBaseName(String baseName) {
    var result = baseName.trim();
    result = result.replaceAll(RegExp(r' {2,}'), ' ');
    return result.trim();
  }
}
