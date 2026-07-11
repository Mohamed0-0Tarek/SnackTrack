import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/meal_controller.dart';
import '../../controllers/setting_controller.dart';
import '../../models/meal_model.dart';

class MealAnalysisScreen extends StatelessWidget {
  const MealAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MealController>();
    final meal = controller.analyzedMeal;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (meal == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
}

void showPortionAdjuster(BuildContext context, MealController controller) {
  final meal = controller.analyzedMeal;
  if (meal == null) return;

  final factorCtrl = TextEditingController(text: '1.0');
  final theme = Theme.of(context);
  final colors = theme.colorScheme;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: theme.cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 24,
        bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Adjust Portions', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Enter a portion multiplier (e.g. 0.5 for half, 2.0 for double)',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: factorCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Portion factor',
              hintText: '1.0',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Calories: ${(meal.calories * 1.0).toInt()} → ${(meal.calories * (double.tryParse(factorCtrl.text) ?? 1.0)).toInt()} kcal',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final factor = double.tryParse(factorCtrl.text) ?? 1.0;
                if (factor <= 0) return;
                final adjusted = MealModel(
                  id: meal.id,
                  name: meal.name,
                  type: meal.type,
                  calories: (meal.calories * factor).round(),
                  protein: meal.protein * factor,
                  carbs: meal.carbs * factor,
                  fat: meal.fat * factor,
                  loggedAt: meal.loggedAt,
                  imageUrl: meal.imageUrl,
                  source: meal.source,
                  notes: meal.notes,
                  analyzedBy: meal.analyzedBy,
                );
                controller.updateAnalyzedMeal(adjusted);
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Apply Adjustment'),
            ),
          ),
        ],
      ),
    ),
  );
}

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Hero image ───────────────────────────────────────────────
              _HeroSection(mealName: meal.name),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // ── Health score card ─────────────────────────────────
                    _HealthScoreCard(
                      score: _computeHealthScore(
                        meal,
                        context.watch<SettingController>(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Macronutrients ────────────────────────────────────
                    _SectionTitle(
                      icon: Icons.bar_chart_rounded,
                      title: 'Macronutrients',
                    ),
                    const SizedBox(height: 12),
                    _MacroGrid(meal: meal),

                    const SizedBox(height: 24),

                    // ── Vitamins ──────────────────────────────────────────
                    if (meal.vitamins != null && meal.vitamins!.isNotEmpty)
                      _NutrientSection(
                        title: 'Vitamins',
                        items: meal.vitamins!.entries.map((e) {
                          final pct = (e.value * 100).round();
                          return _NutrientItem(
                            name: e.key,
                            percent: e.value,
                            label: '$pct%',
                          );
                        }).toList(),
                        color: colors.primary,
                      )
                    else ...[
                      _SectionTitle(
                        icon: Icons.eco,
                        title: 'Vitamins',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No micronutrient data available. Try re-analyzing with a more detailed description.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // ── Minerals ──────────────────────────────────────────
                    if (meal.minerals != null && meal.minerals!.isNotEmpty)
                      _NutrientSection(
                        title: 'Minerals',
                        items: meal.minerals!.entries.map((e) {
                          final pct = (e.value * 100).round();
                          return _NutrientItem(
                            name: e.key,
                            percent: e.value,
                            label: '$pct%',
                          );
                        }).toList(),
                        color: colors.secondary,
                      )
                    else ...[
                      _SectionTitle(
                        icon: Icons.grain,
                        title: 'Minerals',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No micronutrient data available. Try re-analyzing with a more detailed description.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // ── Log to Diary button ───────────────────────────────
                    _LogButton(
                      isLoading: controller.isLoading,
                      onTap: () async {
                        await controller.saveMeal();
                        if (context.mounted) Navigator.pop(context);
                      },
                    ),

                    const SizedBox(height: 12),

                    // ── Adjust Portions ───────────────────────────────────
                    Center(
                      child: TextButton(
                        onPressed: () => showPortionAdjuster(context, controller),
                        child: Text(
                          'Adjust Portions',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor,
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
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero Section
// ─────────────────────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  final String mealName;
  const _HeroSection({required this.mealName});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Stack(
      children: [
        // Background image placeholder
        Container(
          width: double.infinity,
          height: 200,
          color: Colors.black87,
          child: Icon(
            Icons.restaurant_menu_rounded,
            color: Colors.white24,
            size: 64,
          ),
        ),
        // Gradient overlay
        Container(
          width: double.infinity,
          height: 200,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black87],
            ),
          ),
        ),
        // Text overlay
        Positioned(
          left: 20,
          bottom: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ANALYSIS COMPLETE',
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                mealName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Health Score Card
// ─────────────────────────────────────────────────────────────────────────────
class _HealthScoreCard extends StatelessWidget {
  final int score;
  const _HealthScoreCard({required this.score});

  Color _ringColor() {
    if (score >= 80) return const Color(0xFF00E676);
    if (score >= 60) return const Color(0xFFFFC107);
    if (score >= 40) return const Color(0xFFFF9800);
    return const Color(0xFFE53935);
  }

  String _label() {
    if (score >= 80) return 'Well-balanced meal';
    if (score >= 60) return 'Moderate balance';
    if (score >= 40) return 'Needs adjustment';
    return 'Highly unbalanced';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ringColor = _ringColor();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor, width: 1),
      ),
      child: Column(
        children: [
          // Circle score
          SizedBox(
            width: 140,
            height: 140,
            child: CustomPaint(
              painter: _ScoreRingPainter(
                score: score / 100,
                color: ringColor,
                trackColor: theme.dividerColor,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$score',
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'HEALTH SCORE',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.hintColor,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: ringColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _label(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Score Ring Painter
// ─────────────────────────────────────────────────────────────────────────────
class _ScoreRingPainter extends CustomPainter {
  final double score;
  final Color color;
  final Color trackColor;

  _ScoreRingPainter({
    required this.score,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const stroke = 10.0;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );

    // Progress
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * score,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ScoreRingPainter old) => old.score != score;
}

// ─────────────────────────────────────────────────────────────────────────────
// Macro Grid
// ─────────────────────────────────────────────────────────────────────────────
class _MacroGrid extends StatelessWidget {
  final dynamic meal;
  const _MacroGrid({required this.meal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _MacroTile(
          label: 'CALORIES',
          value: '${meal.calories}',
          unit: 'kcal',
          percent: 0.6,
          color: colors.primary,
        ),
        _MacroTile(
          label: 'PROTEIN',
          value: '${meal.protein.toInt()}',
          unit: 'g',
          percent: 0.4,
          color: colors.secondary,
        ),
        _MacroTile(
          label: 'CARBS',
          value: '${meal.carbs.toInt()}',
          unit: 'g',
          percent: 0.7,
          color: colors.tertiary,
        ),
        _MacroTile(
          label: 'FATS',
          value: '${meal.fat.toInt()}',
          unit: 'g',
          percent: 0.3,
          color: colors.secondary,
        ),
      ],
    );
  }
}

class _MacroTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final double percent;
  final Color color;

  const _MacroTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.hintColor,
              letterSpacing: 1,
              fontSize: 10,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: theme.textTheme.displayMedium?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 3),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unit,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ),
            ],
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: theme.dividerColor,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Nutrient Section (Vitamins / Minerals)
// ─────────────────────────────────────────────────────────────────────────────
class _NutrientSection extends StatelessWidget {
  final String title;
  final List<_NutrientItem> items;
  final Color color;

  const _NutrientSection({
    required this.title,
    required this.items,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: theme.textTheme.headlineMedium),
            Text(
              '% OF DAILY VALUE',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.hintColor,
                letterSpacing: 1,
                fontSize: 9,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                SizedBox(
                  width: 90,
                  child: Text(item.name, style: theme.textTheme.bodyMedium),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: item.percent.clamp(0.0, 1.0),
                      backgroundColor: theme.dividerColor,
                      valueColor: AlwaysStoppedAnimation(color),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 40,
                  child: Text(
                    item.label,
                    style: theme.textTheme.labelMedium,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NutrientItem {
  final String name;
  final double percent;
  final String label;
  const _NutrientItem({
    required this.name,
    required this.percent,
    required this.label,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Title
// ─────────────────────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 20),
        const SizedBox(width: 8),
        Text(title, style: theme.textTheme.headlineMedium),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Log Button
// ─────────────────────────────────────────────────────────────────────────────
class _LogButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;
  const _LogButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.primary, colors.secondary],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: isLoading
            ? const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Log to Diary',
                    style: text.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Health Score Computation
// ─────────────────────────────────────────────────────────────────────────────

/// Computes a 0-100 health score based on how well a single meal's macros
/// align with 1/3 of the user's daily goals (breakfast/lunch/dinner split).
/// Higher scores mean the meal is well-proportioned relative to the goals.
int _computeHealthScore(MealModel meal, SettingController settings) {
  if (settings.goalCalories <= 0) return 50;

  double component(double actual, double expected) {
    if (expected <= 0) return 100;
    return max(0, 100 - ((actual - expected).abs() / expected) * 100);
  }

  final expectedCal = settings.goalCalories / 3;
  final expectedProtein = settings.goalProtein / 3;
  final expectedCarbs = settings.goalCarbs / 3;
  final expectedFat = settings.goalFat / 3;

  final calScore = component(meal.calories.toDouble(), expectedCal);
  final proteinScore = component(meal.protein, expectedProtein);
  final carbsScore = component(meal.carbs, expectedCarbs);
  final fatScore = component(meal.fat, expectedFat);

  return ((calScore + proteinScore + carbsScore + fatScore) / 4).round();
}
