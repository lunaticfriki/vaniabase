import 'package:backend/modules/catalog/application/item_read_model.dart';
import 'package:backend/modules/catalog/application/query/get_item_by_id_query.dart';
import 'package:backend/modules/catalog/application/query/get_item_by_id_query_handler.dart';
import 'package:backend/modules/catalog/application/query/list_items_query.dart';
import 'package:backend/modules/catalog/application/query/list_items_query_handler.dart';
import 'package:core/shared/pagination/page_result.dart';

abstract class ItemReadService {
  Future<ItemReadModel> getById(GetItemByIdQuery query);

  Future<PageResult<ItemReadModel>> list(ListItemsQuery query);
}

class ItemReadServiceImpl implements ItemReadService {
  ItemReadServiceImpl(this._getById, this._list);

  final GetItemByIdQueryHandler _getById;
  final ListItemsQueryHandler _list;

  @override
  Future<ItemReadModel> getById(GetItemByIdQuery query) =>
      _getById.handle(query);

  @override
  Future<PageResult<ItemReadModel>> list(ListItemsQuery query) =>
      _list.handle(query);
}
