import 'package:frontend/modules/catalog/application/item_read_model.dart';

sealed class ItemDetailState {
  const ItemDetailState();
}

class ItemDetailLoading extends ItemDetailState {
  const ItemDetailLoading();
}

class ItemDetailLoaded extends ItemDetailState {
  const ItemDetailLoaded(this.item);

  final ItemReadModel item;
}

class ItemDetailError extends ItemDetailState {
  const ItemDetailError(this.message);

  final String message;
}
