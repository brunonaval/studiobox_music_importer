import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                            'Status do projeto:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          const Text('Round 1 - Shell inicial'),
                          const SizedBox(height: 4),
                          const Text(
                            'Estado: Nenhuma biblioteca indexada ainda.',
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
