import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/meal_plan_controller.dart';
import '../../../controllers/setting_controller.dart';
import '../../../models/meal_plan_model.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 7, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MealPlanController>().loadPlans();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MealPlanController>();
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1629) : const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text('Meal Plan'),
        backgroundColor: isDark ? const Color(0xFF0F1629) : const Color(0xFFF4F4F4),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'Generate with AI',
            onPressed: controller.isGenerating ? null : () => _generatePlan(context),
          ),
        ],
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : controller.isGenerating
              ? const Center(child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Generating meal plan…'),
                  ],
                ))
              : controller.currentPlan == null
              ? _EmptyState(scheme: scheme, tt: tt, onGenerate: () => _generatePlan(context))
              : _buildPlan(controller, scheme, tt),
    );
  }

  Widget _buildPlan(MealPlanController ctrl, ColorScheme scheme, TextTheme tt) {
    final plan = ctrl.currentPlan!;
    return Column(
      children: [
        // Plan header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plan.name, style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w600)),
                  Text(
                    '${plan.days.length} days',
                    style: tt.bodySmall?.copyWith(color: scheme.onSurface.withAlpha(120)),
                  ),
                ],
              ),
              if (plan.days.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _planColor(plan).withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.local_fire_department, size: 14, color: _planColor(plan)),
                      const SizedBox(width: 4),
                      Text(
                        '${_totalCalories(plan)} kcal/day',
                        style: tt.labelSmall?.copyWith(
                          color: _planColor(plan),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // Day tabs
        TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          labelColor: scheme.primary,
          unselectedLabelColor: scheme.onSurface.withAlpha(120),
          indicatorColor: scheme.primary,
          tabs: plan.days.map((d) {
            return Tab(text: MealPlanDay.dayNames[d.dayOfWeek] ?? 'Day ${d.dayOfWeek}');
          }).toList(),
        ),

        // Day content
        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: plan.days.map((day) {
              return _DayView(day: day, scheme: scheme, tt: tt);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Color _planColor(MealPlanModel plan) {
    final total = _totalCalories(plan);
    if (total < 1500) return Colors.orange;
    if (total > 3000) return Colors.red;
    return Colors.green;
  }

  int _totalCalories(MealPlanModel plan) {
    if (plan.days.isEmpty) return 0;
    final dayCals = plan.days.first.meals.fold<int>(0, (sum, m) => sum + m.calories);
    return dayCals;
  }

  void _generatePlan(BuildContext context) async {
    final settings = context.read<SettingController>();
    final ctrl = context.read<MealPlanController>();
    final messenger = ScaffoldMessenger.of(context);
    final prefsCtrl = TextEditingController();

    final preferences = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Generate Meal Plan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'AI will create a 7-day plan based on your nutrition goals.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: prefsCtrl,
              decoration: const InputDecoration(
                hintText: 'Preferences (e.g. vegetarian, high-protein)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, prefsCtrl.text.trim()),
            child: const Text('Generate'),
          ),
        ],
      ),
    );
    prefsCtrl.dispose();
    if (preferences == null) return;
    if (!mounted) return;

    await ctrl.generatePlan(
      settings,
      preferences: preferences.isNotEmpty ? preferences : null,
    );
    if (!mounted) return;
    if (ctrl.error != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(ctrl.error!),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _EmptyState extends StatelessWidget {
  final ColorScheme scheme;
  final TextTheme tt;
  final VoidCallback onGenerate;

  const _EmptyState({
    required this.scheme,
    required this.tt,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_view_week_rounded, size: 64, color: scheme.onSurface.withAlpha(60)),
            const SizedBox(height: 16),
            Text('No meal plan yet', style: tt.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Generate a 7-day meal plan with AI tailored to your nutrition goals.',
              textAlign: TextAlign.center,
              style: tt.bodyMedium?.copyWith(color: scheme.onSurface.withAlpha(120)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onGenerate,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate Plan'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayView extends StatelessWidget {
  final MealPlanDay day;
  final ColorScheme scheme;
  final TextTheme tt;

  const _DayView({
    required this.day,
    required this.scheme,
    required this.tt,
  });

  @override
  Widget build(BuildContext context) {
    final totalCals = day.meals.fold<int>(0, (sum, m) => sum + m.calories);
    final totalProtein = day.meals.fold<double>(0, (sum, m) => sum + m.protein);
    final totalCarbs = day.meals.fold<double>(0, (sum, m) => sum + m.carbs);
    final totalFat = day.meals.fold<double>(0, (sum, m) => sum + m.fat);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Daily totals
          Row(
            children: [
              _totalBadge(context, Icons.local_fire_department, '${totalCals}kcal', Colors.orange),
              const SizedBox(width: 8),
              _totalBadge(context, Icons.fitness_center, '${totalProtein.toStringAsFixed(0)}g P', scheme.primary),
              const SizedBox(width: 8),
              _totalBadge(context, Icons.grain, '${totalCarbs.toStringAsFixed(0)}g C', Colors.blue),
              const SizedBox(width: 8),
              _totalBadge(context, Icons.water_drop, '${totalFat.toStringAsFixed(0)}g F', Colors.green),
            ],
          ),
          const SizedBox(height: 20),

          // Meals grouped by type
          if (day.meals.where((m) => m.mealType == 'breakfast').isNotEmpty) ...[
            _mealTypeHeader(Icons.free_breakfast, 'Breakfast'),
            ...day.meals.where((m) => m.mealType == 'breakfast').map((m) => _MealCard(m: m, scheme: scheme, tt: tt)),
          ],
          if (day.meals.where((m) => m.mealType == 'lunch').isNotEmpty) ...[
            const SizedBox(height: 12),
            _mealTypeHeader(Icons.lunch_dining, 'Lunch'),
            ...day.meals.where((m) => m.mealType == 'lunch').map((m) => _MealCard(m: m, scheme: scheme, tt: tt)),
          ],
          if (day.meals.where((m) => m.mealType == 'dinner').isNotEmpty) ...[
            const SizedBox(height: 12),
            _mealTypeHeader(Icons.dinner_dining, 'Dinner'),
            ...day.meals.where((m) => m.mealType == 'dinner').map((m) => _MealCard(m: m, scheme: scheme, tt: tt)),
          ],
          if (day.meals.where((m) => m.mealType == 'snack').isNotEmpty) ...[
            const SizedBox(height: 12),
            _mealTypeHeader(Icons.cookie, 'Snacks'),
            ...day.meals.where((m) => m.mealType == 'snack').map((m) => _MealCard(m: m, scheme: scheme, tt: tt)),
          ],
        ],
      ),
    );
  }

  Widget _totalBadge(BuildContext context, IconData icon, String label, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tt = Theme.of(context).textTheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2236) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? const Color(0xFF2A2A3E) : Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 2),
            Text(label, style: tt.labelSmall?.copyWith(fontWeight: FontWeight.w600, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _mealTypeHeader(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: scheme.onSurface.withAlpha(120)),
          const SizedBox(width: 6),
          Text(label, style: tt.labelSmall?.copyWith(
            color: scheme.onSurface.withAlpha(120),
            letterSpacing: 1.2,
          )),
        ],
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final PlannedMeal m;
  final ColorScheme scheme;
  final TextTheme tt;

  const _MealCard({
    required this.m,
    required this.scheme,
    required this.tt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.name, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  '${m.calories} kcal · P:${m.protein.toStringAsFixed(0)}g C:${m.carbs.toStringAsFixed(0)}g F:${m.fat.toStringAsFixed(0)}g',
                  style: tt.labelSmall?.copyWith(color: scheme.onSurface.withAlpha(120)),
                ),
              ],
            ),
          ),
          if (m.recipeId != null)
            Icon(Icons.link, size: 16, color: scheme.primary.withAlpha(120)),
        ],
      ),
    );
  }
}
