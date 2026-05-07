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
import '../../output_plan/application/output_plan_application.dart';
import '../../output_plan/domain/output_plan.dart';
import '../../session_cache/application/session_cache_application.dart';
import '../../session_cache/domain/session_cache.dart';
import 'widgets/home_dashboard_badge.dart';
import 'widgets/home_dashboard_button.dart';
import 'widgets/home_dashboard_card.dart';
import 'widgets/home_dashboard_header.dart';
import 'widgets/home_dashboard_metric.dart';
import 'widgets/home_dashboard_shell.dart';
import 'widgets/home_dashboard_sidebar.dart';
import 'widgets/home_dashboard_stepper.dart';
import 'widgets/home_dashboard_theme.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({
    super.key,
    FolderPickerService? folderPickerService,
    OfficialLibraryScanService? officialLibraryScanService,
    DuplicateCodeRepairExecutor? duplicateCodeRepairExecutor,
    InvalidFileRepairExecutor? invalidFileRepairExecutor,
    IncomingSongsScanService? incomingSongsScanService,
    ImportOperationExecutor? importOperationExecutor,
    ImportOperationManifestWriter? importOperationManifestWriter,
    AppSessionCacheService? sessionCacheService,
  }) : folderPickerService = folderPickerService ?? const FolderPickerService(),
       officialLibraryScanService =
           officialLibraryScanService ?? OfficialLibraryScanService(),
       duplicateCodeRepairExecutor =
           duplicateCodeRepairExecutor ?? DuplicateCodeRepairExecutor(),
       invalidFileRepairExecutor =
           invalidFileRepairExecutor ?? InvalidFileRepairExecutor(),
       incomingSongsScanService =
           incomingSongsScanService ?? IncomingSongsScanService(),
       importOperationExecutor =
           importOperationExecutor ?? ImportOperationExecutor(),
       importOperationManifestWriter =
           importOperationManifestWriter ?? ImportOperationManifestWriter(),
       sessionCacheService =
           sessionCacheService ?? const AppSessionCacheService();

  final FolderPickerService folderPickerService;
  final OfficialLibraryScanService officialLibraryScanService;
  final DuplicateCodeRepairExecutor duplicateCodeRepairExecutor;
  final InvalidFileRepairExecutor invalidFileRepairExecutor;
  final IncomingSongsScanService incomingSongsScanService;
  final ImportOperationExecutor importOperationExecutor;
  final ImportOperationManifestWriter importOperationManifestWriter;
  final AppSessionCacheService sessionCacheService;

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
  bool _invertIncomingSongMusicArtist = false;
  ImportSuggestionPlan? _importSuggestionPlan;
  bool _showImportSuggestionPlan = false;
  String? _importSuggestionMessage;
  ImportCandidateSelectionPlan? _importCandidateSelectionPlan;
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
  bool _confirmImportOperationExecution = false;
  bool _executingImportOperation = false;
  String _importOperationConfirmationText = '';
  ImportOperationExecutionResult? _importOperationExecutionResult;
  String? _importOperationExecutionResultMessage;
  ImportOperationManifest? _importOperationManifest;
  String? _importOperationManifestMessage;
  String? _importManifestFolderPath;
  bool _selectingImportManifestFolder = false;
  bool _savingImportManifest = false;
  ImportOperationManifestWriteResult? _importOperationManifestWriteResult;
  bool _loadingSessionCache = false;
  bool _savingSessionCache = false;
  String? _sessionCacheMessage;
  AppSessionSnapshot? _lastSessionSnapshot;
  bool _showManualImportCandidateEdit = false;
  final Set<String> _manuallyApprovedCandidateIds = <String>{};
  final ScrollController _suggestionsTableHorizontalController =
      ScrollController();
  final ScrollController _suggestionsTableVerticalController =
      ScrollController();
  final ScrollController _manualEditTableHorizontalController =
      ScrollController();
  final ScrollController _manualEditTableVerticalController =
      ScrollController();

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
  late final TextEditingController _importOperationConfirmationController;
  final GlobalKey _dashboardKey = GlobalKey();
  final GlobalKey _libraryKey = GlobalKey();
  final GlobalKey _incomingSongsKey = GlobalKey();
  final GlobalKey _reviewKey = GlobalKey();
  final GlobalKey _outputKey = GlobalKey();
  final GlobalKey _manifestKey = GlobalKey();
  final GlobalKey _cacheKey = GlobalKey();
  final GlobalKey _statusKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _duplicateRepairConfirmationController = TextEditingController();
    _invalidRepairConfirmationController = TextEditingController();
    _importOperationConfirmationController = TextEditingController();
    _loadSessionCache();
  }

  @override
  void dispose() {
    _duplicateRepairConfirmationController.dispose();
    _invalidRepairConfirmationController.dispose();
    _importOperationConfirmationController.dispose();
    _suggestionsTableHorizontalController.dispose();
    _suggestionsTableVerticalController.dispose();
    _manualEditTableHorizontalController.dispose();
    _manualEditTableVerticalController.dispose();
    super.dispose();
  }

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context == null) {
      return;
    }
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  void _toggleInvalidFilesVisibility() {
    setState(() {
      _showInvalidFiles = !_showInvalidFiles;
    });
  }

  void _toggleDuplicateCodesVisibility() {
    setState(() {
      _showDuplicateCodes = !_showDuplicateCodes;
    });
  }

  void _toggleDuplicateRepairPlanVisibility() {
    setState(() {
      _showDuplicateRepairPlan = !_showDuplicateRepairPlan;
    });
  }

  void _toggleDuplicateRepairExecutionPlanVisibility() {
    setState(() {
      _showDuplicateRepairExecutionPlan = !_showDuplicateRepairExecutionPlan;
    });
  }

  void _toggleInvalidFileRepairPlanVisibility() {
    setState(() {
      _showInvalidFileRepairPlan = !_showInvalidFileRepairPlan;
    });
  }

  void _toggleInvalidFileRepairExecutionPlanVisibility() {
    setState(() {
      _showInvalidFileRepairExecutionPlan =
          !_showInvalidFileRepairExecutionPlan;
    });
  }

  void _setDuplicateRepairExecutionConfirmation(bool value) {
    setState(() {
      _confirmDuplicateRepairExecution = value;
    });
  }

  void _setInvalidRepairExecutionConfirmation(bool value) {
    setState(() {
      _confirmInvalidRepairExecution = value;
    });
  }

  void _setDuplicateRepairConfirmationText(String value) {
    setState(() {
      _duplicateRepairConfirmationText = value;
    });
  }

  void _setInvalidRepairConfirmationText(String value) {
    setState(() {
      _invalidRepairConfirmationText = value;
    });
  }

  void _setInvertIncomingSongMusicArtist(bool value) {
    setState(() {
      _invertIncomingSongMusicArtist = value;
    });
  }

  void _changeImportOutputMode(ImportOutputMode value) {
    setState(() {
      _importOutputMode = value;
      _resetImportOperationDryRun();
    });
    _validateImportOutputConfiguration();
    _saveSessionCache();
  }

  void _toggleImportOperationDryRunVisibility() {
    setState(() {
      _showImportOperationDryRun = !_showImportOperationDryRun;
    });
  }

  void _setImportOperationExecutionConfirmation(bool value) {
    setState(() {
      _confirmImportOperationExecution = value;
    });
  }

  void _setImportOperationConfirmationText(String value) {
    setState(() {
      _importOperationConfirmationText = value;
    });
  }

  bool get _shouldRenderLegacyManifestBlock => false;

  Future<void> _selectIncomingSongsFolder() async {
    if (_selectingIncomingSongsFolder) {
      return;
    }

    setState(() {
      _selectingIncomingSongsFolder = true;
    });

    final selectedFolder = await widget.folderPickerService
        .pickIncomingSongsFolder();
    final shouldSaveCache = selectedFolder != null;

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

    if (shouldSaveCache) {
      _saveSessionCache();
    }
  }

  Future<void> _scanIncomingSongsFolder() async {
    if (_scanningIncomingSongsFolder) {
      return;
    }

    if (_incomingSongsFolderPath == null ||
        _incomingSongsFolderPath!.trim().isEmpty) {
      setState(() {
        _incomingSongsScanMessage =
            'Selecione a pasta de musicas novas antes de escanear.';
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
      _incomingSongsScanMessage = 'Pasta de musicas novas escaneada.';
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
            'Escaneie a pasta de musicas novas antes da pre-limpeza.';
      });
      return;
    }

    var plan = IncomingSongNameCleaner().buildPreview(
      scanResult: scanResult,
      rules: IncomingSongCleaningRule.defaultRules(),
      invertMusicArtist: _invertIncomingSongMusicArtist,
    );

    if (_invertIncomingSongMusicArtist) {
      final transformedItems = <IncomingSongCleaningPreviewItem>[];
      final extraWarnings = <String>[];
      for (final item in plan.items) {
        final inverted = _invertMusicArtistFileName(item.cleanedFileName);
        transformedItems.add(
          IncomingSongCleaningPreviewItem(
            scannedFile: item.scannedFile,
            originalFileName: item.originalFileName,
            cleanedFileName: inverted.cleanedFileName,
            appliedRules: item.appliedRules,
            warnings: [...item.warnings, ...inverted.warnings],
          ),
        );
        extraWarnings.addAll(inverted.warnings);
      }
      plan = IncomingSongCleaningPreviewPlan(
        items: transformedItems,
        warnings: [...plan.warnings, ...extraWarnings],
      );
    }

    setState(() {
      _incomingSongCleaningPreviewPlan = plan;
      _showIncomingSongCleaningPreview = true;
      _incomingSongCleaningMessage = 'pre-limpeza de nomes gerada.';
      _importSuggestionPlan = null;
      _showImportSuggestionPlan = false;
      _importSuggestionMessage = null;
      _resetImportSelection();
    });
  }

  _InvertedFileNameResult _invertMusicArtistFileName(String fileName) {
    final dot = fileName.lastIndexOf('.');
    final base = dot > 0 ? fileName.substring(0, dot) : fileName;
    final extension = dot > 0 ? fileName.substring(dot) : '';
    const separator = ' - ';
    final pivot = base.lastIndexOf(separator);
    if (pivot <= 0 || pivot >= base.length - separator.length) {
      return _InvertedFileNameResult(
        cleanedFileName: fileName,
        warnings: const [
          'Nao foi possivel inverter Musica - Artista: separador invalido.',
        ],
      );
    }
    final music = base.substring(0, pivot).trim();
    final artist = base.substring(pivot + separator.length).trim();
    if (music.isEmpty || artist.isEmpty) {
      return _InvertedFileNameResult(
        cleanedFileName: fileName,
        warnings: const [
          'Nao foi possivel inverter Musica - Artista: partes vazias.',
        ],
      );
    }
    return _InvertedFileNameResult(
      cleanedFileName: '$artist - $music$extension',
      warnings: const [],
    );
  }

  void _toggleIncomingSongCleaningPreview() {
    setState(() {
      _showIncomingSongCleaningPreview = !_showIncomingSongCleaningPreview;
    });
  }

  void _toggleImportSuggestionPlanVisibility() {
    setState(() {
      _showImportSuggestionPlan = !_showImportSuggestionPlan;
    });
  }

  void _toggleManualImportCandidateEditVisibility() {
    setState(() {
      _showManualImportCandidateEdit = !_showManualImportCandidateEdit;
    });
  }

  void _updateCandidateSelection({required String id, required bool selected}) {
    setState(() {
      _importCandidateSelectionPlan = _importCandidateSelectionPlan
          ?.withCandidateSelection(id, selected);
    });
    _validateImportOutputConfiguration();
  }

  List<ImportSuggestionCandidate> _readyImportCandidates() =>
      (_importSuggestionPlan?.candidates ?? [])
          .where(
            (c) =>
                c.status == ImportCandidateStatus.autoApproved &&
                !c.hasDuplicate,
          )
          .toList();

  List<ImportSuggestionCandidate> _duplicateImportCandidates() =>
      (_importSuggestionPlan?.candidates ?? [])
          .where((c) => c.hasDuplicate)
          .toList();

  List<ImportCandidateEditItem> _editItemsForDisplay() {
    final editPlan = _importCandidateEditPlan;
    final selectionPlan = _importCandidateSelectionPlan;
    if (editPlan == null || selectionPlan == null) {
      return const <ImportCandidateEditItem>[];
    }
    final selectedIds = selectionPlan.items
        .where((item) => item.isSelected)
        .map((item) => item.id)
        .toSet();
    return editPlan.items
        .where((item) => selectedIds.contains(item.id))
        .take(50)
        .toList();
  }

  List<ImportOperationDryRunItem> _dryRunItemsForDisplay() =>
      (_importOperationDryRunPlan?.items ?? []).take(100).toList();

  List<ImportOperationManifestItem> _manifestItemsForDisplay() =>
      (_importOperationManifest?.items ?? []).take(100).toList();

  AppSessionSnapshot _buildCurrentSessionSnapshot() {
    return AppSessionSnapshot(
      officialLibraryFolderPath: _officialLibraryFolderPath,
      incomingSongsFolderPath: _incomingSongsFolderPath,
      customImportOutputFolderPath: _customImportOutputFolderPath,
      importManifestFolderPath: _importManifestFolderPath,
      importOutputModeName: _importOutputMode.name,
      savedAtIso8601: null,
    );
  }

  ImportOutputMode _importOutputModeFromName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return ImportOutputMode.renameInIncomingFolder;
    }
    for (final mode in ImportOutputMode.values) {
      if (mode.name == name.trim()) {
        return mode;
      }
    }
    return ImportOutputMode.renameInIncomingFolder;
  }

  String _importOutputModeLabelFromName(String? name) {
    return _importOutputModeFromName(name).label;
  }

  Future<void> _loadSessionCache() async {
    setState(() {
      _loadingSessionCache = true;
      _sessionCacheMessage = 'Carregando cache...';
    });

    final snapshot = await widget.sessionCacheService.loadSnapshot();

    if (!mounted) {
      return;
    }

    setState(() {
      _loadingSessionCache = false;
      _officialLibraryFolderPath = snapshot.officialLibraryFolderPath;
      _incomingSongsFolderPath = snapshot.incomingSongsFolderPath;
      _customImportOutputFolderPath = snapshot.customImportOutputFolderPath;
      _importManifestFolderPath = snapshot.importManifestFolderPath;
      _importOutputMode = _importOutputModeFromName(
        snapshot.importOutputModeName,
      );
      _lastSessionSnapshot = snapshot;
      _sessionCacheMessage = snapshot.isEmpty
          ? 'Nenhum cache local encontrado.'
          : 'Cache local da sessao carregado.';
    });
  }

  Future<void> _saveSessionCache() async {
    setState(() {
      _savingSessionCache = true;
      _sessionCacheMessage = 'Salvando cache...';
    });

    final snapshot = _buildCurrentSessionSnapshot();
    await widget.sessionCacheService.saveSnapshot(snapshot);
    final savedSnapshot = await widget.sessionCacheService.loadSnapshot();

    if (!mounted) {
      return;
    }

    setState(() {
      _savingSessionCache = false;
      _lastSessionSnapshot = savedSnapshot;
      _sessionCacheMessage = 'Cache local da sessao salvo.';
    });
  }

  Future<void> _clearSessionCache() async {
    setState(() {
      _savingSessionCache = true;
      _sessionCacheMessage = 'Salvando cache...';
    });

    await widget.sessionCacheService.clearSnapshot();

    if (!mounted) {
      return;
    }

    setState(() {
      _savingSessionCache = false;
      _lastSessionSnapshot = null;
      _sessionCacheMessage = 'Cache local da sessao limpo.';
    });
  }

  void _resetImportManifestState({bool clearFolder = false}) {
    _importOperationManifest = null;
    _importOperationManifestMessage = null;
    _importOperationManifestWriteResult = null;
    _savingImportManifest = false;
    _selectingImportManifestFolder = false;
    if (clearFolder) {
      _importManifestFolderPath = null;
    }
  }

  void _resetImportOperationDryRun() {
    _importOperationDryRunPlan = null;
    _showImportOperationDryRun = false;
    _importOperationDryRunMessage = null;
    _confirmImportOperationExecution = false;
    _executingImportOperation = false;
    _importOperationConfirmationText = '';
    _importOperationConfirmationController.clear();
    _importOperationExecutionResult = null;
    _importOperationExecutionResultMessage = null;
    _resetImportManifestState();
  }

  void _resetImportSelection() {
    _importCandidateSelectionPlan = null;
    _importCandidateEditPlan = null;
    _importCandidateEditMessage = null;
    _importOutputMode = ImportOutputMode.renameInIncomingFolder;
    _customImportOutputFolderPath = null;
    _selectingImportOutputFolder = false;
    _importOutputValidationResult = null;
    _importOutputMessage = null;
    _resetImportOperationDryRun();
    _resetImportManifestState(clearFolder: true);
    _manuallyApprovedCandidateIds.clear();
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

    final effectiveEditPlan = _buildEffectiveEditPlanForOutput(
      selectionPlan: selectionPlan,
      editPlan: editPlan,
    );
    final effectiveSelectionPlan = _buildEffectiveSelectionPlanForOutput(
      selectionPlan: selectionPlan,
      editPlan: effectiveEditPlan,
    );
    final result = ImportOutputConfigurationValidator().validate(
      configuration: _buildImportOutputConfiguration(),
      selectionPlan: effectiveSelectionPlan,
      editPlan: effectiveEditPlan,
    );

    setState(() {
      _importOutputValidationResult = result;
      final hasBlockingCandidates = _hasBlockingSelectedCandidates();
      if (hasBlockingCandidates) {
        _importOutputMessage =
            'Execucao bloqueada: existem candidatos selecionados que ainda precisam de aprovacao manual ou correcao.';
      } else if (setSuccessMessage && result.isValid) {
        _importOutputMessage = 'Configuracao de saida validada.';
      } else if (setSuccessMessage && !result.isValid) {
        _importOutputMessage = 'Configuracao de saida invalida.';
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
    _saveSessionCache();
  }

  void _selectAllReadyCandidates() {
    final plan = _importCandidateSelectionPlan;
    if (plan == null) {
      return;
    }

    setState(() {
      _importCandidateSelectionPlan = plan.selectAllReady();
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
      _resetImportOperationDryRun();
    });
    _validateImportOutputConfiguration();
  }

  void _selectAllSelectableCandidates() {
    final plan = _importCandidateSelectionPlan;
    if (plan == null) {
      return;
    }

    var next = plan;
    for (final item in plan.items) {
      if (item.selectable) {
        next = next.withCandidateSelection(item.id, true);
      }
    }

    setState(() {
      _importCandidateSelectionPlan = next;
      _resetImportOperationDryRun();
    });
    _validateImportOutputConfiguration();
  }

  Widget _buildImportCandidatesTable() {
    final plan = _importCandidateSelectionPlan;
    if (plan == null || plan.items.isEmpty) {
      return const Text('Nenhum candidato para exibir.');
    }

    return DataTable(
      columnSpacing: 14,
      columns: const [
        DataColumn(label: Text('Selecionar')),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Arquivo')),
        DataColumn(label: Text('Artista')),
        DataColumn(label: Text('Musica')),
        DataColumn(label: Text('Nome oficial')),
        DataColumn(label: Text('Avisos')),
      ],
      rows: plan.items
          .map((item) {
            final candidate = item.candidate;
            final editItem = _findEditItemById(item.id);
            final status = candidate.isBlocked
                ? 'Bloqueado'
                : (editItem != null &&
                      _isManualApprovalCandidate(editItem) &&
                      _isManuallyApproved(editItem))
                ? 'Aprovado manualmente'
                : candidate.hasDuplicate
                ? 'Duplicado'
                : candidate.needsReview
                ? 'Revisao'
                : 'Pronto';
            final warnings = item.warnings.isEmpty
                ? '-'
                : item.warnings.join(' | ');

            return DataRow(
              cells: [
                DataCell(
                  Checkbox(
                    value: item.isSelected,
                    onChanged: item.selectable
                        ? (value) => _updateCandidateSelection(
                            id: item.id,
                            selected: value ?? false,
                          )
                        : null,
                  ),
                ),
                DataCell(Text(status)),
                DataCell(
                  Tooltip(
                    message: candidate.originalFileName,
                    child: SizedBox(
                      width: 240,
                      child: Text(
                        candidate.originalFileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Tooltip(
                    message: candidate.analysis.detectedArtist ?? '-',
                    child: SizedBox(
                      width: 190,
                      child: Text(
                        candidate.analysis.detectedArtist ?? '-',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Tooltip(
                    message: candidate.analysis.detectedTitle ?? '-',
                    child: SizedBox(
                      width: 190,
                      child: Text(
                        candidate.analysis.detectedTitle ?? '-',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Tooltip(
                    message: candidate.suggestedOfficialFileName ?? '-',
                    child: SizedBox(
                      width: 360,
                      child: Text(
                        candidate.suggestedOfficialFileName ?? '-',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Tooltip(
                    message: warnings,
                    child: SizedBox(
                      width: 420,
                      child: Text(
                        warnings,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            );
          })
          .toList(growable: false),
    );
  }

  void _updateCandidateArtist({required String id, required String value}) {
    setState(() {
      _importCandidateEditPlan = _importCandidateEditPlan?.withManualEdit(
        id: id,
        artist: value,
      );
      _manuallyApprovedCandidateIds.remove(id);
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
      _manuallyApprovedCandidateIds.remove(id);
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
      _manuallyApprovedCandidateIds.remove(id);
      _resetImportOperationDryRun();
    });
    _validateImportOutputConfiguration();
  }

  bool _hasStructuralEditError(ImportCandidateEditItem item) {
    final artist = item.artist.trim();
    final title = item.title.trim();
    final code = item.code.trim();
    if (artist.isEmpty || title.isEmpty || code.isEmpty) {
      return true;
    }
    final isNumeric5 = RegExp(r'^\d{5}$').hasMatch(code);
    if (!isNumeric5 || code == '00000') {
      return true;
    }
    return false;
  }

  bool _isManualApprovalCandidate(ImportCandidateEditItem item) {
    if (!item.editable) {
      return false;
    }
    return item.editStatus != ImportCandidateEditStatus.valid &&
        !_hasStructuralEditError(item);
  }

  bool _isManuallyApproved(ImportCandidateEditItem item) =>
      _manuallyApprovedCandidateIds.contains(item.id);

  ImportCandidateEditItem? _findEditItemById(String id) {
    final plan = _importCandidateEditPlan;
    if (plan == null) {
      return null;
    }
    for (final item in plan.items) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  bool _hasBlockingSelectedCandidates() {
    final selectionPlan = _importCandidateSelectionPlan;
    final editPlan = _importCandidateEditPlan;
    if (selectionPlan == null || editPlan == null) {
      return false;
    }
    final byId = <String, ImportCandidateEditItem>{
      for (final item in editPlan.items) item.id: item,
    };
    for (final selected in selectionPlan.items.where((s) => s.isSelected)) {
      final editItem = byId[selected.id];
      if (editItem == null) {
        return true;
      }
      if (!_isEffectivelyValidForExecution(editItem)) {
        return true;
      }
    }
    return false;
  }

  ImportCandidateSelectionPlan _buildEffectiveSelectionPlanForOutput({
    required ImportCandidateSelectionPlan selectionPlan,
    required ImportCandidateEditPlan editPlan,
  }) {
    final editById = <String, ImportCandidateEditItem>{
      for (final item in editPlan.items) item.id: item,
    };
    final sanitizedItems = selectionPlan.items
        .map((selectionItem) {
          final editItem = editById[selectionItem.id];
          if (editItem == null) {
            return selectionItem;
          }
          final isSelected = selectionItem.isSelected;
          final isApprovedManually = _isManuallyApproved(editItem);
          if (!isSelected ||
              !_isEffectivelyValidForExecution(editItem) ||
              !isApprovedManually) {
            return selectionItem;
          }
          final filteredWarnings = selectionItem.warnings
              .where(
                (warning) => !_isManualApprovalInformationalWarning(warning),
              )
              .toList(growable: false);
          return selectionItem.copyWith(
            warnings: List.unmodifiable(filteredWarnings),
          );
        })
        .toList(growable: false);

    final hasBlocked = sanitizedItems.any((item) => item.isBlocked);
    final hasNeedsReview = sanitizedItems.any(
      (item) =>
          item.candidate.status == ImportCandidateStatus.needsReview &&
          item.warnings.any(_isManualApprovalInformationalWarning),
    );
    final hasDuplicate = sanitizedItems.any(
      (item) =>
          item.candidate.duplicateMatch != null &&
          item.warnings.any(_isManualApprovalInformationalWarning),
    );

    final warnings = <String>[];
    if (hasBlocked) {
      warnings.add('Existem candidatos bloqueados.');
    }
    if (hasNeedsReview) {
      warnings.add('Existem candidatos aguardando revisao.');
    }
    if (hasDuplicate) {
      warnings.add('Existem possiveis duplicados.');
    }

    return ImportCandidateSelectionPlan(
      items: List.unmodifiable(sanitizedItems),
      warnings: List.unmodifiable(warnings),
    );
  }

  ImportCandidateEditPlan _buildEffectiveEditPlanForOutput({
    required ImportCandidateSelectionPlan selectionPlan,
    required ImportCandidateEditPlan editPlan,
  }) {
    final selectedIds = selectionPlan.items
        .where((item) => item.isSelected)
        .map((item) => item.id)
        .toSet();
    final effectiveItems = editPlan.items
        .map((item) {
          if (!selectedIds.contains(item.id)) {
            return item;
          }
          if (!_isEffectivelyValidForExecution(item)) {
            return item;
          }
          if (item.editStatus == ImportCandidateEditStatus.valid) {
            return item;
          }
          final keptWarnings = item.warnings
              .where(
                (warning) => !_isManualApprovalInformationalWarning(warning),
              )
              .toList(growable: false);
          return ImportCandidateEditItem(
            id: item.id,
            selectionItem: item.selectionItem,
            artist: item.artist,
            title: item.title,
            code: item.code,
            officialFileName: item.officialFileName,
            editStatus: ImportCandidateEditStatus.valid,
            editable: item.editable,
            warnings: List.unmodifiable(keptWarnings),
          );
        })
        .toList(growable: false);

    final planWarnings = <String>[];
    if (effectiveItems.any((item) => item.isInvalid)) {
      planWarnings.add('Existem candidatos com edicao invalida.');
    }
    if (effectiveItems.any((item) => item.isBlocked)) {
      planWarnings.add('Existem candidatos bloqueados para edicao.');
    }

    return ImportCandidateEditPlan(
      items: List.unmodifiable(effectiveItems),
      warnings: List.unmodifiable(planWarnings),
      usedCodes: editPlan.usedCodes,
    );
  }

  bool _isManualApprovalInformationalWarning(String warning) {
    final text = _normalizeForWarningComparison(warning);
    return text.contains('artista nao reconhecido') ||
        text.contains('revise manualmente') ||
        text.contains('revisao necessaria') ||
        text.contains('possivel duplicidade') ||
        text.contains('possivel duplicado') ||
        text.contains('duplicidade') ||
        text.contains('duplicado') ||
        text.contains('ordem musica') ||
        text.contains('autor detectada e invertida') ||
        text.contains('edicao do candidato invalida');
  }

  String _normalizeForWarningComparison(String input) {
    const replacements = <String, String>{
      'á': 'a',
      'à': 'a',
      'â': 'a',
      'ã': 'a',
      'ä': 'a',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'í': 'i',
      'ì': 'i',
      'î': 'i',
      'ï': 'i',
      'ó': 'o',
      'ò': 'o',
      'ô': 'o',
      'õ': 'o',
      'ö': 'o',
      'ú': 'u',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'ç': 'c',
      'ñ': 'n',
    };
    final lower = input.toLowerCase();
    final buffer = StringBuffer();
    for (final rune in lower.runes) {
      final char = String.fromCharCode(rune);
      buffer.write(replacements[char] ?? char);
    }
    return buffer.toString();
  }

  bool _isEffectivelyValidForExecution(ImportCandidateEditItem item) {
    final artist = item.artist.trim();
    final title = item.title.trim();
    final code = item.code.trim();
    final isCodeValid = RegExp(r'^\d{5}$').hasMatch(code) && code != '00000';

    final hasStructuralError =
        artist.isEmpty || title.isEmpty || code.isEmpty || !isCodeValid;
    if (hasStructuralError) {
      return false;
    }

    if (!item.editable) {
      return item.editStatus == ImportCandidateEditStatus.valid;
    }

    if (item.editStatus == ImportCandidateEditStatus.valid) {
      return true;
    }

    final isManualApprovalCandidate =
        item.editStatus != ImportCandidateEditStatus.blocked &&
        item.editStatus != ImportCandidateEditStatus.valid;
    final isManuallyApproved = _manuallyApprovedCandidateIds.contains(item.id);
    if (isManualApprovalCandidate && isManuallyApproved) {
      return true;
    }

    return false;
  }

  void _setManualApprovalForCandidate({
    required String id,
    required bool approved,
  }) {
    setState(() {
      if (approved) {
        _manuallyApprovedCandidateIds.add(id);
      } else {
        _manuallyApprovedCandidateIds.remove(id);
      }
      _resetImportOperationDryRun();
    });
    _validateImportOutputConfiguration();
  }

  void _approveSelectedReviewCandidates() {
    final selectionPlan = _importCandidateSelectionPlan;
    final editPlan = _importCandidateEditPlan;
    if (selectionPlan == null || editPlan == null) {
      return;
    }
    final byId = <String, ImportCandidateEditItem>{
      for (final item in editPlan.items) item.id: item,
    };
    setState(() {
      for (final selected in selectionPlan.items.where((s) => s.isSelected)) {
        final editItem = byId[selected.id];
        if (editItem == null) {
          continue;
        }
        if (_isManualApprovalCandidate(editItem) &&
            !_hasStructuralEditError(editItem)) {
          _manuallyApprovedCandidateIds.add(editItem.id);
        }
      }
      _resetImportOperationDryRun();
    });
    _validateImportOutputConfiguration();
  }

  void _approveAllVisibleManualEditCandidates() {
    setState(() {
      for (final item in _editItemsForDisplay()) {
        if (_isManualApprovalCandidate(item) &&
            !_hasStructuralEditError(item)) {
          _manuallyApprovedCandidateIds.add(item.id);
        }
      }
      _resetImportOperationDryRun();
    });
    _validateImportOutputConfiguration();
  }

  void _clearManualApprovals() {
    setState(() {
      _manuallyApprovedCandidateIds.clear();
      _resetImportOperationDryRun();
    });
    _validateImportOutputConfiguration();
  }

  void _generateImportSuggestions() {
    final baseIndex = _officialLibraryIndexResult;
    if (baseIndex == null) {
      setState(() {
        _importSuggestionMessage =
            'Indexe a biblioteca oficial antes de gerar sugestoes.';
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
            'Escaneie a pasta de musicas novas antes de gerar sugestoes.';
      });
      return;
    }

    if (fileNames.isEmpty) {
      setState(() {
        _importSuggestionMessage =
            'Nenhum arquivo novo para sugerir importacao.';
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
      _importCandidateEditPlan = editPlan;
      _importCandidateEditMessage = 'Edicao manual dos candidatos preparada.';
      _importOutputValidationResult = initialOutputValidation;
      _showImportSuggestionPlan = true;
      _importSuggestionMessage = 'sugestoes de importacao geradas.';
      _showManualImportCandidateEdit = false;
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

    if (_hasBlockingSelectedCandidates()) {
      setState(() {
        _importOperationDryRunMessage =
            'Execucao bloqueada: existem candidatos selecionados que ainda precisam de aprovacao manual ou correcao.';
      });
      return;
    }

    final effectiveEditPlan = _buildEffectiveEditPlanForOutput(
      selectionPlan: selectionPlan,
      editPlan: editPlan,
    );
    final effectiveSelectionPlan = _buildEffectiveSelectionPlanForOutput(
      selectionPlan: selectionPlan,
      editPlan: effectiveEditPlan,
    );
    final outputValidation = ImportOutputConfigurationValidator().validate(
      configuration: _buildImportOutputConfiguration(),
      selectionPlan: effectiveSelectionPlan,
      editPlan: effectiveEditPlan,
    );
    final dryRunPlan = ImportOperationDryRunPlanner().buildDryRun(
      outputValidationResult: outputValidation,
      selectionPlan: effectiveSelectionPlan,
      editPlan: effectiveEditPlan,
      cleaningPlan: cleaningPlan,
    );

    setState(() {
      _importOutputValidationResult = outputValidation;
      _importOperationDryRunPlan = dryRunPlan;
      _showImportOperationDryRun = true;
      _importOperationDryRunMessage = 'Dry-run da importacao gerado.';
      _confirmImportOperationExecution = false;
      _executingImportOperation = false;
      _importOperationConfirmationText = '';
      _importOperationConfirmationController.clear();
      _importOperationExecutionResult = null;
      _importOperationExecutionResultMessage = null;
    });
  }

  bool get _canExecuteImportOperation {
    final dryRunPlan = _importOperationDryRunPlan;
    if (dryRunPlan == null) {
      return false;
    }
    if (!dryRunPlan.hasReadyItems) {
      return false;
    }
    if (!_confirmImportOperationExecution) {
      return false;
    }
    if (_importOperationConfirmationText.trim().toUpperCase() != 'IMPORTAR') {
      return false;
    }
    return !_executingImportOperation;
  }

  Future<void> _executeImportOperation() async {
    final dryRunPlan = _importOperationDryRunPlan;
    if (dryRunPlan == null || !dryRunPlan.hasReadyItems) {
      return;
    }

    if (!_canExecuteImportOperation) {
      setState(() {
        _importOperationExecutionResultMessage =
            'Confirme a revisao do dry-run antes de executar.';
      });
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar importacao real'),
          content: Text(
            'Voce esta prestes a executar ${dryRunPlan.readyCount} operacao(oes) real(is).\n\nEsta acao pode renomear, copiar ou mover arquivos reais e nao possui desfazer automatico nesta fase.\n\nDeseja continuar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Executar importacao real'),
            ),
          ],
        );
      },
    );

    if (!mounted) {
      return;
    }

    if (confirmed != true) {
      setState(() {
        _importOperationExecutionResultMessage =
            'Execucao da importacao cancelada.';
      });
      return;
    }

    setState(() {
      _executingImportOperation = true;
      _importOperationExecutionResultMessage = null;
      _resetImportManifestState();
    });

    final result = await widget.importOperationExecutor.execute(dryRunPlan);

    if (!mounted) {
      return;
    }

    setState(() {
      _executingImportOperation = false;
      _importOperationExecutionResult = result;
      _importOperationExecutionResultMessage =
          'Execucao da importacao concluida. Reindexe a biblioteca oficial e reescaneie as musicas novas para atualizar os resultados.';
      _resetImportManifestState();
    });
  }

  void _generateImportOperationManifest() {
    final executionResult = _importOperationExecutionResult;
    if (executionResult == null) {
      setState(() {
        _importOperationManifestMessage =
            'Execute a importacao antes de gerar o manifesto.';
      });
      return;
    }

    final manifest = ImportOperationManifestBuilder().build(
      configuration: _buildImportOutputConfiguration(),
      executionResult: executionResult,
    );

    setState(() {
      _importOperationManifest = manifest;
      _importOperationManifestMessage = 'Manifesto da importacao gerado.';
      _importOperationManifestWriteResult = null;
    });
  }

  Future<void> _selectImportManifestFolder() async {
    if (_selectingImportManifestFolder) {
      return;
    }

    setState(() {
      _selectingImportManifestFolder = true;
    });

    final selectedFolder = await widget.folderPickerService
        .pickImportManifestFolder();

    if (!mounted) {
      return;
    }

    if (selectedFolder == null) {
      setState(() {
        _selectingImportManifestFolder = false;
        _importOperationManifestMessage = 'Selecao cancelada.';
      });
      return;
    }

    setState(() {
      _selectingImportManifestFolder = false;
      _importManifestFolderPath = selectedFolder.path;
      _importOperationManifestMessage = 'Pasta do manifesto selecionada.';
      _importOperationManifestWriteResult = null;
    });
    _saveSessionCache();
  }

  Future<void> _saveImportOperationManifestJson() async {
    final manifest = _importOperationManifest;
    final folderPath = _importManifestFolderPath;
    if (manifest == null || folderPath == null || folderPath.trim().isEmpty) {
      return;
    }

    setState(() {
      _savingImportManifest = true;
      _importOperationManifestWriteResult = null;
    });

    final result = await widget.importOperationManifestWriter.writeJson(
      manifest: manifest,
      folderPath: folderPath,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _savingImportManifest = false;
      _importOperationManifestWriteResult = result;
      _importOperationManifestMessage = result.success
          ? 'Manifesto JSON salvo.'
          : 'Falha ao salvar manifesto JSON.';
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
    final shouldSaveCache = selectedFolder != null;

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
    if (shouldSaveCache) {
      _saveSessionCache();
    }
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
    final completedSteps = [
      _officialLibraryIndexResult != null,
      _incomingSongsScanResult != null,
      _importSuggestionPlan != null,
      _importCandidateSelectionPlan != null,
      _importOutputValidationResult?.isValid == true,
      _importOperationExecutionResult != null,
      _importOperationManifest != null,
    ].where((v) => v).length;
    final progressPercent = ((completedSteps / 7) * 100).round();
    final dashboardSteps = [
      HomeDashboardStep(
        number: '1',
        label: 'Biblioteca',
        status: _officialLibraryIndexResult != null
            ? HomeStepperStatus.done
            : HomeStepperStatus.pending,
      ),
      HomeDashboardStep(
        number: '2',
        label: 'Novas musicas',
        status: _incomingSongsScanResult != null
            ? HomeStepperStatus.done
            : HomeStepperStatus.pending,
      ),
      HomeDashboardStep(
        number: '3',
        label: 'Sugestoes',
        status: _importSuggestionPlan != null
            ? HomeStepperStatus.done
            : HomeStepperStatus.pending,
      ),
      HomeDashboardStep(
        number: '4',
        label: 'Revisao',
        status: _importCandidateSelectionPlan != null
            ? HomeStepperStatus.ready
            : HomeStepperStatus.pending,
      ),
      HomeDashboardStep(
        number: '5',
        label: 'Saida',
        status: _importOutputValidationResult?.isValid == true
            ? HomeStepperStatus.ready
            : HomeStepperStatus.pending,
      ),
      HomeDashboardStep(
        number: '6',
        label: 'Execucao',
        status: _importOperationExecutionResult != null
            ? HomeStepperStatus.done
            : HomeStepperStatus.pending,
      ),
      HomeDashboardStep(
        number: '7',
        label: 'Manifesto',
        status: _importOperationManifest != null
            ? HomeStepperStatus.done
            : HomeStepperStatus.pending,
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

    return HomeDashboardShell(
      sidebar: HomeDashboardSidebar(
        onNavigate: (sectionId) {
          switch (sectionId) {
            case 'dashboard':
              _scrollToSection(_dashboardKey);
              break;
            case 'library':
              _scrollToSection(_libraryKey);
              break;
            case 'incoming':
              _scrollToSection(_incomingSongsKey);
              break;
            case 'review':
              _scrollToSection(_reviewKey);
              break;
            case 'output':
            case 'execution':
              _scrollToSection(_outputKey);
              break;
            case 'manifest':
              _scrollToSection(_manifestKey);
              break;
            case 'settings':
              _scrollToSection(_cacheKey);
              break;
            case 'help':
              _scrollToSection(_statusKey);
              break;
          }
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KeyedSubtree(
            key: _dashboardKey,
            child: HomeDashboardHeader(
              progressPercent: progressPercent,
              stepsLabel: '$completedSteps/7',
              totalFilesLabel: '${_incomingSongsScanResult?.totalCount ?? 0}',
              validFilesLabel:
                  '${_officialLibraryIndexResult?.validCount ?? 0}',
              pendingFilesLabel: '${7 - completedSteps}',
            ),
          ),
          const SizedBox(height: 16),
          HomeDashboardStepper(steps: dashboardSteps),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _TopMetricCard(
                title: 'Biblioteca',
                lines: [
                  _officialLibraryFolderPath ?? '-',
                  'Validas: ${_officialLibraryIndexResult?.validCount ?? 0}',
                ],
              ),
              _TopMetricCard(
                title: 'Novas musicas',
                lines: [
                  _incomingSongsFolderPath ?? '-',
                  'Scan: ${_incomingSongsScanResult?.totalCount ?? 0}',
                ],
              ),
              _TopMetricCard(
                title: 'Importacao',
                lines: [
                  'Selecionados: ${_importCandidateSelectionPlan?.selectedCount ?? 0}',
                  'Invalidos: ${_importCandidateEditPlan?.invalidCount ?? 0}',
                ],
              ),
              _TopMetricCard(
                title: 'Execucao',
                lines: [
                  _importOperationExecutionResult == null
                      ? 'Pendente'
                      : 'Concluida',
                ],
              ),
              _TopMetricCard(
                title: 'Sessao',
                lines: [
                  _lastSessionSnapshot?.hasSavedAt == true
                      ? 'Cache salvo'
                      : 'Sem cache',
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final lateral = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSessionSummaryPanel(context),
                  const SizedBox(height: 16),
                  _buildSessionCachePanel(context),
                  const SizedBox(height: 16),
                  _buildEngineStatusPanel(context, engineItems),
                  const SizedBox(height: 16),
                  _buildProjectStatusPanel(context),
                ],
              );

              final mainStart = <Widget>[
                _buildOfficialLibraryDashboardCard(
                  context,
                  officialLibraryResult,
                ),
                const SizedBox(height: 20),
                _buildIncomingSongsDashboardCard(context),
                const SizedBox(height: 20),
                _buildSuggestionsReviewDashboardCard(context),
                const SizedBox(height: 20),
                _buildOutputExecutionDashboardCard(context),
                const SizedBox(height: 20),
                _buildManifestDashboardCard(context),
              ];

              if (constraints.maxWidth >= 1180) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: mainStart,
                      ),
                    ),
                    const SizedBox(width: 24),
                    SizedBox(width: 400, child: lateral),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [...mainStart, const SizedBox(height: 24), lateral],
              );
            },
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

extension on _HomeScreenState {
  Widget _buildManifestDashboardCard(BuildContext context) {
    final statusLabel = _importOperationManifestWriteResult?.success == true
        ? 'Salvo'
        : _importOperationManifest != null
        ? 'Gerado'
        : _importOperationExecutionResult != null
        ? 'Pronto para gerar'
        : 'Pendente';
    final statusColor = _importOperationManifestWriteResult?.success == true
        ? HomeDashboardTheme.success
        : _importOperationManifest != null
        ? HomeDashboardTheme.cyan
        : _importOperationExecutionResult != null
        ? HomeDashboardTheme.warning
        : HomeDashboardTheme.textSecondary;

    return KeyedSubtree(
      key: _manifestKey,
      child: HomeDashboardCard(
        title: '5. Manifesto',
        subtitle: 'Gere e salve o manifesto da importacao em JSON.',
        icon: Icons.description_outlined,
        statusLabel: statusLabel,
        statusColor: statusColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_importOperationExecutionResult != null)
              FilledButton.tonal(
                onPressed: _generateImportOperationManifest,
                child: const Text('Gerar manifesto da importacao'),
              )
            else
              const Text('Execute a importacao para gerar o manifesto.'),
            if (_importOperationManifestMessage != null) ...[
              const SizedBox(height: 8),
              Text(_importOperationManifestMessage!),
            ],
            if (_importOperationManifest != null) ...[
              const SizedBox(height: 8),
              Text('ID: ${_importOperationManifest!.id}'),
              const SizedBox(height: 4),
              Text(
                'Gerado em: ${_importOperationManifest!.generatedAtIso8601}',
              ),
              const SizedBox(height: 4),
              Text('Modo de saida: ${_importOperationManifest!.outputMode}'),
              const SizedBox(height: 4),
              Text('Total: ${_importOperationManifest!.summary.totalCount}'),
              const SizedBox(height: 4),
              Text(
                'Sucessos: ${_importOperationManifest!.summary.successCount}',
              ),
              const SizedBox(height: 4),
              Text('Falhas: ${_importOperationManifest!.summary.failedCount}'),
              const SizedBox(height: 4),
              Text(
                'Ignorados: ${_importOperationManifest!.summary.skippedCount}',
              ),
              if (_importOperationManifest!.hasWarnings) ...[
                const SizedBox(height: 8),
                const Text('Avisos:'),
                for (final warning in _importOperationManifest!.warnings)
                  Text('- $warning'),
              ],
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: _selectingImportManifestFolder
                    ? null
                    : _selectImportManifestFolder,
                child: Text(
                  _selectingImportManifestFolder
                      ? 'Selecionando...'
                      : 'Selecionar pasta do manifesto',
                ),
              ),
              const SizedBox(height: 8),
              Text('Pasta do manifesto: ${_importManifestFolderPath ?? '-'}'),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed:
                    _importOperationManifest != null &&
                        _importManifestFolderPath != null &&
                        _importManifestFolderPath!.trim().isNotEmpty &&
                        !_savingImportManifest
                    ? _saveImportOperationManifestJson
                    : null,
                child: Text(
                  _savingImportManifest
                      ? 'Salvando manifesto...'
                      : 'Salvar manifesto JSON',
                ),
              ),
              if (_importOperationManifestWriteResult != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Resultado do salvamento do manifesto',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  _importOperationManifestWriteResult!.success
                      ? 'Sucesso'
                      : 'Falha',
                ),
                const SizedBox(height: 4),
                Text(
                  'Caminho: ${_importOperationManifestWriteResult!.filePath ?? '-'}',
                ),
                if (_importOperationManifestWriteResult!.hasMessages) ...[
                  const SizedBox(height: 4),
                  const Text('Mensagens:'),
                  for (final message
                      in _importOperationManifestWriteResult!.messages)
                    Text('- $message'),
                ],
              ],
              const SizedBox(height: 8),
              for (final item in _manifestItemsForDisplay()) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Acao: ${item.action}'),
                        Text('Status: ${item.status}'),
                        Text('Arquivo: ${item.originalFileName}'),
                        Text('Nome oficial: ${item.officialFileName}'),
                        Text('Origem: ${item.sourcePath ?? '-'}'),
                        Text('Destino: ${item.destinationPath ?? '-'}'),
                        if (item.hasMessages) ...[
                          const SizedBox(height: 4),
                          const Text('Mensagens:'),
                          for (final message in item.messages)
                            Text('- $message'),
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
    );
  }

  Widget _buildOutputExecutionDashboardCard(BuildContext context) {
    final statusLabel = _importOperationExecutionResult != null
        ? 'Concluida'
        : _importOperationDryRunPlan != null
        ? 'Dry-run gerado'
        : _importOutputValidationResult?.isValid == true
        ? 'Configurada'
        : (_importCandidateSelectionPlan != null &&
              _importCandidateEditPlan != null)
        ? 'Pendente'
        : 'Aguardando revisao';
    final statusColor = _importOperationExecutionResult != null
        ? HomeDashboardTheme.success
        : _importOperationDryRunPlan != null
        ? HomeDashboardTheme.cyan
        : _importOutputValidationResult?.isValid == true
        ? HomeDashboardTheme.warning
        : HomeDashboardTheme.textSecondary;

    return KeyedSubtree(
      key: _outputKey,
      child: HomeDashboardCard(
        title: '4. Saida e execucao',
        subtitle:
            'Configure o modo de saida, valide o dry-run e execute com confirmacao forte.',
        icon: Icons.playlist_add_check_circle_outlined,
        statusLabel: statusLabel,
        statusColor: statusColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_importCandidateSelectionPlan != null &&
                _importCandidateEditPlan != null) ...[
              Text(
                'Modo de saida da importacao',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<ImportOutputMode>(
                initialValue: _importOutputMode,
                decoration: const InputDecoration(labelText: 'Modo de saida'),
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
                  _changeImportOutputMode(value);
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
              Text('Biblioteca oficial: ${_officialLibraryFolderPath ?? '-'}'),
              const SizedBox(height: 4),
              Text('Pasta de saida: ${_customImportOutputFolderPath ?? '-'}'),
              const SizedBox(height: 8),
              Text(
                (_importOutputValidationResult?.isValid ?? false)
                    ? 'Configuracao de saida valida.'
                    : 'Configuracao de saida invalida.',
              ),
              if (_importOutputValidationResult?.hasErrors ?? false) ...[
                const SizedBox(height: 8),
                const Text('Erros:'),
                for (final error in _importOutputValidationResult!.errors)
                  Text('- $error'),
              ],
              if (_importOutputValidationResult?.hasWarnings ?? false) ...[
                const SizedBox(height: 8),
                const Text('Avisos:'),
                for (final warning in _importOutputValidationResult!.warnings)
                  Text('- $warning'),
              ],
              if (_importOutputMessage != null) ...[
                const SizedBox(height: 8),
                Text(_importOutputMessage!),
              ],
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {
                  _validateImportOutputConfiguration(setSuccessMessage: true);
                },
                child: const Text('Validar configuracao de saida'),
              ),
            ],
            if (_importCandidateSelectionPlan != null &&
                _importCandidateEditPlan != null &&
                _incomingSongCleaningPreviewPlan != null) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.tonal(
                    onPressed: _generateImportOperationDryRun,
                    child: const Text('Gerar dry-run da importacao'),
                  ),
                  OutlinedButton(
                    onPressed: _importOperationDryRunPlan == null
                        ? null
                        : _toggleImportOperationDryRunVisibility,
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
                Text('Prontas: ${_importOperationDryRunPlan!.readyCount}'),
                const SizedBox(height: 4),
                Text('Bloqueadas: ${_importOperationDryRunPlan!.blockedCount}'),
                if (_importOperationDryRunPlan!.hasWarnings) ...[
                  const SizedBox(height: 8),
                  const Text('Avisos:'),
                  for (final warning in _importOperationDryRunPlan!.warnings)
                    Text('- $warning'),
                ],
                if (_importOperationDryRunPlan!.totalCount > 100) ...[
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status: ${item.status.label}'),
                          Text('Acao: ${item.action.label}'),
                          Text('Arquivo: ${item.originalFileName}'),
                          Text('Nome oficial: ${item.officialFileName}'),
                          Text('Origem: ${item.sourcePathPreview ?? '-'}'),
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
                if (_importOperationDryRunPlan!.hasReadyItems) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Confirmacao obrigatoria para executar importacao real',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Esta acao ira alterar arquivos reais conforme o dry-run da importacao.',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Operacoes prontas para executar: ${_importOperationDryRunPlan!.readyCount}',
                  ),
                  const SizedBox(height: 4),
                  Text('Modo de saida atual: ${_importOutputMode.label}'),
                  const SizedBox(height: 4),
                  const Text(
                    'Esta acao nao possui desfazer automatico nesta fase.',
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Recomendado: teste primeiro em uma copia da pasta de musicas novas.',
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _confirmImportOperationExecution,
                    onChanged: _executingImportOperation
                        ? null
                        : (value) => _setImportOperationExecutionConfirmation(
                            value ?? false,
                          ),
                    title: const Text(
                      'Revisei o dry-run da importacao e confirmo que desejo executar as operacoes prontas.',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _importOperationConfirmationController,
                    enabled: !_executingImportOperation,
                    onChanged: _setImportOperationConfirmationText,
                    decoration: const InputDecoration(
                      labelText: 'Digite IMPORTAR para liberar a execucao',
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: _canExecuteImportOperation
                        ? _executeImportOperation
                        : null,
                    child: Text(
                      _executingImportOperation
                          ? 'Executando importacao...'
                          : 'Executar importacao real',
                    ),
                  ),
                ],
                if (_importOperationExecutionResultMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(_importOperationExecutionResultMessage!),
                ],
                if (_importOperationExecutionResult != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Resultado da execucao da importacao',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Renomeados: ${_importOperationExecutionResult!.renamedCount}',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Copiados: ${_importOperationExecutionResult!.copiedCount}',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Movidos: ${_importOperationExecutionResult!.movedCount}',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ignorados: ${_importOperationExecutionResult!.skippedCount}',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Falhas: ${_importOperationExecutionResult!.failedCount}',
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Reindexe a biblioteca oficial e reescaneie as musicas novas para conferir o resultado atualizado.',
                  ),
                  const SizedBox(height: 8),
                  for (final item
                      in _importOperationExecutionResult!.items.take(100)) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Status: ${item.status.label}'),
                            Text('Acao: ${item.action.label}'),
                            Text('Arquivo: ${item.originalFileName}'),
                            Text('Nome oficial: ${item.officialFileName}'),
                            Text('Origem: ${item.sourcePath ?? '-'}'),
                            Text('Destino: ${item.destinationPath ?? '-'}'),
                            if (item.hasMessages) ...[
                              const SizedBox(height: 4),
                              const Text('Mensagens:'),
                              for (final message in item.messages)
                                Text('- $message'),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (_shouldRenderLegacyManifestBlock &&
                      _importOperationManifest != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Manifesto da importacao',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('ID: ${_importOperationManifest!.id}'),
                    const SizedBox(height: 4),
                    Text(
                      'Gerado em: ${_importOperationManifest!.generatedAtIso8601}',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Modo de saida: ${_importOperationManifest!.outputMode}',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total: ${_importOperationManifest!.summary.totalCount}',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sucessos: ${_importOperationManifest!.summary.successCount}',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Falhas: ${_importOperationManifest!.summary.failedCount}',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ignorados: ${_importOperationManifest!.summary.skippedCount}',
                    ),
                    if (_importOperationManifest!.hasWarnings) ...[
                      const SizedBox(height: 8),
                      const Text('Avisos:'),
                      for (final warning in _importOperationManifest!.warnings)
                        Text('- $warning'),
                    ],
                    const SizedBox(height: 8),
                    FilledButton.tonal(
                      onPressed: _selectingImportManifestFolder
                          ? null
                          : _selectImportManifestFolder,
                      child: Text(
                        _selectingImportManifestFolder
                            ? 'Selecionando...'
                            : 'Selecionar pasta do manifesto',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pasta do manifesto: ${_importManifestFolderPath ?? '-'}',
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed:
                          _importOperationManifest != null &&
                              _importManifestFolderPath != null &&
                              _importManifestFolderPath!.trim().isNotEmpty &&
                              !_savingImportManifest
                          ? _saveImportOperationManifestJson
                          : null,
                      child: Text(
                        _savingImportManifest
                            ? 'Salvando manifesto...'
                            : 'Salvar manifesto JSON',
                      ),
                    ),
                    if (_importOperationManifestWriteResult != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Resultado do salvamento do manifesto',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _importOperationManifestWriteResult!.success
                            ? 'Sucesso'
                            : 'Falha',
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Caminho: ${_importOperationManifestWriteResult!.filePath ?? '-'}',
                      ),
                      if (_importOperationManifestWriteResult!.hasMessages) ...[
                        const SizedBox(height: 4),
                        const Text('Mensagens:'),
                        for (final message
                            in _importOperationManifestWriteResult!.messages)
                          Text('- $message'),
                      ],
                    ],
                    const SizedBox(height: 8),
                    for (final item in _manifestItemsForDisplay()) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Acao: ${item.action}'),
                              Text('Status: ${item.status}'),
                              Text('Arquivo: ${item.originalFileName}'),
                              Text('Nome oficial: ${item.officialFileName}'),
                              Text('Origem: ${item.sourcePath ?? '-'}'),
                              Text('Destino: ${item.destinationPath ?? '-'}'),
                              if (item.hasMessages) ...[
                                const SizedBox(height: 4),
                                const Text('Mensagens:'),
                                for (final message in item.messages)
                                  Text('- $message'),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                ],
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsReviewDashboardCard(BuildContext context) {
    return _buildSuggestionsReviewDashboardCardCompact(context);

    /*
    final statusLabel = _importCandidateSelectionPlan != null
        ? 'Em revisao'
        : _importSuggestionPlan != null
        ? 'Gerada'
        : _incomingSongsScanResult != null
        ? 'Pronta para sugestoes'
        : 'Pendente';
    final statusColor = _importCandidateSelectionPlan != null
        ? HomeDashboardTheme.cyan
        : _importSuggestionPlan != null
        ? HomeDashboardTheme.success
        : _incomingSongsScanResult != null
        ? HomeDashboardTheme.warning
        : HomeDashboardTheme.textSecondary;

    return KeyedSubtree(
      key: _reviewKey,
      child: HomeDashboardCard(
        title: '3. Sugestoes e revisao',
        subtitle:
            'Gere sugestoes de importacao, revise candidatos e prepare a selecao.',
        icon: Icons.fact_check_outlined,
        statusLabel: statusLabel,
        statusColor: statusColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_incomingSongsScanResult != null &&
                _incomingSongsScanResult!.totalCount > 0) ...[
              FilledButton.tonal(
                onPressed: _generateImportSuggestions,
                child: const Text('Gerar sugestoes de importacao'),
              ),
            ] else ...[
              const Text('Escaneie as musicas novas para gerar sugestoes.'),
            ],
            if (_importSuggestionMessage != null) ...[
              const SizedBox(height: 8),
              Text(_importSuggestionMessage!),
            ],
            if (_importSuggestionPlan != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _toggleImportSuggestionPlanVisibility,
                child: Text(
                  _showImportSuggestionPlan
                      ? 'Ocultar sugestoes de importacao'
                      : 'Mostrar sugestoes de importacao',
                ),
              ),
            ],
            if (_importSuggestionPlan != null && _showImportSuggestionPlan) ...[
              const SizedBox(height: 12),
              Text(
                'sugestoes de importacao',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text('Total: ${_importSuggestionPlan!.totalCount}'),
              const SizedBox(height: 4),
              Text('Prontos: ${_readyImportCandidates().length}'),
              const SizedBox(height: 4),
              Text(
                'Revisao necessaria: ${_importSuggestionPlan!.needsReviewCount}',
              ),
              const SizedBox(height: 4),
              Text('Bloqueados: ${_importSuggestionPlan!.blockedCount}'),
              const SizedBox(height: 4),
              Text(
                'Possiveis duplicados: ${_duplicateImportCandidates().length}',
              ),
              if (_importSuggestionPlan!.hasWarnings) ...[
                const SizedBox(height: 8),
                const Text('Avisos:'),
                const SizedBox(height: 4),
                for (final warning in _importSuggestionPlan!.warnings) ...[
                  Text('- $warning'),
                  const SizedBox(height: 2),
                ],
              ],
              const SizedBox(height: 16),
              Text(
                'Revisao dos candidatos',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Prontos para importar: ${_readyImportCandidates().length}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  OutlinedButton(
                    onPressed: _toggleReadyImportCandidatesVisibility,
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
                for (final candidate in _readyImportCandidates().take(50)) ...[
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
                  if (candidate.analysis.detectedArtist != null) ...[
                    const SizedBox(height: 2),
                    Text('Artista: ${candidate.analysis.detectedArtist}'),
                  ],
                  if (candidate.analysis.detectedTitle != null) ...[
                    const SizedBox(height: 2),
                    Text('Musica: ${candidate.analysis.detectedTitle}'),
                  ],
                  if (candidate.hasSuggestedCode) ...[
                    const SizedBox(height: 2),
                    Text('Codigo sugerido: ${candidate.suggestedCode}'),
                  ],
                  if (candidate.suggestedOfficialFileName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Nome oficial sugerido: ${candidate.suggestedOfficialFileName}',
                    ),
                  ],
                  const SizedBox(height: 10),
                ],
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Precisam de revisao: ${_reviewImportCandidates().length}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  OutlinedButton(
                    onPressed: _toggleReviewImportCandidatesVisibility,
                    child: Text(
                      _showReviewImportCandidates
                          ? 'Ocultar revisao'
                          : 'Mostrar revisao',
                    ),
                  ),
                ],
              ),
              if (_showReviewImportCandidates) ...[
                const SizedBox(height: 8),
                if (_reviewImportCandidates().isEmpty)
                  const Text('Nenhum candidato para revisao.'),
                if (_reviewImportCandidates().length > 50)
                  Text(
                    'Exibindo os primeiros 50 de ${_reviewImportCandidates().length} candidatos.',
                  ),
                for (final candidate in _reviewImportCandidates().take(50)) ...[
                  const Text('Revisao necessaria'),
                  const SizedBox(height: 2),
                  const Text('Arquivo:'),
                  Text(candidate.originalFileName),
                  const SizedBox(height: 2),
                  const Text('Original:'),
                  Text(candidate.analysis.originalFileName),
                  const SizedBox(height: 2),
                  const Text('Nome limpo:'),
                  Text(candidate.analysis.cleanedName),
                  if (candidate.analysis.detectedArtist != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Artista detectado: ${candidate.analysis.detectedArtist}',
                    ),
                  ],
                  if (candidate.analysis.detectedTitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Musica detectada: ${candidate.analysis.detectedTitle}',
                    ),
                  ],
                  const SizedBox(height: 2),
                  Text('Confianca: ${candidate.analysis.confidence.label}'),
                  if (candidate.suggestedOfficialFileName != null) ...[
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
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Bloqueados: ${_blockedImportCandidates().length}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  OutlinedButton(
                    onPressed: _toggleBlockedImportCandidatesVisibility,
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
                for (final candidate in _blockedImportCandidates().take(
                  50,
                )) ...[
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
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Possiveis duplicados: ${_duplicateImportCandidates().length}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  OutlinedButton(
                    onPressed: _toggleDuplicateImportCandidatesVisibility,
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
                  const Text('Nenhum possivel duplicado encontrado.'),
                if (_duplicateImportCandidates().length > 50)
                  Text(
                    'Exibindo os primeiros 50 de ${_duplicateImportCandidates().length} Possiveis duplicados.',
                  ),
                for (final candidate in _duplicateImportCandidates().take(
                  50,
                )) ...[
                  const Text('possivel duplicado'),
                  const SizedBox(height: 2),
                  const Text('Arquivo:'),
                  Text(candidate.originalFileName),
                  if (candidate.suggestedOfficialFileName != null) ...[
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
            if (_importCandidateSelectionPlan != null) ...[
              const SizedBox(height: 16),
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
                'Nao selecionados: ${_importCandidateSelectionPlan!.notSelectedCount}',
              ),
              const SizedBox(height: 4),
              Text(
                'Bloqueados: ${_importCandidateSelectionPlan!.blockedCount}',
              ),
              const SizedBox(height: 4),
              Text(
                'Selecionaveis: ${_importCandidateSelectionPlan!.selectableCount}',
              ),
              if (_importCandidateSelectionPlan!.hasWarnings) ...[
                const SizedBox(height: 8),
                const Text('Avisos do plano:'),
                const SizedBox(height: 4),
                for (final warning
                    in _importCandidateSelectionPlan!.warnings) ...[
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
                    child: const Text('Selecionar todos os prontos'),
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
                      ? (value) => _updateCandidateSelection(
                          id: item.id,
                          selected: value ?? false,
                        )
                      : null,
                  title: Text('Selecao: ${item.selectionStatus.label}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status do candidato: ${item.candidate.status.label}',
                      ),
                      Text('Arquivo: ${item.candidate.originalFileName}'),
                      Text(
                        'Nome oficial sugerido: ${item.candidate.suggestedOfficialFileName ?? '-'}',
                      ),
                      Text(
                        'Codigo sugerido: ${item.candidate.suggestedCode ?? '-'}',
                      ),
                      if (item.hasWarnings) ...[
                        const SizedBox(height: 4),
                        const Text('Avisos:'),
                        for (final warning in item.warnings) Text('- $warning'),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ],
            if (_importCandidateEditPlan != null) ...[
              const SizedBox(height: 16),
                      Text(
                        'Edicao manual dos candidatos',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      _buildManualEditTable(),
                      const SizedBox(height: 12),
              const SizedBox(height: 8),
              Text(
                'Total de candidatos: ${_importCandidateEditPlan!.totalCount}',
              ),
              const SizedBox(height: 4),
              Text('Editaveis: ${_importCandidateEditPlan!.editableCount}'),
              const SizedBox(height: 4),
              Text('Validos: ${_importCandidateEditPlan!.validCount}'),
              const SizedBox(height: 4),
              Text('Invalidos: ${_importCandidateEditPlan!.invalidCount}'),
              const SizedBox(height: 4),
              Text('Bloqueados: ${_importCandidateEditPlan!.blockedCount}'),
              if (_importCandidateEditPlan!.hasWarnings) ...[
                const SizedBox(height: 8),
                const Text('Avisos do plano:'),
                const SizedBox(height: 4),
                for (final warning in _importCandidateEditPlan!.warnings) ...[
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
              for (var i = 0; i < _editItemsForDisplay().length; i++) ...[
                Builder(
                  builder: (context) {
                    final item = _editItemsForDisplay()[i];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Status da edicao: ${item.editStatus.label}'),
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
                                key: ValueKey('import-edit-artist-$i'),
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
                                key: ValueKey('import-edit-title-$i'),
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
                                key: ValueKey('import-edit-code-$i'),
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
          ],
        ),
      ),
    );
    */
  }

  Widget _buildIncomingSongsDashboardCard(BuildContext context) {
    final statusLabel =
        _incomingSongCleaningPreviewPlan != null ||
            _importSuggestionPlan != null
        ? 'Pronta'
        : _incomingSongsScanResult != null
        ? 'Escaneada'
        : _incomingSongsFolderPath != null
        ? 'Selecionada'
        : 'Pendente';
    final statusColor =
        _incomingSongCleaningPreviewPlan != null ||
            _importSuggestionPlan != null
        ? HomeDashboardTheme.success
        : _incomingSongsScanResult != null
        ? HomeDashboardTheme.cyan
        : _incomingSongsFolderPath != null
        ? HomeDashboardTheme.warning
        : HomeDashboardTheme.textSecondary;

    final metrics = [
      ('Arquivos escaneados', '${_incomingSongsScanResult?.totalCount ?? 0}'),
      ('Avisos', '${_incomingSongsScanResult?.warnings.length ?? 0}'),
      (
        'Pre-limpeza',
        _incomingSongCleaningPreviewPlan == null
            ? '-'
            : '${_incomingSongCleaningPreviewPlan!.totalCount}',
      ),
      (
        'Sugestoes',
        _importSuggestionPlan == null
            ? '-'
            : '${_importSuggestionPlan!.totalCount}',
      ),
    ];

    return KeyedSubtree(
      key: _incomingSongsKey,
      child: HomeDashboardCard(
        title: '2. Musicas novas',
        subtitle:
            'Selecione, escaneie e prepare os arquivos novos antes da importacao.',
        icon: Icons.library_music_outlined,
        statusLabel: statusLabel,
        statusColor: statusColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: HomeDashboardTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: HomeDashboardTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pasta de musicas novas selecionada:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _incomingSongsFolderPath ??
                        'Nenhuma pasta de musicas novas selecionada.',
                    style: const TextStyle(
                      color: HomeDashboardTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                HomeDashboardButton.primary(
                  label: _selectingIncomingSongsFolder
                      ? 'Selecionando...'
                      : 'Selecionar pasta de musicas novas',
                  onPressed: _selectingIncomingSongsFolder
                      ? null
                      : _selectIncomingSongsFolder,
                ),
                if (_incomingSongsFolderPath != null)
                  HomeDashboardButton.secondary(
                    label: _scanningIncomingSongsFolder
                        ? 'Escaneando...'
                        : 'Escanear musicas novas',
                    onPressed: _scanningIncomingSongsFolder
                        ? null
                        : _scanIncomingSongsFolder,
                  ),
              ],
            ),
            if (_incomingSongsFolderPath == null) ...[
              const SizedBox(height: 8),
              const Text('Selecione a pasta para habilitar o scan.'),
            ],
            if (_incomingSongsFolderSelectionMessage != null) ...[
              const SizedBox(height: 12),
              Text(_incomingSongsFolderSelectionMessage!),
            ],
            if (_incomingSongsScanMessage != null) ...[
              const SizedBox(height: 8),
              Text(_incomingSongsScanMessage!),
            ],
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final metric in metrics)
                  Container(
                    width: 170,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: HomeDashboardTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: HomeDashboardTheme.border),
                    ),
                    child: HomeDashboardMetric(
                      label: metric.$1,
                      value: metric.$2,
                    ),
                  ),
              ],
            ),
            if (_incomingSongsScanResult != null) ...[
              const SizedBox(height: 20),
              Divider(color: HomeDashboardTheme.border),
              const SizedBox(height: 16),
              Text(
                'musicas novas encontradas: ${_incomingSongsScanResult!.totalCount}',
              ),
              if (_incomingSongsScanResult!.hasWarnings) ...[
                const SizedBox(height: 8),
                const Text('Avisos do scan:'),
                const SizedBox(height: 4),
                for (final warning in _incomingSongsScanResult!.warnings) ...[
                  Text('- $warning'),
                  const SizedBox(height: 2),
                ],
              ],
              if (_incomingSongsScanResult!.totalCount == 0) ...[
                const SizedBox(height: 8),
                const Text('Nenhum .mp4 encontrado na pasta de musicas novas.'),
              ],
              if (_incomingSongsScanResult!.totalCount > 0) ...[
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Inverter Musica - Artista'),
                  subtitle: const Text(
                    'Use quando os arquivos vierem do YouTube como "Nome da musica - Nome do artista".',
                  ),
                  value: _invertIncomingSongMusicArtist,
                  onChanged: _setInvertIncomingSongMusicArtist,
                ),
                const SizedBox(height: 8),
                FilledButton.tonal(
                  onPressed: _generateIncomingSongCleaningPreview,
                  child: const Text('Gerar pre-limpeza dos nomes'),
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
                onPressed: _toggleIncomingSongCleaningPreview,
                child: Text(
                  _showIncomingSongCleaningPreview
                      ? 'Ocultar pre-limpeza'
                      : 'Mostrar pre-limpeza',
                ),
              ),
            ],
            if (_incomingSongCleaningPreviewPlan != null &&
                _showIncomingSongCleaningPreview) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: HomeDashboardTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: HomeDashboardTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pre-limpeza dos nomes',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Arquivos analisados: ${_incomingSongCleaningPreviewPlan!.totalCount}',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Alterados: ${_incomingSongCleaningPreviewPlan!.changedCount}',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sem alteracao: ${_incomingSongCleaningPreviewPlan!.unchangedCount}',
                    ),
                    if (_incomingSongCleaningPreviewPlan!.hasWarnings) ...[
                      const SizedBox(height: 8),
                      const Text('Avisos:'),
                      for (final warning
                          in _incomingSongCleaningPreviewPlan!.warnings)
                        Text('- $warning'),
                    ],
                    const SizedBox(height: 12),
                    if (_incomingSongCleaningPreviewPlan!.items.length > 30)
                      Text(
                        'Exibindo os primeiros 30 de ${_incomingSongCleaningPreviewPlan!.items.length} arquivos.',
                      ),
                    const SizedBox(height: 8),
                    Table(
                      border: TableBorder.all(color: HomeDashboardTheme.border),
                      columnWidths: const {
                        0: FlexColumnWidth(3),
                        1: FlexColumnWidth(3),
                        2: FlexColumnWidth(2),
                      },
                      children: [
                        const TableRow(
                          decoration: BoxDecoration(
                            color: HomeDashboardTheme.surface,
                          ),
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Text('Original'),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Text('Renomeado'),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Text('Status'),
                            ),
                          ],
                        ),
                        for (final item
                            in _incomingSongCleaningPreviewPlan!.items.take(30))
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(item.originalFileName),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(item.cleanedFileName),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  item.hasWarnings
                                      ? 'Aviso'
                                      : (item.originalFileName !=
                                            item.cleanedFileName)
                                      ? 'Alterado'
                                      : 'Sem alteracao',
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOfficialLibraryDashboardCard(
    BuildContext context,
    BaseLibraryIndexResult? officialLibraryResult,
  ) {
    final statusLabel = officialLibraryResult != null
        ? 'Indexada'
        : (_officialLibraryFolderPath == null ? 'Pendente' : 'Selecionada');
    final statusColor = officialLibraryResult != null
        ? HomeDashboardTheme.success
        : (_officialLibraryFolderPath == null
              ? HomeDashboardTheme.warning
              : HomeDashboardTheme.cyan);
    final metrics = [
      ('Musicas validas', '${officialLibraryResult?.validCount ?? 0}'),
      ('Arquivos invalidos', '${officialLibraryResult?.invalidCount ?? 0}'),
      ('Duplicados', '${officialLibraryResult?.duplicateCodeCount ?? 0}'),
      (
        'Maior codigo',
        officialLibraryResult?.maxCodeNumber?.toString().padLeft(5, '0') ?? '-',
      ),
      (
        'Buracos disponiveis',
        '${officialLibraryResult?.availableCodeGaps.length ?? 0}',
      ),
      (
        'Artistas conhecidos',
        '${officialLibraryResult?.knownArtists.length ?? 0}',
      ),
    ];

    return KeyedSubtree(
      key: _libraryKey,
      child: HomeDashboardCard(
        title: '1. Biblioteca oficial',
        subtitle: 'Selecione e indexe a pasta oficial ja padronizada.',
        icon: Icons.library_music_rounded,
        statusLabel: statusLabel,
        statusColor: statusColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: HomeDashboardTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: HomeDashboardTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Biblioteca oficial selecionada:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _officialLibraryFolderPath ?? 'Nenhuma pasta selecionada.',
                    style: const TextStyle(
                      color: HomeDashboardTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                HomeDashboardButton.primary(
                  label: _selectingOfficialFolder
                      ? 'Selecionando...'
                      : 'Selecionar biblioteca oficial',
                  onPressed: _selectingOfficialFolder
                      ? null
                      : _selectOfficialLibraryFolder,
                ),
                HomeDashboardButton.secondary(
                  label: _indexingOfficialLibrary
                      ? 'Indexando...'
                      : 'Indexar biblioteca oficial',
                  onPressed:
                      (_indexingOfficialLibrary ||
                          _officialLibraryFolderPath == null)
                      ? null
                      : _indexOfficialLibrary,
                ),
              ],
            ),
            if (_folderSelectionMessage != null) ...[
              const SizedBox(height: 12),
              Text(_folderSelectionMessage!),
            ],
            if (_officialLibraryIndexMessage != null) ...[
              const SizedBox(height: 8),
              Text(_officialLibraryIndexMessage!),
            ],
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final metric in metrics)
                  Container(
                    width: 170,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: HomeDashboardTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: HomeDashboardTheme.border),
                    ),
                    child: HomeDashboardMetric(
                      label: metric.$1,
                      value: metric.$2,
                    ),
                  ),
              ],
            ),
            if (officialLibraryResult != null) ...[
              if (officialLibraryResult.hasInvalidFiles ||
                  officialLibraryResult.hasDuplicates) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: HomeDashboardTheme.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: HomeDashboardTheme.border),
                  ),
                  child: const Text(
                    'Atencao: revise os problemas encontrados na auditoria.',
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Divider(color: HomeDashboardTheme.border),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Auditoria da biblioteca oficial',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  HomeDashboardBadge(
                    label:
                        'Invalidos ${officialLibraryResult.invalidCount} | Duplicados ${officialLibraryResult.duplicateCodeCount}',
                    color: HomeDashboardTheme.primary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('Arquivos invalidos: ${officialLibraryResult.invalidCount}'),
              const SizedBox(height: 4),
              Text(
                'Codigos duplicados: ${officialLibraryResult.duplicateCodeCount}',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: _toggleInvalidFilesVisibility,
                    child: Text(
                      _showInvalidFiles
                          ? 'Ocultar arquivos invalidos'
                          : 'Mostrar arquivos invalidos',
                    ),
                  ),
                  OutlinedButton(
                    onPressed: _toggleDuplicateCodesVisibility,
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
                  const Text('Nenhum arquivo invalido encontrado.')
                else ...[
                  if (officialLibraryResult.invalidFiles.length >
                      _HomeScreenState._auditListLimit)
                    Text(
                      'Exibindo os primeiros ${_HomeScreenState._auditListLimit} de ${officialLibraryResult.invalidFiles.length} arquivos invalidos.',
                    ),
                  const SizedBox(height: 8),
                  for (final invalidFile
                      in officialLibraryResult.invalidFiles.take(
                        _HomeScreenState._auditListLimit,
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
                  const Text('Nenhum codigo duplicado encontrado.')
                else ...[
                  if (officialLibraryResult.duplicateCodes.length >
                      _HomeScreenState._auditListLimit)
                    Text(
                      'Exibindo os primeiros ${_HomeScreenState._auditListLimit} de ${officialLibraryResult.duplicateCodes.length} codigos duplicados.',
                    ),
                  const SizedBox(height: 8),
                  for (final duplicate
                      in officialLibraryResult.duplicateCodes.take(
                        _HomeScreenState._auditListLimit,
                      )) ...[
                    Text('Codigo duplicado: ${duplicate.code}'),
                    const SizedBox(height: 4),
                    for (final entry in duplicate.entries) ...[
                      Text('- ${entry.song.artist} - ${entry.song.title}'),
                      Text('  Arquivo: ${entry.displayPath}'),
                      const SizedBox(height: 4),
                    ],
                    const SizedBox(height: 8),
                  ],
                ],
              ],
              if (officialLibraryResult.duplicateCodes.isNotEmpty) ...[
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: _generateDuplicateRepairPlan,
                  child: const Text('Gerar plano de reparo de duplicados'),
                ),
              ],
              if (_duplicateRepairMessage != null) ...[
                const SizedBox(height: 8),
                Text(_duplicateRepairMessage!),
              ],
              if (_duplicateCodeRepairPlan != null) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _toggleDuplicateRepairPlanVisibility,
                  child: Text(
                    _showDuplicateRepairPlan
                        ? 'Ocultar plano de reparo'
                        : 'Mostrar plano de reparo',
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton.tonal(
                  onPressed: _generateDuplicateRepairExecutionDryRun,
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
                  for (final warning in _duplicateCodeRepairPlan!.warnings) ...[
                    Text('- $warning'),
                    const SizedBox(height: 2),
                  ],
                ],
                const SizedBox(height: 8),
                if (_duplicateCodeRepairPlan!.groups.length >
                    _HomeScreenState._repairGroupLimit)
                  Text(
                    'Exibindo os primeiros ${_HomeScreenState._repairGroupLimit} de ${_duplicateCodeRepairPlan!.groups.length} grupos de reparo.',
                  ),
                const SizedBox(height: 6),
                for (final group in _duplicateCodeRepairPlan!.groups.take(
                  _HomeScreenState._repairGroupLimit,
                )) ...[
                  Text('Codigo duplicado: ${group.duplicatedCode}'),
                  const SizedBox(height: 4),
                  if (group.items.length >
                      _HomeScreenState._repairItemsPerGroupLimit)
                    Text(
                      'Exibindo os primeiros ${_HomeScreenState._repairItemsPerGroupLimit} de ${group.items.length} itens deste grupo.',
                    ),
                  const SizedBox(height: 4),
                  for (final item in group.items.take(
                    _HomeScreenState._repairItemsPerGroupLimit,
                  )) ...[
                    if (item.keepsOriginalCode) ...[
                      const Text('Manter codigo original:'),
                      Text('${item.artist} - ${item.title}'),
                      Text('Arquivo: ${item.displayPath}'),
                      Text('Codigo mantido: ${item.originalCode}'),
                    ] else if (item.assignsNewCode) ...[
                      const Text('Atribuir novo codigo:'),
                      Text('${item.artist} - ${item.title}'),
                      Text('Arquivo atual: ${item.displayPath}'),
                      Text('Novo codigo: ${item.suggestedCode}'),
                      Text('Novo nome sugerido: ${item.suggestedFileName}'),
                    ] else ...[
                      const Text('Bloqueado:'),
                      Text('${item.artist} - ${item.title}'),
                      Text('Arquivo: ${item.displayPath}'),
                      const Text('Avisos:'),
                      for (final warning in item.warnings) Text('- $warning'),
                    ],
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 8),
                ],
              ],
              if (_duplicateRepairExecutionPlan != null) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _toggleDuplicateRepairExecutionPlanVisibility,
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
                if (_duplicateRepairExecutionPlan!.hasWarnings) ...[
                  const SizedBox(height: 8),
                  const Text('Avisos do dry-run:'),
                  const SizedBox(height: 4),
                  for (final warning
                      in _duplicateRepairExecutionPlan!.warnings) ...[
                    Text('- $warning'),
                    const SizedBox(height: 2),
                  ],
                ],
                const SizedBox(height: 8),
                if (_duplicateRepairExecutionPlan!.items.length >
                    _HomeScreenState._executionItemsLimit)
                  Text(
                    'Exibindo os primeiros ${_HomeScreenState._executionItemsLimit} de ${_duplicateRepairExecutionPlan!.items.length} itens do dry-run.',
                  ),
                const SizedBox(height: 6),
                for (final item in _duplicateRepairExecutionPlan!.items.take(
                  _HomeScreenState._executionItemsLimit,
                )) ...[
                  if (item.isReadyToRename) ...[
                    const Text('Pronto para renomear:'),
                    Text('${item.artist} - ${item.title}'),
                    Text('Origem: ${item.sourcePathPreview}'),
                    Text('Destino: ${item.destinationPathPreview}'),
                  ] else if (item.isSkipped) ...[
                    const Text('Ignorado: mantem codigo original'),
                    Text('${item.artist} - ${item.title}'),
                    Text('Origem: ${item.sourcePathPreview}'),
                  ] else ...[
                    const Text('Bloqueado:'),
                    Text('${item.artist} - ${item.title}'),
                    Text('Origem: ${item.sourcePathPreview}'),
                    const Text('Avisos:'),
                    for (final warning in item.warnings) Text('- $warning'),
                  ],
                  const SizedBox(height: 8),
                ],
              ],
              if (_duplicateRepairExecutionPlan != null &&
                  _duplicateRepairExecutionPlan!.hasReadyItems) ...[
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
                      : (value) => _setDuplicateRepairExecutionConfirmation(
                          value ?? false,
                        ),
                ),
                TextField(
                  controller: _duplicateRepairConfirmationController,
                  enabled: !_executingDuplicateRepair,
                  decoration: const InputDecoration(
                    labelText: 'Digite RENOMEAR para liberar a execucao',
                  ),
                  onChanged: _setDuplicateRepairConfirmationText,
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
              if (_duplicateRepairExecutionResultMessage != null) ...[
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
                Text('Falhas: ${_duplicateRepairExecutionResult!.failedCount}'),
                const SizedBox(height: 8),
                const Text(
                  'Reindexe a biblioteca oficial para conferir o resultado atualizado.',
                ),
                const SizedBox(height: 8),
                if (_duplicateRepairExecutionResult!.items.length >
                    _HomeScreenState._executionItemsLimit)
                  Text(
                    'Exibindo os primeiros ${_HomeScreenState._executionItemsLimit} de ${_duplicateRepairExecutionResult!.items.length} itens do resultado.',
                  ),
                const SizedBox(height: 6),
                for (final item in _duplicateRepairExecutionResult!.items.take(
                  _HomeScreenState._executionItemsLimit,
                )) ...[
                  Text('Status: ${item.status.label}'),
                  const SizedBox(height: 2),
                  Text('Arquivo original: ${item.suggestedFileName ?? '-'}'),
                  Text('Origem: ${item.sourcePath ?? '-'}'),
                  Text('Destino: ${item.destinationPath ?? '-'}'),
                  if (item.messages.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    const Text('Mensagens:'),
                    for (final message in item.messages) Text('- $message'),
                  ],
                  const SizedBox(height: 8),
                ],
              ],
              if (officialLibraryResult.hasInvalidFiles) ...[
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: _generateInvalidFileRepairPlan,
                  child: const Text('Gerar plano de reparo de invalidos'),
                ),
              ],
              if (_invalidFileRepairMessage != null) ...[
                const SizedBox(height: 8),
                Text(_invalidFileRepairMessage!),
              ],
              if (_invalidFileRepairPlan != null) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _toggleInvalidFileRepairPlanVisibility,
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
                Text('Total: ${_invalidFileRepairPlan!.totalCount}'),
                const SizedBox(height: 4),
                Text(
                  'Sugestoes prontas: ${_invalidFileRepairPlan!.readyToSuggestCount}',
                ),
                const SizedBox(height: 4),
                Text(
                  'Revisao necessaria: ${_invalidFileRepairPlan!.needsReviewCount}',
                ),
                const SizedBox(height: 4),
                Text('Bloqueados: ${_invalidFileRepairPlan!.blockedCount}'),
                if (_invalidFileRepairPlan!.warnings.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text('Avisos do plano:'),
                  const SizedBox(height: 4),
                  for (final warning in _invalidFileRepairPlan!.warnings) ...[
                    Text('- $warning'),
                    const SizedBox(height: 2),
                  ],
                ],
                const SizedBox(height: 8),
                if (_invalidFileRepairPlan!.items.length >
                    _HomeScreenState._invalidFileRepairItemsLimit)
                  Text(
                    'Exibindo os primeiros ${_HomeScreenState._invalidFileRepairItemsLimit} de ${_invalidFileRepairPlan!.items.length} itens do plano.',
                  ),
                const SizedBox(height: 6),
                for (final item in _invalidFileRepairPlan!.items.take(
                  _HomeScreenState._invalidFileRepairItemsLimit,
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
                    Text('Artista detectado: ${item.analysis.detectedArtist}'),
                  ],
                  if (item.analysis.detectedTitle != null) ...[
                    const SizedBox(height: 2),
                    Text('Musica detectada: ${item.analysis.detectedTitle}'),
                  ],
                  if (item.hasSuggestedFileName) ...[
                    const SizedBox(height: 2),
                    Text('Novo nome sugerido: ${item.suggestedFileName}'),
                  ],
                  if (item.hasSuggestedCode) ...[
                    const SizedBox(height: 2),
                    Text('Codigo sugerido: ${item.suggestedCode}'),
                  ],
                  if (item.warnings.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    const Text('Avisos:'),
                    for (final warning in item.warnings) Text('- $warning'),
                  ],
                  const SizedBox(height: 10),
                ],
              ],
              if (_invalidFileRepairPlan != null) ...[
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: _generateInvalidFileRepairExecutionDryRun,
                  child: const Text('Validar execucao dos invalidos'),
                ),
              ],
              if (_invalidFileRepairExecutionMessage != null) ...[
                const SizedBox(height: 8),
                Text(_invalidFileRepairExecutionMessage!),
              ],
              if (_invalidFileRepairExecutionPlan != null) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _toggleInvalidFileRepairExecutionPlanVisibility,
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
                if (_invalidFileRepairExecutionPlan!.warnings.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text('Avisos do dry-run:'),
                  const SizedBox(height: 4),
                  for (final warning
                      in _invalidFileRepairExecutionPlan!.warnings) ...[
                    Text('- $warning'),
                    const SizedBox(height: 2),
                  ],
                ],
                const SizedBox(height: 8),
                if (_invalidFileRepairExecutionPlan!.items.length >
                    _HomeScreenState._invalidFileRepairItemsLimit)
                  Text(
                    'Exibindo os primeiros ${_HomeScreenState._invalidFileRepairItemsLimit} de ${_invalidFileRepairExecutionPlan!.items.length} itens do dry-run de invalidos.',
                  ),
                const SizedBox(height: 6),
                for (final item in _invalidFileRepairExecutionPlan!.items.take(
                  _HomeScreenState._invalidFileRepairItemsLimit,
                )) ...[
                  if (item.isReadyToRename) ...[
                    const Text('Pronto para renomear:'),
                    if (item.detectedArtist != null &&
                        item.detectedTitle != null)
                      Text('${item.detectedArtist} - ${item.detectedTitle}'),
                    const Text('Arquivo atual:'),
                    Text(item.sourcePathPreview ?? item.displayPath),
                    const Text('Destino:'),
                    Text(item.destinationPathPreview ?? '-'),
                  ] else if (item.isSkipped) ...[
                    const Text('Aguardando revisao:'),
                    if (item.detectedArtist != null &&
                        item.detectedTitle != null)
                      Text('${item.detectedArtist} - ${item.detectedTitle}'),
                    const Text('Arquivo atual:'),
                    Text(item.sourcePathPreview ?? item.displayPath),
                    if (item.warnings.isNotEmpty) ...[
                      const Text('Avisos:'),
                      for (final warning in item.warnings) Text('- $warning'),
                    ],
                  ] else ...[
                    const Text('Bloqueado:'),
                    const Text('Arquivo atual:'),
                    Text(item.sourcePathPreview ?? item.displayPath),
                    if (item.warnings.isNotEmpty) ...[
                      const Text('Avisos:'),
                      for (final warning in item.warnings) Text('- $warning'),
                    ],
                  ],
                  const SizedBox(height: 8),
                ],
              ],
              if (_invalidFileRepairExecutionPlan != null &&
                  _invalidFileRepairExecutionPlan!.hasReadyItems) ...[
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
                      : (value) => _setInvalidRepairExecutionConfirmation(
                          value ?? false,
                        ),
                ),
                TextField(
                  controller: _invalidRepairConfirmationController,
                  enabled: !_executingInvalidRepair,
                  decoration: const InputDecoration(
                    labelText: 'Digite RENOMEAR para liberar a execucao',
                  ),
                  onChanged: _setInvalidRepairConfirmationText,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed:
                      _executingInvalidRepair ||
                          !_confirmInvalidRepairExecution ||
                          _invalidRepairConfirmationText.trim().toUpperCase() !=
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
              if (_invalidRepairExecutionResultMessage != null) ...[
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
                Text('Falhas: ${_invalidRepairExecutionResult!.failedCount}'),
                const SizedBox(height: 8),
                const Text(
                  'Reindexe a biblioteca oficial para conferir o resultado atualizado.',
                ),
                const SizedBox(height: 8),
                if (_invalidRepairExecutionResult!.items.length >
                    _HomeScreenState._invalidFileRepairItemsLimit)
                  Text(
                    'Exibindo os primeiros ${_HomeScreenState._invalidFileRepairItemsLimit} de ${_invalidRepairExecutionResult!.items.length} itens do resultado.',
                  ),
                const SizedBox(height: 6),
                for (final item in _invalidRepairExecutionResult!.items.take(
                  _HomeScreenState._invalidFileRepairItemsLimit,
                )) ...[
                  if (item.isRenamed) ...[
                    const Text('Renomeado:'),
                    if (item.detectedArtist != null &&
                        item.detectedTitle != null)
                      Text('${item.detectedArtist} - ${item.detectedTitle}'),
                    Text('Origem: ${item.sourcePath ?? '-'}'),
                    Text('Destino: ${item.destinationPath ?? '-'}'),
                    if (item.messages.isNotEmpty)
                      Text('Mensagem: ${item.messages.first}'),
                  ] else if (item.isSkipped) ...[
                    const Text('Ignorado:'),
                    Text('Arquivo original: ${item.originalFileName}'),
                    for (final message in item.messages)
                      Text('Mensagem: $message'),
                  ] else ...[
                    const Text('Falhou:'),
                    Text('Arquivo original: ${item.originalFileName}'),
                    Text('Origem: ${item.sourcePath ?? '-'}'),
                    Text('Destino: ${item.destinationPath ?? '-'}'),
                    const Text('Mensagens:'),
                    for (final message in item.messages) Text('- $message'),
                  ],
                  const SizedBox(height: 8),
                ],
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSessionSummaryPanel(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumo da sessao',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Biblioteca oficial: ${_officialLibraryFolderPath == null ? 'Pendente' : 'Pronta'}',
            ),
            Text(
              'Novas musicas: ${_incomingSongsFolderPath == null ? 'Pendente' : 'Pronta'}',
            ),
            Text(
              'Sugestoes: ${_importSuggestionPlan == null ? 'Pendente' : 'Geradas'}',
            ),
            Text(
              'Revisao: ${_importCandidateSelectionPlan == null ? 'Pendente' : 'Disponivel'}',
            ),
            Text(
              'Saida: ${_importOutputValidationResult?.isValid == true ? 'Valida' : 'Pendente'}',
            ),
            Text(
              'Execucao: ${_importOperationExecutionResult == null ? 'Pendente' : 'Concluida'}',
            ),
            Text(
              'Manifesto: ${_importOperationManifest == null ? 'Pendente' : 'Gerado'}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCachePanel(BuildContext context) {
    return KeyedSubtree(
      key: _cacheKey,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cache local da sessao',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (_loadingSessionCache) const Text('Carregando cache...'),
              if (_savingSessionCache) const Text('Salvando cache...'),
              if (_sessionCacheMessage != null) ...[
                Text(_sessionCacheMessage!),
                const SizedBox(height: 8),
              ],
              Text(
                'Ultimo cache salvo em: ${_lastSessionSnapshot?.savedAtIso8601 ?? '-'}',
              ),
              Text(
                'Biblioteca oficial salva: ${_lastSessionSnapshot?.officialLibraryFolderPath ?? '-'}',
              ),
              Text(
                'Pasta de musicas novas salva: ${_lastSessionSnapshot?.incomingSongsFolderPath ?? '-'}',
              ),
              Text(
                'Pasta de saida salva: ${_lastSessionSnapshot?.customImportOutputFolderPath ?? '-'}',
              ),
              Text(
                'Pasta do manifesto salva: ${_lastSessionSnapshot?.importManifestFolderPath ?? '-'}',
              ),
              Text(
                'Modo de saida salvo: ${_lastSessionSnapshot?.importOutputModeName == null ? '-' : _importOutputModeLabelFromName(_lastSessionSnapshot?.importOutputModeName)}',
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: _savingSessionCache ? null : _saveSessionCache,
                    child: const Text('Salvar sessao agora'),
                  ),
                  OutlinedButton(
                    onPressed: _savingSessionCache ? null : _clearSessionCache,
                    child: const Text('Limpar cache local'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEngineStatusPanel(
    BuildContext context,
    List<String> engineItems,
  ) {
    return KeyedSubtree(
      key: _statusKey,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Motor e status',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              const Text('Motor preparado'),
              const SizedBox(height: 8),
              for (final item in engineItems) ...[
                Text('- $item'),
                const SizedBox(height: 2),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectStatusPanel(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status do projeto',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text('Round 35D12 - Duplicidade canonica artista musica'),
            const SizedBox(height: 4),
            const Text(
              'Estado: Duplicidade forte detectada por artista e musica canonicos, mantendo aprovacao manual e dry-run liberado.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualEditTable() {
    final items = _editItemsForDisplay();
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    return DataTable(
      columnSpacing: 12,
      columns: const [
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Aprovado manualmente')),
        DataColumn(label: Text('Arquivo original')),
        DataColumn(label: Text('Artista')),
        DataColumn(label: Text('Musica')),
        DataColumn(label: Text('Codigo')),
        DataColumn(label: Text('Nome oficial')),
        DataColumn(label: Text('Avisos')),
      ],
      rows: [
        for (var i = 0; i < items.length; i++) _buildManualEditRow(items[i], i),
      ],
    );
  }

  DataRow _buildManualEditRow(ImportCandidateEditItem item, int index) {
    final warnings = item.warnings.isEmpty ? '-' : item.warnings.join(' | ');
    final canManualApprove =
        _isManualApprovalCandidate(item) && !_hasStructuralEditError(item);
    final manuallyApproved = _isManuallyApproved(item);
    final effectiveStatus = canManualApprove && manuallyApproved
        ? 'Aprovado manualmente'
        : item.editStatus.label;
    return DataRow(
      cells: [
        DataCell(Text(effectiveStatus)),
        DataCell(
          Checkbox(
            value: manuallyApproved,
            onChanged: canManualApprove
                ? (value) => _setManualApprovalForCandidate(
                    id: item.id,
                    approved: value ?? false,
                  )
                : null,
          ),
        ),
        DataCell(
          Tooltip(
            message: item.selectionItem.candidate.originalFileName,
            child: SizedBox(
              width: 240,
              child: Text(
                item.selectionItem.candidate.originalFileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        DataCell(
          Tooltip(
            message: item.artist,
            child: SizedBox(
              width: 190,
              child: TextFormField(
                key: ValueKey('import-edit-artist-$index'),
                initialValue: item.artist,
                enabled: item.editable,
                onChanged: (value) {
                  _updateCandidateArtist(id: item.id, value: value);
                },
                decoration: const InputDecoration(isDense: true),
              ),
            ),
          ),
        ),
        DataCell(
          Tooltip(
            message: item.title,
            child: SizedBox(
              width: 190,
              child: TextFormField(
                key: ValueKey('import-edit-title-$index'),
                initialValue: item.title,
                enabled: item.editable,
                onChanged: (value) {
                  _updateCandidateTitle(id: item.id, value: value);
                },
                decoration: const InputDecoration(isDense: true),
              ),
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 120,
            child: TextFormField(
              key: ValueKey('import-edit-code-$index'),
              initialValue: item.code,
              enabled: item.editable,
              onChanged: (value) {
                _updateCandidateCode(id: item.id, value: value);
              },
              decoration: const InputDecoration(isDense: true),
            ),
          ),
        ),
        DataCell(
          Tooltip(
            message: item.officialFileName.isEmpty
                ? '-'
                : item.officialFileName,
            child: SizedBox(
              width: 360,
              child: Text(
                item.officialFileName.isEmpty ? '-' : item.officialFileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        DataCell(
          Tooltip(
            message: warnings,
            child: SizedBox(
              width: 420,
              child: Text(
                warnings,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ignore: unused_element
  Widget _buildSuggestionsReviewDashboardCardCompact(BuildContext context) {
    final statusLabel = _importCandidateSelectionPlan != null
        ? 'Em revisao'
        : _importSuggestionPlan != null
        ? 'Gerada'
        : _incomingSongsScanResult != null
        ? 'Pronta para sugestoes'
        : 'Pendente';
    final statusColor = _importCandidateSelectionPlan != null
        ? HomeDashboardTheme.cyan
        : _importSuggestionPlan != null
        ? HomeDashboardTheme.success
        : _incomingSongsScanResult != null
        ? HomeDashboardTheme.warning
        : HomeDashboardTheme.textSecondary;

    return KeyedSubtree(
      key: _reviewKey,
      child: HomeDashboardCard(
        title: '3. Sugestoes e revisao',
        subtitle:
            'Gere sugestoes de importacao, revise candidatos e prepare a selecao.',
        icon: Icons.fact_check_outlined,
        statusLabel: statusLabel,
        statusColor: statusColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_incomingSongsScanResult != null &&
                _incomingSongsScanResult!.totalCount > 0) ...[
              FilledButton.tonal(
                onPressed: _generateImportSuggestions,
                child: const Text('Gerar sugestoes de importacao'),
              ),
            ],
            if (_importSuggestionMessage != null) ...[
              const SizedBox(height: 8),
              Text(_importSuggestionMessage!),
            ],
            if (_importSuggestionPlan != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _toggleImportSuggestionPlanVisibility,
                child: Text(
                  _showImportSuggestionPlan
                      ? 'Ocultar sugestoes de importacao'
                      : 'Mostrar sugestoes de importacao',
                ),
              ),
            ],
            if (_importSuggestionPlan != null && _showImportSuggestionPlan) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildCompactMetric(
                    'Total',
                    '${_importSuggestionPlan!.totalCount}',
                  ),
                  _buildCompactMetric(
                    'Prontos',
                    '${_readyImportCandidates().length}',
                  ),
                  _buildCompactMetric(
                    'Revisao necessaria',
                    '${_importSuggestionPlan!.needsReviewCount}',
                  ),
                  _buildCompactMetric(
                    'Bloqueados',
                    '${_importSuggestionPlan!.blockedCount}',
                  ),
                  _buildCompactMetric(
                    'Possiveis duplicados',
                    '${_duplicateImportCandidates().length}',
                  ),
                  _buildCompactMetric(
                    'Selecionados',
                    '${_importCandidateSelectionPlan?.selectedCount ?? 0}',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: _selectAllSelectableCandidates,
                    child: const Text('Selecionar todos'),
                  ),
                  OutlinedButton(
                    onPressed: _selectAllReadyCandidates,
                    child: const Text('Selecionar todos os prontos'),
                  ),
                  OutlinedButton(
                    onPressed: _clearSelectedCandidates,
                    child: const Text('Limpar selecao'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Use a tabela para selecionar candidatos. Itens Pronto ja foram aprovados automaticamente; itens Revisao precisam de confirmacao manual antes da execucao.',
              ),
              const SizedBox(height: 8),
              _buildSuggestionsTableWithVisibleScrollbars(),
            ],
            if (_importCandidateEditPlan != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _toggleManualImportCandidateEditVisibility,
                child: Text(
                  _showManualImportCandidateEdit
                      ? 'Ocultar Edicao manual'
                      : 'Mostrar Edicao manual',
                ),
              ),
              if (_showManualImportCandidateEdit) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
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
                      Text('Validos: ${_importCandidateEditPlan!.validCount}'),
                      const SizedBox(height: 4),
                      Text(
                        'Invalidos: ${_importCandidateEditPlan!.invalidCount}',
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bloqueados: ${_importCandidateEditPlan!.blockedCount}',
                      ),
                      if (_importCandidateEditMessage != null) ...[
                        const SizedBox(height: 8),
                        Text(_importCandidateEditMessage!),
                      ],
                      const SizedBox(height: 8),
                      const Text(
                        'Itens em Revisao ou Duplicado podem ser selecionados, mas so poderao executar quando a edicao manual estiver valida. Confira artista, musica e codigo antes de gerar o dry-run final.',
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton(
                            onPressed: _approveSelectedReviewCandidates,
                            child: const Text(
                              'Aprovar selecionados em revisao',
                            ),
                          ),
                          OutlinedButton(
                            onPressed: _approveAllVisibleManualEditCandidates,
                            child: const Text('Aprovar todos visiveis'),
                          ),
                          OutlinedButton(
                            onPressed: _clearManualApprovals,
                            child: const Text('Limpar aprovacao manual'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_editItemsForDisplay().isEmpty)
                        const Text(
                          'Selecione candidatos na tabela de sugestoes para revisar ou aprovar manualmente.',
                        )
                      else
                        _buildManualEditTableWithVisibleScrollbars(),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsTableWithVisibleScrollbars() {
    return _buildScrollableTableFrame(
      horizontalController: _suggestionsTableHorizontalController,
      verticalController: _suggestionsTableVerticalController,
      child: _buildImportCandidatesTable(),
    );
  }

  Widget _buildManualEditTableWithVisibleScrollbars() {
    return _buildScrollableTableFrame(
      horizontalController: _manualEditTableHorizontalController,
      verticalController: _manualEditTableVerticalController,
      child: _buildManualEditTable(),
    );
  }

  Widget _buildScrollableTableFrame({
    required ScrollController horizontalController,
    required ScrollController verticalController,
    required Widget child,
  }) {
    final colors = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final minWidth = constraints.maxWidth + 520;
        return SizedBox(
          width: double.infinity,
          height: 480,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Scrollbar(
                controller: horizontalController,
                thumbVisibility: true,
                notificationPredicate: (notification) =>
                    notification.metrics.axis == Axis.horizontal,
                child: SingleChildScrollView(
                  controller: horizontalController,
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: minWidth),
                    child: Scrollbar(
                      controller: verticalController,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        controller: verticalController,
                        child: child,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactMetric(String label, String value) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: HomeDashboardTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HomeDashboardTheme.border),
      ),
      child: HomeDashboardMetric(label: label, value: value),
    );
  }
}

class _InvertedFileNameResult {
  _InvertedFileNameResult({
    required this.cleanedFileName,
    required this.warnings,
  });

  final String cleanedFileName;
  final List<String> warnings;
}

class _TopMetricCard extends StatelessWidget {
  const _TopMetricCard({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        color: const Color(0xFF171B24),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 6),
              for (final line in lines) ...[
                Text(line, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
