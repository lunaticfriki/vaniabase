import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Brand colors: a light purple as primary. Secondary (used for links) is a
/// brilliant yellow on dark backgrounds, and a deeper purple on light
/// backgrounds where a bright yellow wouldn't read well. Dark backgrounds
/// stay off-black rather than pure `#000000`.
class AppTheme {
  const AppTheme._();

  static const _seedPurple = Color(0xFF9B7EF7);
  static const _darkBackground = Color(0xFF161219);
  static const _darkSurface = Color(0xFF1E1A22);
  static const _lightPurpleSecondary = Color(0xFF6C3CE9);
  static const _darkYellow = Color(0xFFFFDD00);

  static ThemeData get light => _themeFrom(_lightScheme);

  static ThemeData get dark => _themeFrom(_darkScheme);

  static ColorScheme get _lightScheme =>
      ColorScheme.fromSeed(
        seedColor: _seedPurple,
        brightness: Brightness.light,
      ).copyWith(secondary: _lightPurpleSecondary, onSecondary: Colors.white);

  static ColorScheme get _darkScheme =>
      ColorScheme.fromSeed(
        seedColor: _seedPurple,
        brightness: Brightness.dark,
      ).copyWith(
        secondary: _darkYellow,
        onSecondary: const Color(0xFF3A2E00),
        surface: _darkSurface,
        onSurface: const Color(0xFFEAE4F0),
      );

  static ThemeData _themeFrom(ColorScheme colorScheme) {
    final textTheme = GoogleFonts.inconsolataTextTheme(
      ThemeData(brightness: colorScheme.brightness).textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.brightness == Brightness.dark
          ? _darkBackground
          : colorScheme.surface,
      textTheme: textTheme,
      fontFamily: GoogleFonts.inconsolata().fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.brightness == Brightness.dark
            ? _darkBackground
            : colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: colorScheme.secondary),
      ),
    );
  }
}
