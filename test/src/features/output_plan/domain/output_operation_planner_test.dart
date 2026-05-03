import 'package:flutter_test/flutter_test.dart';
import 'package:studiobox_music_importer/src/features/import_planner/domain/import_candidate_status.dart';
import 'package:studiobox_music_importer/src/features/import_planner/domain/import_suggestion_candidate.dart';
import 'package:studiobox_music_importer/src/features/import_planner/domain/import_suggestion_plan.dart';
import 'package:studiobox_music_importer/src/features/incoming_songs/domain/incoming_song_name_analysis.dart';
import 'package:studiobox_music_importer/src/features/incoming_songs/domain/incoming_song_parse_confidence.dart';
import 'package:studiobox_music_importer/src/features/output_plan/domain/output_operation_item_status.dart';
import 'package:studiobox_music_importer/src/features/output_plan/domain/output_operation_mode.dart';
import 'package:studiobox_music_importer/src/features/output_plan/domain/output_operation_planner.dart';
import 'package:studiobox_music_importer/src/features/output_plan/domain/output_transfer_action.dart';

void main() {
  final planner = OutputOperationPlanner();

  IncomingSongNameAnalysis validAnalysis({List<String> warnings = const []}) {
    return IncomingSongNameAnalysis(
      originalFileName: 'x.mp4',
      cleanedName: 'x',
      detectedArtist: 'Legiao Urbana',
      detectedTitle: 'Tempo Perdido',
      detectedExtra: null,
      confidence: IncomingSongParseConfidence.high,
      warnings: warnings,
    );
  }

  IncomingSongNameAnalysis failedAnalysis() {
    return const IncomingSongNameAnalysis(
      originalFileName: 'x.mp4',
      cleanedName: 'x',
      detectedArtist: null,
      detectedTitle: null,
      detectedExtra: null,
      confidence: IncomingSongParseConfidence.failed,
      warnings: ['Falha'],
    );
  }

  ImportSuggestionCandidate candidate({
    required String originalFileName,
    required ImportCandidateStatus status,
    required String? suggestedOfficialFileName,
    IncomingSongNameAnalysis? analysis,
    List<String> warnings = const [],
  }) {
    return ImportSuggestionCandidate(
      originalFileName: originalFileName,
      analysis: analysis ?? validAnalysis(warnings: warnings),
      suggestedCode: suggestedOfficialFileName == null ? null : '00006',
      suggestedOfficialFileName: suggestedOfficialFileName,
      status: status,
      duplicateMatch: null,
      warnings: warnings,
    );
  }

  ImportSuggestionPlan planWithCandidates(List<ImportSuggestionCandidate> c) {
    return ImportSuggestionPlan(candidates: c, warnings: const []);
  }

  test('renameInPlace com autoApproved gera item ready', () {
    final plan = planner.buildPlan(
      suggestionPlan: planWithCandidates([
        candidate(
          originalFileName: 'Tempo Perdido - Legiao Urbana.mp4',
          status: ImportCandidateStatus.autoApproved,
          suggestedOfficialFileName:
              'Legiao Urbana - Tempo Perdido - 00006.mp4',
        ),
      ]),
      mode: OutputOperationMode.renameInPlace,
      transferAction: OutputTransferAction.rename,
      sourceFolderPath: 'C:/Novas',
    );

    final item = plan.items.first;
    expect(item.status, OutputOperationItemStatus.ready);
    expect(item.action, OutputTransferAction.rename);
    expect(
      item.sourcePathPreview,
      'C:/Novas/Tempo Perdido - Legiao Urbana.mp4',
    );
    expect(
      item.destinationPathPreview,
      'C:/Novas/Legiao Urbana - Tempo Perdido - 00006.mp4',
    );
  });

  test('renameInPlace sem sourceFolderPath gera preview com nome final', () {
    final plan = planner.buildPlan(
      suggestionPlan: planWithCandidates([
        candidate(
          originalFileName: 'Tempo Perdido - Legiao Urbana.mp4',
          status: ImportCandidateStatus.autoApproved,
          suggestedOfficialFileName:
              'Legiao Urbana - Tempo Perdido - 00006.mp4',
        ),
      ]),
      mode: OutputOperationMode.renameInPlace,
      transferAction: OutputTransferAction.rename,
    );

    final item = plan.items.first;
    expect(item.sourcePathPreview, 'Tempo Perdido - Legiao Urbana.mp4');
    expect(
      item.destinationPathPreview,
      'Legiao Urbana - Tempo Perdido - 00006.mp4',
    );
  });

  test('officialLibrary com copy usa officialLibraryFolderPath', () {
    final plan = planner.buildPlan(
      suggestionPlan: planWithCandidates([
        candidate(
          originalFileName: 'a.mp4',
          status: ImportCandidateStatus.autoApproved,
          suggestedOfficialFileName: 'Legiao Urbana - A - 00006.mp4',
        ),
      ]),
      mode: OutputOperationMode.officialLibrary,
      transferAction: OutputTransferAction.copy,
      officialLibraryFolderPath: 'C:/Biblioteca',
    );

    expect(plan.items.first.action, OutputTransferAction.copy);
    expect(
      plan.items.first.destinationPathPreview,
      'C:/Biblioteca/Legiao Urbana - A - 00006.mp4',
    );
  });

  test('officialLibrary com move usa officialLibraryFolderPath', () {
    final plan = planner.buildPlan(
      suggestionPlan: planWithCandidates([
        candidate(
          originalFileName: 'a.mp4',
          status: ImportCandidateStatus.autoApproved,
          suggestedOfficialFileName: 'Legiao Urbana - A - 00006.mp4',
        ),
      ]),
      mode: OutputOperationMode.officialLibrary,
      transferAction: OutputTransferAction.move,
      officialLibraryFolderPath: 'C:/Biblioteca',
    );

    expect(plan.items.first.action, OutputTransferAction.move);
    expect(
      plan.items.first.destinationPathPreview,
      'C:/Biblioteca/Legiao Urbana - A - 00006.mp4',
    );
  });

  test('customOutputFolder com copy usa customOutputFolderPath', () {
    final plan = planner.buildPlan(
      suggestionPlan: planWithCandidates([
        candidate(
          originalFileName: 'a.mp4',
          status: ImportCandidateStatus.autoApproved,
          suggestedOfficialFileName: 'Legiao Urbana - A - 00006.mp4',
        ),
      ]),
      mode: OutputOperationMode.customOutputFolder,
      transferAction: OutputTransferAction.copy,
      customOutputFolderPath: 'C:/Saida',
    );

    expect(plan.items.first.action, OutputTransferAction.copy);
    expect(
      plan.items.first.destinationPathPreview,
      'C:/Saida/Legiao Urbana - A - 00006.mp4',
    );
  });

  test('customOutputFolder sem pasta bloqueia item', () {
    final plan = planner.buildPlan(
      suggestionPlan: planWithCandidates([
        candidate(
          originalFileName: 'a.mp4',
          status: ImportCandidateStatus.autoApproved,
          suggestedOfficialFileName: 'Legiao Urbana - A - 00006.mp4',
        ),
      ]),
      mode: OutputOperationMode.customOutputFolder,
      transferAction: OutputTransferAction.copy,
    );

    expect(plan.items.first.status, OutputOperationItemStatus.blocked);
    expect(
      plan.items.first.warnings,
      contains('Pasta de destino nao informada.'),
    );
  });

  test('needsReview fica skipped por padrao', () {
    final plan = planner.buildPlan(
      suggestionPlan: planWithCandidates([
        candidate(
          originalFileName: 'a.mp4',
          status: ImportCandidateStatus.needsReview,
          suggestedOfficialFileName: 'Legiao Urbana - A - 00006.mp4',
        ),
      ]),
      mode: OutputOperationMode.renameInPlace,
      transferAction: OutputTransferAction.rename,
    );

    expect(plan.items.first.status, OutputOperationItemStatus.skipped);
  });

  test('needsReview vira ready quando includeNeedsReview true', () {
    final plan = planner.buildPlan(
      suggestionPlan: planWithCandidates([
        candidate(
          originalFileName: 'a.mp4',
          status: ImportCandidateStatus.needsReview,
          suggestedOfficialFileName: 'Legiao Urbana - A - 00006.mp4',
        ),
      ]),
      mode: OutputOperationMode.renameInPlace,
      transferAction: OutputTransferAction.rename,
      includeNeedsReview: true,
    );

    expect(plan.items.first.status, OutputOperationItemStatus.ready);
  });

  test('blocked do import planner continua blocked', () {
    final plan = planner.buildPlan(
      suggestionPlan: planWithCandidates([
        candidate(
          originalFileName: 'a.mp4',
          status: ImportCandidateStatus.blocked,
          suggestedOfficialFileName: 'Legiao Urbana - A - 00006.mp4',
          analysis: failedAnalysis(),
        ),
      ]),
      mode: OutputOperationMode.renameInPlace,
      transferAction: OutputTransferAction.rename,
    );

    expect(plan.items.first.status, OutputOperationItemStatus.blocked);
    expect(
      plan.items.first.warnings,
      contains('Item bloqueado no plano de importacao.'),
    );
  });

  test('candidato sem suggestedOfficialFileName fica blocked', () {
    final plan = planner.buildPlan(
      suggestionPlan: planWithCandidates([
        candidate(
          originalFileName: 'a.mp4',
          status: ImportCandidateStatus.autoApproved,
          suggestedOfficialFileName: null,
        ),
      ]),
      mode: OutputOperationMode.renameInPlace,
      transferAction: OutputTransferAction.rename,
    );

    expect(plan.items.first.status, OutputOperationItemStatus.blocked);
    expect(
      plan.items.first.warnings,
      contains('Nome oficial sugerido indisponivel.'),
    );
  });

  test('combinacao invalida renameInPlace + copy gera warning e bloqueia', () {
    final plan = planner.buildPlan(
      suggestionPlan: planWithCandidates([
        candidate(
          originalFileName: 'a.mp4',
          status: ImportCandidateStatus.autoApproved,
          suggestedOfficialFileName: 'Legiao Urbana - A - 00006.mp4',
        ),
      ]),
      mode: OutputOperationMode.renameInPlace,
      transferAction: OutputTransferAction.copy,
    );

    expect(plan.warnings, contains('Combinacao de modo e acao invalida.'));
    expect(plan.items.first.status, OutputOperationItemStatus.blocked);
  });

  test(
    'combinacao invalida officialLibrary + rename gera warning e bloqueia',
    () {
      final plan = planner.buildPlan(
        suggestionPlan: planWithCandidates([
          candidate(
            originalFileName: 'a.mp4',
            status: ImportCandidateStatus.autoApproved,
            suggestedOfficialFileName: 'Legiao Urbana - A - 00006.mp4',
          ),
        ]),
        mode: OutputOperationMode.officialLibrary,
        transferAction: OutputTransferAction.rename,
        officialLibraryFolderPath: 'C:/Biblioteca',
      );

      expect(plan.warnings, contains('Combinacao de modo e acao invalida.'));
      expect(plan.items.first.status, OutputOperationItemStatus.blocked);
    },
  );

  test('plan counts total/ready/skipped/blocked corretamente', () {
    final plan = planner.buildPlan(
      suggestionPlan: planWithCandidates([
        candidate(
          originalFileName: 'ready.mp4',
          status: ImportCandidateStatus.autoApproved,
          suggestedOfficialFileName: 'Legiao Urbana - Ready - 00006.mp4',
        ),
        candidate(
          originalFileName: 'review.mp4',
          status: ImportCandidateStatus.needsReview,
          suggestedOfficialFileName: 'Legiao Urbana - Review - 00007.mp4',
        ),
        candidate(
          originalFileName: 'blocked.mp4',
          status: ImportCandidateStatus.blocked,
          suggestedOfficialFileName: null,
          analysis: failedAnalysis(),
        ),
      ]),
      mode: OutputOperationMode.renameInPlace,
      transferAction: OutputTransferAction.rename,
    );

    expect(plan.totalCount, 3);
    expect(plan.readyCount, 1);
    expect(plan.skippedCount, 1);
    expect(plan.blockedCount, 1);
  });

  test('plan warnings indicam skipped e blocked', () {
    final plan = planner.buildPlan(
      suggestionPlan: planWithCandidates([
        candidate(
          originalFileName: 'review.mp4',
          status: ImportCandidateStatus.needsReview,
          suggestedOfficialFileName: 'Legiao Urbana - Review - 00007.mp4',
        ),
        candidate(
          originalFileName: 'blocked.mp4',
          status: ImportCandidateStatus.blocked,
          suggestedOfficialFileName: null,
          analysis: failedAnalysis(),
        ),
      ]),
      mode: OutputOperationMode.renameInPlace,
      transferAction: OutputTransferAction.rename,
    );

    expect(plan.warnings, contains('Existem itens aguardando revisao.'));
    expect(plan.warnings, contains('Existem itens bloqueados.'));
  });

  test('warnings do candidato sao preservados no item', () {
    final plan = planner.buildPlan(
      suggestionPlan: planWithCandidates([
        candidate(
          originalFileName: 'warn.mp4',
          status: ImportCandidateStatus.autoApproved,
          suggestedOfficialFileName: 'Legiao Urbana - Warn - 00006.mp4',
          warnings: const ['Warning original'],
        ),
      ]),
      mode: OutputOperationMode.renameInPlace,
      transferAction: OutputTransferAction.rename,
    );

    expect(plan.items.first.warnings, contains('Warning original'));
  });
}
