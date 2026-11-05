import 'package:flutter/material.dart';

import 'tokens.dart';

const _font = 'NotoSans';

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: Tokens.brand,
    primary: Tokens.brand,
    surface: Tokens.surface,
    tertiary: Tokens.highlight,
    outlineVariant: Tokens.outline,
  );
  final base = ThemeData(useMaterial3: true, colorScheme: scheme, fontFamily: _font);
  final text = base.textTheme.apply(bodyColor: Tokens.ink, displayColor: Tokens.ink);
  final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(Tokens.radius));
  const buttonText = TextStyle(fontFamily: _font, fontSize: 17, fontWeight: FontWeight.w600);
  return base.copyWith(
    scaffoldBackgroundColor: Tokens.surface,
    textTheme: text.copyWith(
      headlineSmall: text.headlineSmall?.copyWith(fontSize: 26, fontWeight: FontWeight.w700, height: 1.2),
      titleLarge: text.titleLarge?.copyWith(fontSize: 21, fontWeight: FontWeight.w700, height: 1.25),
      titleMedium: text.titleMedium?.copyWith(fontSize: 17, fontWeight: FontWeight.w600, height: 1.3),
      bodyLarge: text.bodyLarge?.copyWith(fontSize: 17, height: 1.4),
      bodyMedium: text.bodyMedium?.copyWith(fontSize: 15, height: 1.4),
      bodySmall: text.bodySmall?.copyWith(fontSize: 13, height: 1.35, color: Tokens.inkMuted),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Tokens.surface,
      foregroundColor: Tokens.ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
          fontFamily: _font, fontSize: 19, fontWeight: FontWeight.w700, color: Tokens.ink),
    ),
    cardTheme: CardThemeData(
      color: Tokens.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Tokens.radius),
        side: const BorderSide(color: Tokens.outline),
      ),
    ),
    dividerTheme: const DividerThemeData(color: Tokens.outline, space: 1, thickness: 1),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(Tokens.touch),
        padding: const EdgeInsets.symmetric(horizontal: Tokens.s4, vertical: Tokens.s3),
        textStyle: buttonText,
        shape: shape,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(Tokens.touch),
        padding: const EdgeInsets.symmetric(horizontal: Tokens.s4, vertical: Tokens.s3),
        textStyle: buttonText,
        backgroundColor: Tokens.card,
        side: const BorderSide(color: Tokens.control, width: 1.5),
        shape: shape,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        textStyle: const TextStyle(fontFamily: _font, fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(0, 52)),
        backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? Tokens.brandSoft : Tokens.card),
        foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? Tokens.brand : Tokens.ink),
        side: const WidgetStatePropertyAll(BorderSide(color: Tokens.control)),
        textStyle: const WidgetStatePropertyAll(
            TextStyle(fontFamily: _font, fontSize: 15, fontWeight: FontWeight.w600)),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      labelStyle: const TextStyle(fontFamily: _font, fontSize: 15, color: Tokens.ink),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      backgroundColor: Tokens.card,
      selectedColor: Tokens.brandSoft,
      side: const BorderSide(color: Tokens.control),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Tokens.radiusSmall + 2)),
    ),
    listTileTheme: const ListTileThemeData(
      minVerticalPadding: Tokens.s3,
      iconColor: Tokens.brand,
      titleTextStyle: TextStyle(fontFamily: _font, fontSize: 16, fontWeight: FontWeight.w600, color: Tokens.ink),
      subtitleTextStyle: TextStyle(fontFamily: _font, fontSize: 14, height: 1.35, color: Tokens.inkMuted),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      backgroundColor: Tokens.card,
      surfaceTintColor: Colors.transparent,
      indicatorColor: Tokens.brandSoft,
      iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
          color: s.contains(WidgetState.selected) ? Tokens.brand : Tokens.inkMuted)),
      labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(
          fontFamily: _font,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: s.contains(WidgetState.selected) ? Tokens.brand : Tokens.inkMuted)),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: Tokens.brand),
  );
}
