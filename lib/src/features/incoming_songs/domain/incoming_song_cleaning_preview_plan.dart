import 'incoming_song_cleaning_preview_item.dart';

class IncomingSongCleaningPreviewPlan {
  const IncomingSongCleaningPreviewPlan({
    required this.items,
    required this.warnings,
  });

  final List<IncomingSongCleaningPreviewItem> items;
  final List<String> warnings;

  int get totalCount => items.length;

  int get changedCount => items.where((i) => i.wasChanged).length;

  int get unchangedCount => items.where((i) => !i.wasChanged).length;

  bool get hasChanges => changedCount > 0;

  bool get hasWarnings => warnings.isNotEmpty;
}
