import 'package:flutter/material.dart';

import 'home_dashboard_theme.dart';

class HomeDashboardShell extends StatelessWidget {
  const HomeDashboardShell({
    super.key,
    required this.sidebar,
    required this.child,
  });

  final Widget sidebar;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeDashboardTheme.background,
      body: SafeArea(
        child: Row(
          children: [
            SizedBox(width: HomeDashboardTheme.sidebarWidth, child: sidebar),
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1500),
                    child: Padding(
                      padding: const EdgeInsets.all(
                        HomeDashboardTheme.pagePadding,
                      ),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
