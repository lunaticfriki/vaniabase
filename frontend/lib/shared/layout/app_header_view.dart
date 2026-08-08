import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/shared/session/session_state.dart';
import 'package:frontend/shared/session/session_state_service.dart';
import 'package:frontend/shared/theme/theme_state_service.dart';
import 'package:pixelarticons/pixel.dart';

/// Below this width the inline nav links no longer fit comfortably, so they
/// collapse into a hamburger menu instead.
const navWideBreakpoint = 640.0;

class _NavItem {
  const _NavItem({required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;
}

class AppHeaderView extends StatelessWidget implements PreferredSizeWidget {
  const AppHeaderView({
    required this.onNavigateHome,
    required this.onNavigateItems,
    required this.onNavigateCategories,
    required this.onNavigateAddItem,
    required this.onLogout,
    super.key,
  });

  final VoidCallback onNavigateHome;
  final VoidCallback onNavigateItems;
  final VoidCallback onNavigateCategories;
  final VoidCallback onNavigateAddItem;
  final VoidCallback onLogout;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = context.select(
      (SessionStateService service) => service.state is SessionAuthenticated,
    );
    final themeMode = context.watch<ThemeStateService>().state;
    final isWide = MediaQuery.sizeOf(context).width >= navWideBreakpoint;

    final navItems = [
      _NavItem(label: 'All items', icon: Pixel.grid, onTap: onNavigateItems),
      _NavItem(label: 'Categories', icon: Pixel.bookmarks, onTap: onNavigateCategories),
      _NavItem(label: 'Add item', icon: Pixel.fileplus, onTap: onNavigateAddItem),
    ];

    return AppBar(
      title: InkWell(onTap: onNavigateHome, child: const Text('vaniabase')),
      actions: [
        ...isWide
            ? [
                for (final item in navItems)
                  TextButton.icon(
                    onPressed: item.onTap,
                    icon: Icon(item.icon),
                    label: Text(item.label),
                  ),
              ]
            : [
                PopupMenuButton<VoidCallback>(
                  icon: const Icon(Pixel.menu),
                  tooltip: 'Menu',
                  onSelected: (onTap) => onTap(),
                  itemBuilder: (context) => [
                    for (final item in navItems)
                      PopupMenuItem<VoidCallback>(
                        value: item.onTap,
                        child: Row(
                          children: [
                            Icon(item.icon, size: 20),
                            const SizedBox(width: 12),
                            Text(item.label),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
        IconButton(
          onPressed: () => context.read<ThemeStateService>().toggle(),
          icon: Icon(themeMode == ThemeMode.dark ? Pixel.sun : Pixel.moon),
          tooltip: themeMode == ThemeMode.dark
              ? 'Switch to light theme'
              : 'Switch to dark theme',
        ),
        if (isAuthenticated)
          IconButton(
            onPressed: onLogout,
            icon: const Icon(Pixel.logout),
            tooltip: 'Log out',
          ),
      ],
    );
  }
}
