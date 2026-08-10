import 'dart:async';

import 'package:core/shared/pagination/page_request.dart';
import 'package:core/shared/pagination/page_result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/modules/catalog/application/item_list_state.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';

class ItemListStateService extends Cubit<ItemListState> {
  ItemListStateService(this._readService, {String? category}) : super(const ItemListLoading()) {
    _subscription = _readService
        .watchAll(category: category)
        .listen(_onItems, onError: (Object error) => emit(ItemListError(error.toString())));
  }

  final ItemReadService _readService;
  late final StreamSubscription<List<ItemReadModel>> _subscription;
  List<ItemReadModel> _allItems = const [];
  int _page = 1;

  void _onItems(List<ItemReadModel> items) {
    _allItems = items;
    _emitPage();
  }

  void _emitPage() {
    final pageRequest = PageRequest.create(page: _page);
    final start = pageRequest.offset;
    final end = (start + pageRequest.limit).clamp(0, _allItems.length);
    final pageItems = start >= _allItems.length ? const <ItemReadModel>[] : _allItems.sublist(start, end);
    emit(
      ItemListLoaded(
        PageResult(
          items: pageItems,
          page: _page,
          pageSize: pageRequest.pageSize,
          totalItems: _allItems.length,
        ),
      ),
    );
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
