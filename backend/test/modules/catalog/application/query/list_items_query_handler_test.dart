import 'package:backend/modules/catalog/application/query/list_items_query.dart';
import 'package:backend/modules/catalog/application/query/list_items_query_handler.dart';
import 'package:core/modules/catalog/domain/criteria/item_criteria.dart';
import 'package:core/modules/catalog/domain/repositories/item_repository.dart';
import 'package:core/shared/pagination/page_request.dart';
import 'package:core/shared/pagination/page_result.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../../../../core/test/modules/identity/domain/entities/user_mother.dart';
import '../../../../../../core/test/modules/catalog/domain/entities/item_mother.dart';

class MockItemRepository extends Mock implements ItemRepository {}

void main() {
  group('ListItemsQueryHandler', () {
    test('returns read models for the requester\'s items', () async {
      final repository = MockItemRepository();
      final ownerId = UserMother.random().id;
      final items = [ItemMother.book(), ItemMother.movie()];
      when(
        () => repository.list(
          ItemCriteria(
            ownerId: ownerId,
            pageRequest: PageRequest.create(page: 1, pageSize: 10),
          ),
        ),
      ).thenAnswer(
        (_) async => PageResult(
          items: items,
          page: 1,
          pageSize: 10,
          totalItems: items.length,
        ),
      );

      final handler = ListItemsQueryHandler(repository);
      final result = await handler.handle(
        ListItemsQuery(ownerId: ownerId.value, page: 1, pageSize: 10),
      );

      expect(result.items, hasLength(2));
      expect(result.items[0].id, items[0].id.value);
      expect(result.items[1].id, items[1].id.value);
      expect(result.totalItems, 2);
    });
  });
}
