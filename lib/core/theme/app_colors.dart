import 'package:flutter/material.dart';

/// Brand colour palette and gradients used throughout CreateIQ.
class AppColors {
  AppColors._();

  // --- Brand ---
  static const Color violet = Color(0xFF7C3AED);
  static const Color pink = Color(0xFFEC4899);
  static const Color cyan = Color(0xFF06B6D4);

  // --- Semantic ---
  static const Color success = Color(0xFF10B981);
  static const Color danger = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // --- Light surfaces ---
  static const Color lightBackground = Color(0xFFF7F7FB);
  static const Color lightSurface = Colors.white;
  static const Color lightText = Color(0xFF111827);
  static const Color lightMuted = Color(0xFF6B7280);

  // --- Dark surfaces ---
  static const Color darkBackground = Color(0xFF0B0B14);
  static const Color darkSurface = Color(0xFF16162A);
  static const Color darkText = Color(0xFFF3F4F6);
  static const Color darkMuted = Color(0xFF9CA3AF);

  /// Primary violet → pink gradient.
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [violet, pink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Violet → cyan gradient for secondary accents.
  static const LinearGradient accentGradient = LinearGradient(
    colors: [violet, cyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Categorical chart colours, in a fixed order.
  static const List<Color> chartPalette = [
    violet,
    pink,
    cyan,
    warning,
    success,
  ];
}
