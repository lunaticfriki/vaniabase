import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/shared/layout/app_footer_view.dart';
import 'package:frontend/shared/layout/app_header_view.dart';
import 'package:frontend/shared/session/session_cubit.dart';
import 'package:go_router/go_router.dart';

class AppShellView extends StatelessWidget {
  const AppShellView({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeaderView(
        onNavigateHome: () => context.go('/'),
        onNavigateItems: () => context.go('/items'),
        onLogout: () async {
          await context.read<SessionCubit>().clear();
          if (context.mounted) context.go('/login');
        },
      ),
      body: Column(
        children: [
          Expanded(child: child),
          const AppFooterView(),
        ],
      ),
    );
  }
}
