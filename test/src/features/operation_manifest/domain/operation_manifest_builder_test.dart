import 'package:flutter_test/flutter_test.dart';
import 'package:studiobox_music_importer/src/features/operation_manifest/domain/operation_manifest_builder.dart';
import 'package:studiobox_music_importer/src/features/output_plan/domain/output_operation_item.dart';
import 'package:studiobox_music_importer/src/features/output_plan/domain/output_operation_item_status.dart';
import 'package:studiobox_music_importer/src/features/output_plan/domain/output_operation_mode.dart';
import 'package:studiobox_music_importer/src/features/output_plan/domain/output_operation_plan.dart';
import 'package:studiobox_music_importer/src/features/output_plan/domain/output_transfer_action.dart';

void main() {
  final builder = OperationManifestBuilder();

  OutputOperationPlan buildPlan() {
    return const OutputOperationPlan(
      mode: OutputOperationMode.renameInPlace,
      transferAction: OutputTransferAction.rename,
      items: [
        OutputOperationItem(
          originalFileName: 'Tempo Perdido - Legiao Urbana.mp4',
          sourceFolderPath: 'C:/Novas',
          destinationFolderPath: 'C:/Novas',
          sourcePathPreview: 'C:/Novas/Tempo Perdido - Legiao Urbana.mp4',
          destinationPathPreview:
              'C:/Novas/Legiao Urbana - Tempo Perdido - 00006.mp4',
          suggestedOfficialFileName:
              'Legiao Urbana - Tempo Perdido - 00006.mp4',
          action: OutputTransferAction.rename,
          status: OutputOperationItemStatus.ready,
          warnings: ['Warning item'],
        ),
        OutputOperationItem(
          originalFileName: 'ArquivoSemSeparador.mp4',
          sourceFolderPath: 'C:/Novas',
          destinationFolderPath: 'C:/Novas',
          sourcePathPreview: 'C:/Novas/ArquivoSemSeparador.mp4',
          destinationPathPreview: null,
          suggestedOfficialFileName: null,
          action: null,
          status: OutputOperationItemStatus.blocked,
          warnings: [],
        ),
      ],
      warnings: ['Warning plan'],
    );
  }

  test('build cria manifesto com schemaVersion 1', () {
    final manifest = builder.build(
      operationPlan: buildPlan(),
      createdAtUtc: DateTime.utc(2026, 5, 3, 10, 20, 30),
    );

    expect(manifest.schemaVersion, '1');
  });

  test('createdAtUtcIso e ISO UTC', () {
    final manifest = builder.build(
      operationPlan: buildPlan(),
      createdAtUtc: DateTime.utc(2026, 5, 3, 10, 20, 30),
    );

    expect(manifest.createdAtUtcIso.endsWith('Z'), isTrue);
  });

  test('mode e transferAction usam .name', () {
    final manifest = builder.build(
      operationPlan: buildPlan(),
      createdAtUtc: DateTime.utc(2026, 5, 3, 10, 20, 30),
    );

    expect(manifest.mode, 'renameInPlace');
    expect(manifest.transferAction, 'rename');
  });

  test('summary copia total ready skipped blocked do operationPlan', () {
    final manifest = builder.build(
      operationPlan: buildPlan(),
      createdAtUtc: DateTime.utc(2026, 5, 3, 10, 20, 30),
    );

    expect(manifest.summary.totalCount, 2);
    expect(manifest.summary.readyCount, 1);
    expect(manifest.summary.skippedCount, 0);
    expect(manifest.summary.blockedCount, 1);
  });

  test('warningCount soma warnings do plano e dos itens', () {
    final manifest = builder.build(
      operationPlan: buildPlan(),
      createdAtUtc: DateTime.utc(2026, 5, 3, 10, 20, 30),
    );

    expect(manifest.summary.warningCount, 2);
  });

  test('items sao convertidos preservando campos principais', () {
    final manifest = builder.build(
      operationPlan: buildPlan(),
      createdAtUtc: DateTime.utc(2026, 5, 3, 10, 20, 30),
    );

    final item = manifest.items.first;
    expect(item.originalFileName, 'Tempo Perdido - Legiao Urbana.mp4');
    expect(
      item.suggestedOfficialFileName,
      'Legiao Urbana - Tempo Perdido - 00006.mp4',
    );
    expect(
      item.sourcePathPreview,
      'C:/Novas/Tempo Perdido - Legiao Urbana.mp4',
    );
    expect(
      item.destinationPathPreview,
      'C:/Novas/Legiao Urbana - Tempo Perdido - 00006.mp4',
    );
    expect(item.status, 'ready');
    expect(item.action, 'rename');
    expect(item.warnings, contains('Warning item'));
  });

  test('toMap do Manifest contem chaves principais', () {
    final manifest = builder.build(
      operationPlan: buildPlan(),
      createdAtUtc: DateTime.utc(2026, 5, 3, 10, 20, 30),
    );

    final map = manifest.toMap();
    expect(map.containsKey('schemaVersion'), isTrue);
    expect(map.containsKey('createdAtUtcIso'), isTrue);
    expect(map.containsKey('mode'), isTrue);
    expect(map.containsKey('transferAction'), isTrue);
    expect(map.containsKey('summary'), isTrue);
    expect(map.containsKey('items'), isTrue);
    expect(map.containsKey('warnings'), isTrue);
  });

  test('toMap do item contem chaves esperadas', () {
    final manifest = builder.build(
      operationPlan: buildPlan(),
      createdAtUtc: DateTime.utc(2026, 5, 3, 10, 20, 30),
    );

    final map = manifest.items.first.toMap();
    expect(map.containsKey('originalFileName'), isTrue);
    expect(map.containsKey('suggestedOfficialFileName'), isTrue);
    expect(map.containsKey('sourcePathPreview'), isTrue);
    expect(map.containsKey('destinationPathPreview'), isTrue);
    expect(map.containsKey('sourceFolderPath'), isTrue);
    expect(map.containsKey('destinationFolderPath'), isTrue);
    expect(map.containsKey('action'), isTrue);
    expect(map.containsKey('status'), isTrue);
    expect(map.containsKey('warnings'), isTrue);
  });

  test('hasWarnings true quando manifesto tem warning no plano', () {
    final manifest = builder.build(
      operationPlan: buildPlan(),
      createdAtUtc: DateTime.utc(2026, 5, 3, 10, 20, 30),
    );

    expect(manifest.hasWarnings, isTrue);
  });

  test('hasWarnings true quando item tem warning', () {
    const plan = OutputOperationPlan(
      mode: OutputOperationMode.renameInPlace,
      transferAction: OutputTransferAction.rename,
      items: [
        OutputOperationItem(
          originalFileName: 'a.mp4',
          sourceFolderPath: null,
          destinationFolderPath: null,
          sourcePathPreview: 'a.mp4',
          destinationPathPreview: 'b.mp4',
          suggestedOfficialFileName: 'b.mp4',
          action: OutputTransferAction.rename,
          status: OutputOperationItemStatus.ready,
          warnings: ['warning'],
        ),
      ],
      warnings: [],
    );

    final manifest = builder.build(
      operationPlan: plan,
      createdAtUtc: DateTime.utc(2026, 5, 3, 10, 20, 30),
    );

    expect(manifest.hasWarnings, isTrue);
  });

  test('itemCount reflete quantidade de itens', () {
    final manifest = builder.build(
      operationPlan: buildPlan(),
      createdAtUtc: DateTime.utc(2026, 5, 3, 10, 20, 30),
    );

    expect(manifest.itemCount, 2);
  });

  test('converte createdAt nao UTC para UTC', () {
    final manifest = builder.build(
      operationPlan: buildPlan(),
      createdAtUtc: DateTime(2026, 5, 3, 10, 20, 30),
    );

    final parsed = DateTime.parse(manifest.createdAtUtcIso);
    expect(parsed.isUtc, isTrue);
  });
}
