import 'package:bloc_test/bloc_test.dart';
import 'package:core/shared/pagination/page_request.dart';
import 'package:core/shared/pagination/page_result.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:frontend/modules/catalog/presentation/item_list/item_list_cubit.dart';
import 'package:frontend/modules/catalog/presentation/item_list/item_list_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../application/item_read_model_mother.dart';

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
      () => readService.list(pageRequest: PageRequest.create(page: 1, pageSize: 10)),
    ).thenAnswer((_) async => _pageOf(1));
    when(
      () => readService.list(pageRequest: PageRequest.create(page: 2, pageSize: 10)),
    ).thenAnswer((_) async => _pageOf(2));
  });

  group('ItemListCubit', () {
    blocTest<ItemListCubit, ItemListState>(
      'loads page 1 on construction',
      build: () => ItemListCubit(readService),
      expect: () => [isA<ItemListLoaded>()],
      verify: (cubit) {
        final state = cubit.state as ItemListLoaded;
        expect(state.result.page, 1);
      },
    );

    blocTest<ItemListCubit, ItemListState>(
      'nextPage loads the following page',
      build: () => ItemListCubit(readService),
      skip: 1, // the page-1 ItemListLoaded emitted by the constructor's own load
      act: (cubit) async {
        await Future<void>.delayed(Duration.zero);
        await cubit.nextPage();
      },
      expect: () => [isA<ItemListLoading>(), isA<ItemListLoaded>()],
      verify: (cubit) {
        final state = cubit.state as ItemListLoaded;
        expect(state.result.page, 2);
      },
    );

    blocTest<ItemListCubit, ItemListState>(
      'previousPage is a no-op on the first page',
      build: () => ItemListCubit(readService),
      skip: 1, // the page-1 ItemListLoaded emitted by the constructor's own load
      act: (cubit) async {
        await Future<void>.delayed(Duration.zero);
        await cubit.previousPage();
      },
      expect: () => [],
      verify: (cubit) {
        final state = cubit.state as ItemListLoaded;
        expect(state.result.page, 1);
      },
    );

    blocTest<ItemListCubit, ItemListState>(
      'nextPage is a no-op when already on the only page',
      setUp: () {
        when(
          () => readService.list(pageRequest: PageRequest.create(page: 1, pageSize: 10)),
        ).thenAnswer((_) async => _pageOf(1, totalItems: 10));
      },
      build: () => ItemListCubit(readService),
      skip: 1, // the page-1 ItemListLoaded emitted by the constructor's own load
      act: (cubit) async {
        await Future<void>.delayed(Duration.zero);
        await cubit.nextPage();
      },
      expect: () => [],
    );
  });
}
