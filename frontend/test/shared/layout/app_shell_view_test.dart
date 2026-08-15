import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/shared/layout/app_shell_view.dart';
import 'package:frontend/shared/session/session_state_service.dart';
import 'package:frontend/shared/theme/theme_state_service.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  late SessionStateService session;
  late ThemeStateService theme;

  setUp(() async {
    final firebaseAuth = MockFirebaseAuth();
    when(
      () => firebaseAuth.authStateChanges(),
    ).thenAnswer((_) => const Stream.empty());
    session = SessionStateService(firebaseAuth);
    SharedPreferences.setMockInitialValues({});
    theme = ThemeStateService(await SharedPreferences.getInstance());
  });

  Widget buildApp(String initialLocation) {
    final router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        ShellRoute(
          builder: (context, state, child) =>
              AppShellView(state: state, child: child),
          routes: [
            GoRoute(path: '/', builder: (context, state) => const SizedBox()),
            GoRoute(
              path: '/items',
              builder: (context, state) => const SizedBox(),
            ),
            GoRoute(
              path: '/items/new',
              builder: (context, state) => const SizedBox(),
            ),
            GoRoute(
              path: '/items/:id',
              builder: (context, state) => const SizedBox(),
            ),
          ],
        ),
      ],
    );
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: session),
        BlocProvider.value(value: theme),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets('shows the add-item FAB on the home page', (tester) async {
    await tester.pumpWidget(buildApp('/'));
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('shows the add-item FAB on the items list page', (tester) async {
    await tester.pumpWidget(buildApp('/items'));
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('hides the add-item FAB on an item detail page', (tester) async {
    await tester.pumpWidget(buildApp('/items/abc123'));
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('tapping the FAB navigates to the add-item form', (tester) async {
    await tester.pumpWidget(buildApp('/items'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // The add-item form is itself one of the hidden routes.
    expect(find.byType(FloatingActionButton), findsNothing);
  });
}
