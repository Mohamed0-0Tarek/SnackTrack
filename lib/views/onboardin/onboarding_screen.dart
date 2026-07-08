import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snacktrack/views/onboardin/onboarding_page1_screen.dart';
import 'package:snacktrack/views/onboardin/onboarding_page2_screen.dart';
import 'package:snacktrack/views/onboardin/onboarding_page3_screen.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  // Slide-in animation for content
  late final AnimationController _slideCtrl;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));

    _fadeAnim = CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < 2) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      context.go(AppRoutes.signIn);
    }
  }

  void _back() {
    if (_currentPage > 0) {
      _pageCtrl.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skip() => context.go(AppRoutes.signIn);

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _slideCtrl
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? CyberCortexColors.primary : LuminaColors.primary;
    final second = isDark
        ? CyberCortexColors.secondary
        : LuminaColors.secondary;
    final bgColor = isDark
        ? CyberCortexColors.background
        : const Color(0xFFEFF2F7);
    final tt = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back arrow (hidden on first page)
                  SizedBox(
                    width: 40,
                    child: _currentPage > 0
                        ? GestureDetector(
                            onTap: _back,
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: scheme.onSurface,
                              size: 22,
                            ),
                          )
                        : null,
                  ),

                  // Page counter
                  Text(
                    '${_currentPage + 1} OF 3',
                    style: tt.labelMedium?.copyWith(
                      color: primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),

                  // Skip
                  GestureDetector(
                    onTap: _skip,
                    child: SizedBox(
                      width: 40,
                      child: Text(
                        'Skip',
                        textAlign: TextAlign.end,
                        style: tt.bodyMedium?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Dot indicators ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  final isActive = i <= _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 64,
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: isActive
                          ? LinearGradient(colors: [primary, second])
                          : null,
                      color: isActive
                          ? null
                          : scheme.onSurface.withValues(alpha: 0.15),
                    ),
                  );
                }),
              ),
            ),

            // ── Pages ────────────────────────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                onPageChanged: _onPageChanged,
                children: [
                  Page1(
                    isDark: isDark,
                    primary: primary,
                    secondary: second,
                    slideAnim: _slideAnim,
                    fadeAnim: _fadeAnim,
                  ),
                  Page2(
                    isDark: isDark,
                    primary: primary,
                    secondary: second,
                    slideAnim: _slideAnim,
                    fadeAnim: _fadeAnim,
                  ),
                  Page3(
                    isDark: isDark,
                    primary: primary,
                    secondary: second,
                    slideAnim: _slideAnim,
                    fadeAnim: _fadeAnim,
                  ),
                ],
              ),
            ),

            // ── Continue / Get Started button ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: GestureDetector(
                onTap: _next,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [primary, second],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentPage == 2 ? 'Get Started' : 'Continue',
                        style: tt.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
