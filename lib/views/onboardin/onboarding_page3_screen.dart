import 'package:flutter/material.dart';

class Page3 extends StatelessWidget {
  final bool isDark;
  final Color primary;
  final Color secondary;
  final Animation<Offset> slideAnim;
  final Animation<double> fadeAnim;

  const Page3({
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

              // ── Coach visual ──────────────────────────────────────────────
              SizedBox(
                height: 280,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // Glow background
                    Positioned(
                      top: 0,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              primary.withValues(alpha: 0.15),
                              secondary.withValues(alpha: 0.08),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Coach icon blob
                    Positioned(
                      top: 20,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(26),
                              gradient: LinearGradient(
                                colors: [primary, secondary],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Icon(
                              Icons.eco_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          // Sparkles
                          Positioned(
                            top: -8,
                            right: -8,
                            child: Icon(
                              Icons.auto_awesome,
                              color: primary,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Chat bubble card
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1A2236)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // THE ORACLE label
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: primary,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'THE ORACLE',
                                  style: tt.labelSmall?.copyWith(
                                    color: primary,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Quote with highlighted text
                            RichText(
                              text: TextSpan(
                                style: tt.bodyMedium?.copyWith(height: 1.5),
                                children: [
                                  const TextSpan(
                                    text:
                                        '"Based on your recent activity, try to ',
                                  ),
                                  TextSpan(
                                    text: 'increase protein by 10%',
                                    style: TextStyle(
                                      color: primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: ' today to optimize recovery."',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // Title with "Oracle" highlighted
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: tt.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    const TextSpan(text: 'Digital '),
                    TextSpan(
                      text: 'Oracle ',
                      style: TextStyle(color: primary),
                    ),
                    const TextSpan(text: 'Coaching'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Receive real-time, personalized guidance tailored to your unique metabolic needs and goals.',
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
