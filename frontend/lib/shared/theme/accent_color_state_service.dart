import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/shared/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccentColorStateService extends Cubit<AppAccentColor> {
  AccentColorStateService(this._preferences) : super(_readColor(_preferences));

  static const _prefsKey = 'accent_color';

  final SharedPreferences _preferences;

  static AppAccentColor _readColor(SharedPreferences preferences) {
    final stored = preferences.getString(_prefsKey);
    return AppAccentColor.values.firstWhere(
      (color) => color.name == stored,
      orElse: () => AppAccentColor.magenta,
    );
  }

  void setColor(AppAccentColor color) {
    emit(color);
    _preferences.setString(_prefsKey, color.name);
  }
}
