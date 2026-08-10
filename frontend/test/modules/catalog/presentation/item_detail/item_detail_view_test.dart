import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/modules/catalog/presentation/item_detail/item_detail_view.dart';

import '../../application/item_read_model_mother.dart';

void main() {
  final item = ItemReadModelMother.random(title: 'Dune');

  Widget buildApp() {
    return MaterialApp(
      home: Scaffold(
        body: ItemDetailView(
          item: item,
          onBack: () {},
          onEdit: () {},
          onToggleCompleted: () {},
          onTagTap: (tag) {},
        ),
      ),
    );
  }

  testWidgets(
    'wide screen: title and author overlay the bottom of the image; back/edit stay on the right',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      final imageRect = tester.getRect(find.byKey(itemDetailImageKey));
      final backButtonPos = tester.getTopLeft(find.text('Back'));
      final titleRect = tester.getRect(find.text('Dune'));

      expect(imageRect.height, greaterThan(750));
      expect(imageRect.width, greaterThan(450));
      expect(titleRect.left, greaterThanOrEqualTo(imageRect.left));
      expect(titleRect.right, lessThanOrEqualTo(imageRect.right + 1));
      expect(imageRect.bottom - titleRect.bottom, lessThan(150));
      expect(backButtonPos.dx, greaterThan(imageRect.right - 1));
    },
  );

  testWidgets('narrow screen: title and author overlay the bottom of the hero image', (tester) async {
    tester.view.physicalSize = const Size(375, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final imageRect = tester.getRect(find.byKey(itemDetailImageKey));
    final backButtonY = tester.getTopLeft(find.text('Back')).dy;

    expect(imageRect.top, 0);
    expect(imageRect.height, closeTo(900, 1));
    expect(backButtonY, lessThan(50));

    final titleY = tester.getTopLeft(find.text('Dune')).dy;
    final creatorY = tester.getTopLeft(find.text(item.creator.join(', '))).dy;
    final publisherLabelY = tester.getTopLeft(find.text('Publisher')).dy;

    expect(titleY, lessThan(imageRect.height));
    expect(titleY, lessThan(creatorY));
    expect(creatorY, lessThan(imageRect.height));
    expect(publisherLabelY, greaterThan(imageRect.height));
  });

  testWidgets(
    'narrow screen: below a real app bar, the image and title are visible without scrolling',
    (tester) async {
      tester.view.physicalSize = const Size(375, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('vaniabase')),
            body: ItemDetailView(
              item: item,
              onBack: () {},
              onEdit: () {},
              onToggleCompleted: () {},
              onTagTap: (tag) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      final imageRect = tester.getRect(find.byKey(itemDetailImageKey));
      final titleRect = tester.getRect(find.text('Dune'));

      // The image must not extend past the bottom of a real device screen (it
      // should stop at the window height minus the app bar, not the full
      // window height), and the title must land within the visible viewport
      // without requiring a scroll.
      expect(imageRect.height, lessThan(900));
      expect(imageRect.bottom, lessThanOrEqualTo(900));
      expect(titleRect.bottom, lessThanOrEqualTo(900));
    },
  );

  testWidgets('narrow screen: the floating header is transparent until the user scrolls', (tester) async {
    tester.view.physicalSize = const Size(375, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    final headerBefore = tester.widget<Container>(find.byKey(itemDetailHeaderKey));
    expect((headerBefore.color as Color).a, 0);

    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();

    final headerAfter = tester.widget<Container>(find.byKey(itemDetailHeaderKey));
    expect((headerAfter.color as Color).a, greaterThan(0.9));
  });

  testWidgets('back button invokes onBack', (tester) async {
    var backPressed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ItemDetailView(
            item: item,
            onBack: () => backPressed = true,
            onEdit: () {},
            onToggleCompleted: () {},
            onTagTap: (tag) {},
          ),
        ),
      ),
    );
    await tester.tap(find.text('Back'));
    expect(backPressed, isTrue);
  });

  testWidgets('shows "Not completed" and toggles it on tap', (tester) async {
    var toggled = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ItemDetailView(
            item: item,
            onBack: () {},
            onEdit: () {},
            onToggleCompleted: () => toggled = true,
            onTagTap: (tag) {},
          ),
        ),
      ),
    );

    expect(find.text('Not completed'), findsOneWidget);

    await tester.tap(find.text('Not completed'));
    expect(toggled, isTrue);
  });

  testWidgets('tapping a tag invokes onTagTap with that tag', (tester) async {
    String? tappedTag;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ItemDetailView(
            item: item,
            onBack: () {},
            onEdit: () {},
            onToggleCompleted: () {},
            onTagTap: (tag) => tappedTag = tag,
          ),
        ),
      ),
    );

    await tester.tap(find.text('sci-fi'));
    expect(tappedTag, 'sci-fi');
  });
}
