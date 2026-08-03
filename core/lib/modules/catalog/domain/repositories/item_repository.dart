import 'package:core/modules/catalog/domain/criteria/item_criteria.dart';
import 'package:core/modules/catalog/domain/entities/item.dart';
import 'package:core/modules/catalog/domain/value_objects/item_id.dart';
import 'package:core/shared/pagination/page_result.dart';

abstract class ItemRepository {
  Future<Item?> findById(ItemId id);

  Future<PageResult<Item>> list(ItemCriteria criteria);

  Future<void> save(Item item);

  Future<void> delete(ItemId id);
}
