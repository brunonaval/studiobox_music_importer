import 'invalid_file_repair_execution_item.dart';
import 'invalid_file_repair_execution_item_status.dart';
import 'invalid_file_repair_execution_plan.dart';
import 'invalid_file_repair_item.dart';
import 'invalid_file_repair_item_status.dart';
import 'invalid_file_repair_plan.dart';

class InvalidFileRepairExecutionPlanner {
  InvalidFileRepairExecutionPlan buildDryRun(InvalidFileRepairPlan repairPlan) {
    final executionItems = <InvalidFileRepairExecutionItem>[];

    for (final item in repairPlan.items) {
      executionItems.add(_mapRepairItem(item));
    }

    final processedItems = _applySafetyChecks(executionItems);

    final warnings = <String>[...repairPlan.warnings];

    final hasBlocked = processedItems.any((item) => item.isBlocked);
    final hasSkipped = processedItems.any((item) => item.isSkipped);
    final hasDuplicateDestination = processedItems.any(
      (item) => item.warnings.contains(
        'Destino duplicado dentro do plano de execução.',
      ),
    );

    if (hasBlocked) {
      warnings.add('Existem itens bloqueados no dry-run de inválidos.');
    }

    if (hasSkipped) {
      warnings.add(
        'Existem itens aguardando revisão manual no dry-run de inválidos.',
      );
    }

    if (hasDuplicateDestination) {
      warnings.add('Foram detectados destinos duplicados no dry-run.');
    }

    return InvalidFileRepairExecutionPlan(
      items: List.unmodifiable(processedItems),
      warnings: List.unmodifiable(warnings),
    );
  }

  InvalidFileRepairExecutionItem _mapRepairItem(InvalidFileRepairItem item) {
    final sourcePath = _sourcePathPreview(
      fullPath: item.fullPath,
      displayPath: item.displayPath,
    );

    if (item.status == InvalidFileRepairItemStatus.needsReview) {
      final warnings = List<String>.from(item.warnings);
      warnings.add('Item precisa de revisão manual antes do renomeio.');

      return InvalidFileRepairExecutionItem(
        originalFileName: item.originalFileName,
        originalReason: item.originalReason,
        displayPath: item.displayPath,
        fullPath: item.fullPath,
        relativePath: item.relativePath,
        suggestedCode: item.suggestedCode,
        suggestedFileName: item.suggestedFileName,
        sourcePathPreview: sourcePath,
        destinationPathPreview: null,
        detectedArtist: item.analysis.detectedArtist,
        detectedTitle: item.analysis.detectedTitle,
        status: InvalidFileRepairExecutionItemStatus.skippedNeedsReview,
        warnings: List.unmodifiable(warnings),
      );
    }

    if (item.status == InvalidFileRepairItemStatus.blocked) {
      final warnings = List<String>.from(item.warnings);
      if (warnings.isEmpty) {
        warnings.add('Item bloqueado no plano de reparo.');
      }

      return InvalidFileRepairExecutionItem(
        originalFileName: item.originalFileName,
        originalReason: item.originalReason,
        displayPath: item.displayPath,
        fullPath: item.fullPath,
        relativePath: item.relativePath,
        suggestedCode: item.suggestedCode,
        suggestedFileName: item.suggestedFileName,
        sourcePathPreview: sourcePath,
        destinationPathPreview: null,
        detectedArtist: item.analysis.detectedArtist,
        detectedTitle: item.analysis.detectedTitle,
        status: InvalidFileRepairExecutionItemStatus.blocked,
        warnings: List.unmodifiable(warnings),
      );
    }

    // readyToSuggest — validate prerequisites
    final itemWarnings = <String>[];

    if (item.suggestedFileName == null ||
        item.suggestedFileName!.trim().isEmpty) {
      itemWarnings.add('Nome sugerido indisponível.');
    }

    final fullPath = item.fullPath?.trim();
    if (fullPath == null || fullPath.isEmpty) {
      itemWarnings.add('Caminho completo indisponível para renomeio seguro.');
    }

    if (itemWarnings.isNotEmpty) {
      return InvalidFileRepairExecutionItem(
        originalFileName: item.originalFileName,
        originalReason: item.originalReason,
        displayPath: item.displayPath,
        fullPath: item.fullPath,
        relativePath: item.relativePath,
        suggestedCode: item.suggestedCode,
        suggestedFileName: item.suggestedFileName,
        sourcePathPreview: sourcePath,
        destinationPathPreview: null,
        detectedArtist: item.analysis.detectedArtist,
        detectedTitle: item.analysis.detectedTitle,
        status: InvalidFileRepairExecutionItemStatus.blocked,
        warnings: List.unmodifiable(itemWarnings),
      );
    }

    final destinationPath = _destinationPathPreview(
      fullPath: fullPath!,
      suggestedFileName: item.suggestedFileName!,
    );

    return InvalidFileRepairExecutionItem(
      originalFileName: item.originalFileName,
      originalReason: item.originalReason,
      displayPath: item.displayPath,
      fullPath: item.fullPath,
      relativePath: item.relativePath,
      suggestedCode: item.suggestedCode,
      suggestedFileName: item.suggestedFileName,
      sourcePathPreview: fullPath,
      destinationPathPreview: destinationPath,
      detectedArtist: item.analysis.detectedArtist,
      detectedTitle: item.analysis.detectedTitle,
      status: InvalidFileRepairExecutionItemStatus.readyToRename,
      warnings: const [],
    );
  }

  List<InvalidFileRepairExecutionItem> _applySafetyChecks(
    List<InvalidFileRepairExecutionItem> items,
  ) {
    final copied = items.toList();

    final destinationToIndexes = <String, List<int>>{};

    for (var i = 0; i < copied.length; i++) {
      final item = copied[i];
      if (!item.isReadyToRename || item.destinationPathPreview == null) {
        continue;
      }

      if (item.sourcePathPreview == item.destinationPathPreview) {
        copied[i] = _toBlocked(item, 'Origem e destino são iguais.');
        continue;
      }

      destinationToIndexes
          .putIfAbsent(item.destinationPathPreview!, () => <int>[])
          .add(i);
    }

    for (final indexes in destinationToIndexes.values) {
      if (indexes.length <= 1) {
        continue;
      }

      for (final index in indexes) {
        copied[index] = _toBlocked(
          copied[index],
          'Destino duplicado dentro do plano de execução.',
        );
      }
    }

    return copied;
  }

  InvalidFileRepairExecutionItem _toBlocked(
    InvalidFileRepairExecutionItem item,
    String warning,
  ) {
    final warnings = List<String>.from(item.warnings);
    if (!warnings.contains(warning)) {
      warnings.add(warning);
    }

    return InvalidFileRepairExecutionItem(
      originalFileName: item.originalFileName,
      originalReason: item.originalReason,
      displayPath: item.displayPath,
      fullPath: item.fullPath,
      relativePath: item.relativePath,
      suggestedCode: item.suggestedCode,
      suggestedFileName: item.suggestedFileName,
      sourcePathPreview: item.sourcePathPreview,
      destinationPathPreview: null,
      detectedArtist: item.detectedArtist,
      detectedTitle: item.detectedTitle,
      status: InvalidFileRepairExecutionItemStatus.blocked,
      warnings: List.unmodifiable(warnings),
    );
  }

  String _sourcePathPreview({
    required String? fullPath,
    required String displayPath,
  }) {
    final trimmed = fullPath?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return trimmed;
    }
    return displayPath;
  }

  String _destinationPathPreview({
    required String fullPath,
    required String suggestedFileName,
  }) {
    final useBackslash = fullPath.contains('\\');
    final separator = useBackslash ? '\\' : '/';

    final lastSeparator = fullPath.lastIndexOf(separator);
    if (lastSeparator < 0) {
      return suggestedFileName;
    }

    final directory = fullPath.substring(0, lastSeparator);
    if (directory.isEmpty) {
      return suggestedFileName;
    }

    return '$directory$separator$suggestedFileName';
  }
}
