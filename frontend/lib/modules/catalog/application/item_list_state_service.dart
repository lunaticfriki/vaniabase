import 'dart:async';

import 'package:core/shared/pagination/page_request.dart';
import 'package:core/shared/pagination/page_result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:frontend/modules/catalog/application/item_sort_option.dart';

sealed class ItemListState {
  const ItemListState();
}

class ItemListLoading extends ItemListState {
  const ItemListLoading();
}

class ItemListLoaded extends ItemListState {
  const ItemListLoaded(this.result, this.sortOption);

  final PageResult<ItemReadModel> result;
  final ItemSortOption sortOption;
}

class ItemListError extends ItemListState {
  const ItemListError(this.message);

  final String message;
}

class ItemListStateService extends Cubit<ItemListState> {
  ItemListStateService(this._readService, {String? category, bool? completed})
    : super(const ItemListLoading()) {
    _subscription = _readService
        .watchAll(category: category, completed: completed)
        .listen(
          _onItems,
          onError: (Object error) => emit(ItemListError(error.toString())),
        );
  }

  final ItemReadService _readService;
  late final StreamSubscription<List<ItemReadModel>> _subscription;
  List<ItemReadModel> _allItems = const [];
  ItemSortOption _sortOption = ItemSortOption.createdAtDesc;
  int _page = 1;

  void _onItems(List<ItemReadModel> items) {
    _allItems = items;
    _emitPage();
  }

  List<ItemReadModel> _sortedItems() {
    final items = [..._allItems];
    switch (_sortOption) {
      case ItemSortOption.createdAtDesc:
        items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case ItemSortOption.createdAtAsc:
        items.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case ItemSortOption.title:
        items.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
      case ItemSortOption.author:
        items.sort(
          (a, b) => a.creator
              .join(', ')
              .toLowerCase()
              .compareTo(b.creator.join(', ').toLowerCase()),
        );
    }
    return items;
  }

  void _emitPage() {
    final sortedItems = _sortedItems();
    final pageRequest = PageRequest.create(page: _page);
    final start = pageRequest.offset;
    final end = (start + pageRequest.limit).clamp(0, sortedItems.length);
    final pageItems = start >= sortedItems.length
        ? const <ItemReadModel>[]
        : sortedItems.sublist(start, end);
    emit(
      ItemListLoaded(
        PageResult(
          items: pageItems,
          page: _page,
          pageSize: pageRequest.pageSize,
          totalItems: sortedItems.length,
        ),
        _sortOption,
      ),
    );
  }

  void setSortOption(ItemSortOption sortOption) {
    if (sortOption == _sortOption) return;
    _sortOption = sortOption;
    _page = 1;
    _emitPage();
  }

  void nextPage() {
    final current = state;
    if (current is ItemListLoaded && current.result.hasNextPage) {
      _page++;
      _emitPage();
    }
  }

  void previousPage() {
    final current = state;
    if (current is ItemListLoaded && current.result.hasPreviousPage) {
      _page--;
      _emitPage();
    }
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
