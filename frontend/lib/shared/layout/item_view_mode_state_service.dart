import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/shared/layout/item_view_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ItemViewModeStateService extends Cubit<ItemViewMode> {
  ItemViewModeStateService(this._preferences, this._storageKey)
    : super(_readMode(_preferences, _storageKey));

  final SharedPreferences _preferences;
  final String _storageKey;

  static ItemViewMode _readMode(SharedPreferences preferences, String key) {
    final stored = preferences.getString(key);
    return ItemViewMode.values.firstWhere(
      (mode) => mode.name == stored,
      orElse: () => ItemViewMode.grid,
    );
  }

  void setMode(ItemViewMode mode) {
    emit(mode);
    _preferences.setString(_storageKey, mode.name);
  }
}
