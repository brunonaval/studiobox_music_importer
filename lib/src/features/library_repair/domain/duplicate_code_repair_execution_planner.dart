import 'duplicate_code_repair_execution_item.dart';
import 'duplicate_code_repair_execution_item_status.dart';
import 'duplicate_code_repair_execution_plan.dart';
import 'duplicate_code_repair_item.dart';
import 'duplicate_code_repair_plan.dart';
import 'duplicate_code_repair_item_status.dart';

class DuplicateCodeRepairExecutionPlanner {
  DuplicateCodeRepairExecutionPlan buildDryRun(
    DuplicateCodeRepairPlan repairPlan,
  ) {
    final executionItems = <DuplicateCodeRepairExecutionItem>[];

    for (final group in repairPlan.groups) {
      for (final item in group.items) {
        executionItems.add(_mapRepairItem(item));
      }
    }

    final processedItems = _applySafetyChecks(executionItems);

    final warnings = <String>[...repairPlan.warnings];

    final hasBlocked = processedItems.any((item) => item.isBlocked);
    final hasDuplicateDestination = processedItems.any(
      (item) => item.warnings.contains(
        'Destino duplicado dentro do plano de execucao.',
      ),
    );

    if (hasBlocked) {
      warnings.add('Existem itens bloqueados no dry-run.');
    }

    if (hasDuplicateDestination) {
      warnings.add('Foram detectados destinos duplicados no dry-run.');
    }

    return DuplicateCodeRepairExecutionPlan(
      items: List.unmodifiable(processedItems),
      warnings: List.unmodifiable(warnings),
    );
  }

  DuplicateCodeRepairExecutionItem _mapRepairItem(
    DuplicateCodeRepairItem repairItem,
  ) {
    final sourcePath = _sourcePathPreview(
      fullPath: repairItem.fullPath,
      displayPath: repairItem.displayPath,
    );

    if (repairItem.status == DuplicateCodeRepairItemStatus.keepOriginalCode) {
      return DuplicateCodeRepairExecutionItem(
        originalCode: repairItem.originalCode,
        suggestedCode: null,
        artist: repairItem.artist,
        title: repairItem.title,
        originalFileName: repairItem.originalFileName,
        displayPath: repairItem.displayPath,
        sourcePathPreview: sourcePath,
        destinationPathPreview: null,
        suggestedFileName: repairItem.suggestedFileName,
        status: DuplicateCodeRepairExecutionItemStatus.skippedKeepOriginal,
        warnings: const [],
      );
    }

    if (repairItem.status == DuplicateCodeRepairItemStatus.blocked) {
      return DuplicateCodeRepairExecutionItem(
        originalCode: repairItem.originalCode,
        suggestedCode: repairItem.suggestedCode,
        artist: repairItem.artist,
        title: repairItem.title,
        originalFileName: repairItem.originalFileName,
        displayPath: repairItem.displayPath,
        sourcePathPreview: sourcePath,
        destinationPathPreview: null,
        suggestedFileName: repairItem.suggestedFileName,
        status: DuplicateCodeRepairExecutionItemStatus.blocked,
        warnings: List.unmodifiable(repairItem.warnings),
      );
    }

    final warnings = <String>[];

    if (repairItem.suggestedFileName == null ||
        repairItem.suggestedFileName.toString().trim().isEmpty) {
      warnings.add('Nome sugerido indisponivel.');
    }

    final fullPath = repairItem.fullPath?.toString().trim();
    if (fullPath == null || fullPath.isEmpty) {
      warnings.add('Caminho completo indisponivel para renomeio seguro.');
    }

    if (warnings.isNotEmpty) {
      return DuplicateCodeRepairExecutionItem(
        originalCode: repairItem.originalCode,
        suggestedCode: repairItem.suggestedCode,
        artist: repairItem.artist,
        title: repairItem.title,
        originalFileName: repairItem.originalFileName,
        displayPath: repairItem.displayPath,
        sourcePathPreview: sourcePath,
        destinationPathPreview: null,
        suggestedFileName: repairItem.suggestedFileName,
        status: DuplicateCodeRepairExecutionItemStatus.blocked,
        warnings: List.unmodifiable(warnings),
      );
    }

    final destinationPath = _destinationPathPreview(
      fullPath: fullPath!,
      suggestedFileName: repairItem.suggestedFileName!,
    );

    return DuplicateCodeRepairExecutionItem(
      originalCode: repairItem.originalCode,
      suggestedCode: repairItem.suggestedCode,
      artist: repairItem.artist,
      title: repairItem.title,
      originalFileName: repairItem.originalFileName,
      displayPath: repairItem.displayPath,
      sourcePathPreview: sourcePath,
      destinationPathPreview: destinationPath,
      suggestedFileName: repairItem.suggestedFileName,
      status: DuplicateCodeRepairExecutionItemStatus.readyToRename,
      warnings: const [],
    );
  }

  List<DuplicateCodeRepairExecutionItem> _applySafetyChecks(
    List<DuplicateCodeRepairExecutionItem> items,
  ) {
    final copied = items.toList();

    final destinationToIndexes = <String, List<int>>{};

    for (var i = 0; i < copied.length; i++) {
      final item = copied[i];
      if (!item.isReadyToRename || item.destinationPathPreview == null) {
        continue;
      }

      if (item.sourcePathPreview == item.destinationPathPreview) {
        copied[i] = _toBlocked(item, 'Origem e destino sao iguais.');
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
          'Destino duplicado dentro do plano de execucao.',
        );
      }
    }

    return copied;
  }

  DuplicateCodeRepairExecutionItem _toBlocked(
    DuplicateCodeRepairExecutionItem item,
    String warning,
  ) {
    final warnings = List<String>.from(item.warnings);
    if (!warnings.contains(warning)) {
      warnings.add(warning);
    }

    return DuplicateCodeRepairExecutionItem(
      originalCode: item.originalCode,
      suggestedCode: item.suggestedCode,
      artist: item.artist,
      title: item.title,
      originalFileName: item.originalFileName,
      displayPath: item.displayPath,
      sourcePathPreview: item.sourcePathPreview,
      destinationPathPreview: null,
      suggestedFileName: item.suggestedFileName,
      status: DuplicateCodeRepairExecutionItemStatus.blocked,
      warnings: List.unmodifiable(warnings),
    );
  }

  String _sourcePathPreview({
    required String? fullPath,
    required String displayPath,
  }) {
    final trimmedFullPath = fullPath?.trim();
    if (trimmedFullPath != null && trimmedFullPath.isNotEmpty) {
      return trimmedFullPath;
    }
    return displayPath;
  }

  String _destinationPathPreview({
    required String fullPath,
    required String suggestedFileName,
  }) {
    final useBackslash = fullPath.contains('\\');
    final separator = useBackslash ? '\\' : '/';
    final normalized = fullPath;

    final lastSeparator = normalized.lastIndexOf(separator);
    if (lastSeparator < 0) {
      return suggestedFileName;
    }

    final directory = normalized.substring(0, lastSeparator);
    if (directory.isEmpty) {
      return suggestedFileName;
    }

    return '$directory$separator$suggestedFileName';
  }
}
