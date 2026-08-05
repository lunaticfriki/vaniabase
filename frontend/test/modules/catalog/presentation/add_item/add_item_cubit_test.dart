import 'package:bloc_test/bloc_test.dart';
import 'package:frontend/modules/catalog/application/item_write_service.dart';
import 'package:frontend/modules/catalog/presentation/add_item/add_item_cubit.dart';
import 'package:frontend/modules/catalog/presentation/add_item/add_item_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

class MockItemWriteService extends Mock implements ItemWriteService {}

void main() {
  late MockItemWriteService writeService;

  setUp(() {
    writeService = MockItemWriteService();
  });

  group('AddItemCubit', () {
    blocTest<AddItemCubit, AddItemState>(
      'emits success after creating the item',
      setUp: () {
        when(
          () => writeService.create(
            title: 'Dune',
            creator: ['Frank Herbert'],
            publisher: 'Chilton Books',
            category: 'book',
            format: 'hardcover',
          ),
        ).thenAnswer((_) async => 'item-1');
      },
      build: () => AddItemCubit(writeService),
      act: (cubit) => cubit.submit(
        title: 'Dune',
        creator: ['Frank Herbert'],
        publisher: 'Chilton Books',
        category: 'book',
        format: 'hardcover',
      ),
      expect: () => [isA<AddItemInProgress>(), isA<AddItemSuccess>()],
    );

    blocTest<AddItemCubit, AddItemState>(
      'emits AddItemFailure with the backend message on error',
      setUp: () {
        when(
          () => writeService.create(
            title: 'Dune',
            creator: ['Frank Herbert'],
            publisher: 'Chilton Books',
            category: 'book',
            format: 'dvd',
          ),
        ).thenThrow(Exception('"dvd" is not a valid format for category "book"'));
      },
      build: () => AddItemCubit(writeService),
      act: (cubit) => cubit.submit(
        title: 'Dune',
        creator: ['Frank Herbert'],
        publisher: 'Chilton Books',
        category: 'book',
        format: 'dvd',
      ),
      expect: () => [isA<AddItemInProgress>(), isA<AddItemFailure>()],
    );
  });
}
