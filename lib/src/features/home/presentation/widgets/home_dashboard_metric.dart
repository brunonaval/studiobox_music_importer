import 'package:flutter/material.dart';

import 'home_dashboard_theme.dart';

class HomeDashboardMetric extends StatelessWidget {
  const HomeDashboardMetric({
    super.key,
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: HomeDashboardTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: color ?? HomeDashboardTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
