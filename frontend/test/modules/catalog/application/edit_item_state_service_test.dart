import 'package:bloc_test/bloc_test.dart';
import 'package:frontend/modules/catalog/application/edit_item_state.dart';
import 'package:frontend/modules/catalog/application/edit_item_state_service.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:frontend/modules/catalog/application/item_write_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

class MockItemReadService extends Mock implements ItemReadService {}

class MockItemWriteService extends Mock implements ItemWriteService {}

Future<void> _settleLoad() => Future<void>.delayed(Duration.zero);

void main() {
  late MockItemReadService readService;
  late MockItemWriteService writeService;

  final item = ItemReadModel(
    id: 'item-1',
    ownerId: 'user-1',
    title: 'Dune',
    creator: const ['Frank Herbert'],
    publisher: 'Chilton Books',
    category: 'book',
    format: 'hardcover',
    tags: const [],
    topic: '',
    year: 1965,
    description: '',
    language: 'en',
    imageUrl: '',
    completed: false,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );

  setUp(() {
    readService = MockItemReadService();
    writeService = MockItemWriteService();
    when(() => readService.getById(id: 'item-1')).thenAnswer((_) async => item);
  });

  group('EditItemStateService', () {
    blocTest<EditItemStateService, EditItemState>(
      'loads the item on construction',
      build: () => EditItemStateService(readService, writeService, 'item-1'),
      expect: () => [isA<EditItemReady>()],
    );

    blocTest<EditItemStateService, EditItemState>(
      'emits EditItemLoadFailure when loading fails',
      setUp: () {
        when(
          () => readService.getById(id: 'item-1'),
        ).thenAnswer((_) async => throw Exception('item not found'));
      },
      build: () => EditItemStateService(readService, writeService, 'item-1'),
      expect: () => [isA<EditItemLoadFailure>()],
    );

    blocTest<EditItemStateService, EditItemState>(
      'emits success after updating the item',
      setUp: () {
        when(
          () => writeService.update(
            id: 'item-1',
            title: 'Dune Messiah',
            creator: any(named: 'creator'),
            publisher: any(named: 'publisher'),
            category: any(named: 'category'),
            format: any(named: 'format'),
            tags: any(named: 'tags'),
            topic: any(named: 'topic'),
            year: any(named: 'year'),
            description: any(named: 'description'),
            language: any(named: 'language'),
            imageBytes: any(named: 'imageBytes'),
            removeImage: any(named: 'removeImage'),
            completed: any(named: 'completed'),
          ),
        ).thenAnswer((_) async {});
      },
      build: () => EditItemStateService(readService, writeService, 'item-1'),
      act: (service) async {
        await _settleLoad();
        await service.submit(
          title: 'Dune Messiah',
          creator: item.creator,
          publisher: item.publisher,
          category: item.category,
          format: item.format,
        );
      },
      expect: () => [isA<EditItemReady>(), isA<EditItemReady>(), isA<EditItemSuccess>()],
    );

    blocTest<EditItemStateService, EditItemState>(
      'emits EditItemReady with submitError when update fails',
      setUp: () {
        when(
          () => writeService.update(
            id: 'item-1',
            title: 'Dune Messiah',
            creator: any(named: 'creator'),
            publisher: any(named: 'publisher'),
            category: any(named: 'category'),
            format: any(named: 'format'),
            tags: any(named: 'tags'),
            topic: any(named: 'topic'),
            year: any(named: 'year'),
            description: any(named: 'description'),
            language: any(named: 'language'),
            imageBytes: any(named: 'imageBytes'),
            removeImage: any(named: 'removeImage'),
            completed: any(named: 'completed'),
          ),
        ).thenThrow(Exception('update failed'));
      },
      build: () => EditItemStateService(readService, writeService, 'item-1'),
      act: (service) async {
        await _settleLoad();
        await service.submit(
          title: 'Dune Messiah',
          creator: item.creator,
          publisher: item.publisher,
          category: item.category,
          format: item.format,
        );
      },
      expect: () => [
        isA<EditItemReady>(),
        isA<EditItemReady>(),
        isA<EditItemReady>().having((s) => s.submitError, 'submitError', isNotNull),
      ],
    );

    blocTest<EditItemStateService, EditItemState>(
      'emits EditItemDeleting then EditItemDeleted after successful delete',
      setUp: () {
        when(() => writeService.delete(id: 'item-1')).thenAnswer((_) async {});
      },
      build: () => EditItemStateService(readService, writeService, 'item-1'),
      act: (service) async {
        await _settleLoad();
        await service.delete();
      },
      expect: () => [isA<EditItemReady>(), isA<EditItemDeleting>(), isA<EditItemDeleted>()],
    );

    blocTest<EditItemStateService, EditItemState>(
      'emits EditItemDeleting then EditItemReady with submitError on delete failure',
      setUp: () {
        when(() => writeService.delete(id: 'item-1')).thenThrow(Exception('delete failed'));
      },
      build: () => EditItemStateService(readService, writeService, 'item-1'),
      act: (service) async {
        await _settleLoad();
        await service.delete();
      },
      expect: () => [
        isA<EditItemReady>(),
        isA<EditItemDeleting>(),
        isA<EditItemReady>().having((s) => s.submitError, 'submitError', isNotNull),
      ],
    );
  });
}
