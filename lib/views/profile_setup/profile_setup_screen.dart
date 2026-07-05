import 'package:flutter/material.dart';
import 'package:health_assistant/views/profile_setup/widgets/data_slider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../services/storage_service.dart';
import '../../controllers/profile_controller.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  int    _selectedGoal = 0; // 0=Weight loss, 1=Muscle gain, 2=Maintenance
  double _age          = 28;
  double _weight       = 74.5;
  double _height       = 182;

  final List<Map<String, dynamic>> _goals = [
    {
      'icon':     Icons.trending_down_rounded,
      'title':    'Weight loss',
      'subtitle': 'Aggressive fat oxidation with muscle preservation protocols.',
    },
    {
      'icon':     Icons.fitness_center_rounded,
      'title':    'Muscle gain',
      'subtitle': 'Hypertrophy-focused nutrient partitioning and surplus tracking.',
    },
    {
      'icon':     Icons.balance_rounded,
      'title':    'Maintenance',
      'subtitle': 'Sustainable metabolic equilibrium for long-term health.',
    },
  ];

  String get _aiInsight {
    if (_weight > 80 && _selectedGoal == 0) {
      return 'AI INSIGHT: Your stats suggest a caloric deficit of 400–500 kcal/day for optimal fat loss without muscle breakdown.';
    } else if (_selectedGoal == 1) {
      return 'AI INSIGHT: These stats indicate a highly active metabolism. We recommend a high-protein baseline of ${(_weight * 1.8).toStringAsFixed(0)}g/day.';
    } else if (_selectedGoal == 2) {
      return 'AI INSIGHT: These stats indicate a highly active metabolism. We recommend a high-protein baseline.';
    }
    return 'AI INSIGHT: These stats indicate a highly active metabolism. We recommend a high-protein baseline.';
  }

  Future<void> _submit() async {
    final controller = context.read<ProfileController>();
    final currentUser = StorageService.getUser() ?? controller.profile;

    if (currentUser != null) {
      await StorageService.saveUser(currentUser.copyWith(
        age: _age.round(),
        weight: _weight,
        height: _height.round().toDouble(),
        objective: _goals[_selectedGoal]['title'] as String,
      ));
    }

    if (!mounted) return;

    await controller.loadProfile();
    if (!mounted) return;
    context.go(AppRoutes.main);
  }

  void _skip() async {
    if (mounted) context.go(AppRoutes.main);
  }

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? CyberCortexColors.primary   : LuminaColors.primary;
    final second  = isDark ? CyberCortexColors.secondary : LuminaColors.secondary;
    final bgColor = isDark ? CyberCortexColors.background: const Color(0xFFEFF2F7);
    final tt      = Theme.of(context).textTheme;
    final scheme  = Theme.of(context).colorScheme;

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
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Snake',
                          style: tt.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface,
                          ),
                        ),
                        TextSpan(
                          text: 'Track',
                          style: tt.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            foreground: Paint()
                              ..shader = LinearGradient(
                                colors: [primary, second],
                              ).createShader(
                                const Rect.fromLTWH(0, 0, 80, 20),
                              ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'STEP 02 OF 04',
                    style: tt.labelSmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.4),
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            // ── Progress bar ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: List.generate(4, (i) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 4),
                    height: 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: i < 2
                          ? LinearGradient(colors: [primary, second])
                          : null,
                      color: i >= 2
                          ? scheme.onSurface.withValues(alpha: 0.15)
                          : null,
                    ),
                  ),
                )),
              ),
            ),

            // ── Scrollable content ───────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 24),
                children: [

                  // ── Heading ────────────────────────────────────────────────
                  Text(
                    'Define Your',
                    style: tt.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Trajectory',
                    style: tt.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..shader = LinearGradient(
                          colors: [primary, second],
                        ).createShader(
                          const Rect.fromLTWH(0, 0, 220, 60),
                        ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Our AI Oracle requires your physiological coordinates to calculate the optimal metabolic path.',
                    style: tt.bodyMedium?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.5),
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Goal selector ──────────────────────────────────────────
                  Text(
                    'Select Primary Objective',
                    style: tt.bodyLarge?.copyWith(
                      color: primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),

                  ..._goals.asMap().entries.map((e) {
                    final i      = e.key;
                    final goal   = e.value;
                    final active = _selectedGoal == i;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedGoal = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1A2236)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border(
                            left: BorderSide(
                              color: active ? primary : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          boxShadow: active
                              ? [
                                  BoxShadow(
                                    color: primary.withValues(alpha: 0.15),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            // Icon
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                color: active
                                    ? primary.withValues(alpha: 0.15)
                                    : scheme.onSurface.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                goal['icon'] as IconData,
                                color: active
                                    ? primary
                                    : scheme.onSurface.withValues(alpha: 0.4),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Text
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    goal['title'] as String,
                                    style: tt.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: active
                                          ? scheme.onSurface
                                          : scheme.onSurface.withValues(alpha: 0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    goal['subtitle'] as String,
                                    style: tt.bodySmall?.copyWith(
                                      color: scheme.onSurface.withValues(alpha: 0.45),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Radio
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 20, height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: active
                                      ? primary
                                      : scheme.onSurface.withValues(alpha: 0.25),
                                  width: 2,
                                ),
                                color: active
                                    ? primary
                                    : Colors.transparent,
                              ),
                              child: active
                                  ? const Icon(Icons.check,
                                      color: Colors.white, size: 12)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 28),

                  // ── Physiological Data ─────────────────────────────────────
                  Text(
                    'Physiological Data',
                    style: tt.bodyLarge?.copyWith(
                      color: primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Age slider
                  DataSlider(
                    label:    'AGE',
                    value:    _age,
                    min:      10, max: 80,
                    unit:     'YRS',
                    primary:  primary,
                    scheme:   scheme,
                    tt:       tt,
                    isDark:   isDark,
                    onChanged: (v) => setState(() => _age = v),
                    displayValue: _age.round().toString(),
                  ),
                  const SizedBox(height: 20),

                  // Weight slider
                  DataSlider(
                    label:    'CURRENT WEIGHT',
                    value:    _weight,
                    min:      30, max: 200,
                    unit:     'KG',
                    primary:  primary,
                    scheme:   scheme,
                    tt:       tt,
                    isDark:   isDark,
                    onChanged: (v) =>
                        setState(() => _weight = double.parse(v.toStringAsFixed(1))),
                    displayValue: _weight.toStringAsFixed(1),
                  ),
                  const SizedBox(height: 20),

                  // Height slider
                  DataSlider(
                    label:    'HEIGHT',
                    value:    _height,
                    min:      120, max: 230,
                    unit:     'CM',
                    primary:  primary,
                    scheme:   scheme,
                    tt:       tt,
                    isDark:   isDark,
                    onChanged: (v) => setState(() => _height = v),
                    displayValue: _height.round().toString(),
                  ),

                  const SizedBox(height: 20),

                  // ── AI Insight box ─────────────────────────────────────────
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1A2236)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 30, height: 30,
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.psychology_outlined,
                              color: primary, size: 16),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: tt.bodySmall?.copyWith(
                                height: 1.5,
                                color: scheme.onSurface.withValues(alpha: 0.7),
                              ),
                              children: [
                                TextSpan(
                                  text: 'AI INSIGHT: ',
                                  style: TextStyle(
                                    color: primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: _aiInsight.replaceFirst(
                                      'AI INSIGHT: ', ''),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Submit button ──────────────────────────────────────────
                  GestureDetector(
                    onTap: _submit,
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [primary, second],
                          begin:  Alignment.centerLeft,
                          end:    Alignment.centerRight,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Synchronize Profile',
                            style: tt.labelLarge?.copyWith(
                              color:      Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize:   16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded,
                              color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Skip
                  Center(
                    child: GestureDetector(
                      onTap: _skip,
                      child: Text(
                        'SKIP FOR NOW',
                        style: tt.labelSmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.35),
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}