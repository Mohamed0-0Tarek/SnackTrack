import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../controllers/recipe_controller.dart';
import '../../../core/constants/app_routes.dart';
import '../../../models/recipe_model.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String recipeId;
  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  RecipeModel? _recipe;
  final _checkedIngredients = <int>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRecipe();
    });
  }

  void _loadRecipe() {
    final controller = context.read<RecipeController>();
    final recipe = controller.recipes.where((r) => r.id == widget.recipeId).firstOrNull;
    if (recipe != null) {
      setState(() => _recipe = recipe);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RecipeController>();
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_recipe == null) {
      // Try to find it in case the controller updated
      final found = controller.recipes.where((r) => r.id == widget.recipeId).firstOrNull;
      if (found != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => setState(() => _recipe = found));
      }
    }

    final recipe = _recipe;
    if (recipe == null) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F1629) : const Color(0xFFF4F4F4),
        appBar: AppBar(title: const Text('Recipe')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1629) : const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: Text(recipe.name),
        backgroundColor: isDark ? const Color(0xFF0F1629) : const Color(0xFFF4F4F4),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              await context.push(
                '${AppRoutes.recipeCreate}?edit=${recipe.id}',
                extra: recipe,
              );
              _loadRecipe();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outlined),
            color: Colors.red,
            onPressed: () => _delete(context, controller, recipe),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: scheme.primary.withAlpha(15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(Icons.restaurant_menu_rounded, size: 64, color: scheme.primary.withAlpha(80)),
              ),
            ),
            const SizedBox(height: 16),

            // Name
            Text(recipe.name, style: tt.headlineLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),

            // Stats
            Row(
              children: [
                _statChip(icon: Icons.local_fire_department, label: '${recipe.calories}', sublabel: 'kcal', color: Colors.orange),
                const SizedBox(width: 8),
                _statChip(icon: Icons.fitness_center, label: '${recipe.protein.toStringAsFixed(0)}g', sublabel: 'protein', color: scheme.primary),
                const SizedBox(width: 8),
                _statChip(icon: Icons.grain, label: '${recipe.carbs.toStringAsFixed(0)}g', sublabel: 'carbs', color: Colors.blue),
                const SizedBox(width: 8),
                _statChip(icon: Icons.water_drop, label: '${recipe.fat.toStringAsFixed(0)}g', sublabel: 'fat', color: Colors.green),
              ],
            ),
            const SizedBox(height: 12),

            // Servings + Prep time
            Row(
              children: [
                _infoChip(Icons.people_outline, '${recipe.servings} servings'),
                const SizedBox(width: 12),
                if (recipe.prepTime != null)
                  _infoChip(Icons.timer_outlined, '${recipe.prepTime} min'),
              ],
            ),
            const SizedBox(height: 24),

            // Ingredients
            Text('INGREDIENTS', style: tt.labelSmall?.copyWith(
              color: scheme.onSurface.withAlpha(100),
              letterSpacing: 1.5,
            )),
            const SizedBox(height: 10),
            ...recipe.ingredients.asMap().entries.map((entry) {
              final i = entry.key;
              final checked = _checkedIngredients.contains(i);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (checked) {
                      _checkedIngredients.remove(i);
                    } else {
                      _checkedIngredients.add(i);
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Icon(
                        checked ? Icons.check_box : Icons.check_box_outline_blank,
                        size: 22,
                        color: checked ? scheme.primary : scheme.onSurface.withAlpha(80),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        entry.value,
                        style: tt.bodyMedium?.copyWith(
                          decoration: checked ? TextDecoration.lineThrough : null,
                          color: checked ? scheme.onSurface.withAlpha(80) : null,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),

            // Steps
            Text('STEPS', style: tt.labelSmall?.copyWith(
              color: scheme.onSurface.withAlpha(100),
              letterSpacing: 1.5,
            )),
            const SizedBox(height: 10),
            ...recipe.steps.asMap().entries.map((entry) {
              final i = entry.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24, height: 24,
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text('${i + 1}', style: TextStyle(color: scheme.onPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(entry.value, style: tt.bodyMedium),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _statChip({
    required IconData icon,
    required String label,
    required String sublabel,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            Text(sublabel, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 9)),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: scheme.onSurface.withAlpha(100)),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  void _delete(BuildContext context, RecipeController controller, RecipeModel recipe) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Recipe'),
        content: Text('Delete "${recipe.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await controller.deleteRecipe(recipe.id);
      if (!context.mounted) return;
      Navigator.pop(context);
    }
  }
}
