import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeStateService extends Cubit<ThemeMode> {
  ThemeStateService(this._preferences) : super(_readMode(_preferences));

  static const _prefsKey = 'theme_mode';

  final SharedPreferences _preferences;

  static ThemeMode _readMode(SharedPreferences preferences) {
    final stored = preferences.getString(_prefsKey);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == stored,
      orElse: () => ThemeMode.dark,
    );
  }

  void setMode(ThemeMode mode) {
    emit(mode);
    _preferences.setString(_prefsKey, mode.name);
  }
}
