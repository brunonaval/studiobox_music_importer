import 'package:flutter/material.dart';

import 'home_dashboard_theme.dart';

enum HomeStepperStatus { pending, ready, attention, done }

class HomeDashboardStep {
  const HomeDashboardStep({
    required this.number,
    required this.label,
    required this.status,
  });

  final String number;
  final String label;
  final HomeStepperStatus status;
}

class HomeDashboardStepper extends StatelessWidget {
  const HomeDashboardStepper({super.key, required this.steps});

  final List<HomeDashboardStep> steps;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: HomeDashboardTheme.surface,
        borderRadius: BorderRadius.circular(HomeDashboardTheme.cardRadius),
        border: Border.all(color: HomeDashboardTheme.border),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [for (final step in steps) _StepPill(step: step)],
      ),
    );
  }
}

class _StepPill extends StatelessWidget {
  const _StepPill({required this.step});

  final HomeDashboardStep step;

  Color _statusColor(HomeStepperStatus status) {
    switch (status) {
      case HomeStepperStatus.done:
        return HomeDashboardTheme.success;
      case HomeStepperStatus.attention:
        return HomeDashboardTheme.warning;
      case HomeStepperStatus.ready:
        return HomeDashboardTheme.cyan;
      case HomeStepperStatus.pending:
        return HomeDashboardTheme.textSecondary;
    }
  }

  String _statusLabel(HomeStepperStatus status) {
    switch (status) {
      case HomeStepperStatus.done:
        return 'Concluido';
      case HomeStepperStatus.attention:
        return 'Atencao';
      case HomeStepperStatus.ready:
        return 'Pronto';
      case HomeStepperStatus.pending:
        return 'Pendente';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(step.status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: HomeDashboardTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: HomeDashboardTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: color.withValues(alpha: 0.2),
            child: Text(
              step.number,
              style: TextStyle(fontSize: 11, color: color),
            ),
          ),
          const SizedBox(width: 8),
          Text(step.label),
          const SizedBox(width: 6),
          Text(
            '- ${_statusLabel(step.status)}',
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
