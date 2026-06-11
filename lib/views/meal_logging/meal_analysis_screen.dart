import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/meal_controller.dart';

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
                    _HealthScoreCard(score: 85),

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
                    _NutrientSection(
                      title: 'Vitamins',
                      items: const [
                        _NutrientItem(
                          name: 'Vitamin A',
                          percent: 0.85,
                          label: '85%',
                        ),
                        _NutrientItem(
                          name: 'Vitamin C',
                          percent: 0.42,
                          label: '42%',
                        ),
                        _NutrientItem(
                          name: 'Vitamin K',
                          percent: 1.0,
                          label: '100%+',
                        ),
                      ],
                      color: colors.primary,
                    ),

                    const SizedBox(height: 24),

                    // ── Minerals ──────────────────────────────────────────
                    _NutrientSection(
                      title: 'Minerals',
                      items: const [
                        _NutrientItem(
                          name: 'Iron',
                          percent: 0.28,
                          label: '28%',
                        ),
                        _NutrientItem(
                          name: 'Magnesium',
                          percent: 0.55,
                          label: '55%',
                        ),
                        _NutrientItem(
                          name: 'Potassium',
                          percent: 0.15,
                          label: '15%',
                        ),
                      ],
                      color: colors.secondary,
                    ),

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
                        onPressed: () => Navigator.pop(context),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

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
                color: colors.secondary,
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
                  color: colors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Optimal Nutrient Density',
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
