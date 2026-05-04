import 'package:flutter/material.dart';

import '../../base_library/application/official_library_scan_service.dart';
import '../../base_library/domain/base_library.dart';
import '../../folder_selection/application/folder_picker_service.dart';
import '../../library_repair/domain/library_repair.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({
    super.key,
    FolderPickerService? folderPickerService,
    OfficialLibraryScanService? officialLibraryScanService,
  }) : folderPickerService = folderPickerService ?? const FolderPickerService(),
       officialLibraryScanService =
           officialLibraryScanService ?? OfficialLibraryScanService();

  final FolderPickerService folderPickerService;
  final OfficialLibraryScanService officialLibraryScanService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int _auditListLimit = 50;
  static const int _repairGroupLimit = 50;
  static const int _repairItemsPerGroupLimit = 20;

  String? _officialLibraryFolderPath;
  bool _selectingOfficialFolder = false;
  String? _folderSelectionMessage;

  bool _indexingOfficialLibrary = false;
  BaseLibraryIndexResult? _officialLibraryIndexResult;
  String? _officialLibraryIndexMessage;
  bool _showInvalidFiles = false;
  bool _showDuplicateCodes = false;
  DuplicateCodeRepairPlan? _duplicateCodeRepairPlan;
  bool _showDuplicateRepairPlan = false;
  String? _duplicateRepairMessage;

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

    setState(() {
      _indexingOfficialLibrary = false;
      _officialLibraryIndexResult = result;
      _officialLibraryIndexMessage = 'Biblioteca oficial indexada.';
      _showInvalidFiles = false;
      _showDuplicateCodes = false;
      _duplicateCodeRepairPlan = null;
      _showDuplicateRepairPlan = false;
      _duplicateRepairMessage = null;
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

    setState(() {
      _duplicateCodeRepairPlan = plan;
      _showDuplicateRepairPlan = true;
      _duplicateRepairMessage = 'Plano de reparo de duplicados gerado.';
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
                            'Round 11 - Indexacao da biblioteca oficial',
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Estado: Selecao e indexacao real da biblioteca oficial habilitadas.',
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
