import 'package:flutter/material.dart';

import '../models/ecg_case.dart';

/// Design tokens. Urgency is always shown with colour + icon + word, never colour
/// alone (colour-blind safety). Text/background pairs meet WCAG AA (≥ 4.5:1);
/// ratios are listed in docs/design/README.md.
class Tokens {
  // Colour: brand and neutrals.
  static const brand = Color(0xFF1D4E89); // deep clinical blue
  static const brandSoft = Color(0xFFE6EEF8); // tonal fill behind brand icons
  static const ink = Color(0xFF1B1D21); // body text
  static const inkMuted = Color(0xFF545B66); // secondary text
  static const surface = Color(0xFFF5F7FA); // page background
  static const card = Colors.white;
  static const outline = Color(0xFFDDE2E9); // card borders, dividers (decorative)
  static const control = Color(0xFF858E9B); // borders of buttons, chips, checkboxes: 3.3:1 on white
  static const highlight = Color(0xFF7A4DC9); // "look here" boxes on the trace
  static const caution = Color(0xFF8A5A00); // non-urgency warnings (photo quality)
  static const research = Color(0xFFFFF8E6); // research-prototype notice fill

  // Spacing scale (dp). Use these instead of ad-hoc numbers.
  static const s1 = 4.0;
  static const s2 = 8.0;
  static const s3 = 12.0;
  static const s4 = 16.0;
  static const s5 = 24.0;
  static const s6 = 32.0;
  static const gap = s4;
  static const pagePadding = EdgeInsets.fromLTRB(s4, s2, s4, s5);

  // Shape scale.
  static const radiusSmall = 10.0; // notices, tags
  static const radius = 16.0; // cards, buttons
  static const radiusLarge = 24.0; // hero card, urgency banner

  static const touch = 56.0; // minimum height for primary buttons

  static UrgencyStyle urgency(Urgency u) => switch (u) {
        Urgency.red => const UrgencyStyle(
            bg: Color(0xFFB3261E), fg: Colors.white, soft: Color(0xFFFCE8E6),
            onSoft: Color(0xFF8C1D18), icon: Icons.emergency_outlined),
        Urgency.amber => const UrgencyStyle(
            bg: Color(0xFFFFC107), fg: Color(0xFF1F1F1F), soft: Color(0xFFFFF4D6),
            onSoft: Color(0xFF6B4700), icon: Icons.warning_amber_rounded),
        Urgency.green => const UrgencyStyle(
            bg: Color(0xFF1B6E3C), fg: Colors.white, soft: Color(0xFFE5F4EA),
            onSoft: Color(0xFF14532D), icon: Icons.check_circle_outline),
        // Grey is outlined (dashed), not filled: "no result" must not look like a result colour.
        Urgency.grey => const UrgencyStyle(
            bg: Color(0xFFECEEF1), fg: Color(0xFF3C4043), soft: Color(0xFFECEEF1),
            onSoft: Color(0xFF3C4043), icon: Icons.hide_image_outlined, border: Color(0xFF5F6368)),
      };
}

class UrgencyStyle {
  const UrgencyStyle({
    required this.bg,
    required this.fg,
    required this.soft,
    required this.onSoft,
    required this.icon,
    this.border,
  });
  final Color bg;
  final Color fg;

  /// Light tint of the level colour, for list rows and tags.
  final Color soft;

  /// Text and icon colour on [soft] and on white.
  final Color onSoft;
  final IconData icon;

  /// Only grey has a border: it is outlined instead of filled.
  final Color? border;
}
