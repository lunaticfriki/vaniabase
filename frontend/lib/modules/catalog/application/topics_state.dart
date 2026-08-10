import 'package:frontend/modules/catalog/application/item_read_model.dart';

sealed class TopicsState {
  const TopicsState();
}

class TopicsLoading extends TopicsState {
  const TopicsLoading();
}

class TopicsLoaded extends TopicsState {
  const TopicsLoaded(this.topics, this.items, {this.selectedLetter, this.selectedTopic});

  final List<String> topics;
  final List<ItemReadModel> items;
  final String? selectedLetter;
  final String? selectedTopic;

  List<ItemReadModel> get selectedItems {
    final topic = selectedTopic;
    if (topic == null) return const [];
    return items.where((item) => item.topic == topic).toList();
  }
}

class TopicsError extends TopicsState {
  const TopicsError(this.message);

  final String message;
}
