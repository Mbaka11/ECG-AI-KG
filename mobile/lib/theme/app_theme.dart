import 'package:flutter/material.dart';

import 'tokens.dart';

const _font = 'NotoSans';

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: Tokens.brand,
    primary: Tokens.brand,
    surface: Tokens.surface,
    tertiary: const Color(0xFF7A4DC9),
  );
  final base = ThemeData(useMaterial3: true, colorScheme: scheme, fontFamily: _font);
  final text = base.textTheme.apply(bodyColor: Tokens.ink, displayColor: Tokens.ink);
  return base.copyWith(
    scaffoldBackgroundColor: Tokens.surface,
    textTheme: text.copyWith(
      bodyLarge: text.bodyLarge?.copyWith(fontSize: 17, height: 1.4),
      bodyMedium: text.bodyMedium?.copyWith(fontSize: 15, height: 1.4),
      titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Tokens.surface,
      foregroundColor: Tokens.ink,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Tokens.radius),
        side: const BorderSide(color: Color(0xFFE3E6EB)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(Tokens.touch),
        textStyle: const TextStyle(fontFamily: _font, fontSize: 17, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Tokens.radius)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(Tokens.touch),
        textStyle: const TextStyle(fontFamily: _font, fontSize: 17, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Tokens.radius)),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      labelStyle: const TextStyle(fontFamily: _font, fontSize: 15),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      backgroundColor: Colors.white,
      indicatorColor: scheme.primaryContainer,
      labelTextStyle: WidgetStateProperty.all(const TextStyle(fontFamily: _font, fontSize: 13, fontWeight: FontWeight.w600)),
    ),
  );
}
