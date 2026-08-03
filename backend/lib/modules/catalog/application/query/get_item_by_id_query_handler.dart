import 'package:backend/modules/catalog/application/item_read_model.dart';
import 'package:backend/modules/catalog/application/query/get_item_by_id_query.dart';
import 'package:core/modules/catalog/domain/errors/item_not_found_error.dart';
import 'package:core/modules/catalog/domain/repositories/item_repository.dart';
import 'package:core/modules/catalog/domain/value_objects/item_id.dart';
import 'package:core/modules/identity/domain/value_objects/user_id.dart';

class GetItemByIdQueryHandler {
  GetItemByIdQueryHandler(this._items);

  final ItemRepository _items;

  Future<ItemReadModel> handle(GetItemByIdQuery query) async {
    final id = ItemId.create(query.itemId);
    final requestingUserId = UserId.create(query.requestingUserId);
    final item = await _items.findById(id);
    if (item == null || !item.isOwnedBy(requestingUserId)) {
      throw ItemNotFoundError(id);
    }

    return ItemReadModel.fromDomain(item);
  }
}
