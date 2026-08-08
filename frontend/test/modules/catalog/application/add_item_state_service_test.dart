import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:frontend/modules/catalog/application/add_item_state.dart';
import 'package:frontend/modules/catalog/application/add_item_state_service.dart';
import 'package:frontend/modules/catalog/application/item_write_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

class MockItemWriteService extends Mock implements ItemWriteService {}

void main() {
  late MockItemWriteService writeService;

  setUp(() {
    writeService = MockItemWriteService();
  });

  group('AddItemStateService', () {
    blocTest<AddItemStateService, AddItemState>(
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
      build: () => AddItemStateService(writeService),
      act: (service) => service.submit(
        title: 'Dune',
        creator: ['Frank Herbert'],
        publisher: 'Chilton Books',
        category: 'book',
        format: 'hardcover',
      ),
      expect: () => [isA<AddItemInProgress>(), isA<AddItemSuccess>()],
    );

    blocTest<AddItemStateService, AddItemState>(
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
      build: () => AddItemStateService(writeService),
      act: (service) => service.submit(
        title: 'Dune',
        creator: ['Frank Herbert'],
        publisher: 'Chilton Books',
        category: 'book',
        format: 'dvd',
      ),
      expect: () => [isA<AddItemInProgress>(), isA<AddItemFailure>()],
    );

    blocTest<AddItemStateService, AddItemState>(
      'forwards picked image bytes to the write service',
      setUp: () {
        when(
          () => writeService.create(
            title: 'Dune',
            creator: ['Frank Herbert'],
            publisher: 'Chilton Books',
            category: 'book',
            format: 'hardcover',
            imageBytes: Uint8List.fromList([1, 2, 3]),
          ),
        ).thenAnswer((_) async => 'item-1');
      },
      build: () => AddItemStateService(writeService),
      act: (service) => service.submit(
        title: 'Dune',
        creator: ['Frank Herbert'],
        publisher: 'Chilton Books',
        category: 'book',
        format: 'hardcover',
        imageBytes: Uint8List.fromList([1, 2, 3]),
      ),
      expect: () => [isA<AddItemInProgress>(), isA<AddItemSuccess>()],
    );
  });
}
