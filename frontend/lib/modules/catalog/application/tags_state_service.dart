import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';

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

class TagsStateService extends Cubit<TagsState> {
  TagsStateService(this._readService, {String? initialTag})
    : _initialTag = initialTag,
      super(const TagsLoading()) {
    _subscription = _readService.watchAll().listen(
      _onItems,
      onError: (Object error) => emit(TagsError(error.toString())),
    );
  }

  final ItemReadService _readService;
  final String? _initialTag;
  late final StreamSubscription<List<ItemReadModel>> _subscription;

  void _onItems(List<ItemReadModel> items) {
    final counts = <String, int>{};
    for (final item in items) {
      for (final tag in item.tags) {
        counts[tag] = (counts[tag] ?? 0) + 1;
      }
    }
    final tagCounts =
        counts.entries.map((entry) => TagCount(entry.key, entry.value)).toList()
          ..sort((a, b) => a.tag.compareTo(b.tag));

    final current = state;
    final selectedTag = current is TagsLoaded
        ? (tagCounts.any((t) => t.tag == current.selectedTag)
              ? current.selectedTag
              : null)
        : (_initialTag ?? (tagCounts.isEmpty ? null : tagCounts.first.tag));

    emit(TagsLoaded(tagCounts, items, selectedTag: selectedTag));
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

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
