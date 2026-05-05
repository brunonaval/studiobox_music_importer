import 'package:flutter/material.dart';

import 'home_dashboard_badge.dart';
import 'home_dashboard_theme.dart';

class HomeDashboardCard extends StatelessWidget {
  const HomeDashboardCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.icon,
    this.trailing,
    this.statusLabel,
    this.statusColor,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget child;
  final Widget? trailing;
  final String? statusLabel;
  final Color? statusColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HomeDashboardTheme.surface,
        borderRadius: BorderRadius.circular(HomeDashboardTheme.cardRadius),
        border: Border.all(color: HomeDashboardTheme.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (statusLabel != null)
                  HomeDashboardBadge(
                    label: statusLabel!,
                    color: statusColor ?? HomeDashboardTheme.primary,
                  ),
                if (trailing != null) ...[const SizedBox(width: 8), trailing!],
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                style: const TextStyle(color: HomeDashboardTheme.textSecondary),
              ),
            ],
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}
