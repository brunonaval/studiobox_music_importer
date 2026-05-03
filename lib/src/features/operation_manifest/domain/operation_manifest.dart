import 'operation_manifest_item.dart';
import 'operation_manifest_summary.dart';

class OperationManifest {
  const OperationManifest({
    this.schemaVersion = '1',
    required this.createdAtUtcIso,
    required this.mode,
    required this.transferAction,
    required this.sourceFolderPath,
    required this.officialLibraryFolderPath,
    required this.customOutputFolderPath,
    required this.summary,
    required this.items,
    required this.warnings,
  });

  final String schemaVersion;
  final String createdAtUtcIso;
  final String mode;
  final String transferAction;
  final String? sourceFolderPath;
  final String? officialLibraryFolderPath;
  final String? customOutputFolderPath;
  final OperationManifestSummary summary;
  final List<OperationManifestItem> items;
  final List<String> warnings;

  bool get hasWarnings =>
      warnings.isNotEmpty || items.any((item) => item.hasWarnings);

  int get itemCount => items.length;

  Map<String, dynamic> toMap() {
    return {
      'schemaVersion': schemaVersion,
      'createdAtUtcIso': createdAtUtcIso,
      'mode': mode,
      'transferAction': transferAction,
      'sourceFolderPath': sourceFolderPath,
      'officialLibraryFolderPath': officialLibraryFolderPath,
      'customOutputFolderPath': customOutputFolderPath,
      'summary': summary.toMap(),
      'items': items.map((item) => item.toMap()).toList(growable: false),
      'warnings': warnings,
    };
  }
}
