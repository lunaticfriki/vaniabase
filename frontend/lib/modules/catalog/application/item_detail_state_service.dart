import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/modules/catalog/application/item_detail_state.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:frontend/modules/catalog/application/item_write_service.dart';

class ItemDetailStateService extends Cubit<ItemDetailState> {
  ItemDetailStateService(this._readService, this._writeService, this._itemId)
    : super(const ItemDetailLoading()) {
    _load();
  }

  final ItemReadService _readService;
  final ItemWriteService _writeService;
  final String _itemId;

  Future<void> _load() async {
    try {
      final item = await _readService.getById(id: _itemId);
      emit(ItemDetailLoaded(item));
    } catch (error) {
      emit(ItemDetailError(error.toString()));
    }
  }

  Future<void> toggleCompleted() async {
    final current = state;
    if (current is! ItemDetailLoaded) return;
    final updated = current.item.copyWith(completed: !current.item.completed);
    await _writeService.update(id: _itemId, completed: updated.completed);
    emit(ItemDetailLoaded(updated));
  }
}
