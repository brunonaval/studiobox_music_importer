import 'import_operation_manifest_item.dart';
import 'import_operation_manifest_summary.dart';

class ImportOperationManifest {
  const ImportOperationManifest({
    required this.id,
    required this.generatedAtIso8601,
    required this.appName,
    required this.manifestVersion,
    required this.outputMode,
    required this.incomingSongsFolderPath,
    required this.officialLibraryFolderPath,
    required this.customOutputFolderPath,
    required this.summary,
    required this.items,
    required this.warnings,
  });

  final String id;
  final String generatedAtIso8601;
  final String appName;
  final String manifestVersion;
  final String outputMode;
  final String? incomingSongsFolderPath;
  final String? officialLibraryFolderPath;
  final String? customOutputFolderPath;
  final ImportOperationManifestSummary summary;
  final List<ImportOperationManifestItem> items;
  final List<String> warnings;

  int get totalCount => summary.totalCount;
  bool get hasItems => items.isNotEmpty;
  bool get hasWarnings => warnings.isNotEmpty;
}
