import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/history_controller.dart';
import '../../models/daily_summary_model.dart';
import '../../models/meal_model.dart';
import 'widgets/meal_card.dart';

class MealHistoryScreen extends StatefulWidget {
  const MealHistoryScreen({super.key});

  @override
  State<MealHistoryScreen> createState() => _MealHistoryScreenState();
}

class _MealHistoryScreenState extends State<MealHistoryScreen> {
  final _searchCtrl = TextEditingController();

  static const Map<String, String> _mealImages = {
    'grilled salmon & avocado': 'assets/images/grilled_salmon_avocado.png',
    'berry blast smoothie bowl': 'assets/images/berry_blast_smoothie.png',
    'spicy ahi poke bowl': 'assets/images/spicy_ahi_poke.png',
  };

  String? _imageFor(MealModel meal) => _mealImages[meal.name.toLowerCase()];

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
                            // TODO: فلتر بالتاريخ لما الباك يكون جاهز
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
        ...summary.meals.map(
          (meal) => MealCard(meal: meal, imagePath: _imageFor(meal)),
        ),
        const SizedBox(height: 8),
      ],
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
            color: theme.hintColor.withOpacity(0.4),
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
