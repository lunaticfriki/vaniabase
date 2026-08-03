import 'package:bloc_test/bloc_test.dart';
import 'package:core/shared/pagination/page_request.dart';
import 'package:core/shared/pagination/page_result.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:frontend/modules/catalog/presentation/home/home_cubit.dart';
import 'package:frontend/modules/catalog/presentation/home/home_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../application/item_read_model_mother.dart';

class MockItemReadService extends Mock implements ItemReadService {}

void main() {
  late MockItemReadService readService;

  setUp(() {
    readService = MockItemReadService();
  });

  group('HomeCubit', () {
    blocTest<HomeCubit, HomeState>(
      'starts in HomeLoading and settles on HomeLoaded with the first page of 10 items',
      setUp: () {
        final items = ItemReadModelMother.list(10);
        when(
          () => readService.list(pageRequest: PageRequest.first(pageSize: 10)),
        ).thenAnswer(
          (_) async => PageResult(items: items, page: 1, pageSize: 10, totalItems: 25),
        );
      },
      build: () => HomeCubit(readService),
      expect: () => [isA<HomeLoaded>()],
      verify: (cubit) {
        final state = cubit.state as HomeLoaded;
        expect(state.items, hasLength(10));
      },
    );

    test('the initial state is HomeLoading before the request resolves', () {
      when(
        () => readService.list(pageRequest: PageRequest.first(pageSize: 10)),
      ).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return PageResult(items: const [], page: 1, pageSize: 10, totalItems: 0);
      });

      final cubit = HomeCubit(readService);

      expect(cubit.state, isA<HomeLoading>());
    });

    blocTest<HomeCubit, HomeState>(
      'emits HomeError when the read service throws',
      setUp: () {
        when(
          () => readService.list(pageRequest: PageRequest.first(pageSize: 10)),
        ).thenAnswer((_) async => throw Exception('network error'));
      },
      build: () => HomeCubit(readService),
      expect: () => [isA<HomeError>()],
    );
  });
}
