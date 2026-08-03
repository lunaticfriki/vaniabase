import 'package:backend/modules/catalog/application/item_read_model.dart';
import 'package:backend/modules/catalog/application/query/list_items_query.dart';
import 'package:core/modules/catalog/domain/criteria/item_criteria.dart';
import 'package:core/modules/catalog/domain/repositories/item_repository.dart';
import 'package:core/modules/identity/domain/value_objects/user_id.dart';
import 'package:core/shared/pagination/page_request.dart';
import 'package:core/shared/pagination/page_result.dart';

class ListItemsQueryHandler {
  ListItemsQueryHandler(this._items);

  final ItemRepository _items;

  Future<PageResult<ItemReadModel>> handle(ListItemsQuery query) async {
    final criteria = ItemCriteria(
      ownerId: UserId.create(query.ownerId),
      pageRequest: PageRequest.create(page: query.page, pageSize: query.pageSize),
    );

    final result = await _items.list(criteria);

    return result.map(ItemReadModel.fromDomain);
  }
}
