import 'package:frontend/modules/catalog/presentation/add_item/add_item_container.dart';
import 'package:frontend/modules/catalog/presentation/home/home_container.dart';
import 'package:frontend/modules/catalog/presentation/item_detail/item_detail_container.dart';
import 'package:frontend/modules/catalog/presentation/item_list/item_list_container.dart';
import 'package:frontend/modules/identity/presentation/login/login_container.dart';
import 'package:frontend/modules/identity/presentation/signup/signup_container.dart';
import 'package:frontend/shared/layout/app_shell_view.dart';
import 'package:frontend/shared/routing/go_router_refresh_stream.dart';
import 'package:frontend/shared/session/session_state_service.dart';
import 'package:go_router/go_router.dart';

const _publicRoutes = {'/login', '/signup'};

GoRouter buildAppRouter(SessionStateService sessionStateService) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(sessionStateService.stream),
    redirect: (context, state) {
      final isPublicRoute = _publicRoutes.contains(state.matchedLocation);
      if (!sessionStateService.isAuthenticated && !isPublicRoute) return '/login';
      if (sessionStateService.isAuthenticated && isPublicRoute) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginContainer()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupContainer(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShellView(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomeContainer()),
          GoRoute(
            path: '/items',
            builder: (context, state) => const ItemListContainer(),
          ),
          GoRoute(
            path: '/items/new',
            builder: (context, state) => const AddItemContainer(),
          ),
          GoRoute(
            path: '/items/:id',
            builder: (context, state) => ItemDetailContainer(itemId: state.pathParameters['id']!),
          ),
        ],
      ),
    ],
  );
}
