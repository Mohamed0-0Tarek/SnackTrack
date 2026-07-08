import 'package:flutter/material.dart';
import 'package:snacktrack/views/onboardin/widgets/scan_grid_lines_painter.dart';
import 'package:snacktrack/views/onboardin/widgets/scan_tag_pill.dart';
import 'package:snacktrack/views/onboardin/widgets/scanner_corner_brackets_painter.dart';

class Page1 extends StatelessWidget {
  final bool isDark;
  final Color primary;
  final Color secondary;
  final Animation<Offset> slideAnim;
  final Animation<double> fadeAnim;

  const Page1({
    super.key,
    required this.isDark,
    required this.primary,
    required this.secondary,
    required this.slideAnim,
    required this.fadeAnim,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return FadeTransition(
      opacity: fadeAnim,
      child: SlideTransition(
        position: slideAnim,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // ── Scanner image card ─────────────────────────────────────────
              Container(
                width: double.infinity,
                height: 280,
                decoration: BoxDecoration(
                  color: const Color(0xFF00C8C8).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    // Food image placeholder
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        color: const Color(0xFF00C8C8),
                        child: Center(
                          child: Icon(
                            Icons.set_meal_rounded,
                            size: 120,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ),

                    // Scanner corner brackets
                    Positioned.fill(
                      child: CustomPaint(painter: ScannerCornerPainter()),
                    ),

                    // Scan lines
                    Positioned.fill(
                      child: CustomPaint(
                        painter: ScanGridPainter(
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                    ),

                    // Avocado tag
                    Positioned(
                      top: 30,
                      left: 20,
                      child: ScanTag(
                        label: 'Avocado',
                        dotColor: primary,
                        isDark: true,
                      ),
                    ),

                    // Calories tag
                    Positioned(
                      bottom: 30,
                      right: 20,
                      child: ScanTag(
                        label: '320 kcal',
                        dotColor: secondary,
                        isDark: true,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // ── Text ──────────────────────────────────────────────────────
              Text(
                'Instant AI Scanning',
                style: tt.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Just point and track. Our AI recognizes thousands of foods and portions instantly.',
                style: tt.bodyMedium?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.55),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
