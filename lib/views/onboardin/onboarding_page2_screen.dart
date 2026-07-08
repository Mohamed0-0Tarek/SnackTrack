import 'package:flutter/material.dart';
import 'package:snacktrack/views/onboardin/widgets/ring_painter.dart';

class Page2 extends StatelessWidget {
  final bool isDark;
  final Color primary;
  final Color secondary;
  final Animation<Offset> slideAnim;
  final Animation<double> fadeAnim;

  const Page2({
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

              // ── Calc card ─────────────────────────────────────────────────
              Container(
                width: double.infinity,
                height: 230,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: scheme.onSurface.withValues(alpha: 0.1),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      primary.withValues(alpha: 0.08),
                      secondary.withValues(alpha: 0.12),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Big ring
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: CustomPaint(
                        painter: RingPainter(color: primary, strokeWidth: 10),
                      ),
                    ),

                    // Floating dots
                    Positioned(
                      top: 50,
                      right: 55,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: secondary,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 70,
                      left: 55,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primary.withValues(alpha: 0.6),
                        ),
                      ),
                    ),

                    // Center white card
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A2236) : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.monitor_heart_outlined,
                            color: primary,
                            size: 28,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Calc',
                            style: tt.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'REAL-TIME',
                            style: tt.labelSmall?.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.4),
                              letterSpacing: 1,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              Text(
                'Precision Calorie\nMapping',
                style: tt.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "Our AI doesn't just estimate; it calculates your metabolic burn and nutrient absorption in real-time.",
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
