import 'package:core/shared/pagination/page_result.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';

sealed class ItemListState {
  const ItemListState();
}

class ItemListLoading extends ItemListState {
  const ItemListLoading();
}

class ItemListLoaded extends ItemListState {
  const ItemListLoaded(this.result);

  final PageResult<ItemReadModel> result;
}

class ItemListError extends ItemListState {
  const ItemListError(this.message);

  final String message;
}
