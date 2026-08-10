import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/shared/session/session_state.dart';
import 'package:frontend/shared/session/session_state_service.dart';
import 'package:frontend/shared/theme/theme_state_service.dart';
import 'package:pixelarticons/pixel.dart';

const navWideBreakpoint = 640.0;

class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
}

class AppHeaderView extends StatelessWidget implements PreferredSizeWidget {
  const AppHeaderView({
    required this.onNavigateHome,
    required this.onNavigateItems,
    required this.onNavigateCategories,
    required this.onNavigateTags,
    required this.onNavigateTopics,
    required this.onNavigateAuthors,
    required this.onNavigateLanguages,
    required this.onNavigatePublishers,
    required this.onNavigateSearch,
    required this.onNavigateAddItem,
    required this.onNavigateImport,
    required this.onLogout,
    super.key,
  });

  final VoidCallback onNavigateHome;
  final VoidCallback onNavigateItems;
  final VoidCallback onNavigateCategories;
  final VoidCallback onNavigateTags;
  final VoidCallback onNavigateTopics;
  final VoidCallback onNavigateAuthors;
  final VoidCallback onNavigateLanguages;
  final VoidCallback onNavigatePublishers;
  final VoidCallback onNavigateSearch;
  final VoidCallback onNavigateAddItem;
  final VoidCallback onNavigateImport;
  final VoidCallback onLogout;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = context.select(
      (SessionStateService service) => service.state is SessionAuthenticated,
    );
    final greetingName = context.select((SessionStateService service) {
      final state = service.state;
      if (state is! SessionAuthenticated) return null;
      final displayName = state.displayName?.trim();
      if (displayName != null && displayName.isNotEmpty) return displayName;
      final email = state.email;
      if (email != null && email.contains('@')) return email.split('@').first;
      return null;
    });
    final themeMode = context.watch<ThemeStateService>().state;
    final isWide = MediaQuery.sizeOf(context).width >= navWideBreakpoint;

    final navItems = [
      _NavItem(label: 'All items', icon: Pixel.grid, onTap: onNavigateItems),
      _NavItem(
        label: 'Categories',
        icon: Pixel.bookmarks,
        onTap: onNavigateCategories,
      ),
      _NavItem(label: 'Tags', icon: Pixel.label, onTap: onNavigateTags),
      _NavItem(label: 'Topics', icon: Pixel.note, onTap: onNavigateTopics),
      _NavItem(label: 'Authors', icon: Pixel.user, onTap: onNavigateAuthors),
      _NavItem(
        label: 'Languages',
        icon: Pixel.flag,
        onTap: onNavigateLanguages,
      ),
      _NavItem(
        label: 'Publishers',
        icon: Pixel.building,
        onTap: onNavigatePublishers,
      ),
      _NavItem(label: 'Search', icon: Pixel.search, onTap: onNavigateSearch),
      _NavItem(
        label: 'Add item',
        icon: Pixel.fileplus,
        onTap: onNavigateAddItem,
      ),
      _NavItem(label: 'Import', icon: Pixel.upload, onTap: onNavigateImport),
    ];

    return AppBar(
      title: InkWell(onTap: onNavigateHome, child: const Text('VANIABASE')),
      actions: [
        if (greetingName != null && isWide)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 160),
              child: Text(
                'Hi, $greetingName!',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ...isWide
            ? [
                for (final item in navItems)
                  IconButton(
                    onPressed: item.onTap,
                    icon: Icon(item.icon),
                    tooltip: item.label,
                  ),
              ]
            : [
                PopupMenuButton<VoidCallback>(
                  icon: const Icon(Pixel.menu),
                  tooltip: 'Menu',
                  onSelected: (onTap) => onTap(),
                  itemBuilder: (context) => [
                    if (greetingName != null) ...[
                      PopupMenuItem<VoidCallback>(
                        enabled: false,
                        child: Text(
                          'Hi, $greetingName!',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      const PopupMenuDivider(),
                    ],
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
