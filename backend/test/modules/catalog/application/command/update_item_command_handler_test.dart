import 'package:backend/modules/catalog/application/command/update_item_command.dart';
import 'package:backend/modules/catalog/application/command/update_item_command_handler.dart';
import 'package:core/modules/catalog/domain/errors/item_not_found_error.dart';
import 'package:core/modules/catalog/domain/repositories/item_repository.dart';
import 'package:core/modules/catalog/domain/value_objects/item_id.dart';
import 'package:core/modules/catalog/domain/value_objects/title.dart';
import 'package:core/modules/identity/domain/value_objects/user_id.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../../../../core/test/modules/identity/domain/entities/user_mother.dart';
import '../../../../../../core/test/modules/catalog/domain/entities/item_mother.dart';

class MockItemRepository extends Mock implements ItemRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(ItemMother.book());
    registerFallbackValue(ItemId.generate());
  });

  group('UpdateItemCommandHandler', () {
    test('updates an item owned by the requester', () async {
      final repository = MockItemRepository();
      final item = ItemMother.book();
      when(() => repository.findById(item.id)).thenAnswer((_) async => item);
      when(() => repository.save(any())).thenAnswer((_) async {});

      final handler = UpdateItemCommandHandler(repository);
      await handler.handle(
        UpdateItemCommand(
          itemId: item.id.value,
          requestingUserId: item.ownerId.value,
          title: 'New Title',
        ),
      );

      expect(item.title, Title.create('New Title'));
      verify(() => repository.save(item)).called(1);
    });

    test('throws ItemNotFoundError when the item does not exist', () async {
      final repository = MockItemRepository();
      when(() => repository.findById(any())).thenAnswer((_) async => null);

      final handler = UpdateItemCommandHandler(repository);

      expect(
        () => handler.handle(
          UpdateItemCommand(
            itemId: ItemMother.book().id.value,
            requestingUserId: UserMother.random().id.value,
            title: 'New Title',
          ),
        ),
        throwsA(isA<ItemNotFoundError>()),
      );
    });

    test(
      'throws ItemNotFoundError (not a distinct forbidden error) when the '
      'requester does not own the item',
      () async {
        final repository = MockItemRepository();
        final item = ItemMother.book();
        when(
          () => repository.findById(item.id),
        ).thenAnswer((_) async => item);

        final handler = UpdateItemCommandHandler(repository);

        expect(
          () => handler.handle(
            UpdateItemCommand(
              itemId: item.id.value,
              requestingUserId: UserId.generate().value,
              title: 'New Title',
            ),
          ),
          throwsA(isA<ItemNotFoundError>()),
        );
      },
    );
  });
}
