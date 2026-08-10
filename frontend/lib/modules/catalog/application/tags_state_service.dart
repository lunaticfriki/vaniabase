import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/modules/catalog/application/fetch_all_items_util.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:frontend/modules/catalog/application/tags_state.dart';

class TagsStateService extends Cubit<TagsState> {
  TagsStateService(this._readService, {String? initialTag})
    : _initialTag = initialTag,
      super(const TagsLoading()) {
    _load();
  }

  final ItemReadService _readService;
  final String? _initialTag;

  Future<void> _load() async {
    try {
      final items = await fetchAllItems(_readService);
      final counts = <String, int>{};
      for (final item in items) {
        for (final tag in item.tags) {
          counts[tag] = (counts[tag] ?? 0) + 1;
        }
      }
      final tagCounts = counts.entries.map((entry) => TagCount(entry.key, entry.value)).toList()
        ..sort((a, b) => a.tag.compareTo(b.tag));
      final selectedTag = _initialTag ?? (tagCounts.isEmpty ? null : tagCounts.first.tag);
      emit(TagsLoaded(tagCounts, items, selectedTag: selectedTag));
    } catch (error) {
      emit(TagsError(error.toString()));
    }
  }

  void selectTag(String tag) {
    final current = state;
    if (current is! TagsLoaded) return;
    emit(
      TagsLoaded(
        current.tagCounts,
        current.items,
        selectedTag: current.selectedTag == tag ? null : tag,
      ),
    );
  }
}
