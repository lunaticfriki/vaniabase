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
            onNavigateAddItem: () {},
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

    expect(find.text('All items'), findsOneWidget);
    expect(find.text('Add item'), findsOneWidget);
    expect(find.widgetWithIcon(TextButton, Pixel.grid), findsOneWidget);
    expect(find.widgetWithIcon(TextButton, Pixel.fileplus), findsOneWidget);
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
              onNavigateAddItem: () {},
              onLogout: () {},
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('vaniabase'));
    expect(homeTapped, isTrue);
  });
}
