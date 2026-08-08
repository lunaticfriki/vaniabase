import 'package:core/shared/pagination/page_request.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/modules/catalog/application/item_list_state.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';

class ItemListStateService extends Cubit<ItemListState> {
  ItemListStateService(this._readService, {String? category})
    : _category = category,
      super(const ItemListLoading()) {
    _load(PageRequest.first());
  }

  final ItemReadService _readService;
  final String? _category;

  Future<void> _load(PageRequest pageRequest) async {
    if (state is! ItemListLoading) emit(const ItemListLoading());
    try {
      final result = await _readService.list(pageRequest: pageRequest, category: _category);
      emit(ItemListLoaded(result));
    } catch (error) {
      emit(ItemListError(error.toString()));
    }
  }

  Future<void> nextPage() async {
    final current = state;
    if (current is ItemListLoaded && current.result.hasNextPage) {
      await _load(
        PageRequest.create(
          page: current.result.page + 1,
          pageSize: current.result.pageSize,
        ),
      );
    }
  }

  Future<void> previousPage() async {
    final current = state;
    if (current is ItemListLoaded && current.result.hasPreviousPage) {
      await _load(
        PageRequest.create(
          page: current.result.page - 1,
          pageSize: current.result.pageSize,
        ),
      );
    }
  }
}
