import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/shared/session/session_cubit.dart';
import 'package:frontend/shared/session/session_state.dart';
import 'package:frontend/shared/theme/theme_cubit.dart';
import 'package:pixelarticons/pixel.dart';

class AppHeaderView extends StatelessWidget implements PreferredSizeWidget {
  const AppHeaderView({
    required this.onNavigateHome,
    required this.onNavigateItems,
    required this.onLogout,
    super.key,
  });

  final VoidCallback onNavigateHome;
  final VoidCallback onNavigateItems;
  final VoidCallback onLogout;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = context.select(
      (SessionCubit cubit) => cubit.state is SessionAuthenticated,
    );
    final themeMode = context.watch<ThemeCubit>().state;

    return AppBar(
      title: const Text('vaniabase'),
      actions: [
        TextButton(onPressed: onNavigateHome, child: const Text('Home')),
        TextButton(onPressed: onNavigateItems, child: const Text('All items')),
        IconButton(
          onPressed: () => context.read<ThemeCubit>().toggle(),
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
