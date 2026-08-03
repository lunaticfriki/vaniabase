import 'package:core/modules/catalog/domain/value_objects/item_id.dart';
import 'package:core/shared/errors/domain_error.dart';

class ItemNotFoundError extends DomainError {
  ItemNotFoundError(ItemId id) : super('item "${id.value}" not found');
}
