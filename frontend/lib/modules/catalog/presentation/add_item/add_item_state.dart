sealed class AddItemState {
  const AddItemState();
}

class AddItemIdle extends AddItemState {
  const AddItemIdle();
}

class AddItemInProgress extends AddItemState {
  const AddItemInProgress();
}

class AddItemSuccess extends AddItemState {
  const AddItemSuccess();
}

class AddItemFailure extends AddItemState {
  const AddItemFailure(this.message);

  final String message;
}
