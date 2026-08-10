import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/shared/layout/app_footer_view.dart';
import 'package:frontend/shared/layout/app_header_view.dart';
import 'package:frontend/shared/session/session_state_service.dart';
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
        onNavigateCategories: () => context.go('/categories'),
        onNavigateTags: () => context.go('/tags'),
        onNavigateTopics: () => context.go('/topics'),
        onNavigateAuthors: () => context.go('/authors'),
        onNavigateLanguages: () => context.go('/languages'),
        onNavigatePublishers: () => context.go('/publishers'),
        onNavigateSearch: () => context.go('/search'),
        onNavigateAddItem: () => context.go('/items/new'),
        onLogout: () async {
          await context.read<SessionStateService>().clear();
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
