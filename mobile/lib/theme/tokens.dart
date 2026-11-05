import 'package:flutter/material.dart';

import '../models/ecg_case.dart';

/// Design tokens. Urgency is always shown with colour + icon + word, never colour
/// alone (colour-blind safety). Text/background pairs meet WCAG AA (≥ 4.5:1).
class Tokens {
  static const brand = Color(0xFF1D4E89); // deep clinical blue
  static const ink = Color(0xFF1B1D21);
  static const surface = Color(0xFFF7F8FA);

  static const radius = 16.0;
  static const radiusSmall = 10.0;
  static const gap = 16.0;
  static const touch = 56.0; // minimum height for primary buttons

  static UrgencyStyle urgency(Urgency u) => switch (u) {
        Urgency.red => const UrgencyStyle(
            bg: Color(0xFFB3261E), fg: Colors.white, soft: Color(0xFFFCE8E6),
            icon: Icons.emergency_outlined),
        Urgency.amber => const UrgencyStyle(
            bg: Color(0xFFFFC107), fg: Color(0xFF1F1F1F), soft: Color(0xFFFFF4D6),
            icon: Icons.warning_amber_rounded),
        Urgency.green => const UrgencyStyle(
            bg: Color(0xFF1B6E3C), fg: Colors.white, soft: Color(0xFFE5F4EA),
            icon: Icons.check_circle_outline),
        // Grey is outlined, not filled: "no result" must not look like a result colour.
        Urgency.grey => const UrgencyStyle(
            bg: Color(0xFFECEEF1), fg: Color(0xFF3C4043), soft: Color(0xFFECEEF1),
            icon: Icons.hide_image_outlined, border: Color(0xFF5F6368)),
      };
}

class UrgencyStyle {
  const UrgencyStyle({required this.bg, required this.fg, required this.soft, required this.icon, this.border});
  final Color bg;
  final Color fg;
  final Color soft;
  final IconData icon;
  final Color? border;
}
