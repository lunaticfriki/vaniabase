import 'package:frontend/modules/catalog/application/item_read_model.dart';

sealed class PublishersState {
  const PublishersState();
}

class PublishersLoading extends PublishersState {
  const PublishersLoading();
}

class PublishersLoaded extends PublishersState {
  const PublishersLoaded(this.publishers, this.items, {this.selectedLetter, this.selectedPublisher});

  final List<String> publishers;
  final List<ItemReadModel> items;
  final String? selectedLetter;
  final String? selectedPublisher;

  List<ItemReadModel> get selectedItems {
    final publisher = selectedPublisher;
    if (publisher == null) return const [];
    return items.where((item) => item.publisher == publisher).toList();
  }
}

class PublishersError extends PublishersState {
  const PublishersError(this.message);

  final String message;
}
