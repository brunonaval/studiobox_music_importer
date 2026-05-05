import 'package:flutter/material.dart';

import 'home_dashboard_theme.dart';

class HomeDashboardSidebar extends StatelessWidget {
  const HomeDashboardSidebar({super.key, this.onNavigate});

  final void Function(String sectionId)? onNavigate;

  @override
  Widget build(BuildContext context) {
    final items = <({String id, String label, IconData icon})>[
      (id: 'dashboard', label: 'Dashboard', icon: Icons.dashboard_outlined),
      (id: 'library', label: 'Biblioteca', icon: Icons.library_music_outlined),
      (id: 'incoming', label: 'Novas musicas', icon: Icons.audio_file_outlined),
      (id: 'review', label: 'Revisao', icon: Icons.fact_check_outlined),
      (id: 'output', label: 'Saida', icon: Icons.output_outlined),
      (id: 'execution', label: 'Execucao', icon: Icons.play_circle_outline),
      (id: 'manifest', label: 'Manifesto', icon: Icons.description_outlined),
    ];

    return Container(
      width: HomeDashboardTheme.sidebarWidth,
      color: HomeDashboardTheme.sidebar,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: HomeDashboardTheme.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: const Text(
              'SB',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                for (final item in items)
                  _SidebarItem(
                    label: item.label,
                    icon: item.icon,
                    highlighted: item.id == 'dashboard',
                    onTap: () => onNavigate?.call(item.id),
                  ),
              ],
            ),
          ),
          _SidebarItem(
            label: 'Configuracoes',
            icon: Icons.settings_outlined,
            onTap: () => onNavigate?.call('settings'),
          ),
          _SidebarItem(
            label: 'Ajuda',
            icon: Icons.help_outline,
            onTap: () => onNavigate?.call('help'),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.label,
    required this.icon,
    this.highlighted = false,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final bool highlighted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: highlighted
                ? HomeDashboardTheme.primary.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Icon(icon, size: 16, color: HomeDashboardTheme.textSecondary),
              const SizedBox(height: 2),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
