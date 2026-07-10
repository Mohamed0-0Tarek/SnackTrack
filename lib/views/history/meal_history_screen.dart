import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/history_controller.dart';
import '../../controllers/meal_controller.dart' hide HistoryFilter;
import '../../models/daily_summary_model.dart';
import '../../models/meal_model.dart';
import 'widgets/meal_card.dart';

/// ## What changed in this file
/// Removed `_mealImages` / `_imageFor()` — that lookup only matched the
/// three hardcoded dummy-data meal names ('grilled salmon & avocado',
/// etc.). Real meals now come from Gemini-generated names via
/// HistoryController's live Firestore path, so the map would almost
/// never hit. `MealCard` already renders a placeholder icon when
/// `imagePath` is null, so this is a clean removal — no behavior change
/// for real data, just deleting a lookup that no longer does anything
/// useful.
class MealHistoryScreen extends StatefulWidget {
  const MealHistoryScreen({super.key});

  @override
  State<MealHistoryScreen> createState() => _MealHistoryScreenState();
}

class _MealHistoryScreenState extends State<MealHistoryScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryController>().loadHistory();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HistoryController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // ── Search ──────────────────────────────────────────────
                  TextField(
                    controller: _searchCtrl,
                    onChanged: controller.setSearch,
                    decoration: InputDecoration(
                      hintText: 'Search your meals...',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.hintColor,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: theme.hintColor,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: theme.cardColor,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Filter chips + date picker ───────────────────────────
                  Row(
                    children: [
                      _FilterChip(
                        label: 'Today',
                        selected: controller.filter == HistoryFilter.today,
                        onTap: () => controller.setFilter(HistoryFilter.today),
                      ),
                      const SizedBox(width: 10),
                      _FilterChip(
                        label: 'Week',
                        selected: controller.filter == HistoryFilter.week,
                        onTap: () => controller.setFilter(HistoryFilter.week),
                      ),
                      const SizedBox(width: 10),
                      _FilterChip(
                        label: 'Month',
                        selected: controller.filter == HistoryFilter.month,
                        onTap: () => controller.setFilter(HistoryFilter.month),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2024),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            // NOTE: real date-range filtering by the
                            // exact picked date isn't implemented yet —
                            // this still only resets to the Today filter.
                            // Leaving as a known gap rather than expanding
                            // scope in this change.
                            controller.setFilter(HistoryFilter.today);
                          }
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: theme.dividerColor,
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.tune_rounded,
                            color: theme.hintColor,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── List ──────────────────────────────────────────────────────
            Expanded(
              child: controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : controller.error != null
                  ? _buildError(theme, controller)
                  : controller.filtered.isEmpty
                  ? _buildEmpty(theme)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: controller.filtered.length,
                      itemBuilder: (_, i) =>
                          _buildDaySection(controller.filtered[i], theme),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySection(DailySummaryModel summary, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(summary.dateLabel, style: theme.textTheme.headlineLarge),
            Text(
              '${summary.totalCalories} kcal total',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...summary.meals.map((meal) => MealCard(
          meal: meal,
          onEdit: () => _showEditSheet(context, meal),
          onDelete: () => _confirmDelete(context, meal),
        )),
        const SizedBox(height: 8),
      ],
    );
  }

  void _confirmDelete(BuildContext context, MealModel meal) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Meal'),
        content: Text('Remove "${meal.name}" from your history?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<MealController>().deleteMeal(meal.id);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red.shade400)),
          ),
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context, MealModel meal) {
    final nameCtrl = TextEditingController(text: meal.name);
    final calCtrl = TextEditingController(text: meal.calories.toString());
    final proteinCtrl = TextEditingController(text: meal.protein.toStringAsFixed(0));
    final carbsCtrl = TextEditingController(text: meal.carbs.toStringAsFixed(0));
    final fatCtrl = TextEditingController(text: meal.fat.toStringAsFixed(0));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Meal', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),),
              const SizedBox(height: 12),
              TextField(controller: calCtrl, decoration: const InputDecoration(labelText: 'Calories', border: OutlineInputBorder()), keyboardType: TextInputType.number,),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextField(controller: proteinCtrl, decoration: const InputDecoration(labelText: 'Protein (g)', border: OutlineInputBorder()), keyboardType: TextInputType.number,)),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: carbsCtrl, decoration: const InputDecoration(labelText: 'Carbs (g)', border: OutlineInputBorder()), keyboardType: TextInputType.number,)),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: fatCtrl, decoration: const InputDecoration(labelText: 'Fat (g)', border: OutlineInputBorder()), keyboardType: TextInputType.number,)),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final updated = MealModel(
                      id: meal.id,
                      name: nameCtrl.text.trim().isEmpty ? meal.name : nameCtrl.text.trim(),
                      type: meal.type,
                      calories: int.tryParse(calCtrl.text) ?? meal.calories,
                      protein: double.tryParse(proteinCtrl.text) ?? meal.protein,
                      carbs: double.tryParse(carbsCtrl.text) ?? meal.carbs,
                      fat: double.tryParse(fatCtrl.text) ?? meal.fat,
                      loggedAt: meal.loggedAt,
                      imageUrl: meal.imageUrl,
                      source: meal.source,
                      notes: meal.notes,
                      analyzedBy: meal.analyzedBy,
                    );
                    context.read<MealController>().updateMeal(updated);
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu_outlined,
            size: 64,
            color: theme.hintColor.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No meals found',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.hintColor,
            ),
          ),
          const SizedBox(height: 8),
          Text('Start logging your meals!', style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildError(ThemeData theme, HistoryController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: theme.colorScheme.error.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            controller.error!,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => controller.loadHistory(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// ── Filter chip ───────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? colors.primary : theme.cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? colors.primary : theme.dividerColor,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: selected ? colors.onPrimary : theme.hintColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
