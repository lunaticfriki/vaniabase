import 'package:flutter/material.dart';
import 'package:frontend/modules/catalog/presentation/add_item/add_item_container.dart';
import 'package:frontend/modules/catalog/presentation/category_list/category_list_container.dart';
import 'package:frontend/modules/catalog/presentation/edit_item/edit_item_container.dart';
import 'package:frontend/modules/catalog/presentation/home/home_container.dart';
import 'package:frontend/modules/catalog/presentation/item_detail/item_detail_container.dart';
import 'package:frontend/modules/catalog/presentation/item_list/item_list_container.dart';
import 'package:frontend/modules/catalog/presentation/search/search_container.dart';
import 'package:frontend/modules/catalog/presentation/tags/tags_container.dart';
import 'package:frontend/modules/identity/presentation/login/login_container.dart';
import 'package:frontend/modules/identity/presentation/signup/signup_container.dart';
import 'package:frontend/shared/layout/app_shell_view.dart';
import 'package:frontend/shared/routing/go_router_refresh_stream.dart';
import 'package:frontend/shared/session/session_state_service.dart';
import 'package:go_router/go_router.dart';

const _publicRoutes = {'/login', '/signup'};

CustomTransitionPage<void> _fastPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 120),
    reverseTransitionDuration: const Duration(milliseconds: 120),
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

GoRouter buildAppRouter(SessionStateService sessionStateService) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(sessionStateService.stream),
    redirect: (context, state) {
      final isPublicRoute = _publicRoutes.contains(state.matchedLocation);
      if (!sessionStateService.isAuthenticated && !isPublicRoute)
        return '/login';
      if (sessionStateService.isAuthenticated && isPublicRoute) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) =>
            _fastPage(state, const LoginContainer()),
      ),
      GoRoute(
        path: '/signup',
        pageBuilder: (context, state) =>
            _fastPage(state, const SignupContainer()),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShellView(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) =>
                _fastPage(state, const HomeContainer()),
          ),
          GoRoute(
            path: '/items',
            pageBuilder: (context, state) =>
                _fastPage(state, const ItemListContainer()),
          ),
          GoRoute(
            path: '/items/new',
            pageBuilder: (context, state) =>
                _fastPage(state, const AddItemContainer()),
          ),
          GoRoute(
            path: '/items/:id',
            pageBuilder: (context, state) => _fastPage(
              state,
              ItemDetailContainer(itemId: state.pathParameters['id']!),
            ),
          ),
          GoRoute(
            path: '/items/:id/edit',
            pageBuilder: (context, state) => _fastPage(
              state,
              EditItemContainer(itemId: state.pathParameters['id']!),
            ),
          ),
          GoRoute(
            path: '/search',
            pageBuilder: (context, state) =>
                _fastPage(state, const SearchContainer()),
          ),
          GoRoute(
            path: '/tags',
            pageBuilder: (context, state) =>
                _fastPage(state, const TagsContainer()),
          ),
          GoRoute(
            path: '/categories',
            pageBuilder: (context, state) =>
                _fastPage(state, const CategoryListContainer()),
          ),
          GoRoute(
            path: '/categories/:category',
            pageBuilder: (context, state) => _fastPage(
              state,
              ItemListContainer(category: state.pathParameters['category']),
            ),
          ),
        ],
      ),
    ],
  );
}
