import 'package:backend/modules/catalog/application/command/delete_item_command.dart';
import 'package:core/modules/catalog/domain/errors/item_not_found_error.dart';
import 'package:core/modules/catalog/domain/repositories/item_repository.dart';
import 'package:core/modules/catalog/domain/value_objects/item_id.dart';
import 'package:core/modules/identity/domain/value_objects/user_id.dart';

class DeleteItemCommandHandler {
  DeleteItemCommandHandler(this._items);

  final ItemRepository _items;

  Future<void> handle(DeleteItemCommand command) async {
    final id = ItemId.create(command.itemId);
    final requestingUserId = UserId.create(command.requestingUserId);
    final item = await _items.findById(id);
    if (item == null || !item.isOwnedBy(requestingUserId)) {
      throw ItemNotFoundError(id);
    }

    await _items.delete(id);
  }
}
