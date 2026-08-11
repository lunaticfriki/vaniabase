import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:frontend/modules/catalog/application/home_state_service.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

import 'item_read_model_mother.dart';

class MockItemReadService extends Mock implements ItemReadService {}

void main() {
  late MockItemReadService readService;

  setUp(() {
    readService = MockItemReadService();
  });

  group('HomeStateService', () {
    blocTest<HomeStateService, HomeState>(
      'starts in HomeLoading and settles on HomeLoaded with only the first 10 items',
      setUp: () {
        when(
          () => readService.watchAll(),
        ).thenAnswer((_) => Stream.value(ItemReadModelMother.list(25)));
      },
      build: () => HomeStateService(readService),
      expect: () => [isA<HomeLoaded>()],
      verify: (service) {
        final state = service.state as HomeLoaded;
        expect(state.items, hasLength(10));
      },
    );

    test('the initial state is HomeLoading before the watch emits', () {
      final controller = StreamController<List<ItemReadModel>>();
      addTearDown(controller.close);
      when(() => readService.watchAll()).thenAnswer((_) => controller.stream);

      final service = HomeStateService(readService);

      expect(service.state, isA<HomeLoading>());
    });

    blocTest<HomeStateService, HomeState>(
      'emits HomeError when the watch stream errors',
      setUp: () {
        when(
          () => readService.watchAll(),
        ).thenAnswer((_) => Stream.error(Exception('network error')));
      },
      build: () => HomeStateService(readService),
      expect: () => [isA<HomeError>()],
    );

    blocTest<HomeStateService, HomeState>(
      'reacts to a new item appearing without needing to be reloaded',
      setUp: () {
        when(() => readService.watchAll()).thenAnswer(
          (_) => Stream.fromIterable([
            ItemReadModelMother.list(1),
            ItemReadModelMother.list(2),
          ]),
        );
      },
      build: () => HomeStateService(readService),
      expect: () => [
        isA<HomeLoaded>().having((s) => s.items, 'items', hasLength(1)),
        isA<HomeLoaded>().having((s) => s.items, 'items', hasLength(2)),
      ],
    );
  });
}
