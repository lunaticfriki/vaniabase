import 'package:backend/modules/catalog/application/command/create_item_command.dart';
import 'package:backend/modules/catalog/application/command/create_item_command_handler.dart';
import 'package:core/modules/catalog/domain/errors/invalid_format_for_category_error.dart';
import 'package:core/modules/catalog/domain/repositories/item_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../../../../core/test/modules/identity/domain/entities/user_mother.dart';
import '../../../../../../core/test/modules/catalog/domain/entities/item_mother.dart';

class MockItemRepository extends Mock implements ItemRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(ItemMother.book());
  });

  group('CreateItemCommandHandler', () {
    test('creates and saves a valid item, returning its id', () async {
      final repository = MockItemRepository();
      when(() => repository.save(any())).thenAnswer((_) async {});
      final ownerId = UserMother.random().id;

      final handler = CreateItemCommandHandler(repository);
      final id = await handler.handle(
        CreateItemCommand(
          ownerId: ownerId.value,
          title: 'Dune',
          creator: const ['Frank Herbert'],
          publisher: 'Chilton Books',
          category: 'book',
          format: 'hardcover',
        ),
      );

      expect(id, isNotEmpty);
      verify(() => repository.save(any())).called(1);
    });

    test('throws when format does not match category', () async {
      final repository = MockItemRepository();

      final handler = CreateItemCommandHandler(repository);

      expect(
        () => handler.handle(
          CreateItemCommand(
            ownerId: UserMother.random().id.value,
            title: 'Dune',
            creator: const ['Frank Herbert'],
            publisher: 'Chilton Books',
            category: 'book',
            format: 'vinyl',
          ),
        ),
        throwsA(isA<InvalidFormatForCategoryError>()),
      );
    });
  });
}
