import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:frontend/modules/catalog/application/search_state.dart';
import 'package:frontend/modules/catalog/application/search_state_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

import 'item_read_model_mother.dart';

class MockItemReadService extends Mock implements ItemReadService {}

void main() {
  late MockItemReadService readService;
  late List<ItemReadModel> items;

  setUp(() {
    readService = MockItemReadService();
    items = [
      ItemReadModelMother.random(id: 'item-1', title: 'Dune'),
      ItemReadModelMother.random(id: 'item-2', title: 'Foundation'),
    ];
    when(() => readService.watchAll()).thenAnswer((_) => Stream.value(items));
  });

  group('SearchStateService', () {
    blocTest<SearchStateService, SearchState>(
      'debounces and only searches once after typing stops',
      build: () => SearchStateService(readService),
      act: (service) {
        service.onQueryChanged('D');
        service.onQueryChanged('Du');
        service.onQueryChanged('Dune');
      },
      wait: searchDebounce + const Duration(milliseconds: 50),
      expect: () => [isA<SearchInProgress>(), isA<SearchLoaded>()],
      verify: (_) {
        verify(() => readService.watchAll()).called(1);
      },
    );

    blocTest<SearchStateService, SearchState>(
      'matches only items whose fields contain the query',
      build: () => SearchStateService(readService),
      act: (service) => service.onQueryChanged('dune'),
      wait: searchDebounce + const Duration(milliseconds: 50),
      expect: () => [isA<SearchInProgress>(), isA<SearchLoaded>()],
      verify: (service) {
        final state = service.state as SearchLoaded;
        expect(state.items.map((item) => item.id), ['item-1']);
      },
    );

    blocTest<SearchStateService, SearchState>(
      'clearing the query resets to idle without searching again',
      build: () => SearchStateService(readService),
      act: (service) async {
        service.onQueryChanged('dune');
        await Future<void>.delayed(searchDebounce + const Duration(milliseconds: 50));
        service.onQueryChanged('');
      },
      skip: 2,
      expect: () => [isA<SearchIdle>()],
    );

    late StreamController<List<ItemReadModel>> controller;

    blocTest<SearchStateService, SearchState>(
      'a live update re-filters an already-displayed search without a new query',
      setUp: () {
        controller = StreamController<List<ItemReadModel>>();
        addTearDown(controller.close);
        when(() => readService.watchAll()).thenAnswer((_) => controller.stream);
      },
      build: () => SearchStateService(readService),
      act: (service) async {
        controller.add([ItemReadModelMother.random(id: 'item-1', title: 'Dune')]);
        service.onQueryChanged('dune');
        await Future<void>.delayed(searchDebounce + const Duration(milliseconds: 50));
        controller.add([
          ItemReadModelMother.random(id: 'item-1', title: 'Dune'),
          ItemReadModelMother.random(id: 'item-2', title: 'Dune Messiah'),
        ]);
      },
      wait: const Duration(milliseconds: 50),
      expect: () => [
        isA<SearchInProgress>(),
        isA<SearchLoaded>().having((s) => s.items, 'items', hasLength(1)),
        isA<SearchInProgress>(),
        isA<SearchLoaded>().having((s) => s.items, 'items', hasLength(2)),
      ],
    );
  });
}
