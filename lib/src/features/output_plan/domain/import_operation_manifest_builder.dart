import 'import_operation_execution_result.dart';
import 'import_operation_manifest.dart';
import 'import_operation_manifest_item.dart';
import 'import_operation_manifest_summary.dart';
import 'import_output_configuration.dart';

class ImportOperationManifestBuilder {
  ImportOperationManifest build({
    required ImportOutputConfiguration configuration,
    required ImportOperationExecutionResult executionResult,
    DateTime? generatedAt,
  }) {
    final generatedUtc = (generatedAt ?? DateTime.now()).toUtc();
    final manifestId = 'import-manifest-${_compactTimestamp(generatedUtc)}';

    final summary = ImportOperationManifestSummary(
      totalCount: executionResult.totalCount,
      renamedCount: executionResult.renamedCount,
      copiedCount: executionResult.copiedCount,
      movedCount: executionResult.movedCount,
      skippedCount: executionResult.skippedCount,
      failedCount: executionResult.failedCount,
      successCount: executionResult.successCount,
    );

    final items = executionResult.items
        .map(
          (item) => ImportOperationManifestItem(
            id: item.id,
            action: item.action.label,
            status: item.status.label,
            originalFileName: item.originalFileName,
            officialFileName: item.officialFileName,
            sourcePath: item.sourcePath,
            destinationPath: item.destinationPath,
            messages: List.unmodifiable(item.messages),
          ),
        )
        .toList(growable: false);

    return ImportOperationManifest(
      id: manifestId,
      generatedAtIso8601: generatedUtc.toIso8601String(),
      appName: 'StudioBox Music Importer',
      manifestVersion: '1.0',
      outputMode: configuration.mode.label,
      incomingSongsFolderPath: configuration.incomingSongsFolderPath,
      officialLibraryFolderPath: configuration.officialLibraryFolderPath,
      customOutputFolderPath: configuration.customOutputFolderPath,
      summary: summary,
      items: List.unmodifiable(items),
      warnings: List.unmodifiable(executionResult.warnings),
    );
  }

  String _compactTimestamp(DateTime value) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${value.year}${two(value.month)}${two(value.day)}T${two(value.hour)}${two(value.minute)}${two(value.second)}Z';
  }
}
