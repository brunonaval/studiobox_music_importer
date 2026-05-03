import 'package:flutter/material.dart';

import '../../folder_selection/application/folder_picker_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, FolderPickerService? folderPickerService})
    : folderPickerService = folderPickerService ?? const FolderPickerService();

  final FolderPickerService folderPickerService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _officialLibraryFolderPath;
  bool _selectingOfficialFolder = false;
  String? _folderSelectionMessage;

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

  @override
  Widget build(BuildContext context) {
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
                          if (_folderSelectionMessage != null) ...[
                            const SizedBox(height: 8),
                            Text(_folderSelectionMessage!),
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
                          const Text('Round 9 - Dominio organizado'),
                          const SizedBox(height: 4),
                          const Text(
                            'Estado: Motor logico preparado. Integracao com pastas reais ainda nao implementada.',
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
