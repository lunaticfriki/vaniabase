import 'package:core/shared/pagination/page_request.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:frontend/modules/catalog/presentation/item_list/item_list_state.dart';

class ItemListCubit extends Cubit<ItemListState> {
  ItemListCubit(this._readService) : super(const ItemListLoading()) {
    _load(PageRequest.first());
  }

  final ItemReadService _readService;

  Future<void> _load(PageRequest pageRequest) async {
    if (state is! ItemListLoading) emit(const ItemListLoading());
    try {
      final result = await _readService.list(pageRequest: pageRequest);
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
