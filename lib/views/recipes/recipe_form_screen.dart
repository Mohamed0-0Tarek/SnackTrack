import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/recipe_controller.dart';
import '../../../models/recipe_model.dart';

class RecipeFormScreen extends StatefulWidget {
  final RecipeModel? recipe; // null = create, non-null = edit
  const RecipeFormScreen({super.key, this.recipe});

  @override
  State<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  final _nameCtrl = TextEditingController();
  final _servingsCtrl = TextEditingController();
  final _prepTimeCtrl = TextEditingController();
  final _caloriesCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _carbsCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();

  final _ingredientCtrls = <TextEditingController>[TextEditingController()];
  final _stepCtrls = <TextEditingController>[TextEditingController()];

  bool _isAiAnalyzing = false;

  @override
  void initState() {
    super.initState();
    if (widget.recipe != null) {
      final r = widget.recipe!;
      _nameCtrl.text = r.name;
      _servingsCtrl.text = r.servings.toString();
      _prepTimeCtrl.text = r.prepTime?.toString() ?? '';
      _caloriesCtrl.text = r.calories.toString();
      _proteinCtrl.text = r.protein.toStringAsFixed(0);
      _carbsCtrl.text = r.carbs.toStringAsFixed(0);
      _fatCtrl.text = r.fat.toStringAsFixed(0);
      _ingredientCtrls
        ..clear()
        ..addAll(r.ingredients.map((i) => TextEditingController(text: i)));
      _stepCtrls
        ..clear()
        ..addAll(r.steps.map((s) => TextEditingController(text: s)));
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _servingsCtrl.dispose();
    _prepTimeCtrl.dispose();
    _caloriesCtrl.dispose();
    _proteinCtrl.dispose();
    _carbsCtrl.dispose();
    _fatCtrl.dispose();
    for (final c in _ingredientCtrls) { c.dispose(); }
    for (final c in _stepCtrls) { c.dispose(); }
    super.dispose();
  }

  Future<void> _analyzeWithAi() async {
    final description = _nameCtrl.text.trim();
    if (description.isEmpty) return;

    final ingredients = _ingredientCtrls
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .join(', ');

    final fullText = ingredients.isNotEmpty
        ? '$description ($ingredients)'
        : description;

    setState(() => _isAiAnalyzing = true);
    final controller = context.read<RecipeController>();
    final result = await controller.analyzeRecipeMacros(fullText);
    setState(() => _isAiAnalyzing = false);

    if (result != null && mounted) {
      _caloriesCtrl.text = (result['calories'] as num?)?.toInt().toString() ?? '';
      _proteinCtrl.text = (result['protein'] as num?)?.toDouble().toStringAsFixed(0) ?? '';
      _carbsCtrl.text = (result['carbs'] as num?)?.toDouble().toStringAsFixed(0) ?? '';
      _fatCtrl.text = (result['fat'] as num?)?.toDouble().toStringAsFixed(0) ?? '';
      _servingsCtrl.text = (result['servings'] as num?)?.toInt().toString() ?? '';
    }
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    final ingredients = _ingredientCtrls
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    final steps = _stepCtrls
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final recipe = RecipeModel(
      id: widget.recipe?.id ?? '',
      name: name,
      calories: int.tryParse(_caloriesCtrl.text) ?? 0,
      protein: double.tryParse(_proteinCtrl.text) ?? 0,
      carbs: double.tryParse(_carbsCtrl.text) ?? 0,
      fat: double.tryParse(_fatCtrl.text) ?? 0,
      ingredients: ingredients,
      steps: steps,
      servings: int.tryParse(_servingsCtrl.text) ?? 1,
      prepTime: int.tryParse(_prepTimeCtrl.text),
      imageUrl: widget.recipe?.imageUrl,
      createdAt: widget.recipe?.createdAt ?? DateTime.now(),
    );

    final controller = context.read<RecipeController>();
    if (widget.recipe != null) {
      await controller.updateRecipe(recipe);
    } else {
      final saved = await controller.saveRecipe(recipe);
      if (saved == null) return;
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1629) : const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: Text(widget.recipe != null ? 'Edit Recipe' : 'New Recipe'),
        backgroundColor: isDark ? const Color(0xFF0F1629) : const Color(0xFFF4F4F4),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(context, 'Basic Info'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              decoration: _inputDec('Recipe name'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _servingsCtrl,
                    decoration: _inputDec('Servings'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _prepTimeCtrl,
                    decoration: _inputDec('Prep time (min)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _sectionTitle(context, 'Ingredients'),
            const SizedBox(height: 8),
            ..._ingredientCtrls.asMap().entries.map((entry) {
              final i = entry.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: entry.value,
                        decoration: _inputDec('Ingredient ${i + 1}'),
                      ),
                    ),
                    if (_ingredientCtrls.length > 1)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, size: 20),
                        color: Colors.red,
                        onPressed: () {
                          setState(() {
                            entry.value.dispose();
                            _ingredientCtrls.removeAt(i);
                          });
                        },
                      ),
                  ],
                ),
              );
            }),
            TextButton.icon(
              onPressed: () => setState(() => _ingredientCtrls.add(TextEditingController())),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add ingredient'),
            ),
            const SizedBox(height: 20),

            _sectionTitle(context, 'Steps'),
            const SizedBox(height: 8),
            ..._stepCtrls.asMap().entries.map((entry) {
              final i = entry.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Text('${i + 1}.', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: entry.value,
                        decoration: _inputDec('Step ${i + 1}'),
                      ),
                    ),
                    if (_stepCtrls.length > 1)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, size: 20),
                        color: Colors.red,
                        onPressed: () {
                          setState(() {
                            entry.value.dispose();
                            _stepCtrls.removeAt(i);
                          });
                        },
                      ),
                  ],
                ),
              );
            }),
            TextButton.icon(
              onPressed: () => setState(() => _stepCtrls.add(TextEditingController())),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add step'),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionTitle(context, 'Nutrition (total)'),
                TextButton.icon(
                  onPressed: _isAiAnalyzing ? null : _analyzeWithAi,
                  icon: _isAiAnalyzing
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome, size: 18),
                  label: const Text('Analyze with AI'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _caloriesCtrl,
                    decoration: _inputDec('Calories'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _proteinCtrl,
                    decoration: _inputDec('Protein (g)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _carbsCtrl,
                    decoration: _inputDec('Carbs (g)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _fatCtrl,
                    decoration: _inputDec('Fat (g)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    final tt = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Text(title, style: tt.labelSmall?.copyWith(
      color: scheme.onSurface.withAlpha(100),
      letterSpacing: 1.5,
    ));
  }

  InputDecoration _inputDec(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Theme.of(context).cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Theme.of(context).dividerColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      isDense: true,
    );
  }
}
