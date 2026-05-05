import 'package:flutter/material.dart';

import '../../base_library/application/official_library_scan_service.dart';
import '../../base_library/domain/base_library.dart';
import '../../folder_selection/application/folder_picker_service.dart';
import '../../import_planner/domain/import_planner.dart';
import '../../incoming_songs/application/incoming_songs_scan_service.dart';
import '../../incoming_songs/domain/incoming_songs.dart';
import '../../library_repair/application/duplicate_code_repair_executor.dart';
import '../../library_repair/application/invalid_file_repair_executor.dart';
import '../../library_repair/domain/library_repair.dart';
import '../../output_plan/domain/output_plan.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({
    super.key,
    FolderPickerService? folderPickerService,
    OfficialLibraryScanService? officialLibraryScanService,
    DuplicateCodeRepairExecutor? duplicateCodeRepairExecutor,
    InvalidFileRepairExecutor? invalidFileRepairExecutor,
    IncomingSongsScanService? incomingSongsScanService,
  }) : folderPickerService = folderPickerService ?? const FolderPickerService(),
       officialLibraryScanService =
           officialLibraryScanService ?? OfficialLibraryScanService(),
       duplicateCodeRepairExecutor =
           duplicateCodeRepairExecutor ?? DuplicateCodeRepairExecutor(),
       invalidFileRepairExecutor =
           invalidFileRepairExecutor ?? InvalidFileRepairExecutor(),
       incomingSongsScanService =
           incomingSongsScanService ?? IncomingSongsScanService();

  final FolderPickerService folderPickerService;
  final OfficialLibraryScanService officialLibraryScanService;
  final DuplicateCodeRepairExecutor duplicateCodeRepairExecutor;
  final InvalidFileRepairExecutor invalidFileRepairExecutor;
  final IncomingSongsScanService incomingSongsScanService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int _auditListLimit = 50;
  static const int _repairGroupLimit = 50;
  static const int _repairItemsPerGroupLimit = 20;
  static const int _executionItemsLimit = 100;
  static const int _invalidFileRepairItemsLimit = 100;

  String? _officialLibraryFolderPath;
  bool _selectingOfficialFolder = false;
  String? _folderSelectionMessage;

  String? _incomingSongsFolderPath;
  bool _selectingIncomingSongsFolder = false;
  String? _incomingSongsFolderSelectionMessage;
  bool _scanningIncomingSongsFolder = false;
  IncomingSongsScanResult? _incomingSongsScanResult;
  String? _incomingSongsScanMessage;
  IncomingSongCleaningPreviewPlan? _incomingSongCleaningPreviewPlan;
  bool _showIncomingSongCleaningPreview = false;
  String? _incomingSongCleaningMessage;
  ImportSuggestionPlan? _importSuggestionPlan;
  bool _showImportSuggestionPlan = false;
  String? _importSuggestionMessage;
  ImportCandidateSelectionPlan? _importCandidateSelectionPlan;
  String? _importCandidateSelectionMessage;
  ImportCandidateEditPlan? _importCandidateEditPlan;
  String? _importCandidateEditMessage;
  ImportOutputMode _importOutputMode = ImportOutputMode.renameInIncomingFolder;
  String? _customImportOutputFolderPath;
  bool _selectingImportOutputFolder = false;
  ImportOutputConfigurationValidationResult? _importOutputValidationResult;
  String? _importOutputMessage;
  ImportOperationDryRunPlan? _importOperationDryRunPlan;
  bool _showImportOperationDryRun = false;
  String? _importOperationDryRunMessage;
  bool _showReadyImportCandidates = true;
  bool _showReviewImportCandidates = true;
  bool _showBlockedImportCandidates = true;
  bool _showDuplicateImportCandidates = false;

  bool _indexingOfficialLibrary = false;
  BaseLibraryIndexResult? _officialLibraryIndexResult;
  String? _officialLibraryIndexMessage;
  bool _showInvalidFiles = false;
  bool _showDuplicateCodes = false;
  DuplicateCodeRepairPlan? _duplicateCodeRepairPlan;
  bool _showDuplicateRepairPlan = false;
  String? _duplicateRepairMessage;
  DuplicateCodeRepairExecutionPlan? _duplicateRepairExecutionPlan;
  bool _showDuplicateRepairExecutionPlan = false;
  String? _duplicateRepairExecutionMessage;
  bool _confirmDuplicateRepairExecution = false;
  String _duplicateRepairConfirmationText = '';
  bool _executingDuplicateRepair = false;
  DuplicateCodeRepairExecutionResult? _duplicateRepairExecutionResult;
  String? _duplicateRepairExecutionResultMessage;
  InvalidFileRepairPlan? _invalidFileRepairPlan;
  bool _showInvalidFileRepairPlan = false;
  String? _invalidFileRepairMessage;
  InvalidFileRepairExecutionPlan? _invalidFileRepairExecutionPlan;
  bool _showInvalidFileRepairExecutionPlan = false;
  String? _invalidFileRepairExecutionMessage;
  bool _confirmInvalidRepairExecution = false;
  String _invalidRepairConfirmationText = '';
  bool _executingInvalidRepair = false;
  InvalidFileRepairExecutionResult? _invalidRepairExecutionResult;
  String? _invalidRepairExecutionResultMessage;

  late final TextEditingController _duplicateRepairConfirmationController;
  late final TextEditingController _invalidRepairConfirmationController;

  @override
  void initState() {
    super.initState();
    _duplicateRepairConfirmationController = TextEditingController();
    _invalidRepairConfirmationController = TextEditingController();
  }

  @override
  void dispose() {
    _duplicateRepairConfirmationController.dispose();
    _invalidRepairConfirmationController.dispose();
    super.dispose();
  }

  Future<void> _selectIncomingSongsFolder() async {
    if (_selectingIncomingSongsFolder) {
      return;
    }

    setState(() {
      _selectingIncomingSongsFolder = true;
    });

    final selectedFolder = await widget.folderPickerService
        .pickIncomingSongsFolder();

    if (!mounted) {
      return;
    }

    setState(() {
      _selectingIncomingSongsFolder = false;

      if (selectedFolder == null) {
        _incomingSongsFolderSelectionMessage = 'Selecao cancelada.';
        return;
      }

      _incomingSongsFolderPath = selectedFolder.path;
      _incomingSongsFolderSelectionMessage =
          'Pasta de musicas novas selecionada.';
      _incomingSongsScanResult = null;
      _incomingSongsScanMessage = null;
      _incomingSongCleaningPreviewPlan = null;
      _showIncomingSongCleaningPreview = false;
      _incomingSongCleaningMessage = null;
      _importSuggestionPlan = null;
      _showImportSuggestionPlan = false;
      _importSuggestionMessage = null;
      _resetImportSelection();
    });
  }

  Future<void> _scanIncomingSongsFolder() async {
    if (_scanningIncomingSongsFolder) {
      return;
    }

    if (_incomingSongsFolderPath == null ||
        _incomingSongsFolderPath!.trim().isEmpty) {
      setState(() {
        _incomingSongsScanMessage =
            'Selecione a pasta de mÃºsicas novas antes de escanear.';
      });
      return;
    }

    setState(() {
      _scanningIncomingSongsFolder = true;
      _incomingSongsScanMessage = null;
    });

    final result = await widget.incomingSongsScanService.scanFolder(
      _incomingSongsFolderPath!,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _scanningIncomingSongsFolder = false;
      _incomingSongsScanResult = result;
      _incomingSongsScanMessage = 'Pasta de mÃºsicas novas escaneada.';
      _incomingSongCleaningPreviewPlan = null;
      _showIncomingSongCleaningPreview = false;
      _incomingSongCleaningMessage = null;
      _importSuggestionPlan = null;
      _showImportSuggestionPlan = false;
      _importSuggestionMessage = null;
      _resetImportSelection();
    });
  }

  void _generateIncomingSongCleaningPreview() {
    final scanResult = _incomingSongsScanResult;
    if (scanResult == null || scanResult.totalCount == 0) {
      setState(() {
        _incomingSongCleaningMessage =
            'Escaneie a pasta de mÃºsicas novas antes da prÃ©-limpeza.';
      });
      return;
    }

    final plan = IncomingSongNameCleaner().buildPreview(
      scanResult: scanResult,
      rules: IncomingSongCleaningRule.defaultRules(),
    );

    setState(() {
      _incomingSongCleaningPreviewPlan = plan;
      _showIncomingSongCleaningPreview = true;
      _incomingSongCleaningMessage = 'PrÃ©-limpeza de nomes gerada.';
      _importSuggestionPlan = null;
      _showImportSuggestionPlan = false;
      _importSuggestionMessage = null;
      _resetImportSelection();
    });
  }

  List<ImportSuggestionCandidate> _readyImportCandidates() =>
      (_importSuggestionPlan?.candidates ?? [])
          .where(
            (c) =>
                c.status == ImportCandidateStatus.autoApproved &&
                !c.hasDuplicate,
          )
          .toList();

  List<ImportSuggestionCandidate> _reviewImportCandidates() =>
      (_importSuggestionPlan?.candidates ?? [])
          .where((c) => c.needsReview)
          .toList();

  List<ImportSuggestionCandidate> _blockedImportCandidates() =>
      (_importSuggestionPlan?.candidates ?? [])
          .where((c) => c.isBlocked)
          .toList();

  List<ImportSuggestionCandidate> _duplicateImportCandidates() =>
      (_importSuggestionPlan?.candidates ?? [])
          .where((c) => c.hasDuplicate)
          .toList();

  List<ImportCandidateSelectionItem> _selectionItemsForDisplay() =>
      (_importCandidateSelectionPlan?.items ?? []).take(100).toList();

  List<ImportCandidateEditItem> _editItemsForDisplay() =>
      (_importCandidateEditPlan?.items ?? []).take(50).toList();

  List<ImportOperationDryRunItem> _dryRunItemsForDisplay() =>
      (_importOperationDryRunPlan?.items ?? []).take(100).toList();

  void _resetImportOperationDryRun() {
    _importOperationDryRunPlan = null;
    _showImportOperationDryRun = false;
    _importOperationDryRunMessage = null;
  }

  void _resetImportSelection() {
    _importCandidateSelectionPlan = null;
    _importCandidateSelectionMessage = null;
    _importCandidateEditPlan = null;
    _importCandidateEditMessage = null;
    _importOutputMode = ImportOutputMode.renameInIncomingFolder;
    _customImportOutputFolderPath = null;
    _selectingImportOutputFolder = false;
    _importOutputValidationResult = null;
    _importOutputMessage = null;
    _resetImportOperationDryRun();
  }

  ImportOutputConfiguration _buildImportOutputConfiguration() {
    return ImportOutputConfiguration(
      mode: _importOutputMode,
      incomingSongsFolderPath: _incomingSongsFolderPath,
      officialLibraryFolderPath: _officialLibraryFolderPath,
      customOutputFolderPath: _customImportOutputFolderPath,
    );
  }

  void _validateImportOutputConfiguration({bool setSuccessMessage = false}) {
    final selectionPlan = _importCandidateSelectionPlan;
    final editPlan = _importCandidateEditPlan;
    if (selectionPlan == null || editPlan == null) {
      return;
    }

    final result = ImportOutputConfigurationValidator().validate(
      configuration: _buildImportOutputConfiguration(),
      selectionPlan: selectionPlan,
      editPlan: editPlan,
    );

    setState(() {
      _importOutputValidationResult = result;
      if (setSuccessMessage) {
        _importOutputMessage = 'Configuracao de saida validada.';
      }
      _resetImportOperationDryRun();
    });
  }

  Future<void> _selectImportOutputFolder() async {
    if (_selectingImportOutputFolder) {
      return;
    }

    setState(() {
      _selectingImportOutputFolder = true;
    });

    final selectedFolder = await widget.folderPickerService
        .pickImportOutputFolder();

    if (!mounted) {
      return;
    }

    if (selectedFolder == null) {
      setState(() {
        _selectingImportOutputFolder = false;
        _importOutputMessage = 'Selecao cancelada.';
        _resetImportOperationDryRun();
      });
      return;
    }

    setState(() {
      _selectingImportOutputFolder = false;
      _customImportOutputFolderPath = selectedFolder.path;
      _importOutputMessage = 'Pasta de saida selecionada.';
      _resetImportOperationDryRun();
    });
    _validateImportOutputConfiguration();
  }

  void _selectAllReadyCandidates() {
    final plan = _importCandidateSelectionPlan;
    if (plan == null) {
      return;
    }

    setState(() {
      _importCandidateSelectionPlan = plan.selectAllReady();
      _importCandidateSelectionMessage =
          'Selecionados todos os candidatos prontos.';
      _resetImportOperationDryRun();
    });
    _validateImportOutputConfiguration();
  }

  void _clearSelectedCandidates() {
    final plan = _importCandidateSelectionPlan;
    if (plan == null) {
      return;
    }

    setState(() {
      _importCandidateSelectionPlan = plan.clearSelection();
      _importCandidateSelectionMessage = 'Selecao de candidatos limpa.';
      _resetImportOperationDryRun();
    });
    _validateImportOutputConfiguration();
  }

  void _updateCandidateArtist({required String id, required String value}) {
    setState(() {
      _importCandidateEditPlan = _importCandidateEditPlan?.withManualEdit(
        id: id,
        artist: value,
      );
      _resetImportOperationDryRun();
    });
    _validateImportOutputConfiguration();
  }

  void _updateCandidateTitle({required String id, required String value}) {
    setState(() {
      _importCandidateEditPlan = _importCandidateEditPlan?.withManualEdit(
        id: id,
        title: value,
      );
      _resetImportOperationDryRun();
    });
    _validateImportOutputConfiguration();
  }

  void _updateCandidateCode({required String id, required String value}) {
    setState(() {
      _importCandidateEditPlan = _importCandidateEditPlan?.withManualEdit(
        id: id,
        code: value,
      );
      _resetImportOperationDryRun();
    });
    _validateImportOutputConfiguration();
  }

  void _generateImportSuggestions() {
    final baseIndex = _officialLibraryIndexResult;
    if (baseIndex == null) {
      setState(() {
        _importSuggestionMessage =
            'Indexe a biblioteca oficial antes de gerar sugestÃµes.';
      });
      return;
    }

    final cleaningPlan = _incomingSongCleaningPreviewPlan;
    final scanResult = _incomingSongsScanResult;

    final List<String> fileNames;
    if (cleaningPlan != null) {
      fileNames = cleaningPlan.items.map((i) => i.cleanedFileName).toList();
    } else if (scanResult != null && scanResult.hasFiles) {
      fileNames = scanResult.files.map((f) => f.fileName).toList();
    } else {
      setState(() {
        _importSuggestionMessage =
            'Escaneie a pasta de mÃºsicas novas antes de gerar sugestÃµes.';
      });
      return;
    }

    if (fileNames.isEmpty) {
      setState(() {
        _importSuggestionMessage =
            'Nenhum arquivo novo para sugerir importaÃ§Ã£o.';
      });
      return;
    }

    final plan = ImportSuggestionPlanner().buildPlan(
      incomingFileNames: fileNames,
      baseIndex: baseIndex,
      codeStrategy: SongCodeAllocationStrategy.fillGapsFirst,
    );
    final selectionPlan = ImportCandidateSelectionPlanner().buildInitialPlan(
      plan,
    );
    final editPlan = ImportCandidateEditPlanner().buildInitialPlan(
      baseIndex: baseIndex,
      selectionPlan: selectionPlan,
    );
    final initialOutputValidation = ImportOutputConfigurationValidator()
        .validate(
          configuration: ImportOutputConfiguration(
            mode: ImportOutputMode.renameInIncomingFolder,
            incomingSongsFolderPath: _incomingSongsFolderPath,
            officialLibraryFolderPath: _officialLibraryFolderPath,
            customOutputFolderPath: null,
          ),
          selectionPlan: selectionPlan,
          editPlan: editPlan,
        );

    setState(() {
      _resetImportSelection();
      _importSuggestionPlan = plan;
      _importCandidateSelectionPlan = selectionPlan;
      _importCandidateSelectionMessage =
          'Selecao inicial dos candidatos preparada.';
      _importCandidateEditPlan = editPlan;
      _importCandidateEditMessage = 'Edicao manual dos candidatos preparada.';
      _importOutputValidationResult = initialOutputValidation;
      _showImportSuggestionPlan = true;
      _importSuggestionMessage = 'SugestÃµes de importaÃ§Ã£o geradas.';
      _showReadyImportCandidates = true;
      _showReviewImportCandidates = true;
      _showBlockedImportCandidates = true;
      _showDuplicateImportCandidates = false;
    });
  }

  void _generateImportOperationDryRun() {
    final selectionPlan = _importCandidateSelectionPlan;
    final editPlan = _importCandidateEditPlan;
    final cleaningPlan = _incomingSongCleaningPreviewPlan;
    if (selectionPlan == null || editPlan == null || cleaningPlan == null) {
      setState(() {
        _importOperationDryRunMessage =
            'Prepare selecao, edicao e pre-limpeza antes do dry-run.';
      });
      return;
    }

    final outputValidation = ImportOutputConfigurationValidator().validate(
      configuration: _buildImportOutputConfiguration(),
      selectionPlan: selectionPlan,
      editPlan: editPlan,
    );
    final dryRunPlan = ImportOperationDryRunPlanner().buildDryRun(
      outputValidationResult: outputValidation,
      selectionPlan: selectionPlan,
      editPlan: editPlan,
      cleaningPlan: cleaningPlan,
    );

    setState(() {
      _importOutputValidationResult = outputValidation;
      _importOperationDryRunPlan = dryRunPlan;
      _showImportOperationDryRun = true;
      _importOperationDryRunMessage = 'Dry-run da importacao gerado.';
    });
  }

  Future<void> _selectOfficialLibraryFolder() async {
    if (_selectingOfficialFolder) {
      return;
    }

    setState(() {
      _selectingOfficialFolder = true;
    });

    final selectedFolder = await widget.folderPickerService
        .pickOfficialLibraryFolder();

    if (!mounted) {
      return;
    }

    setState(() {
      _selectingOfficialFolder = false;

      if (selectedFolder == null) {
        _folderSelectionMessage = 'Selecao cancelada.';
        return;
      }

      _officialLibraryFolderPath = selectedFolder.path;
      _folderSelectionMessage = 'Biblioteca oficial selecionada.';
    });
  }

  Future<void> _indexOfficialLibrary() async {
    if (_indexingOfficialLibrary) {
      return;
    }

    if (_officialLibraryFolderPath == null ||
        _officialLibraryFolderPath!.trim().isEmpty) {
      setState(() {
        _officialLibraryIndexMessage =
            'Selecione a biblioteca oficial antes de indexar.';
      });
      return;
    }

    setState(() {
      _indexingOfficialLibrary = true;
      _officialLibraryIndexMessage = null;
    });

    final result = await widget.officialLibraryScanService.scanFolder(
      _officialLibraryFolderPath!,
    );

    if (!mounted) {
      return;
    }

    _duplicateRepairConfirmationController.clear();
    setState(() {
      _indexingOfficialLibrary = false;
      _officialLibraryIndexResult = result;
      _officialLibraryIndexMessage = 'Biblioteca oficial indexada.';
      _showInvalidFiles = false;
      _showDuplicateCodes = false;
      _duplicateCodeRepairPlan = null;
      _showDuplicateRepairPlan = false;
      _duplicateRepairMessage = null;
      _duplicateRepairExecutionPlan = null;
      _showDuplicateRepairExecutionPlan = false;
      _duplicateRepairExecutionMessage = null;
      _confirmDuplicateRepairExecution = false;
      _duplicateRepairConfirmationText = '';
      _executingDuplicateRepair = false;
      _duplicateRepairExecutionResult = null;
      _duplicateRepairExecutionResultMessage = null;
      _invalidFileRepairPlan = null;
      _showInvalidFileRepairPlan = false;
      _invalidFileRepairMessage = null;
      _invalidFileRepairExecutionPlan = null;
      _showInvalidFileRepairExecutionPlan = false;
      _invalidFileRepairExecutionMessage = null;
      _confirmInvalidRepairExecution = false;
      _invalidRepairConfirmationText = '';
      _executingInvalidRepair = false;
      _invalidRepairExecutionResult = null;
      _invalidRepairExecutionResultMessage = null;
      _importSuggestionPlan = null;
      _showImportSuggestionPlan = false;
      _importSuggestionMessage = null;
      _resetImportSelection();
    });
  }

  void _generateDuplicateRepairPlan() {
    final indexResult = _officialLibraryIndexResult;
    if (indexResult == null || indexResult.duplicateCodes.isEmpty) {
      setState(() {
        _duplicateRepairMessage = 'Nenhum codigo duplicado para reparar.';
      });
      return;
    }

    final plan = DuplicateCodeRepairPlanner().buildPlan(baseIndex: indexResult);

    _duplicateRepairConfirmationController.clear();
    setState(() {
      _duplicateCodeRepairPlan = plan;
      _showDuplicateRepairPlan = true;
      _duplicateRepairMessage = 'Plano de reparo de duplicados gerado.';
      _duplicateRepairExecutionPlan = null;
      _showDuplicateRepairExecutionPlan = false;
      _duplicateRepairExecutionMessage = null;
      _confirmDuplicateRepairExecution = false;
      _duplicateRepairConfirmationText = '';
      _executingDuplicateRepair = false;
      _duplicateRepairExecutionResult = null;
      _duplicateRepairExecutionResultMessage = null;
    });
  }

  void _generateDuplicateRepairExecutionDryRun() {
    final repairPlan = _duplicateCodeRepairPlan;
    if (repairPlan == null) {
      setState(() {
        _duplicateRepairExecutionMessage =
            'Gere o plano de reparo antes de validar a execucao.';
      });
      return;
    }

    final executionPlan = DuplicateCodeRepairExecutionPlanner().buildDryRun(
      repairPlan,
    );

    _duplicateRepairConfirmationController.clear();
    setState(() {
      _duplicateRepairExecutionPlan = executionPlan;
      _showDuplicateRepairExecutionPlan = true;
      _duplicateRepairExecutionMessage = 'Dry-run do reparo gerado.';
      _confirmDuplicateRepairExecution = false;
      _duplicateRepairConfirmationText = '';
      _executingDuplicateRepair = false;
      _duplicateRepairExecutionResult = null;
      _duplicateRepairExecutionResultMessage = null;
    });
  }

  void _generateInvalidFileRepairPlan() {
    final indexResult = _officialLibraryIndexResult;
    if (indexResult == null || indexResult.invalidFiles.isEmpty) {
      setState(() {
        _invalidFileRepairMessage = 'Nenhum arquivo invalido para reparar.';
      });
      return;
    }

    final plan = InvalidFileRepairPlanner().buildPlan(baseIndex: indexResult);

    _invalidRepairConfirmationController.clear();
    setState(() {
      _invalidFileRepairPlan = plan;
      _showInvalidFileRepairPlan = true;
      _invalidFileRepairMessage = 'Plano de reparo de invalidos gerado.';
      _invalidFileRepairExecutionPlan = null;
      _showInvalidFileRepairExecutionPlan = false;
      _invalidFileRepairExecutionMessage = null;
      _confirmInvalidRepairExecution = false;
      _invalidRepairConfirmationText = '';
      _executingInvalidRepair = false;
      _invalidRepairExecutionResult = null;
      _invalidRepairExecutionResultMessage = null;
    });
  }

  void _generateInvalidFileRepairExecutionDryRun() {
    final repairPlan = _invalidFileRepairPlan;
    if (repairPlan == null) {
      setState(() {
        _invalidFileRepairExecutionMessage =
            'Gere o plano de invalidos antes de validar a execucao.';
      });
      return;
    }

    final executionPlan = InvalidFileRepairExecutionPlanner().buildDryRun(
      repairPlan,
    );

    _invalidRepairConfirmationController.clear();
    setState(() {
      _invalidFileRepairExecutionPlan = executionPlan;
      _showInvalidFileRepairExecutionPlan = true;
      _invalidFileRepairExecutionMessage = 'Dry-run dos invalidos gerado.';
      _confirmInvalidRepairExecution = false;
      _invalidRepairConfirmationText = '';
      _executingInvalidRepair = false;
      _invalidRepairExecutionResult = null;
      _invalidRepairExecutionResultMessage = null;
    });
  }

  Future<void> _executeInvalidRepair() async {
    final executionPlan = _invalidFileRepairExecutionPlan;
    if (executionPlan == null || !executionPlan.hasReadyItems) {
      setState(() {
        _invalidRepairExecutionResultMessage =
            'Nenhum item pronto para executar.';
      });
      return;
    }

    if (!_confirmInvalidRepairExecution) {
      setState(() {
        _invalidRepairExecutionResultMessage =
            'Confirme a revisao do dry-run dos invalidos antes de executar.';
      });
      return;
    }

    final readyCount = executionPlan.readyToRenameCount;
    final folderPath = _officialLibraryFolderPath ?? '-';
    final shouldExecute =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Confirmar renomeio real de invalidos'),
              content: Text(
                'Voce esta prestes a renomear $readyCount arquivo(s) invalido(s) em:\n\n$folderPath\n\nEsta acao altera arquivos reais e nao possui desfazer automatico nesta fase.\n\nDeseja continuar?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Renomear arquivos invalidos reais'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldExecute) {
      setState(() {
        _invalidRepairExecutionResultMessage =
            'Execucao de invalidos cancelada.';
      });
      return;
    }

    setState(() {
      _executingInvalidRepair = true;
      _invalidRepairExecutionResultMessage = null;
    });

    final result = await widget.invalidFileRepairExecutor.execute(
      executionPlan,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _executingInvalidRepair = false;
      _invalidRepairExecutionResult = result;
      _invalidRepairExecutionResultMessage =
          'Execucao do reparo de invalidos concluida. Reindexe a biblioteca oficial para atualizar os resultados.';
    });
  }

  Future<void> _executeDuplicateRepair() async {
    final executionPlan = _duplicateRepairExecutionPlan;
    if (executionPlan == null || !executionPlan.hasReadyItems) {
      setState(() {
        _duplicateRepairExecutionResultMessage =
            'Nenhum item pronto para executar.';
      });
      return;
    }

    if (!_confirmDuplicateRepairExecution) {
      setState(() {
        _duplicateRepairExecutionResultMessage =
            'Confirme a revisao do dry-run antes de executar.';
      });
      return;
    }

    final readyCount = executionPlan.readyToRenameCount;
    final folderPath = _officialLibraryFolderPath ?? '-';
    final shouldExecute =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Confirmar renomeio real'),
              content: Text(
                'Voce esta prestes a renomear $readyCount arquivo(s) em:\n\n$folderPath\n\nEsta acao altera arquivos reais e nao possui desfazer automatico nesta fase.\n\nDeseja continuar?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Renomear arquivos reais'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldExecute) {
      setState(() {
        _duplicateRepairExecutionResultMessage = 'Execucao cancelada.';
      });
      return;
    }

    setState(() {
      _executingDuplicateRepair = true;
      _duplicateRepairExecutionResultMessage = null;
    });

    final result = await widget.duplicateCodeRepairExecutor.execute(
      executionPlan,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _executingDuplicateRepair = false;
      _duplicateRepairExecutionResult = result;
      _duplicateRepairExecutionResultMessage =
          'Execucao do reparo concluida. Reindexe a biblioteca oficial para atualizar os resultados.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final officialLibraryResult = _officialLibraryIndexResult;

    final steps = <({IconData icon, String title, String description})>[
      (
        icon: Icons.library_music,
        title: 'Biblioteca oficial',
        description:
            'Selecione futuramente a pasta onde estao as musicas ja padronizadas.',
      ),
      (
        icon: Icons.audio_file,
        title: 'Novas musicas',
        description:
            'Analise futuramente a pasta com arquivos .mp4 baixados ou recebidos.',
      ),
      (
        icon: Icons.verified_user,
        title: 'Revisao segura',
        description:
            'Confira autor, musica, codigo sugerido, duplicidades e avisos antes de executar.',
      ),
      (
        icon: Icons.drive_file_move,
        title: 'Saida',
        description:
            'Renomeie na propria pasta, copie/mova para a biblioteca oficial ou escolha uma pasta de saida.',
      ),
    ];

    final engineItems = <String>[
      'Parser oficial',
      'Indexador em memoria',
      'Estrategia de codigos',
      'Analise inteligente',
      'Plano de importacao',
      'Plano de saida',
      'Manifesto em memoria',
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1080),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'StudioBox Music Importer',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Prepare novas musicas para o padrao do Karaoke StudioBox.',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Indexe sua biblioteca oficial, analise novos arquivos .mp4, gere codigos seguros e revise tudo antes de renomear.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  if (_importCandidateSelectionPlan != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selecao dos candidatos de importacao',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Total de candidatos: ${_importCandidateSelectionPlan!.totalCount}',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Selecionados: ${_importCandidateSelectionPlan!.selectedCount}',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Não selecionados: ${_importCandidateSelectionPlan!.notSelectedCount}',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Bloqueados: ${_importCandidateSelectionPlan!.blockedCount}',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Selecionáveis: ${_importCandidateSelectionPlan!.selectableCount}',
                            ),
                            if (_importCandidateSelectionPlan!.hasWarnings) ...[
                              const SizedBox(height: 8),
                              const Text('Avisos do plano:'),
                              const SizedBox(height: 4),
                              for (final warning
                                  in _importCandidateSelectionPlan!
                                      .warnings) ...[
                                Text('- $warning'),
                                const SizedBox(height: 2),
                              ],
                            ],
                            if (_importCandidateSelectionMessage != null) ...[
                              const SizedBox(height: 8),
                              Text(_importCandidateSelectionMessage!),
                            ],
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                OutlinedButton(
                                  onPressed: _selectAllReadyCandidates,
                                  child: const Text(
                                    'Selecionar todos os prontos',
                                  ),
                                ),
                                OutlinedButton(
                                  onPressed: _clearSelectedCandidates,
                                  child: const Text('Limpar selecao'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_importCandidateSelectionPlan!.totalCount > 100)
                              Text(
                                'Exibindo os primeiros 100 de ${_importCandidateSelectionPlan!.totalCount} candidatos para selecao.',
                              ),
                            const SizedBox(height: 8),
                            for (final item in _selectionItemsForDisplay()) ...[
                              CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                value: item.isSelected,
                                onChanged: item.selectable
                                    ? (value) {
                                        setState(() {
                                          _importCandidateSelectionPlan =
                                              _importCandidateSelectionPlan
                                                  ?.withCandidateSelection(
                                                    item.id,
                                                    value ?? false,
                                                  );
                                        });
                                        _validateImportOutputConfiguration();
                                      }
                                    : null,
                                title: Text(
                                  'Selecao: ${item.selectionStatus.label}',
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Status do candidato: ${item.candidate.status.label}',
                                    ),
                                    Text(
                                      'Arquivo: ${item.candidate.originalFileName}',
                                    ),
                                    Text(
                                      'Nome oficial sugerido: ${item.candidate.suggestedOfficialFileName ?? '-'}',
                                    ),
                                    Text(
                                      'Codigo sugerido: ${item.candidate.suggestedCode ?? '-'}',
                                    ),
                                    if (item.hasWarnings) ...[
                                      const SizedBox(height: 4),
                                      const Text('Avisos:'),
                                      for (final warning in item.warnings)
                                        Text('- $warning'),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (_importCandidateEditPlan != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Edicao manual dos candidatos',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Total de candidatos: ${_importCandidateEditPlan!.totalCount}',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Editaveis: ${_importCandidateEditPlan!.editableCount}',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Validos: ${_importCandidateEditPlan!.validCount}',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Invalidos: ${_importCandidateEditPlan!.invalidCount}',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Bloqueados: ${_importCandidateEditPlan!.blockedCount}',
                            ),
                            if (_importCandidateEditPlan!.hasWarnings) ...[
                              const SizedBox(height: 8),
                              const Text('Avisos do plano:'),
                              const SizedBox(height: 4),
                              for (final warning
                                  in _importCandidateEditPlan!.warnings) ...[
                                Text('- $warning'),
                                const SizedBox(height: 2),
                              ],
                            ],
                            if (_importCandidateEditMessage != null) ...[
                              const SizedBox(height: 8),
                              Text(_importCandidateEditMessage!),
                            ],
                            const SizedBox(height: 8),
                            if (_importCandidateEditPlan!.totalCount > 50)
                              Text(
                                'Exibindo os primeiros 50 de ${_importCandidateEditPlan!.totalCount} candidatos para edicao.',
                              ),
                            const SizedBox(height: 8),
                            for (
                              var i = 0;
                              i < _editItemsForDisplay().length;
                              i++
                            ) ...[
                              Builder(
                                builder: (context) {
                                  final item = _editItemsForDisplay()[i];
                                  return Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Status da edicao: ${item.editStatus.label}',
                                          ),
                                          Text(
                                            'Status da selecao: ${item.selectionItem.selectionStatus.label}',
                                          ),
                                          Text(
                                            'Arquivo/original: ${item.selectionItem.candidate.originalFileName}',
                                          ),
                                          Text(
                                            'Nome oficial atual: ${item.officialFileName.isEmpty ? '-' : item.officialFileName}',
                                          ),
                                          if (item.editable) ...[
                                            const SizedBox(height: 8),
                                            TextFormField(
                                              key: ValueKey(
                                                'import-edit-artist-$i',
                                              ),
                                              initialValue: item.artist,
                                              onChanged: (value) {
                                                _updateCandidateArtist(
                                                  id: item.id,
                                                  value: value,
                                                );
                                              },
                                              decoration: const InputDecoration(
                                                labelText: 'Artista',
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            TextFormField(
                                              key: ValueKey(
                                                'import-edit-title-$i',
                                              ),
                                              initialValue: item.title,
                                              onChanged: (value) {
                                                _updateCandidateTitle(
                                                  id: item.id,
                                                  value: value,
                                                );
                                              },
                                              decoration: const InputDecoration(
                                                labelText: 'Musica',
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            TextFormField(
                                              key: ValueKey(
                                                'import-edit-code-$i',
                                              ),
                                              initialValue: item.code,
                                              onChanged: (value) {
                                                _updateCandidateCode(
                                                  id: item.id,
                                                  value: value,
                                                );
                                              },
                                              decoration: const InputDecoration(
                                                labelText: 'Codigo',
                                              ),
                                            ),
                                          ] else ...[
                                            const SizedBox(height: 8),
                                            const Text(
                                              'Candidato bloqueado nao pode ser editado nesta etapa.',
                                            ),
                                          ],
                                          if (item.hasWarnings) ...[
                                            const SizedBox(height: 8),
                                            const Text('Avisos:'),
                                            for (final warning in item.warnings)
                                              Text('- $warning'),
                                          ],
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (_importCandidateSelectionPlan != null &&
                      _importCandidateEditPlan != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Modo de saida da importacao',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<ImportOutputMode>(
                              initialValue: _importOutputMode,
                              decoration: const InputDecoration(
                                labelText: 'Modo de saida',
                              ),
                              items: ImportOutputMode.values
                                  .map(
                                    (mode) => DropdownMenuItem(
                                      value: mode,
                                      child: Text(mode.label),
                                    ),
                                  )
                                  .toList(growable: false),
                              onChanged: (value) {
                                if (value == null) {
                                  return;
                                }
                                setState(() {
                                  _importOutputMode = value;
                                  _resetImportOperationDryRun();
                                });
                                _validateImportOutputConfiguration();
                              },
                            ),
                            if (_importOutputMode.targetsCustomFolder) ...[
                              const SizedBox(height: 8),
                              FilledButton.tonal(
                                onPressed: _selectingImportOutputFolder
                                    ? null
                                    : _selectImportOutputFolder,
                                child: Text(
                                  _selectingImportOutputFolder
                                      ? 'Selecionando...'
                                      : 'Selecionar pasta de saida',
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              'Pasta de musicas novas: ${_incomingSongsFolderPath ?? '-'}',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Biblioteca oficial: ${_officialLibraryFolderPath ?? '-'}',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Pasta de saida: ${_customImportOutputFolderPath ?? '-'}',
                            ),
                            const SizedBox(height: 8),
                            Text(
                              (_importOutputValidationResult?.isValid ?? false)
                                  ? 'Configuracao de saida valida.'
                                  : 'Configuracao de saida invalida.',
                            ),
                            if (_importOutputValidationResult?.hasErrors ??
                                false) ...[
                              const SizedBox(height: 8),
                              const Text('Erros:'),
                              for (final error
                                  in _importOutputValidationResult!.errors)
                                Text('- $error'),
                            ],
                            if (_importOutputValidationResult?.hasWarnings ??
                                false) ...[
                              const SizedBox(height: 8),
                              const Text('Avisos:'),
                              for (final warning
                                  in _importOutputValidationResult!.warnings)
                                Text('- $warning'),
                            ],
                            if (_importOutputMessage != null) ...[
                              const SizedBox(height: 8),
                              Text(_importOutputMessage!),
                            ],
                            const SizedBox(height: 8),
                            OutlinedButton(
                              onPressed: () {
                                _validateImportOutputConfiguration(
                                  setSuccessMessage: true,
                                );
                              },
                              child: const Text(
                                'Validar configuracao de saida',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (_importCandidateSelectionPlan != null &&
                      _importCandidateEditPlan != null &&
                      _incomingSongCleaningPreviewPlan != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                FilledButton.tonal(
                                  onPressed: _generateImportOperationDryRun,
                                  child: const Text(
                                    'Gerar dry-run da importacao',
                                  ),
                                ),
                                OutlinedButton(
                                  onPressed: _importOperationDryRunPlan == null
                                      ? null
                                      : () {
                                          setState(() {
                                            _showImportOperationDryRun =
                                                !_showImportOperationDryRun;
                                          });
                                        },
                                  child: Text(
                                    _showImportOperationDryRun
                                        ? 'Ocultar dry-run da importacao'
                                        : 'Mostrar dry-run da importacao',
                                  ),
                                ),
                              ],
                            ),
                            if (_importOperationDryRunMessage != null) ...[
                              const SizedBox(height: 8),
                              Text(_importOperationDryRunMessage!),
                            ],
                            if (_showImportOperationDryRun &&
                                _importOperationDryRunPlan != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                'Dry-run da operacao de importacao',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Total de operacoes: ${_importOperationDryRunPlan!.totalCount}',
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Prontas: ${_importOperationDryRunPlan!.readyCount}',
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Bloqueadas: ${_importOperationDryRunPlan!.blockedCount}',
                              ),
                              if (_importOperationDryRunPlan!.hasWarnings) ...[
                                const SizedBox(height: 8),
                                const Text('Avisos:'),
                                for (final warning
                                    in _importOperationDryRunPlan!.warnings)
                                  Text('- $warning'),
                              ],
                              if (_importOperationDryRunPlan!.totalCount >
                                  100) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Exibindo os primeiros 100 de ${_importOperationDryRunPlan!.totalCount} operacoes.',
                                ),
                              ],
                              const SizedBox(height: 8),
                              for (final item in _dryRunItemsForDisplay()) ...[
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Status: ${item.status.label}'),
                                        Text('Acao: ${item.action.label}'),
                                        Text(
                                          'Arquivo: ${item.originalFileName}',
                                        ),
                                        Text(
                                          'Nome oficial: ${item.officialFileName}',
                                        ),
                                        Text(
                                          'Origem: ${item.sourcePathPreview ?? '-'}',
                                        ),
                                        Text(
                                          'Destino: ${item.destinationPathPreview ?? '-'}',
                                        ),
                                        if (item.hasWarnings) ...[
                                          const SizedBox(height: 4),
                                          const Text('Avisos:'),
                                          for (final warning in item.warnings)
                                            Text('- $warning'),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      for (final step in steps)
                        SizedBox(
                          width: 250,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(step.icon, size: 28),
                                  const SizedBox(height: 12),
                                  Text(
                                    step.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(step.description),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Biblioteca oficial selecionada:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _officialLibraryFolderPath ??
                                'Nenhuma pasta selecionada.',
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: _selectingOfficialFolder
                                ? null
                                : _selectOfficialLibraryFolder,
                            child: Text(
                              _selectingOfficialFolder
                                  ? 'Selecionando...'
                                  : 'Selecionar biblioteca oficial',
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed:
                                (_indexingOfficialLibrary ||
                                    _officialLibraryFolderPath == null)
                                ? null
                                : _indexOfficialLibrary,
                            child: Text(
                              _indexingOfficialLibrary
                                  ? 'Indexando...'
                                  : 'Indexar biblioteca oficial',
                            ),
                          ),
                          if (_folderSelectionMessage != null) ...[
                            const SizedBox(height: 8),
                            Text(_folderSelectionMessage!),
                          ],
                          if (_officialLibraryIndexMessage != null) ...[
                            const SizedBox(height: 8),
                            Text(_officialLibraryIndexMessage!),
                          ],
                          if (officialLibraryResult != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              'Musicas validas: ${officialLibraryResult.validCount}',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Arquivos invalidos: ${officialLibraryResult.invalidCount}',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Codigos duplicados: ${officialLibraryResult.duplicateCodeCount}',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Maior codigo: ${officialLibraryResult.maxCodeNumber?.toString().padLeft(5, '0') ?? '-'}',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Buracos disponiveis: ${officialLibraryResult.availableCodeGaps.length}',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Artistas conhecidos: ${officialLibraryResult.knownArtists.length}',
                            ),
                            if (officialLibraryResult.hasInvalidFiles ||
                                officialLibraryResult.hasDuplicates) ...[
                              const SizedBox(height: 8),
                              const Text(
                                'Atencao: revise os problemas encontrados na auditoria.',
                              ),
                            ],
                            const SizedBox(height: 16),
                            Text(
                              'Auditoria da biblioteca oficial',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Arquivos invalidos: ${officialLibraryResult.invalidCount}',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Codigos duplicados: ${officialLibraryResult.duplicateCodeCount}',
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      _showInvalidFiles = !_showInvalidFiles;
                                    });
                                  },
                                  child: Text(
                                    _showInvalidFiles
                                        ? 'Ocultar arquivos invalidos'
                                        : 'Mostrar arquivos invalidos',
                                  ),
                                ),
                                OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      _showDuplicateCodes =
                                          !_showDuplicateCodes;
                                    });
                                  },
                                  child: Text(
                                    _showDuplicateCodes
                                        ? 'Ocultar codigos duplicados'
                                        : 'Mostrar codigos duplicados',
                                  ),
                                ),
                              ],
                            ),
                            if (_showInvalidFiles) ...[
                              const SizedBox(height: 12),
                              if (officialLibraryResult.invalidFiles.isEmpty)
                                const Text(
                                  'Nenhum arquivo invalido encontrado.',
                                )
                              else ...[
                                if (officialLibraryResult.invalidFiles.length >
                                    _auditListLimit)
                                  Text(
                                    'Exibindo os primeiros $_auditListLimit de ${officialLibraryResult.invalidFiles.length} arquivos invalidos.',
                                  ),
                                const SizedBox(height: 8),
                                for (final invalidFile
                                    in officialLibraryResult.invalidFiles.take(
                                      _auditListLimit,
                                    )) ...[
                                  const Text('Arquivo:'),
                                  Text(invalidFile.displayPath),
                                  const SizedBox(height: 2),
                                  const Text('Motivo:'),
                                  Text(invalidFile.reason),
                                  const SizedBox(height: 10),
                                ],
                              ],
                            ],
                            if (_showDuplicateCodes) ...[
                              const SizedBox(height: 12),
                              if (officialLibraryResult.duplicateCodes.isEmpty)
                                const Text(
                                  'Nenhum codigo duplicado encontrado.',
                                )
                              else ...[
                                if (officialLibraryResult
                                        .duplicateCodes
                                        .length >
                                    _auditListLimit)
                                  Text(
                                    'Exibindo os primeiros $_auditListLimit de ${officialLibraryResult.duplicateCodes.length} codigos duplicados.',
                                  ),
                                const SizedBox(height: 8),
                                for (final duplicate
                                    in officialLibraryResult.duplicateCodes
                                        .take(_auditListLimit)) ...[
                                  Text('Codigo duplicado: ${duplicate.code}'),
                                  const SizedBox(height: 4),
                                  for (final entry in duplicate.entries) ...[
                                    Text(
                                      '- ${entry.song.artist} - ${entry.song.title}',
                                    ),
                                    Text('  Arquivo: ${entry.displayPath}'),
                                    const SizedBox(height: 4),
                                  ],
                                  const SizedBox(height: 8),
                                ],
                              ],
                            ],
                            if (officialLibraryResult
                                .duplicateCodes
                                .isNotEmpty) ...[
                              const SizedBox(height: 16),
                              FilledButton.tonal(
                                onPressed: _generateDuplicateRepairPlan,
                                child: const Text(
                                  'Gerar plano de reparo de duplicados',
                                ),
                              ),
                            ],
                            if (_duplicateRepairMessage != null) ...[
                              const SizedBox(height: 8),
                              Text(_duplicateRepairMessage!),
                            ],
                            if (_duplicateCodeRepairPlan != null) ...[
                              const SizedBox(height: 12),
                              OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _showDuplicateRepairPlan =
                                        !_showDuplicateRepairPlan;
                                  });
                                },
                                child: Text(
                                  _showDuplicateRepairPlan
                                      ? 'Ocultar plano de reparo'
                                      : 'Mostrar plano de reparo',
                                ),
                              ),
                              const SizedBox(height: 8),
                              FilledButton.tonal(
                                onPressed:
                                    _generateDuplicateRepairExecutionDryRun,
                                child: const Text('Validar execucao do reparo'),
                              ),
                            ],
                            if (_duplicateRepairExecutionMessage != null) ...[
                              const SizedBox(height: 8),
                              Text(_duplicateRepairExecutionMessage!),
                            ],
                            if (_duplicateCodeRepairPlan != null &&
                                _showDuplicateRepairPlan) ...[
                              const SizedBox(height: 12),
                              Text(
                                'Plano de reparo de duplicados',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Grupos duplicados: ${_duplicateCodeRepairPlan!.totalGroups}',
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Itens que manterao codigo original: ${_duplicateCodeRepairPlan!.totalKeepOriginal}',
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Itens que receberao novo codigo: ${_duplicateCodeRepairPlan!.totalAssignNewCode}',
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Itens bloqueados: ${_duplicateCodeRepairPlan!.totalBlocked}',
                              ),
                              if (_duplicateCodeRepairPlan!.hasWarnings) ...[
                                const SizedBox(height: 8),
                                const Text('Avisos do plano:'),
                                const SizedBox(height: 4),
                                for (final warning
                                    in _duplicateCodeRepairPlan!.warnings) ...[
                                  Text('- $warning'),
                                  const SizedBox(height: 2),
                                ],
                              ],
                              const SizedBox(height: 8),
                              if (_duplicateCodeRepairPlan!.groups.length >
                                  _repairGroupLimit)
                                Text(
                                  'Exibindo os primeiros $_repairGroupLimit de ${_duplicateCodeRepairPlan!.groups.length} grupos de reparo.',
                                ),
                              const SizedBox(height: 6),
                              for (final group
                                  in _duplicateCodeRepairPlan!.groups.take(
                                    _repairGroupLimit,
                                  )) ...[
                                Text(
                                  'Codigo duplicado: ${group.duplicatedCode}',
                                ),
                                const SizedBox(height: 4),
                                if (group.items.length >
                                    _repairItemsPerGroupLimit)
                                  Text(
                                    'Exibindo os primeiros $_repairItemsPerGroupLimit de ${group.items.length} itens deste grupo.',
                                  ),
                                const SizedBox(height: 4),
                                for (final item in group.items.take(
                                  _repairItemsPerGroupLimit,
                                )) ...[
                                  if (item.keepsOriginalCode) ...[
                                    const Text('Manter codigo original:'),
                                    Text('${item.artist} - ${item.title}'),
                                    Text('Arquivo: ${item.displayPath}'),
                                    Text(
                                      'Codigo mantido: ${item.originalCode}',
                                    ),
                                  ] else if (item.assignsNewCode) ...[
                                    const Text('Atribuir novo codigo:'),
                                    Text('${item.artist} - ${item.title}'),
                                    Text('Arquivo atual: ${item.displayPath}'),
                                    Text('Novo codigo: ${item.suggestedCode}'),
                                    Text(
                                      'Novo nome sugerido: ${item.suggestedFileName}',
                                    ),
                                  ] else ...[
                                    const Text('Bloqueado:'),
                                    Text('${item.artist} - ${item.title}'),
                                    Text('Arquivo: ${item.displayPath}'),
                                    const Text('Avisos:'),
                                    for (final warning in item.warnings)
                                      Text('- $warning'),
                                  ],
                                  const SizedBox(height: 8),
                                ],
                                const SizedBox(height: 8),
                              ],
                            ],
                            if (_duplicateRepairExecutionPlan != null) ...[
                              const SizedBox(height: 12),
                              OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _showDuplicateRepairExecutionPlan =
                                        !_showDuplicateRepairExecutionPlan;
                                  });
                                },
                                child: Text(
                                  _showDuplicateRepairExecutionPlan
                                      ? 'Ocultar dry-run'
                                      : 'Mostrar dry-run',
                                ),
                              ),
                            ],
                            if (_duplicateRepairExecutionPlan != null &&
                                _showDuplicateRepairExecutionPlan) ...[
                              const SizedBox(height: 12),
                              Text(
                                'Dry-run da execucao',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Prontos para renomear: ${_duplicateRepairExecutionPlan!.readyToRenameCount}',
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ignorados: ${_duplicateRepairExecutionPlan!.skippedCount}',
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Bloqueados: ${_duplicateRepairExecutionPlan!.blockedCount}',
                              ),
                              if (_duplicateRepairExecutionPlan!
                                  .hasWarnings) ...[
                                const SizedBox(height: 8),
                                const Text('Avisos do dry-run:'),
                                const SizedBox(height: 4),
                                for (final warning
                                    in _duplicateRepairExecutionPlan!
                                        .warnings) ...[
                                  Text('- $warning'),
                                  const SizedBox(height: 2),
                                ],
                              ],
                              const SizedBox(height: 8),
                              if (_duplicateRepairExecutionPlan!.items.length >
                                  _executionItemsLimit)
                                Text(
                                  'Exibindo os primeiros $_executionItemsLimit de ${_duplicateRepairExecutionPlan!.items.length} itens do dry-run.',
                                ),
                              const SizedBox(height: 6),
                              for (final item
                                  in _duplicateRepairExecutionPlan!.items.take(
                                    _executionItemsLimit,
                                  )) ...[
                                if (item.isReadyToRename) ...[
                                  const Text('Pronto para renomear:'),
                                  Text('${item.artist} - ${item.title}'),
                                  Text('Origem: ${item.sourcePathPreview}'),
                                  Text(
                                    'Destino: ${item.destinationPathPreview}',
                                  ),
                                ] else if (item.isSkipped) ...[
                                  const Text(
                                    'Ignorado: mantem codigo original',
                                  ),
                                  Text('${item.artist} - ${item.title}'),
                                  Text('Origem: ${item.sourcePathPreview}'),
                                ] else ...[
                                  const Text('Bloqueado:'),
                                  Text('${item.artist} - ${item.title}'),
                                  Text('Origem: ${item.sourcePathPreview}'),
                                  const Text('Avisos:'),
                                  for (final warning in item.warnings)
                                    Text('- $warning'),
                                ],
                                const SizedBox(height: 8),
                              ],
                            ],
                            if (_duplicateRepairExecutionPlan != null &&
                                _duplicateRepairExecutionPlan!
                                    .hasReadyItems) ...[
                              const SizedBox(height: 12),
                              Text(
                                'Confirmacao obrigatoria para renomear arquivos reais',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Esta acao ira renomear arquivos reais na biblioteca oficial selecionada.',
                              ),
                              const SizedBox(height: 8),
                              const Text('Pasta que sera alterada:'),
                              Text(_officialLibraryFolderPath ?? '-'),
                              const SizedBox(height: 8),
                              Text(
                                'Arquivos prontos para renomear: ${_duplicateRepairExecutionPlan!.readyToRenameCount}',
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Esta acao nao possui desfazer automatico nesta fase.',
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Recomendado: teste primeiro em uma copia da biblioteca antes de executar na pasta oficial.',
                              ),
                              CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text(
                                  'Revisei o dry-run e confirmo que desejo renomear os arquivos prontos.',
                                ),
                                value: _confirmDuplicateRepairExecution,
                                onChanged: _executingDuplicateRepair
                                    ? null
                                    : (value) {
                                        setState(() {
                                          _confirmDuplicateRepairExecution =
                                              value ?? false;
                                        });
                                      },
                              ),
                              TextField(
                                controller:
                                    _duplicateRepairConfirmationController,
                                enabled: !_executingDuplicateRepair,
                                decoration: const InputDecoration(
                                  labelText:
                                      'Digite RENOMEAR para liberar a execucao',
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _duplicateRepairConfirmationText = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 12),
                              FilledButton(
                                onPressed:
                                    _executingDuplicateRepair ||
                                        !_confirmDuplicateRepairExecution ||
                                        _duplicateRepairConfirmationText
                                                .trim()
                                                .toUpperCase() !=
                                            'RENOMEAR'
                                    ? null
                                    : _executeDuplicateRepair,
                                child: Text(
                                  _executingDuplicateRepair
                                      ? 'Executando...'
                                      : 'Renomear arquivos reais nesta pasta',
                                ),
                              ),
                            ],
                            if (_duplicateRepairExecutionResultMessage !=
                                null) ...[
                              const SizedBox(height: 8),
                              Text(_duplicateRepairExecutionResultMessage!),
                            ],
                            if (_duplicateRepairExecutionResult != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                'Resultado da execucao',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Renomeados: ${_duplicateRepairExecutionResult!.renamedCount}',
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ignorados: ${_duplicateRepairExecutionResult!.skippedCount}',
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Falhas: ${_duplicateRepairExecutionResult!.failedCount}',
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Reindexe a biblioteca oficial para conferir o resultado atualizado.',
                              ),
                              const SizedBox(height: 8),
                              if (_duplicateRepairExecutionResult!
                                      .items
                                      .length >
                                  _executionItemsLimit)
                                Text(
                                  'Exibindo os primeiros $_executionItemsLimit de ${_duplicateRepairExecutionResult!.items.length} itens do resultado.',
                                ),
                              const SizedBox(height: 6),
                              for (final item
                                  in _duplicateRepairExecutionResult!.items
                                      .take(_executionItemsLimit)) ...[
                                if (item.isRenamed) ...[
                                  const Text('Renomeado:'),
                                  Text('${item.artist} - ${item.title}'),
                                  Text('Origem: ${item.sourcePath ?? '-'}'),
                                  Text(
                                    'Destino: ${item.destinationPath ?? '-'}',
                                  ),
                                  if (item.messages.isNotEmpty)
                                    Text('Mensagem: ${item.messages.first}'),
                                ] else if (item.isSkipped) ...[
                                  const Text('Ignorado:'),
                                  Text('${item.artist} - ${item.title}'),
                                  for (final message in item.messages)
                                    Text('Mensagem: $message'),
                                ] else ...[
                                  const Text('Falhou:'),
                                  Text('${item.artist} - ${item.title}'),
                                  Text('Origem: ${item.sourcePath ?? '-'}'),
                                  Text(
                                    'Destino: ${item.destinationPath ?? '-'}',
                                  ),
                                  const Text('Mensagens:'),
                                  for (final message in item.messages)
                                    Text('- $message'),
                                ],
                                const SizedBox(height: 8),
                              ],
                            ],
                            if (officialLibraryResult.hasInvalidFiles) ...[
                              const SizedBox(height: 16),
                              FilledButton.tonal(
                                onPressed: _generateInvalidFileRepairPlan,
                                child: const Text(
                                  'Gerar plano de reparo de invalidos',
                                ),
                              ),
                            ],
                            if (_invalidFileRepairMessage != null) ...[
                              const SizedBox(height: 8),
                              Text(_invalidFileRepairMessage!),
                            ],
                            if (_invalidFileRepairPlan != null) ...[
                              const SizedBox(height: 12),
                              OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _showInvalidFileRepairPlan =
                                        !_showInvalidFileRepairPlan;
                                  });
                                },
                                child: Text(
                                  _showInvalidFileRepairPlan
                                      ? 'Ocultar plano de invalidos'
                                      : 'Mostrar plano de invalidos',
                                ),
                              ),
                            ],
                            if (_invalidFileRepairPlan != null &&
                                _showInvalidFileRepairPlan) ...[
                              const SizedBox(height: 12),
                              Text(
                                'Plano de reparo de arquivos invalidos',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Total: ${_invalidFileRepairPlan!.totalCount}',
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Sugestoes prontas: ${_invalidFileRepairPlan!.readyToSuggestCount}',
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Revisao necessaria: ${_invalidFileRepairPlan!.needsReviewCount}',
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Bloqueados: ${_invalidFileRepairPlan!.blockedCount}',
                              ),
                              if (_invalidFileRepairPlan!
                                  .warnings
                                  .isNotEmpty) ...[
                                const SizedBox(height: 8),
                                const Text('Avisos do plano:'),
                                const SizedBox(height: 4),
                                for (final warning
                                    in _invalidFileRepairPlan!.warnings) ...[
                                  Text('- $warning'),
                                  const SizedBox(height: 2),
                                ],
                              ],
                              const SizedBox(height: 8),
                              if (_invalidFileRepairPlan!.items.length >
                                  _invalidFileRepairItemsLimit)
                                Text(
                                  'Exibindo os primeiros $_invalidFileRepairItemsLimit de ${_invalidFileRepairPlan!.items.length} itens do plano.',
                                ),
                              const SizedBox(height: 6),
                              for (final item
                                  in _invalidFileRepairPlan!.items.take(
                                    _invalidFileRepairItemsLimit,
                                  )) ...[
                                Text('Status: ${item.status.label}'),
                                const SizedBox(height: 2),
                                const Text('Arquivo atual:'),
                                Text(item.displayPath),
                                const SizedBox(height: 2),
                                const Text('Motivo original:'),
                                Text(item.originalReason),
                                if (item.analysis.detectedArtist != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'Artista detectado: ${item.analysis.detectedArtist}',
                                  ),
                                ],
                                if (item.analysis.detectedTitle != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'Musica detectada: ${item.analysis.detectedTitle}',
                                  ),
                                ],
                                if (item.hasSuggestedFileName) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'Novo nome sugerido: ${item.suggestedFileName}',
                                  ),
                                ],
                                if (item.hasSuggestedCode) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'Codigo sugerido: ${item.suggestedCode}',
                                  ),
                                ],
                                if (item.warnings.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  const Text('Avisos:'),
                                  for (final warning in item.warnings)
                                    Text('- $warning'),
                                ],
                                const SizedBox(height: 10),
                              ],
                            ],
                            if (_invalidFileRepairPlan != null) ...[
                              const SizedBox(height: 16),
                              FilledButton.tonal(
                                onPressed:
                                    _generateInvalidFileRepairExecutionDryRun,
                                child: const Text(
                                  'Validar execucao dos invalidos',
                                ),
                              ),
                            ],
                            if (_invalidFileRepairExecutionMessage != null) ...[
                              const SizedBox(height: 8),
                              Text(_invalidFileRepairExecutionMessage!),
                            ],
                            if (_invalidFileRepairExecutionPlan != null) ...[
                              const SizedBox(height: 12),
                              OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _showInvalidFileRepairExecutionPlan =
                                        !_showInvalidFileRepairExecutionPlan;
                                  });
                                },
                                child: Text(
                                  _showInvalidFileRepairExecutionPlan
                                      ? 'Ocultar dry-run de invalidos'
                                      : 'Mostrar dry-run de invalidos',
                                ),
                              ),
                            ],
                            if (_invalidFileRepairExecutionPlan != null &&
                                _showInvalidFileRepairExecutionPlan) ...[
                              const SizedBox(height: 12),
                              Text(
                                'Dry-run dos arquivos invalidos',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Prontos para renomear: ${_invalidFileRepairExecutionPlan!.readyToRenameCount}',
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Aguardando revisao: ${_invalidFileRepairExecutionPlan!.skippedCount}',
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Bloqueados: ${_invalidFileRepairExecutionPlan!.blockedCount}',
                              ),
                              if (_invalidFileRepairExecutionPlan!
                                  .warnings
                                  .isNotEmpty) ...[
                                const SizedBox(height: 8),
                                const Text('Avisos do dry-run:'),
                                const SizedBox(height: 4),
                                for (final warning
                                    in _invalidFileRepairExecutionPlan!
                                        .warnings) ...[
                                  Text('- $warning'),
                                  const SizedBox(height: 2),
                                ],
                              ],
                              const SizedBox(height: 8),
                              if (_invalidFileRepairExecutionPlan!
                                      .items
                                      .length >
                                  _invalidFileRepairItemsLimit)
                                Text(
                                  'Exibindo os primeiros $_invalidFileRepairItemsLimit de ${_invalidFileRepairExecutionPlan!.items.length} itens do dry-run de invalidos.',
                                ),
                              const SizedBox(height: 6),
                              for (final item
                                  in _invalidFileRepairExecutionPlan!.items
                                      .take(_invalidFileRepairItemsLimit)) ...[
                                if (item.isReadyToRename) ...[
                                  const Text('Pronto para renomear:'),
                                  if (item.detectedArtist != null &&
                                      item.detectedTitle != null)
                                    Text(
                                      '${item.detectedArtist} - ${item.detectedTitle}',
                                    ),
                                  const Text('Arquivo atual:'),
                                  Text(
                                    item.sourcePathPreview ?? item.displayPath,
                                  ),
                                  const Text('Destino:'),
                                  Text(item.destinationPathPreview ?? '-'),
                                ] else if (item.isSkipped) ...[
                                  const Text('Aguardando revisao:'),
                                  if (item.detectedArtist != null &&
                                      item.detectedTitle != null)
                                    Text(
                                      '${item.detectedArtist} - ${item.detectedTitle}',
                                    ),
                                  const Text('Arquivo atual:'),
                                  Text(
                                    item.sourcePathPreview ?? item.displayPath,
                                  ),
                                  if (item.warnings.isNotEmpty) ...[
                                    const Text('Avisos:'),
                                    for (final warning in item.warnings)
                                      Text('- $warning'),
                                  ],
                                ] else ...[
                                  const Text('Bloqueado:'),
                                  const Text('Arquivo atual:'),
                                  Text(
                                    item.sourcePathPreview ?? item.displayPath,
                                  ),
                                  if (item.warnings.isNotEmpty) ...[
                                    const Text('Avisos:'),
                                    for (final warning in item.warnings)
                                      Text('- $warning'),
                                  ],
                                ],
                                const SizedBox(height: 8),
                              ],
                            ],
                            if (_invalidFileRepairExecutionPlan != null &&
                                _invalidFileRepairExecutionPlan!
                                    .hasReadyItems) ...[
                              const SizedBox(height: 16),
                              Text(
                                'Confirmacao obrigatoria para renomear arquivos invalidos reais',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Esta acao ira renomear arquivos reais na biblioteca oficial selecionada.',
                              ),
                              const SizedBox(height: 8),
                              const Text('Pasta que sera alterada:'),
                              Text(_officialLibraryFolderPath ?? '-'),
                              const SizedBox(height: 8),
                              Text(
                                'Arquivos invalidos prontos para renomear: ${_invalidFileRepairExecutionPlan!.readyToRenameCount}',
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Esta acao nao possui desfazer automatico nesta fase.',
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Recomendado: teste primeiro em uma copia da biblioteca antes de executar na pasta oficial.',
                              ),
                              CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text(
                                  'Revisei o dry-run dos invalidos e confirmo que desejo renomear os arquivos prontos.',
                                ),
                                value: _confirmInvalidRepairExecution,
                                onChanged: _executingInvalidRepair
                                    ? null
                                    : (value) {
                                        setState(() {
                                          _confirmInvalidRepairExecution =
                                              value ?? false;
                                        });
                                      },
                              ),
                              TextField(
                                controller:
                                    _invalidRepairConfirmationController,
                                enabled: !_executingInvalidRepair,
                                decoration: const InputDecoration(
                                  labelText:
                                      'Digite RENOMEAR para liberar a execucao',
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _invalidRepairConfirmationText = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 12),
                              FilledButton(
                                onPressed:
                                    _executingInvalidRepair ||
                                        !_confirmInvalidRepairExecution ||
                                        _invalidRepairConfirmationText
                                                .trim()
                                                .toUpperCase() !=
                                            'RENOMEAR'
                                    ? null
                                    : _executeInvalidRepair,
                                child: Text(
                                  _executingInvalidRepair
                                      ? 'Executando...'
                                      : 'Renomear arquivos invalidos reais nesta pasta',
                                ),
                              ),
                            ],
                            if (_invalidRepairExecutionResultMessage !=
                                null) ...[
                              const SizedBox(height: 8),
                              Text(_invalidRepairExecutionResultMessage!),
                            ],
                            if (_invalidRepairExecutionResult != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                'Resultado da execucao dos invalidos',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Renomeados: ${_invalidRepairExecutionResult!.renamedCount}',
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ignorados: ${_invalidRepairExecutionResult!.skippedCount}',
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Falhas: ${_invalidRepairExecutionResult!.failedCount}',
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Reindexe a biblioteca oficial para conferir o resultado atualizado.',
                              ),
                              const SizedBox(height: 8),
                              if (_invalidRepairExecutionResult!.items.length >
                                  _invalidFileRepairItemsLimit)
                                Text(
                                  'Exibindo os primeiros $_invalidFileRepairItemsLimit de ${_invalidRepairExecutionResult!.items.length} itens do resultado.',
                                ),
                              const SizedBox(height: 6),
                              for (final item
                                  in _invalidRepairExecutionResult!.items.take(
                                    _invalidFileRepairItemsLimit,
                                  )) ...[
                                if (item.isRenamed) ...[
                                  const Text('Renomeado:'),
                                  if (item.detectedArtist != null &&
                                      item.detectedTitle != null)
                                    Text(
                                      '${item.detectedArtist} - ${item.detectedTitle}',
                                    ),
                                  Text('Origem: ${item.sourcePath ?? '-'}'),
                                  Text(
                                    'Destino: ${item.destinationPath ?? '-'}',
                                  ),
                                  if (item.messages.isNotEmpty)
                                    Text('Mensagem: ${item.messages.first}'),
                                ] else if (item.isSkipped) ...[
                                  const Text('Ignorado:'),
                                  Text(
                                    'Arquivo original: ${item.originalFileName}',
                                  ),
                                  for (final message in item.messages)
                                    Text('Mensagem: $message'),
                                ] else ...[
                                  const Text('Falhou:'),
                                  Text(
                                    'Arquivo original: ${item.originalFileName}',
                                  ),
                                  Text('Origem: ${item.sourcePath ?? '-'}'),
                                  Text(
                                    'Destino: ${item.destinationPath ?? '-'}',
                                  ),
                                  const Text('Mensagens:'),
                                  for (final message in item.messages)
                                    Text('- $message'),
                                ],
                                const SizedBox(height: 8),
                              ],
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pasta de musicas novas selecionada:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _incomingSongsFolderPath ??
                                'Nenhuma pasta de musicas novas selecionada.',
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: _selectingIncomingSongsFolder
                                ? null
                                : _selectIncomingSongsFolder,
                            child: Text(
                              _selectingIncomingSongsFolder
                                  ? 'Selecionando...'
                                  : 'Selecionar pasta de musicas novas',
                            ),
                          ),
                          if (_incomingSongsFolderSelectionMessage != null) ...[
                            const SizedBox(height: 8),
                            Text(_incomingSongsFolderSelectionMessage!),
                          ],
                          if (_incomingSongsFolderPath != null) ...[
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: _scanningIncomingSongsFolder
                                  ? null
                                  : _scanIncomingSongsFolder,
                              child: Text(
                                _scanningIncomingSongsFolder
                                    ? 'Escaneando...'
                                    : 'Escanear mÃºsicas novas',
                              ),
                            ),
                          ],
                          if (_incomingSongsScanMessage != null) ...[
                            const SizedBox(height: 8),
                            Text(_incomingSongsScanMessage!),
                          ],
                          if (_incomingSongsScanResult != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              'MÃºsicas novas encontradas: ${_incomingSongsScanResult!.totalCount}',
                            ),
                            if (_incomingSongsScanResult!.hasWarnings) ...[
                              const SizedBox(height: 8),
                              const Text('Avisos do scan:'),
                              const SizedBox(height: 4),
                              for (final warning
                                  in _incomingSongsScanResult!.warnings) ...[
                                Text('- $warning'),
                                const SizedBox(height: 2),
                              ],
                            ],
                            if (_incomingSongsScanResult!.totalCount == 0) ...[
                              const SizedBox(height: 8),
                              const Text(
                                'Nenhum .mp4 encontrado na pasta de mÃºsicas novas.',
                              ),
                            ] else ...[
                              const SizedBox(height: 12),
                              const Text('Amostra de arquivos:'),
                              const SizedBox(height: 4),
                              if (_incomingSongsScanResult!.totalCount > 20)
                                Text(
                                  'Exibindo os primeiros 20 de ${_incomingSongsScanResult!.totalCount} arquivos encontrados.',
                                ),
                              const SizedBox(height: 4),
                              for (final file
                                  in _incomingSongsScanResult!.files.take(
                                    20,
                                  )) ...[
                                Text(file.displayPath),
                                const SizedBox(height: 2),
                              ],
                            ],
                            if (_incomingSongsScanResult!.totalCount > 0) ...[
                              const SizedBox(height: 16),
                              FilledButton.tonal(
                                onPressed: _generateIncomingSongCleaningPreview,
                                child: const Text(
                                  'Gerar prÃ©-limpeza dos nomes',
                                ),
                              ),
                            ],
                          ],
                          if (_incomingSongCleaningMessage != null) ...[
                            const SizedBox(height: 8),
                            Text(_incomingSongCleaningMessage!),
                          ],
                          if (_incomingSongCleaningPreviewPlan != null) ...[
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _showIncomingSongCleaningPreview =
                                      !_showIncomingSongCleaningPreview;
                                });
                              },
                              child: Text(
                                _showIncomingSongCleaningPreview
                                    ? 'Ocultar prÃ©-limpeza'
                                    : 'Mostrar prÃ©-limpeza',
                              ),
                            ),
                          ],
                          if (_incomingSongCleaningPreviewPlan != null &&
                              _showIncomingSongCleaningPreview) ...[
                            const SizedBox(height: 12),
                            Text(
                              'PrÃ©-limpeza dos nomes',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Arquivos analisados: ${_incomingSongCleaningPreviewPlan!.totalCount}',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Nomes alterados: ${_incomingSongCleaningPreviewPlan!.changedCount}',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Nomes sem alteraÃ§Ã£o: ${_incomingSongCleaningPreviewPlan!.unchangedCount}',
                            ),
                            if (_incomingSongCleaningPreviewPlan!
                                .hasWarnings) ...[
                              const SizedBox(height: 8),
                              const Text('Avisos:'),
                              const SizedBox(height: 4),
                              for (final warning
                                  in _incomingSongCleaningPreviewPlan!
                                      .warnings) ...[
                                Text('- $warning'),
                                const SizedBox(height: 2),
                              ],
                            ],
                            const SizedBox(height: 8),
                            if (_incomingSongCleaningPreviewPlan!.totalCount >
                                50)
                              Text(
                                'Exibindo os primeiros 50 de ${_incomingSongCleaningPreviewPlan!.totalCount} itens da prÃ©-limpeza.',
                              ),
                            const SizedBox(height: 4),
                            for (final item
                                in _incomingSongCleaningPreviewPlan!.items.take(
                                  50,
                                )) ...[
                              const Text('Arquivo:'),
                              Text(item.displayPath),
                              const SizedBox(height: 2),
                              const Text('Original:'),
                              Text(item.originalFileName),
                              const SizedBox(height: 2),
                              const Text('Limpo:'),
                              Text(item.cleanedFileName),
                              if (item.appliedRules.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                const Text('Regras aplicadas:'),
                                for (final rule in item.appliedRules)
                                  Text('- $rule'),
                              ],
                              if (item.hasWarnings) ...[
                                const SizedBox(height: 2),
                                const Text('Avisos:'),
                                for (final warning in item.warnings)
                                  Text('- $warning'),
                              ],
                              const SizedBox(height: 10),
                            ],
                          ],
                          if (_incomingSongsScanResult != null &&
                              _incomingSongsScanResult!.totalCount > 0) ...[
                            const SizedBox(height: 16),
                            FilledButton.tonal(
                              onPressed: _generateImportSuggestions,
                              child: const Text(
                                'Gerar sugestÃµes de importaÃ§Ã£o',
                              ),
                            ),
                          ],
                          if (_importSuggestionMessage != null) ...[
                            const SizedBox(height: 8),
                            Text(_importSuggestionMessage!),
                          ],
                          if (_importSuggestionPlan != null) ...[
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _showImportSuggestionPlan =
                                      !_showImportSuggestionPlan;
                                });
                              },
                              child: Text(
                                _showImportSuggestionPlan
                                    ? 'Ocultar sugestÃµes de importaÃ§Ã£o'
                                    : 'Mostrar sugestÃµes de importaÃ§Ã£o',
                              ),
                            ),
                          ],
                          if (_importSuggestionPlan != null &&
                              _showImportSuggestionPlan) ...[
                            const SizedBox(height: 12),
                            Text(
                              'SugestÃµes de importaÃ§Ã£o',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text('Total: ${_importSuggestionPlan!.totalCount}'),
                            const SizedBox(height: 4),
                            Text('Prontos: ${_readyImportCandidates().length}'),
                            const SizedBox(height: 4),
                            Text(
                              'RevisÃ£o necessÃ¡ria: ${_importSuggestionPlan!.needsReviewCount}',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Bloqueados: ${_importSuggestionPlan!.blockedCount}',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'PossÃ­veis duplicados: ${_duplicateImportCandidates().length}',
                            ),
                            if (_importSuggestionPlan!.hasWarnings) ...[
                              const SizedBox(height: 8),
                              const Text('Avisos:'),
                              const SizedBox(height: 4),
                              for (final warning
                                  in _importSuggestionPlan!.warnings) ...[
                                Text('- $warning'),
                                const SizedBox(height: 2),
                              ],
                            ],
                            const SizedBox(height: 16),
                            Text(
                              'RevisÃ£o dos candidatos',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            // --- prontos ---
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Prontos para importar: ${_readyImportCandidates().length}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall,
                                  ),
                                ),
                                OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      _showReadyImportCandidates =
                                          !_showReadyImportCandidates;
                                    });
                                  },
                                  child: Text(
                                    _showReadyImportCandidates
                                        ? 'Ocultar prontos'
                                        : 'Mostrar prontos',
                                  ),
                                ),
                              ],
                            ),
                            if (_showReadyImportCandidates) ...[
                              const SizedBox(height: 8),
                              if (_readyImportCandidates().isEmpty)
                                const Text('Nenhum candidato pronto.'),
                              if (_readyImportCandidates().length > 50)
                                Text(
                                  'Exibindo os primeiros 50 de ${_readyImportCandidates().length} candidatos.',
                                ),
                              for (final candidate
                                  in _readyImportCandidates().take(50)) ...[
                                const Text('Pronto para importar'),
                                const SizedBox(height: 2),
                                const Text('Arquivo:'),
                                Text(candidate.originalFileName),
                                const SizedBox(height: 2),
                                const Text('Original:'),
                                Text(candidate.analysis.originalFileName),
                                const SizedBox(height: 2),
                                const Text('Nome limpo:'),
                                Text(candidate.analysis.cleanedName),
                                if (candidate.analysis.detectedArtist !=
                                    null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'Artista: ${candidate.analysis.detectedArtist}',
                                  ),
                                ],
                                if (candidate.analysis.detectedTitle !=
                                    null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'MÃºsica: ${candidate.analysis.detectedTitle}',
                                  ),
                                ],
                                if (candidate.hasSuggestedCode) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'CÃ³digo sugerido: ${candidate.suggestedCode}',
                                  ),
                                ],
                                if (candidate.suggestedOfficialFileName !=
                                    null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'Nome oficial sugerido: ${candidate.suggestedOfficialFileName}',
                                  ),
                                ],
                                const SizedBox(height: 10),
                              ],
                            ],
                            // --- revisÃ£o ---
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Precisam de revisÃ£o: ${_reviewImportCandidates().length}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall,
                                  ),
                                ),
                                OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      _showReviewImportCandidates =
                                          !_showReviewImportCandidates;
                                    });
                                  },
                                  child: Text(
                                    _showReviewImportCandidates
                                        ? 'Ocultar revisÃ£o'
                                        : 'Mostrar revisÃ£o',
                                  ),
                                ),
                              ],
                            ),
                            if (_showReviewImportCandidates) ...[
                              const SizedBox(height: 8),
                              if (_reviewImportCandidates().isEmpty)
                                const Text('Nenhum candidato para revisÃ£o.'),
                              if (_reviewImportCandidates().length > 50)
                                Text(
                                  'Exibindo os primeiros 50 de ${_reviewImportCandidates().length} candidatos.',
                                ),
                              for (final candidate
                                  in _reviewImportCandidates().take(50)) ...[
                                const Text('RevisÃ£o necessÃ¡ria'),
                                const SizedBox(height: 2),
                                const Text('Arquivo:'),
                                Text(candidate.originalFileName),
                                const SizedBox(height: 2),
                                const Text('Original:'),
                                Text(candidate.analysis.originalFileName),
                                const SizedBox(height: 2),
                                const Text('Nome limpo:'),
                                Text(candidate.analysis.cleanedName),
                                if (candidate.analysis.detectedArtist !=
                                    null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'Artista detectado: ${candidate.analysis.detectedArtist}',
                                  ),
                                ],
                                if (candidate.analysis.detectedTitle !=
                                    null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'MÃºsica detectada: ${candidate.analysis.detectedTitle}',
                                  ),
                                ],
                                const SizedBox(height: 2),
                                Text(
                                  'ConfianÃ§a: ${candidate.analysis.confidence.label}',
                                ),
                                if (candidate.suggestedOfficialFileName !=
                                    null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'Nome oficial sugerido: ${candidate.suggestedOfficialFileName}',
                                  ),
                                ],
                                if (candidate.warnings.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  const Text('Avisos:'),
                                  for (final warning in candidate.warnings)
                                    Text('- $warning'),
                                ],
                                const SizedBox(height: 10),
                              ],
                            ],
                            // --- bloqueados ---
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Bloqueados: ${_blockedImportCandidates().length}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall,
                                  ),
                                ),
                                OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      _showBlockedImportCandidates =
                                          !_showBlockedImportCandidates;
                                    });
                                  },
                                  child: Text(
                                    _showBlockedImportCandidates
                                        ? 'Ocultar bloqueados'
                                        : 'Mostrar bloqueados',
                                  ),
                                ),
                              ],
                            ),
                            if (_showBlockedImportCandidates) ...[
                              const SizedBox(height: 8),
                              if (_blockedImportCandidates().isEmpty)
                                const Text('Nenhum candidato bloqueado.'),
                              if (_blockedImportCandidates().length > 50)
                                Text(
                                  'Exibindo os primeiros 50 de ${_blockedImportCandidates().length} candidatos.',
                                ),
                              for (final candidate
                                  in _blockedImportCandidates().take(50)) ...[
                                const Text('Bloqueado'),
                                const SizedBox(height: 2),
                                const Text('Arquivo:'),
                                Text(candidate.originalFileName),
                                const SizedBox(height: 2),
                                const Text('Original:'),
                                Text(candidate.analysis.originalFileName),
                                const SizedBox(height: 2),
                                const Text('Nome limpo:'),
                                Text(candidate.analysis.cleanedName),
                                if (candidate.warnings.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  const Text('Avisos:'),
                                  for (final warning in candidate.warnings)
                                    Text('- $warning'),
                                ],
                                const SizedBox(height: 10),
                              ],
                            ],
                            // --- duplicados ---
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'PossÃ­veis duplicados: ${_duplicateImportCandidates().length}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall,
                                  ),
                                ),
                                OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      _showDuplicateImportCandidates =
                                          !_showDuplicateImportCandidates;
                                    });
                                  },
                                  child: Text(
                                    _showDuplicateImportCandidates
                                        ? 'Ocultar duplicados'
                                        : 'Mostrar duplicados',
                                  ),
                                ),
                              ],
                            ),
                            if (_showDuplicateImportCandidates) ...[
                              const SizedBox(height: 8),
                              if (_duplicateImportCandidates().isEmpty)
                                const Text(
                                  'Nenhum possÃ­vel duplicado encontrado.',
                                ),
                              if (_duplicateImportCandidates().length > 50)
                                Text(
                                  'Exibindo os primeiros 50 de ${_duplicateImportCandidates().length} possÃ­veis duplicados.',
                                ),
                              for (final candidate
                                  in _duplicateImportCandidates().take(50)) ...[
                                const Text('PossÃ­vel duplicado'),
                                const SizedBox(height: 2),
                                const Text('Arquivo:'),
                                Text(candidate.originalFileName),
                                if (candidate.suggestedOfficialFileName !=
                                    null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'Nome oficial sugerido: ${candidate.suggestedOfficialFileName}',
                                  ),
                                ],
                                const SizedBox(height: 2),
                                const Text('Dados do duplicado:'),
                                Text(
                                  '- ${candidate.duplicateMatch!.existingArtist} - ${candidate.duplicateMatch!.existingTitle} (${candidate.duplicateMatch!.existingCode})',
                                ),
                                if (candidate.warnings.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  const Text('Avisos:'),
                                  for (final warning in candidate.warnings)
                                    Text('- $warning'),
                                ],
                                const SizedBox(height: 10),
                              ],
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Motor preparado',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          for (final item in engineItems) ...[
                            Text('- $item'),
                            const SizedBox(height: 4),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status do projeto:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Round 28 - Selecao/aprovacao em memoria dos candidatos de importacao',
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Estado: Selecao inicial com marcacao individual, selecionar prontos e limpar selecao.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
