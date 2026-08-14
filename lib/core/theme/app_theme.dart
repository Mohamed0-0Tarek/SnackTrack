import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'text_styles.dart';

class AppTheme {
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
      displayLarge:   AppTextStyles.darkDisplayLarge,
      displayMedium:  AppTextStyles.darkDisplayMedium,
      headlineLarge:  AppTextStyles.darkHeadlineLarge,
      headlineMedium: AppTextStyles.darkHeadlineMedium,
      bodyLarge:      AppTextStyles.darkBodyLarge,
      bodyMedium:     AppTextStyles.darkBodyMedium,
      bodySmall:      AppTextStyles.darkBodySmall,
      labelLarge:     AppTextStyles.darkLabelLarge,
      labelMedium:    AppTextStyles.darkLabelMedium,
      labelSmall:     AppTextStyles.darkLabelSmall,
    ),
  );

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
      displayLarge:   AppTextStyles.lightDisplayLarge,
      displayMedium:  AppTextStyles.lightDisplayMedium,
      headlineLarge:  AppTextStyles.lightHeadlineLarge,
      headlineMedium: AppTextStyles.lightHeadlineMedium,
      bodyLarge:      AppTextStyles.lightBodyLarge,
      bodyMedium:     AppTextStyles.lightBodyMedium,
      bodySmall:      AppTextStyles.lightBodySmall,
      labelLarge:     AppTextStyles.lightLabelLarge,
      labelMedium:    AppTextStyles.lightLabelMedium,
      labelSmall:     AppTextStyles.lightLabelSmall,
    ),
  );

  /// Boosts contrast on top of an existing light/dark [base] theme.
  ///
  /// Deliberately surgical rather than a second hand-designed theme:
  /// [AppTextStyles]' "primary" text colors (`textPrimary`) are already
  /// near pure black/white, so only the muted "secondary" text
  /// (`bodySmall`/`labelMedium`/`labelSmall`, which use `textSecondary`)
  /// and dividers get pushed to full contrast — that's where the actual
  /// legibility loss is. `colorScheme.onSurface`/`onSurfaceVariant`/
  /// `outline` are pushed to the same pure extreme so any screen reading
  /// `scheme.onSurface.withAlpha(...)` directly also gets a (smaller,
  /// since it was already close) contrast bump for free.
  static ThemeData highContrast(ThemeData base) {
    final isDark = base.brightness == Brightness.dark;
    final extreme = isDark ? Colors.white : Colors.black;

    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        onSurface: extreme,
        onSurfaceVariant: extreme,
        outline: extreme.withAlpha(220),
        outlineVariant: extreme.withAlpha(160),
      ),
      dividerColor: extreme.withAlpha(140),
      textTheme: base.textTheme.copyWith(
        bodySmall: base.textTheme.bodySmall?.copyWith(color: extreme),
        labelMedium: base.textTheme.labelMedium?.copyWith(color: extreme),
        labelSmall: base.textTheme.labelSmall?.copyWith(color: extreme),
      ),
    );
  }

  /// Strips route-transition animation from [base] for "Adaptive Assist".
  /// Doesn't touch in-screen micro-animations (those live in individual
  /// widgets, not the theme) — this covers screen-to-screen navigation,
  /// which is the biggest single source of motion in the app.
  static ThemeData reducedMotion(ThemeData base) => base.copyWith(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: _InstantPageTransitionsBuilder(),
            TargetPlatform.iOS: _InstantPageTransitionsBuilder(),
            TargetPlatform.macOS: _InstantPageTransitionsBuilder(),
            TargetPlatform.windows: _InstantPageTransitionsBuilder(),
            TargetPlatform.linux: _InstantPageTransitionsBuilder(),
            TargetPlatform.fuchsia: _InstantPageTransitionsBuilder(),
          },
        ),
      );

  /// Enlarges tap targets for "Adaptive Assist" across every Material
  /// widget that respects [ThemeData.materialTapTargetSize] /
  /// [ThemeData.visualDensity] (buttons, switches, checkboxes, list
  /// tiles, etc.) — one setting, no per-widget sizing to maintain.
  static ThemeData largerTapTargets(ThemeData base) => base.copyWith(
        materialTapTargetSize: MaterialTapTargetSize.padded,
        visualDensity: const VisualDensity(horizontal: 1, vertical: 1),
      );
}

/// Instant page transition used when "Adaptive Assist" reduced-motion is
/// on — replaces GoRouter/MaterialPageRoute's default animated transition
/// with a plain cut, since [ThemeData.pageTransitionsTheme] is what
/// MaterialPageRoute (which GoRoute builds under the hood) reads to
/// animate between screens.
class _InstantPageTransitionsBuilder extends PageTransitionsBuilder {
  const _InstantPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => child;
}
