import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/modules/catalog/presentation/item_detail/fullscreen_image_view.dart';

void main() {
  Widget buildApp() {
    return const MaterialApp(
      home: FullscreenImageView(imageUrl: 'https://example.com/cover.jpg'),
    );
  }

  AnimatedOpacity backButtonOpacity(WidgetTester tester) =>
      tester.widget<AnimatedOpacity>(find.byKey(fullscreenImageBackButtonKey));

  testWidgets('shows the image and a visible back button initially', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.byKey(fullscreenImageKey), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
    expect(backButtonOpacity(tester).opacity, 1);
  });

  testWidgets('tapping the image hides the back button, tapping again shows it', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(fullscreenImageKey));
    await tester.pumpAndSettle();
    expect(backButtonOpacity(tester).opacity, 0);

    await tester.tap(find.byKey(fullscreenImageKey));
    await tester.pumpAndSettle();
    expect(backButtonOpacity(tester).opacity, 1);
  });

  testWidgets('tapping the back button pops the route', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => openFullscreenImage(context, 'https://example.com/cover.jpg'),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.byType(FullscreenImageView), findsOneWidget);

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(FullscreenImageView), findsNothing);
  });
}
