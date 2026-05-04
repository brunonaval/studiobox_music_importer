import 'duplicate_code_repair_item_status.dart';

class DuplicateCodeRepairItem {
  const DuplicateCodeRepairItem({
    required this.originalCode,
    required this.suggestedCode,
    required this.artist,
    required this.title,
    required this.originalFileName,
    required this.fullPath,
    required this.relativePath,
    required this.displayPath,
    required this.suggestedFileName,
    required this.status,
    required this.warnings,
  });

  final String originalCode;
  final String? suggestedCode;
  final String artist;
  final String title;
  final String originalFileName;
  final String? fullPath;
  final String? relativePath;
  final String displayPath;
  final String? suggestedFileName;
  final DuplicateCodeRepairItemStatus status;
  final List<String> warnings;

  bool get keepsOriginalCode =>
      status == DuplicateCodeRepairItemStatus.keepOriginalCode;

  bool get assignsNewCode =>
      status == DuplicateCodeRepairItemStatus.assignNewCode;

  bool get isBlocked => status == DuplicateCodeRepairItemStatus.blocked;

  bool get hasWarnings => warnings.isNotEmpty;
}
