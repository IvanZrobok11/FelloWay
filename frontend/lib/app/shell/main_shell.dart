import 'package:flutter/material.dart';
import 'package:felloway_client/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        destinations: [
          NavigationDestination(
            icon: Tooltip(
              message: l10n.tabEvents,
              child: const Icon(Icons.event_outlined),
            ),
            selectedIcon: Tooltip(
              message: l10n.tabEvents,
              child: const Icon(Icons.event),
            ),
            label: l10n.tabEvents,
          ),
          NavigationDestination(
            icon: Tooltip(
              message: l10n.tabMap,
              child: const Icon(Icons.map_outlined),
            ),
            selectedIcon: Tooltip(
              message: l10n.tabMap,
              child: const Icon(Icons.map),
            ),
            label: l10n.tabMap,
          ),
          NavigationDestination(
            icon: Tooltip(
              message: l10n.tabChats,
              child: const Icon(Icons.chat_bubble_outline),
            ),
            selectedIcon: Tooltip(
              message: l10n.tabChats,
              child: const Icon(Icons.chat_bubble),
            ),
            label: l10n.tabChats,
          ),
          NavigationDestination(
            icon: Tooltip(
              message: l10n.tabProfile,
              child: const Icon(Icons.person_outline),
            ),
            selectedIcon: Tooltip(
              message: l10n.tabProfile,
              child: const Icon(Icons.person),
            ),
            label: l10n.tabProfile,
          ),
        ],
      ),
    );
  }
}
