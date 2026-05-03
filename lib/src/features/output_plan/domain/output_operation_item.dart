import 'output_operation_item_status.dart';
import 'output_transfer_action.dart';

class OutputOperationItem {
  const OutputOperationItem({
    required this.originalFileName,
    required this.sourceFolderPath,
    required this.destinationFolderPath,
    required this.sourcePathPreview,
    required this.destinationPathPreview,
    required this.suggestedOfficialFileName,
    required this.action,
    required this.status,
    required this.warnings,
  });

  final String originalFileName;
  final String? sourceFolderPath;
  final String? destinationFolderPath;
  final String? sourcePathPreview;
  final String? destinationPathPreview;
  final String? suggestedOfficialFileName;
  final OutputTransferAction? action;
  final OutputOperationItemStatus status;
  final List<String> warnings;

  bool get isReady => status == OutputOperationItemStatus.ready;

  bool get isBlocked => status == OutputOperationItemStatus.blocked;

  bool get isSkipped => status == OutputOperationItemStatus.skipped;

  bool get hasWarnings => warnings.isNotEmpty;
}
