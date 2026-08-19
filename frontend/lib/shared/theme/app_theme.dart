import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppAccentColor {
  purple('Purple', Color(0xFF6F3194)),
  magenta('Magenta', Color(0xFFF23DD4)),
  yellow('Yellow', Color(0xFFFFD23F)),
  blue('Blue', Color(0xFF448AFF)),
  green('Green', Color(0xFF00C853)),
  orange('Orange', Color(0xFFFF6D00)),
  teal('Teal', Color(0xFF00BFA5));

  const AppAccentColor(this.label, this.seed);

  final String label;
  final Color seed;
}

class AppTheme {
  const AppTheme._();

  static const _darkBackground = Color(0xFF161219);
  static const _darkSurface = Color(0xFF1E1A22);

  static ThemeData light(AppAccentColor accent) =>
      _themeFrom(_lightScheme(accent));

  static ThemeData dark(AppAccentColor accent) =>
      _themeFrom(_darkScheme(accent));

  static ColorScheme _lightScheme(AppAccentColor accent) =>
      ColorScheme.fromSeed(
        seedColor: accent.seed,
        brightness: Brightness.light,
        dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
      );

  static ColorScheme _darkScheme(AppAccentColor accent) => ColorScheme.fromSeed(
    seedColor: accent.seed,
    brightness: Brightness.dark,
    dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
  ).copyWith(surface: _darkSurface, onSurface: const Color(0xFFEAE4F0));

  static const _buttonShape = RoundedRectangleBorder();

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
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.secondary,
          shape: _buttonShape,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(shape: _buttonShape),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(shape: _buttonShape),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(shape: _buttonShape),
      ),
      chipTheme: ChipThemeData(shape: _buttonShape),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        shape: _buttonShape,
      ),
      cardTheme: const CardThemeData(shape: _buttonShape),
    );
  }
}
