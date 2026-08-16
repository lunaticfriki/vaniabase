import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/modules/catalog/application/item_list_state_service.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:frontend/modules/catalog/presentation/item_card_view.dart';
import 'package:frontend/modules/catalog/presentation/item_list/item_list_view.dart';
import 'package:frontend/shared/layout/item_view_mode.dart';
import 'package:mocktail/mocktail.dart';

import '../../application/item_read_model_mother.dart';

class MockItemReadService extends Mock implements ItemReadService {}

void main() {
  testWidgets(
    'typing a page number in the pagination control jumps the visible items',
    (tester) async {
      final readService = MockItemReadService();
      when(
        () => readService.watchAll(
          category: null,
          format: null,
          completed: null,
        ),
      ).thenAnswer((_) => Stream.value(ItemReadModelMother.list(45)));
      final service = ItemListStateService(readService);
      addTearDown(service.close);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: service,
              child: BlocBuilder<ItemListStateService, ItemListState>(
                builder: (context, state) => state is ItemListLoaded
                    ? ItemListView(
                        title: 'Test',
                        result: state.result,
                        onPrevious: service.previousPage,
                        onNext: service.nextPage,
                        onPageChanged: service.goToPage,
                        onItemTap: (_) {},
                        viewMode: ItemViewMode.grid,
                        onViewModeChanged: (_) {},
                      )
                    : const SizedBox(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Page 1 of 5 (45 items, page size 10): 10 cards shown.
      expect(find.byType(ItemCardView), findsNWidgets(10));

      await tester.enterText(find.byType(TextField), '5');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Page 5 is the remainder: 5 cards, and it must be a different slice.
      expect(find.byType(ItemCardView), findsNWidgets(5));
      expect((service.state as ItemListLoaded).result.page, 5);
    },
  );
}
