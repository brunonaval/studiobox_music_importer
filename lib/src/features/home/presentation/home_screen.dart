import 'package:flutter/material.dart';

import '../../base_library/application/official_library_scan_service.dart';
import '../../base_library/domain/base_library.dart';
import '../../folder_selection/application/folder_picker_service.dart';
import '../../library_repair/application/duplicate_code_repair_executor.dart';
import '../../library_repair/application/invalid_file_repair_executor.dart';
import '../../library_repair/domain/library_repair.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({
    super.key,
    FolderPickerService? folderPickerService,
    OfficialLibraryScanService? officialLibraryScanService,
    DuplicateCodeRepairExecutor? duplicateCodeRepairExecutor,
    InvalidFileRepairExecutor? invalidFileRepairExecutor,
  }) : folderPickerService = folderPickerService ?? const FolderPickerService(),
       officialLibraryScanService =
           officialLibraryScanService ?? OfficialLibraryScanService(),
       duplicateCodeRepairExecutor =
           duplicateCodeRepairExecutor ?? DuplicateCodeRepairExecutor(),
       invalidFileRepairExecutor =
           invalidFileRepairExecutor ?? InvalidFileRepairExecutor();

  final FolderPickerService folderPickerService;
  final OfficialLibraryScanService officialLibraryScanService;
  final DuplicateCodeRepairExecutor duplicateCodeRepairExecutor;
  final InvalidFileRepairExecutor invalidFileRepairExecutor;

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
                            'Round 23 - Selecao da pasta de musicas novas',
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Estado: Selecao de pasta de musicas novas sem scan.',
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
