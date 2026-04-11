// app_colors.dart
import 'package:flutter/material.dart';

// ──────────────────────────────────────────
//  CyberCortex  ·  DARK THEME
// ──────────────────────────────────────────
class CyberCortexColors {
  // Brand palette
  static const Color primary   = Color(0xFF00D4FF); // cyan
  static const Color secondary = Color(0xFF8B5CF6); // purple
  static const Color tertiary  = Color(0xFF4C72D5); // blue
  static const Color neutral   = Color(0xFF0F1629); // near-black bg

  // Surface / background
  static const Color background     = Color(0xFF0F1629);
  static const Color surface        = Color(0xFF1A2236); // card bg
  static const Color surfaceVariant = Color(0xFF232E45); // elevated card

  // Text
  static const Color onPrimary   = Color(0xFF000000);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);

  // Divider / border
  static const Color border = Color(0xFF2D3C57);

  // Button states
  static const Color buttonPrimary   = primary;
  static const Color buttonSecondary = surface;
  static const Color buttonInverted  = Color(0xFFFFFFFF);
  static const Color buttonOutlined  = Colors.transparent;

  // Icon tray (bottom-right pill in screenshot)
  static const Color iconPurple = Color(0xFF8B5CF6);
  static const Color iconCyan   = Color(0xFF00D4FF);
  static const Color iconBlue   = Color(0xFF4C72D5);
  static const Color iconRed    = Color(0xFFEF4444);

  // Progress / divider lines
  static const Color linePrimary   = primary;
  static const Color lineSecondary = secondary;
  static const Color lineTertiary  = tertiary;
}

// ──────────────────────────────────────────
//  SnakeTrack Lumina  ·  LIGHT THEME
// ──────────────────────────────────────────
class LuminaColors {
  // Brand palette
  static const Color primary   = Color(0xFF00BAE0); // teal-cyan
  static const Color secondary = Color(0xFF7C3AED); // deep purple
  static const Color tertiary  = Color(0xFFA5B4FC); // lavender
  static const Color neutral   = Color(0xFFF8FAFC); // off-white bg

  // Surface / background
  static const Color background     = Color(0xFFF8FAFC);
  static const Color surface        = Color(0xFFFFFFFF); // card bg
  static const Color surfaceVariant = Color(0xFFF1F5F9); // subtle card

  // Text
  static const Color onPrimary   = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color textPrimary   = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);

  // Divider / border
  static const Color border = Color(0xFFE2E8F0);

  // Button states
  static const Color buttonPrimary   = primary;
  static const Color buttonSecondary = Color(0xFFF1F5F9);
  static const Color buttonInverted  = Color(0xFF0F172A);
  static const Color buttonOutlined  = Colors.transparent;

  // Icon tray
  static const Color iconTeal   = Color(0xFF00BAE0);
  static const Color iconPurple = Color(0xFF7C3AED);
  static const Color iconLavender = Color(0xFFA5B4FC);
  static const Color iconRed    = Color(0xFFEF4444);

  // Progress / divider lines
  static const Color linePrimary   = primary;
  static const Color lineSecondary = secondary;
  static const Color lineTertiary  = tertiary;
}