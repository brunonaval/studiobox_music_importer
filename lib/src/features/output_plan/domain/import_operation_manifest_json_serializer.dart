import 'dart:convert';

import 'import_operation_manifest.dart';

class ImportOperationManifestJsonSerializer {
  Map<String, Object?> toJson(ImportOperationManifest manifest) {
    return {
      'id': manifest.id,
      'generatedAtIso8601': manifest.generatedAtIso8601,
      'appName': manifest.appName,
      'manifestVersion': manifest.manifestVersion,
      'outputMode': manifest.outputMode,
      'folders': {
        'incomingSongsFolderPath': manifest.incomingSongsFolderPath,
        'officialLibraryFolderPath': manifest.officialLibraryFolderPath,
        'customOutputFolderPath': manifest.customOutputFolderPath,
      },
      'summary': {
        'totalCount': manifest.summary.totalCount,
        'renamedCount': manifest.summary.renamedCount,
        'copiedCount': manifest.summary.copiedCount,
        'movedCount': manifest.summary.movedCount,
        'skippedCount': manifest.summary.skippedCount,
        'failedCount': manifest.summary.failedCount,
        'successCount': manifest.summary.successCount,
      },
      'items': manifest.items
          .map(
            (item) => {
              'id': item.id,
              'action': item.action,
              'status': item.status,
              'originalFileName': item.originalFileName,
              'officialFileName': item.officialFileName,
              'sourcePath': item.sourcePath,
              'destinationPath': item.destinationPath,
              'messages': item.messages,
            },
          )
          .toList(growable: false),
      'warnings': manifest.warnings,
    };
  }

  String encodePretty(ImportOperationManifest manifest) {
    return const JsonEncoder.withIndent('  ').convert(toJson(manifest));
  }
}
