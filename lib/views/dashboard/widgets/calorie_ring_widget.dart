// Circular calorie-tracking ring widget.
//
// ## What this file contains
// 1. [CalorieRingWidget] — the public widget placed in the dashboard.
// 2. [_StatColumn]       — small private helper (label + value column).
// 3. [_RingPainter]      — a [CustomPainter] that draws the arc.
//
// ## CustomPainter primer
// Flutter's built-in widgets cover most UI needs, but sometimes you
// need pixel-level control — that's where [CustomPaint] +
// [CustomPainter] come in.  You override `paint(Canvas, Size)` and
// use low-level drawing commands (arcs, circles, lines) directly on
// the canvas.  Flutter calls `shouldRepaint` to decide whether to
// re-invoke `paint` when the widget rebuilds — return `true` only
// when the visual output would actually change, to avoid wasted work.
//
// ## Theme awareness
// Every colour and text style is pulled from [Theme.of(context)] so
// the widget automatically adapts when the app switches between the
// CyberCortex (dark) and Lumina (light) themes.
import 'dart:math';

import 'package:flutter/material.dart';

/// Displays a circular progress ring showing how many kilocalories
/// have been consumed relative to the daily goal.
///
/// The ring fills clockwise from the 12-o'clock position.  Below it,
/// a stat row shows the numeric consumed and exercise values.
class CalorieRingWidget extends StatelessWidget {
  /// Kilocalories consumed so far today.
  final int consumed;

  /// Kilocalories burned through exercise.
  final int exercise;

  /// Daily kilocalorie target.
  final int goal;

  const CalorieRingWidget({
    super.key,
    required this.consumed,
    required this.exercise,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    // ── Pull theme tokens ───────────────────────────────────────────────
    // `scheme` gives access to the active ColorScheme (primary, secondary…).
    // `tt` is a shorthand for the active TextTheme.
    // `isDark` lets us branch on small details like glow intensity.
    final scheme = Theme.of(context).colorScheme;
    final tt     = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ── Derived values ──────────────────────────────────────────────────
    // `.clamp(min, max)` guarantees the value stays within [min..max].
    // This prevents a negative "remaining" if the user over-eats, and
    // keeps the progress fraction between 0 and 1 so the arc never
    // wraps past a full circle.
    final remaining = (goal - consumed).clamp(0, goal);
    final progress  = goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;

    return Column(
      children: [
        // ── Ring with ambient glow ──────────────────────────────────────
        // A [BoxShadow] with a large blur and the primary colour gives
        // the ring a subtle neon glow that reinforces the brand palette.
        // The alpha is higher in dark mode (64) for visibility, and lower
        // in light mode (30) to stay subtle.
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withAlpha(isDark ? 64 : 30),
                blurRadius: 40,
                spreadRadius: 8,
              ),
            ],
          ),
          // [CustomPaint] delegates all drawing to [_RingPainter].
          // Its `child` is the centre label — [CustomPaint] sizes itself
          // to fit the child, and the painter draws behind/around it.
          child: CustomPaint(
            painter: _RingPainter(
              progress:    progress,
              trackColor:  isDark
                  ? Colors.white.withAlpha(15)
                  : scheme.primary.withAlpha(26),
              ringColor:   scheme.primary,
              strokeWidth: 14,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Large remaining-kcal figure
                  Text(
                    _formatNumber(remaining),
                    style: tt.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 42,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // "KCAL LEFT" sub-label with wide letter spacing
                  Text(
                    'KCAL LEFT',
                    style: tt.labelMedium?.copyWith(
                      letterSpacing: 1.6,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // ── Consumed / Exercise stat row ────────────────────────────────
        // Two [_StatColumn] helpers side by side, separated by whitespace.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StatColumn(label: 'CONSUMED', value: _formatNumber(consumed)),
            const SizedBox(width: 48),
            _StatColumn(label: 'EXERCISE', value: _formatNumber(exercise)),
          ],
        ),
      ],
    );
  }

  /// Inserts a comma as a thousands separator (e.g. 1840 → "1,840").
  ///
  /// For numbers < 1000 it returns the plain string.  This avoids
  /// pulling in the `intl` package for a single formatting need.
  ///
  /// `~/` is Dart's **integer division** operator (truncates the
  /// decimal), and `padLeft(3, '0')` ensures the remainder is always
  /// three digits (e.g. 40 → "040").
  static String _formatNumber(int n) {
    if (n >= 1000) {
      return '${n ~/ 1000},${(n % 1000).toString().padLeft(3, '0')}';
    }
    return '$n';
  }
}

// ── Small label + bold value column used under the ring ────────────────────────
//
// Private to this file (name starts with `_`).  Keeping tiny helper
// widgets in the same file is fine when they're only used once and
// are conceptually part of the parent widget.
class _StatColumn extends StatelessWidget {
  final String label;
  final String value;

  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      children: [
        // Muted uppercase label ("CONSUMED" / "EXERCISE")
        Text(
          label,
          style: tt.labelSmall?.copyWith(
            letterSpacing: 0.8,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        // Bold numeric value
        Text(
          value,
          style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// ── CustomPainter that draws the circular progress ring ────────────────────────
//
// ## How it works
// 1. Draw a full-circle "track" with [trackColor] — this is the muted
//    background ring visible behind the progress.
// 2. Draw a partial arc over the track using [ringColor], sweeping
//    from –π/2 (12 o'clock) clockwise by `2π * progress` radians.
//
// ## `shouldRepaint`
// Returns `true` only when the values that affect the visual output
// have changed.  If the ring looks the same, returning `false` avoids
// an unnecessary repaint — a small but meaningful optimisation when the
// widget tree rebuilds frequently (e.g. during animations).
class _RingPainter extends CustomPainter {
  /// Fill fraction (0.0 = empty, 1.0 = full circle).
  final double progress;

  /// Color of the unfilled background track.
  final Color  trackColor;

  /// Color of the filled progress arc.
  final Color  ringColor;

  /// Thickness of the ring stroke in logical pixels.
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.ringColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Centre point of the square canvas area
    final center = Offset(size.width / 2, size.height / 2);

    // Inset the radius by half the stroke width so the thick stroke
    // doesn't clip outside the canvas bounds.
    final radius = (size.width - strokeWidth) / 2;

    // ── 1. Background track (full circle) ───────────────────────────────
    final track = Paint()
      ..color       = trackColor
      ..style       = PaintingStyle.stroke  // stroke = outline, not fill
      ..strokeWidth = strokeWidth
      ..strokeCap   = StrokeCap.round;      // rounded endpoints
    canvas.drawCircle(center, radius, track);

    // ── 2. Foreground progress arc ──────────────────────────────────────
    if (progress > 0) {
      // `sweepAngle` is how far around the circle to draw (in radians).
      // A full circle = 2π, so 50 % progress → π radians.
      final sweep = 2 * pi * progress;

      final arc = Paint()
        ..color       = ringColor
        ..style       = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap   = StrokeCap.round;

      // `drawArc` takes a bounding rectangle, a start angle, and a
      // sweep angle.  `-pi / 2` positions the start at 12 o'clock
      // (the default 0 would be 3 o'clock in Flutter's coordinate
      // system where angles increase clockwise from the positive X axis).
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,  // start at 12 o'clock
        sweep,    // how far to draw
        false,    // don't connect endpoints to centre (arc, not pie)
        arc,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.ringColor != ringColor;
}
