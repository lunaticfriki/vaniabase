import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/modules/catalog/application/item_detail_state.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';

class ItemDetailStateService extends Cubit<ItemDetailState> {
  ItemDetailStateService(this._readService, this._itemId) : super(const ItemDetailLoading()) {
    _load();
  }

  final ItemReadService _readService;
  final String _itemId;

  Future<void> _load() async {
    try {
      final item = await _readService.getById(id: _itemId);
      emit(ItemDetailLoaded(item));
    } catch (error) {
      emit(ItemDetailError(error.toString()));
    }
  }
}
