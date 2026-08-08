import 'package:frontend/modules/catalog/application/item_read_model.dart';

sealed class EditItemState {
  const EditItemState();
}

class EditItemLoading extends EditItemState {
  const EditItemLoading();
}

class EditItemLoadFailure extends EditItemState {
  const EditItemLoadFailure(this.message);

  final String message;
}

class EditItemReady extends EditItemState {
  const EditItemReady(this.item, {this.isSubmitting = false, this.submitError});

  final ItemReadModel item;
  final bool isSubmitting;
  final String? submitError;
}

class EditItemSuccess extends EditItemState {
  const EditItemSuccess(this.itemId);

  final String itemId;
}

class EditItemDeleting extends EditItemState {
  const EditItemDeleting(this.item);

  final ItemReadModel item;
}

class EditItemDeleted extends EditItemState {
  const EditItemDeleted();
}
