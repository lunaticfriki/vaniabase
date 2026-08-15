import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/shared/pagination/pagination_control_view.dart';

void main() {
  Widget wrap(Widget child) =>
      MaterialApp(home: Scaffold(body: Center(child: child)));

  testWidgets('typing a page number and submitting calls onPageChanged', (
    tester,
  ) async {
    int? changedTo;
    await tester.pumpWidget(
      wrap(
        PaginationControlView(
          page: 1,
          totalPages: 5,
          hasPreviousPage: false,
          hasNextPage: true,
          onPrevious: () {},
          onNext: () {},
          onPageChanged: (page) => changedTo = page,
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '4');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(changedTo, 4);
  });

  testWidgets('typing a page beyond totalPages clamps before calling', (
    tester,
  ) async {
    int? changedTo;
    await tester.pumpWidget(
      wrap(
        PaginationControlView(
          page: 1,
          totalPages: 5,
          hasPreviousPage: false,
          hasNextPage: true,
          onPrevious: () {},
          onNext: () {},
          onPageChanged: (page) => changedTo = page,
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '99');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(changedTo, 5);
  });
}
