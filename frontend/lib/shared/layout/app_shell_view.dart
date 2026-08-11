import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/modules/catalog/presentation/item_detail/item_detail_view.dart';
import 'package:frontend/shared/layout/app_header_view.dart';
import 'package:frontend/shared/session/session_state_service.dart';
import 'package:go_router/go_router.dart';

class AppShellView extends StatelessWidget {
  const AppShellView({required this.state, required this.child, super.key});

  final GoRouterState state;
  final Widget child;

  bool get _isItemDetailPage => state.fullPath == '/items/:id';

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= itemDetailWideBreakpoint;
    final hideHeader = _isItemDetailPage && !isWide;

    return Scaffold(
      appBar: hideHeader
          ? null
          : AppHeaderView(
              onNavigateHome: () => context.go('/'),
              onNavigateItems: () => context.go('/items'),
              onNavigateCompleted: () => context.go('/completed'),
              onNavigateCategories: () => context.go('/categories'),
              onNavigateTags: () => context.go('/tags'),
              onNavigateTopics: () => context.go('/topics'),
              onNavigateAuthors: () => context.go('/authors'),
              onNavigateLanguages: () => context.go('/languages'),
              onNavigatePublishers: () => context.go('/publishers'),
              onNavigateSearch: () => context.go('/search'),
              onNavigateAddItem: () => context.go('/items/new'),
              onNavigateImport: () => context.go('/items/import'),
              onLogout: () async {
                await context.read<SessionStateService>().clear();
                if (context.mounted) context.go('/login');
              },
            ),
      body: child,
    );
  }
}
