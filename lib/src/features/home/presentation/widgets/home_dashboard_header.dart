import 'package:flutter/material.dart';

import 'home_dashboard_badge.dart';
import 'home_dashboard_card.dart';
import 'home_dashboard_metric.dart';
import 'home_dashboard_theme.dart';

class HomeDashboardHeader extends StatelessWidget {
  const HomeDashboardHeader({
    super.key,
    required this.progressPercent,
    required this.stepsLabel,
    required this.totalFilesLabel,
    required this.validFilesLabel,
    required this.pendingFilesLabel,
  });

  final int progressPercent;
  final String stepsLabel;
  final String totalFilesLabel;
  final String validFilesLabel;
  final String pendingFilesLabel;

  @override
  Widget build(BuildContext context) {
    return HomeDashboardCard(
      title: 'StudioBox Music Importer',
      subtitle: 'Prepare novas musicas para o padrao do Karaoke StudioBox.',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    HomeDashboardBadge(
                      label: 'Round 35',
                      color: HomeDashboardTheme.primary,
                    ),
                    HomeDashboardBadge(
                      label: 'Fluxo seguro',
                      color: HomeDashboardTheme.cyan,
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text('Revise tudo antes de executar operacoes reais.'),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 300,
            child: HomeDashboardCard(
              title: 'Progresso da sessao',
              statusLabel: '$progressPercent%',
              statusColor: HomeDashboardTheme.success,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HomeDashboardMetric(label: 'Etapas', value: stepsLabel),
                  const SizedBox(height: 8),
                  HomeDashboardMetric(
                    label: 'Arquivos',
                    value: totalFilesLabel,
                  ),
                  const SizedBox(height: 8),
                  HomeDashboardMetric(label: 'Validos', value: validFilesLabel),
                  const SizedBox(height: 8),
                  HomeDashboardMetric(
                    label: 'Pendentes',
                    value: pendingFilesLabel,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
