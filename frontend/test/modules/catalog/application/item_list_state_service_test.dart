import 'package:bloc_test/bloc_test.dart';
import 'package:frontend/modules/catalog/application/item_list_state_service.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:frontend/modules/catalog/application/item_sort_option.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

import 'item_read_model_mother.dart';

class MockItemReadService extends Mock implements ItemReadService {}

void main() {
  late MockItemReadService readService;

  setUp(() {
    readService = MockItemReadService();
    when(
      () => readService.watchAll(category: null, completed: null),
    ).thenAnswer((_) => Stream.value(ItemReadModelMother.list(25)));
  });

  group('ItemListStateService', () {
    blocTest<ItemListStateService, ItemListState>(
      'loads page 1 on construction',
      build: () => ItemListStateService(readService),
      expect: () => [isA<ItemListLoaded>()],
      verify: (service) {
        final state = service.state as ItemListLoaded;
        expect(state.result.page, 1);
        expect(state.result.items, hasLength(10));
        expect(state.result.totalItems, 25);
      },
    );

    blocTest<ItemListStateService, ItemListState>(
      'nextPage moves to the following page without re-watching',
      build: () => ItemListStateService(readService),
      skip: 1,
      act: (service) async {
        await Future<void>.delayed(Duration.zero);
        service.nextPage();
      },
      expect: () => [isA<ItemListLoaded>()],
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
        service.previousPage();
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
          () => readService.watchAll(category: null, completed: null),
        ).thenAnswer((_) => Stream.value(ItemReadModelMother.list(10)));
      },
      build: () => ItemListStateService(readService),
      skip: 1,
      act: (service) async {
        await Future<void>.delayed(Duration.zero);
        service.nextPage();
      },
      expect: () => [],
    );

    blocTest<ItemListStateService, ItemListState>(
      'a live update recomputes the current page in place',
      setUp: () {
        when(
          () => readService.watchAll(category: null, completed: null),
        ).thenAnswer(
          (_) => Stream.fromIterable([
            ItemReadModelMother.list(10),
            ItemReadModelMother.list(11),
          ]),
        );
      },
      build: () => ItemListStateService(readService),
      expect: () => [
        isA<ItemListLoaded>().having(
          (s) => s.result.totalItems,
          'totalItems',
          10,
        ),
        isA<ItemListLoaded>().having(
          (s) => s.result.totalItems,
          'totalItems',
          11,
        ),
      ],
    );

    blocTest<ItemListStateService, ItemListState>(
      'setSortOption reorders items by title and resets to page 1',
      setUp: () {
        when(
          () => readService.watchAll(category: null, completed: null),
        ).thenAnswer(
          (_) => Stream.value([
            ItemReadModelMother.random(title: 'Zebra'),
            ItemReadModelMother.random(title: 'Apple'),
            ItemReadModelMother.random(title: 'Mango'),
          ]),
        );
      },
      build: () => ItemListStateService(readService),
      skip: 1,
      act: (service) async {
        await Future<void>.delayed(Duration.zero);
        service.nextPage();
        service.setSortOption(ItemSortOption.title);
      },
      verify: (service) {
        final state = service.state as ItemListLoaded;
        expect(state.sortOption, ItemSortOption.title);
        expect(state.result.page, 1);
        expect(
          state.result.items.map((item) => item.title),
          ['Apple', 'Mango', 'Zebra'],
        );
      },
    );

    blocTest<ItemListStateService, ItemListState>(
      'setSortOption sorts by author',
      setUp: () {
        when(
          () => readService.watchAll(category: null, completed: null),
        ).thenAnswer(
          (_) => Stream.value([
            ItemReadModelMother.random(creator: const ['Zebra Author']),
            ItemReadModelMother.random(creator: const ['Apple Author']),
          ]),
        );
      },
      build: () => ItemListStateService(readService),
      skip: 1,
      act: (service) => service.setSortOption(ItemSortOption.author),
      verify: (service) {
        final state = service.state as ItemListLoaded;
        expect(
          state.result.items.map((item) => item.creator.first),
          ['Apple Author', 'Zebra Author'],
        );
      },
    );
  });
}
