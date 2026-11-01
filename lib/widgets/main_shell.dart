import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Scaffold hosting the 5 main tabs with a bottom navigation bar.
///
/// Each tab keeps its own navigation stack via [StatefulNavigationShell].
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const _destinations = [
    NavigationDestination(icon: Icon(LucideIcons.home), label: 'Home'),
    NavigationDestination(icon: Icon(LucideIcons.barChart3), label: 'Analytics'),
    NavigationDestination(icon: Icon(LucideIcons.plusCircle), label: 'Add Data'),
    NavigationDestination(icon: Icon(LucideIcons.sparkles), label: 'AI Studio'),
    NavigationDestination(icon: Icon(LucideIcons.user), label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        destinations: _destinations,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        // Tapping the active tab again pops it back to its root.
        onDestinationSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
      ),
    );
  }
}
