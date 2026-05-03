import '../../output_plan/domain/output_operation_plan.dart';
import 'operation_manifest.dart';
import 'operation_manifest_item.dart';
import 'operation_manifest_summary.dart';

class OperationManifestBuilder {
  OperationManifest build({
    required OutputOperationPlan operationPlan,
    required DateTime createdAtUtc,
    String? sourceFolderPath,
    String? officialLibraryFolderPath,
    String? customOutputFolderPath,
  }) {
    final utcCreatedAt = createdAtUtc.isUtc
        ? createdAtUtc
        : createdAtUtc.toUtc();

    final items = operationPlan.items
        .map(
          (item) => OperationManifestItem(
            originalFileName: item.originalFileName,
            suggestedOfficialFileName: item.suggestedOfficialFileName,
            sourcePathPreview: item.sourcePathPreview,
            destinationPathPreview: item.destinationPathPreview,
            sourceFolderPath: item.sourceFolderPath,
            destinationFolderPath: item.destinationFolderPath,
            action: item.action?.name ?? '',
            status: item.status.name,
            warnings: List.unmodifiable(item.warnings),
          ),
        )
        .toList(growable: false);

    final itemWarnings = items.fold<int>(
      0,
      (total, item) => total + item.warnings.length,
    );

    final summary = OperationManifestSummary(
      totalCount: operationPlan.totalCount,
      readyCount: operationPlan.readyCount,
      skippedCount: operationPlan.skippedCount,
      blockedCount: operationPlan.blockedCount,
      warningCount: operationPlan.warnings.length + itemWarnings,
    );

    return OperationManifest(
      createdAtUtcIso: utcCreatedAt.toIso8601String(),
      mode: operationPlan.mode.name,
      transferAction: operationPlan.transferAction.name,
      sourceFolderPath: sourceFolderPath,
      officialLibraryFolderPath: officialLibraryFolderPath,
      customOutputFolderPath: customOutputFolderPath,
      summary: summary,
      items: List.unmodifiable(items),
      warnings: List.unmodifiable(operationPlan.warnings),
    );
  }
}
