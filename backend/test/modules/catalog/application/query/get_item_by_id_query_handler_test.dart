import 'package:backend/modules/catalog/application/query/get_item_by_id_query.dart';
import 'package:backend/modules/catalog/application/query/get_item_by_id_query_handler.dart';
import 'package:core/modules/catalog/domain/errors/item_not_found_error.dart';
import 'package:core/modules/catalog/domain/repositories/item_repository.dart';
import 'package:core/modules/catalog/domain/value_objects/item_id.dart';
import 'package:core/modules/identity/domain/value_objects/user_id.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../../../../core/test/modules/identity/domain/entities/user_mother.dart';
import '../../../../../../core/test/modules/catalog/domain/entities/item_mother.dart';

class MockItemRepository extends Mock implements ItemRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(ItemId.generate());
  });

  group('GetItemByIdQueryHandler', () {
    test('returns the read model for an item owned by the requester', () async {
      final repository = MockItemRepository();
      final item = ItemMother.book();
      when(() => repository.findById(item.id)).thenAnswer((_) async => item);

      final handler = GetItemByIdQueryHandler(repository);
      final readModel = await handler.handle(
        GetItemByIdQuery(
          itemId: item.id.value,
          requestingUserId: item.ownerId.value,
        ),
      );

      expect(readModel.id, item.id.value);
    });

    test('throws ItemNotFoundError when the item does not exist', () async {
      final repository = MockItemRepository();
      when(() => repository.findById(any())).thenAnswer((_) async => null);

      final handler = GetItemByIdQueryHandler(repository);

      expect(
        () => handler.handle(
          GetItemByIdQuery(
            itemId: ItemMother.book().id.value,
            requestingUserId: UserMother.random().id.value,
          ),
        ),
        throwsA(isA<ItemNotFoundError>()),
      );
    });

    test(
      'throws ItemNotFoundError when the requester does not own the item',
      () async {
        final repository = MockItemRepository();
        final item = ItemMother.book();
        when(
          () => repository.findById(item.id),
        ).thenAnswer((_) async => item);

        final handler = GetItemByIdQueryHandler(repository);

        expect(
          () => handler.handle(
            GetItemByIdQuery(
              itemId: item.id.value,
              requestingUserId: UserId.generate().value,
            ),
          ),
          throwsA(isA<ItemNotFoundError>()),
        );
      },
    );
  });
}
