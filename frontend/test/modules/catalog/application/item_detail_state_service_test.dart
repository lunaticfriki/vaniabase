import 'package:bloc_test/bloc_test.dart';
import 'package:frontend/modules/catalog/application/item_detail_state_service.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:frontend/modules/catalog/application/item_write_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

import 'item_read_model_mother.dart';

class MockItemReadService extends Mock implements ItemReadService {}

class MockItemWriteService extends Mock implements ItemWriteService {}

void main() {
  late MockItemReadService readService;
  late MockItemWriteService writeService;

  setUp(() {
    readService = MockItemReadService();
    writeService = MockItemWriteService();
  });

  group('ItemDetailStateService', () {
    blocTest<ItemDetailStateService, ItemDetailState>(
      'loads the item by id and settles on ItemDetailLoaded',
      setUp: () {
        when(() => readService.getById(id: 'item-1')).thenAnswer(
          (_) async => ItemReadModelMother.random(id: 'item-1', title: 'Dune'),
        );
      },
      build: () => ItemDetailStateService(readService, writeService, 'item-1'),
      expect: () => [isA<ItemDetailLoaded>()],
      verify: (service) {
        final state = service.state as ItemDetailLoaded;
        expect(state.item.id, 'item-1');
        expect(state.item.title, 'Dune');
      },
    );

    test(
      'the initial state is ItemDetailLoading before the request resolves',
      () {
        when(() => readService.getById(id: 'item-1')).thenAnswer((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
          return ItemReadModelMother.random(id: 'item-1');
        });

        final service = ItemDetailStateService(
          readService,
          writeService,
          'item-1',
        );

        expect(service.state, isA<ItemDetailLoading>());
      },
    );

    blocTest<ItemDetailStateService, ItemDetailState>(
      'emits ItemDetailError with the backend message when the item is not found',
      setUp: () {
        when(
          () => readService.getById(id: 'missing'),
        ).thenAnswer((_) async => throw Exception('item not found'));
      },
      build: () => ItemDetailStateService(readService, writeService, 'missing'),
      expect: () => [isA<ItemDetailError>()],
    );

    blocTest<ItemDetailStateService, ItemDetailState>(
      'toggleCompleted flips the item and persists it via the write service',
      setUp: () {
        when(() => readService.getById(id: 'item-1')).thenAnswer(
          (_) async =>
              ItemReadModelMother.random(id: 'item-1', completed: false),
        );
        when(
          () => writeService.update(id: 'item-1', completed: true),
        ).thenAnswer((_) async {});
      },
      build: () => ItemDetailStateService(readService, writeService, 'item-1'),
      act: (service) async {
        await Future<void>.delayed(Duration.zero);
        await service.toggleCompleted();
      },
      skip: 1,
      expect: () => [
        isA<ItemDetailLoaded>().having(
          (s) => s.item.completed,
          'completed',
          isTrue,
        ),
      ],
      verify: (_) {
        verify(
          () => writeService.update(id: 'item-1', completed: true),
        ).called(1);
      },
    );
  });
}
