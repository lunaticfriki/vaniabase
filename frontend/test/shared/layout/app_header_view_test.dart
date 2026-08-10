import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/shared/layout/app_header_view.dart';
import 'package:frontend/shared/session/session_state_service.dart';
import 'package:frontend/shared/theme/theme_state_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pixelarticons/pixel.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  late SessionStateService session;
  late ThemeStateService theme;

  setUp(() {
    final firebaseAuth = MockFirebaseAuth();
    when(() => firebaseAuth.authStateChanges()).thenAnswer((_) => const Stream.empty());
    session = SessionStateService(firebaseAuth);
    theme = ThemeStateService();
  });

  Widget buildApp() {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: session),
        BlocProvider.value(value: theme),
      ],
      child: MaterialApp(
        home: Scaffold(
          appBar: AppHeaderView(
            onNavigateHome: () {},
            onNavigateItems: () {},
            onNavigateCategories: () {},
            onNavigateTags: () {},
            onNavigateTopics: () {},
            onNavigateAuthors: () {},
            onNavigateLanguages: () {},
            onNavigatePublishers: () {},
            onNavigateSearch: () {},
            onNavigateAddItem: () {},
            onNavigateImport: () {},
            onLogout: () {},
          ),
        ),
      ),
    );
  }

  testWidgets('wide screen: nav options render inline with icons, no hamburger', (tester) async {
    tester.view.physicalSize = const Size(1024, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('All items'), findsNothing);
    expect(find.widgetWithIcon(IconButton, Pixel.grid), findsOneWidget);
    expect(find.widgetWithIcon(IconButton, Pixel.bookmarks), findsOneWidget);
    expect(find.widgetWithIcon(IconButton, Pixel.label), findsOneWidget);
    expect(find.widgetWithIcon(IconButton, Pixel.search), findsOneWidget);
    expect(find.widgetWithIcon(IconButton, Pixel.fileplus), findsOneWidget);
    expect(find.byIcon(Pixel.menu), findsNothing);
  });

  testWidgets('narrow screen: nav options collapse into a hamburger menu', (tester) async {
    tester.view.physicalSize = const Size(375, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.byIcon(Pixel.menu), findsOneWidget);
    expect(find.text('All items'), findsNothing);
    expect(find.text('Add item'), findsNothing);

    await tester.tap(find.byIcon(Pixel.menu));
    await tester.pumpAndSettle();

    expect(find.text('All items'), findsOneWidget);
    expect(find.text('Add item'), findsOneWidget);
  });

  testWidgets('title navigates home when tapped', (tester) async {
    var homeTapped = false;
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: session),
          BlocProvider.value(value: theme),
        ],
        child: MaterialApp(
          home: Scaffold(
            appBar: AppHeaderView(
              onNavigateHome: () => homeTapped = true,
              onNavigateItems: () {},
              onNavigateCategories: () {},
              onNavigateTags: () {},
              onNavigateTopics: () {},
              onNavigateAuthors: () {},
              onNavigateLanguages: () {},
              onNavigatePublishers: () {},
              onNavigateSearch: () {},
              onNavigateAddItem: () {},
              onNavigateImport: () {},
              onLogout: () {},
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('VANIABASE'));
    expect(homeTapped, isTrue);
  });

  SessionStateService authenticatedSession({String? displayName, String? email}) {
    final firebaseAuth = MockFirebaseAuth();
    final user = MockUser();
    when(() => user.uid).thenReturn('user-1');
    when(() => user.email).thenReturn(email ?? 'jane@example.com');
    when(() => user.displayName).thenReturn(displayName ?? 'Jane');
    when(() => firebaseAuth.authStateChanges()).thenAnswer((_) => Stream.value(user));
    return SessionStateService(firebaseAuth);
  }

  Widget buildAuthenticatedApp(SessionStateService authenticatedSession) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authenticatedSession),
        BlocProvider.value(value: theme),
      ],
      child: MaterialApp(
        home: Scaffold(
          appBar: AppHeaderView(
            onNavigateHome: () {},
            onNavigateItems: () {},
            onNavigateCategories: () {},
            onNavigateTags: () {},
            onNavigateTopics: () {},
            onNavigateAuthors: () {},
            onNavigateLanguages: () {},
            onNavigatePublishers: () {},
            onNavigateSearch: () {},
            onNavigateAddItem: () {},
            onNavigateImport: () {},
            onLogout: () {},
          ),
        ),
      ),
    );
  }

  testWidgets('shows a salutation with the signed-in user\'s name before the menu', (tester) async {
    final session = authenticatedSession();
    addTearDown(session.close);

    await tester.pumpWidget(buildAuthenticatedApp(session));
    await tester.pumpAndSettle();

    expect(find.text('Hi, Jane!'), findsOneWidget);
  });

  testWidgets('narrow screen: salutation appears in full inside the hamburger menu', (tester) async {
    tester.view.physicalSize = const Size(375, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final session = authenticatedSession(displayName: 'Alexandra');
    addTearDown(session.close);

    await tester.pumpWidget(buildAuthenticatedApp(session));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Hi, Alexandra!'), findsNothing);

    await tester.tap(find.byIcon(Pixel.menu));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Hi, Alexandra!'), findsOneWidget);
  });
}
