import 'package:flutter/material.dart';
import '../../../models/meal_model.dart';

class MealCard extends StatelessWidget {
  final MealModel meal;
  final String? imagePath; // e.g. 'assets/images/grilled_salmon_avocado.jpg'

  const MealCard({super.key, required this.meal, this.imagePath});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Meal image ───────────────────────────────────────────────────
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: imagePath != null
                ? Image.asset(
                    imagePath!,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imagePlaceholder(colors),
                  )
                : _imagePlaceholder(colors),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Name + time ──────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        meal.name,
                        style: theme.textTheme.headlineMedium,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _formatTime(meal.loggedAt),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // ── Meal type ────────────────────────────────────────────
                Text(
                  'Lunch • Restaurant',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),

                const SizedBox(height: 12),

                // ── Macro chips ──────────────────────────────────────────
                Row(
                  children: [
                    _MacroChip(label: 'CALS', value: '${meal.calories}'),
                    const SizedBox(width: 8),
                    _MacroChip(
                      label: 'PROTEIN',
                      value: '${meal.protein.toInt()}g',
                      color: colors.secondary,
                    ),
                    const SizedBox(width: 8),
                    _MacroChip(
                      label: 'CARBS',
                      value: '${meal.carbs.toInt()}g',
                      color: colors.tertiary,
                    ),
                    const SizedBox(width: 8),
                    _MacroChip(
                      label: 'FATS',
                      value: '${meal.fat.toInt()}g',
                      color: Colors.redAccent,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder(ColorScheme colors) {
    return Container(
      width: double.infinity,
      height: 180,
      color: colors.primary.withOpacity(0.08),
      child: Icon(
        Icons.restaurant_menu_rounded,
        color: colors.primary.withOpacity(0.3),
        size: 48,
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12
        ? dt.hour - 12
        : dt.hour == 0
        ? 12
        : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final pm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $pm';
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _MacroChip({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.dividerColor, width: 1),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.hintColor,
                fontSize: 9,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: theme.textTheme.labelLarge?.copyWith(
                color: color ?? colors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
