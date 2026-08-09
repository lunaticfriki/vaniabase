import 'package:bloc_test/bloc_test.dart';
import 'package:core/shared/pagination/page_request.dart';
import 'package:core/shared/pagination/page_result.dart';
import 'package:frontend/modules/catalog/application/item_list_state.dart';
import 'package:frontend/modules/catalog/application/item_list_state_service.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

import 'item_read_model_mother.dart';

class MockItemReadService extends Mock implements ItemReadService {}

PageResult<ItemReadModel> _pageOf(int page, {int totalItems = 25}) {
  return PageResult(
    items: ItemReadModelMother.list(10),
    page: page,
    pageSize: 10,
    totalItems: totalItems,
  );
}

void main() {
  late MockItemReadService readService;

  setUp(() {
    readService = MockItemReadService();
    when(
      () => readService.list(
        pageRequest: PageRequest.create(page: 1, pageSize: 10),
        category: null,
      ),
    ).thenAnswer((_) async => _pageOf(1));
    when(
      () => readService.list(
        pageRequest: PageRequest.create(page: 2, pageSize: 10),
        category: null,
      ),
    ).thenAnswer((_) async => _pageOf(2));
  });

  group('ItemListStateService', () {
    blocTest<ItemListStateService, ItemListState>(
      'loads page 1 on construction',
      build: () => ItemListStateService(readService),
      expect: () => [isA<ItemListLoaded>()],
      verify: (service) {
        final state = service.state as ItemListLoaded;
        expect(state.result.page, 1);
      },
    );

    blocTest<ItemListStateService, ItemListState>(
      'nextPage loads the following page',
      build: () => ItemListStateService(readService),
      skip: 1,
      act: (service) async {
        await Future<void>.delayed(Duration.zero);
        await service.nextPage();
      },
      expect: () => [isA<ItemListLoading>(), isA<ItemListLoaded>()],
      verify: (service) {
        final state = service.state as ItemListLoaded;
        expect(state.result.page, 2);
      },
    );

    blocTest<ItemListStateService, ItemListState>(
      'previousPage is a no-op on the first page',
      build: () => ItemListStateService(readService),
      skip: 1,
      act: (service) async {
        await Future<void>.delayed(Duration.zero);
        await service.previousPage();
      },
      expect: () => [],
      verify: (service) {
        final state = service.state as ItemListLoaded;
        expect(state.result.page, 1);
      },
    );

    blocTest<ItemListStateService, ItemListState>(
      'nextPage is a no-op when already on the only page',
      setUp: () {
        when(
          () => readService.list(
            pageRequest: PageRequest.create(page: 1, pageSize: 10),
            category: null,
          ),
        ).thenAnswer((_) async => _pageOf(1, totalItems: 10));
      },
      build: () => ItemListStateService(readService),
      skip: 1,
      act: (service) async {
        await Future<void>.delayed(Duration.zero);
        await service.nextPage();
      },
      expect: () => [],
    );
  });
}
