import 'package:frontend/modules/catalog/application/item_read_model.dart';

class TagCount {
  const TagCount(this.tag, this.count);

  final String tag;
  final int count;
}

sealed class TagsState {
  const TagsState();
}

class TagsLoading extends TagsState {
  const TagsLoading();
}

class TagsLoaded extends TagsState {
  const TagsLoaded(this.tagCounts, this.items, {this.selectedTag});

  final List<TagCount> tagCounts;
  final List<ItemReadModel> items;
  final String? selectedTag;

  List<ItemReadModel> get selectedItems {
    final tag = selectedTag;
    if (tag == null) return const [];
    return items.where((item) => item.tags.contains(tag)).toList();
  }
}

class TagsError extends TagsState {
  const TagsError(this.message);

  final String message;
}
