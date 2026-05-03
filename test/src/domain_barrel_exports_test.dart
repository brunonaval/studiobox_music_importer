import 'package:flutter_test/flutter_test.dart';
import 'package:studiobox_music_importer/src/features/base_library/domain/base_library.dart';
import 'package:studiobox_music_importer/src/features/import_planner/domain/import_planner.dart';
import 'package:studiobox_music_importer/src/features/operation_manifest/domain/operation_manifest_domain.dart';
import 'package:studiobox_music_importer/src/features/output_plan/domain/output_plan.dart';

void main() {
  test('barrel exports support end-to-end in-memory domain flow', () {
    final baseIndex = BaseLibraryIndexer().indexFileNames([
      'Legiao Urbana - Tempo Perdido - 00001.mp4',
      'Capital Inicial - Primeiros Erros - 00002.mp4',
    ]);

    final suggestionPlan = ImportSuggestionPlanner().buildPlan(
      incomingFileNames: ['Pais e Filhos - Legiao Urbana.mp4'],
      baseIndex: baseIndex,
      codeStrategy: SongCodeAllocationStrategy.afterHighestExisting,
    );

    final outputPlan = OutputOperationPlanner().buildPlan(
      suggestionPlan: suggestionPlan,
      mode: OutputOperationMode.renameInPlace,
      transferAction: OutputTransferAction.rename,
      sourceFolderPath: 'C:/Novas',
      includeNeedsReview: true,
    );

    final manifest = OperationManifestBuilder().build(
      operationPlan: outputPlan,
      createdAtUtc: DateTime.utc(2026, 5, 3, 10, 20, 30),
      sourceFolderPath: 'C:/Novas',
    );

    expect(manifest.itemCount, greaterThanOrEqualTo(1));
  });
}
