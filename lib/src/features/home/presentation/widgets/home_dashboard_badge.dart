import 'package:flutter/material.dart';

import 'home_dashboard_theme.dart';

class HomeDashboardBadge extends StatelessWidget {
  const HomeDashboardBadge({super.key, required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: (color ?? HomeDashboardTheme.primary).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: HomeDashboardTheme.border),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}
