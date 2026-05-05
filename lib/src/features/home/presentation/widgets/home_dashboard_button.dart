import 'package:flutter/material.dart';

class HomeDashboardButton extends StatelessWidget {
  const HomeDashboardButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
  }) : _outlined = false;

  const HomeDashboardButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
  }) : _outlined = true;

  final String label;
  final VoidCallback? onPressed;
  final bool _outlined;

  @override
  Widget build(BuildContext context) {
    if (_outlined) {
      return OutlinedButton(onPressed: onPressed, child: Text(label));
    }
    return FilledButton(onPressed: onPressed, child: Text(label));
  }
}
