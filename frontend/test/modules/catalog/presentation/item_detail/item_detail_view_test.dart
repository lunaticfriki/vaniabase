import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/modules/catalog/presentation/item_detail/item_detail_view.dart';

import '../../application/item_read_model_mother.dart';

void main() {
  final item = ItemReadModelMother.random(title: 'Dune');

  Widget buildApp() {
    return MaterialApp(
      home: Scaffold(body: ItemDetailView(item: item, onBack: () {})),
    );
  }

  testWidgets(
    'wide screen: image sits to the left of the info column, filling most of the height',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      final imageRect = tester.getRect(find.byKey(itemDetailImageKey));
      final titleBox = tester.getTopLeft(find.text('Dune'));

      // Image is to the left of (smaller x than) the title/info column.
      expect(imageRect.left, lessThan(titleBox.dx));
      // And roughly level with it vertically (same row), not stacked above it.
      expect((imageRect.top - titleBox.dy).abs(), lessThan(50));
      // The image should dominate the page, not just follow a fixed aspect
      // ratio in a corner: most of the 900px viewport height (minus back
      // button/padding) and a large share of the 1200px width.
      expect(imageRect.height, greaterThan(750));
      expect(imageRect.width, greaterThan(450));
    },
  );

  testWidgets('narrow screen: title/author, then image, then the rest', (tester) async {
    tester.view.physicalSize = const Size(375, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final titleY = tester.getTopLeft(find.text('Dune')).dy;
    final creatorY = tester.getTopLeft(find.text(item.creator.join(', '))).dy;
    final imageY = tester.getTopLeft(find.byKey(itemDetailImageKey)).dy;
    final publisherLabelY = tester.getTopLeft(find.text('Publisher')).dy;

    expect(titleY, lessThan(creatorY));
    expect(creatorY, lessThan(imageY));
    expect(imageY, lessThan(publisherLabelY));
  });

  testWidgets('back button invokes onBack', (tester) async {
    var backPressed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ItemDetailView(item: item, onBack: () => backPressed = true)),
      ),
    );
    await tester.tap(find.text('Back'));
    expect(backPressed, isTrue);
  });
}
