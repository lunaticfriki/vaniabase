import 'package:frontend/modules/catalog/presentation/add_item/add_item_page.dart';
import 'package:frontend/modules/catalog/presentation/home/home_page.dart';
import 'package:frontend/modules/catalog/presentation/item_list/item_list_page.dart';
import 'package:frontend/modules/identity/presentation/login/login_page.dart';
import 'package:frontend/modules/identity/presentation/signup/signup_page.dart';
import 'package:frontend/shared/layout/app_shell_view.dart';
import 'package:frontend/shared/routing/go_router_refresh_stream.dart';
import 'package:frontend/shared/session/session_cubit.dart';
import 'package:go_router/go_router.dart';

const _publicRoutes = {'/login', '/signup'};

GoRouter buildAppRouter(SessionCubit sessionCubit) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(sessionCubit.stream),
    redirect: (context, state) {
      final isPublicRoute = _publicRoutes.contains(state.matchedLocation);
      if (!sessionCubit.isAuthenticated && !isPublicRoute) return '/login';
      if (sessionCubit.isAuthenticated && isPublicRoute) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShellView(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomePage()),
          GoRoute(
            path: '/items',
            builder: (context, state) => const ItemListPage(),
          ),
          GoRoute(
            path: '/items/new',
            builder: (context, state) => const AddItemPage(),
          ),
        ],
      ),
    ],
  );
}
