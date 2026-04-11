import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'text_styles.dart';

class AppTheme {
  // ── DARK ──────────────────────────────────────
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: CyberCortexColors.background,
    colorScheme: const ColorScheme.dark(
      primary:     CyberCortexColors.primary,
      secondary:   CyberCortexColors.secondary,
      tertiary:    CyberCortexColors.tertiary,
      surface:     CyberCortexColors.surface,
      onPrimary:   CyberCortexColors.onPrimary,
      onSecondary: CyberCortexColors.onSecondary,
    ),
    cardColor:    CyberCortexColors.surface,
    dividerColor: CyberCortexColors.border,
    textTheme: TextTheme(
      displayLarge:  AppTextStyles.darkDisplayLarge,
      displayMedium: AppTextStyles.darkDisplayMedium,
      headlineLarge: AppTextStyles.darkHeadlineLarge,
      headlineMedium:AppTextStyles.darkHeadlineMedium,
      bodyLarge:     AppTextStyles.darkBodyLarge,
      bodyMedium:    AppTextStyles.darkBodyMedium,
      bodySmall:     AppTextStyles.darkBodySmall,
      labelLarge:    AppTextStyles.darkLabelLarge,
      labelMedium:   AppTextStyles.darkLabelMedium,
      labelSmall:    AppTextStyles.darkLabelSmall,
    ),
  );

  // ── LIGHT ─────────────────────────────────────
  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: LuminaColors.background,
    colorScheme: const ColorScheme.light(
      primary:     LuminaColors.primary,
      secondary:   LuminaColors.secondary,
      tertiary:    LuminaColors.tertiary,
      surface:     LuminaColors.surface,
      onPrimary:   LuminaColors.onPrimary,
      onSecondary: LuminaColors.onSecondary,
    ),
    cardColor:    LuminaColors.surface,
    dividerColor: LuminaColors.border,
    textTheme: TextTheme(
      displayLarge:  AppTextStyles.lightDisplayLarge,
      displayMedium: AppTextStyles.lightDisplayMedium,
      headlineLarge: AppTextStyles.lightHeadlineLarge,
      headlineMedium:AppTextStyles.lightHeadlineMedium,
      bodyLarge:     AppTextStyles.lightBodyLarge,
      bodyMedium:    AppTextStyles.lightBodyMedium,
      bodySmall:     AppTextStyles.lightBodySmall,
      labelLarge:    AppTextStyles.lightLabelLarge,
      labelMedium:   AppTextStyles.lightLabelMedium,
      labelSmall:    AppTextStyles.lightLabelSmall,
    ),
  );
}