import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/meal_controller.dart';

class AddMealScreen extends StatefulWidget {
  const AddMealScreen({super.key});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final _descCtrl = TextEditingController();

  MealInputMethod _selected = MealInputMethod.text;

  final List<_FavItem> _favorites = const [
    _FavItem(
      name: 'Avocado Toast',
      kcal: 320,
      mealType: 'Breakfast',
      image: 'assets/images/avocado_toast.png',
    ),
    _FavItem(
      name: 'Protein Oats',
      kcal: 450,
      mealType: 'Breakfast',
      image: 'assets/images/protein_oats.png',
    ),
    _FavItem(
      name: 'Salmon Quinoa',
      kcal: 580,
      mealType: 'Dinner',
      image: 'assets/images/salmon_quinoa.png',
    ),
    _FavItem(
      name: 'Green Monster',
      kcal: 180,
      mealType: 'Snack',
      image: 'assets/images/green_monster.png',
    ),
    _FavItem(
      name: 'Pesto Pasta',
      kcal: 610,
      mealType: 'Lunch',
      image: 'assets/images/pesto_pasta.png',
    ),
    _FavItem(
      name: 'Homemade Pizza',
      kcal: 750,
      mealType: 'Dinner',
      image: 'assets/images/homemade_pizza.png',
    ),
  ];

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MealController>();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // ── Title ──────────────────────────────────────────────────────
              Text('Add Meal', style: theme.textTheme.displayLarge),
              const SizedBox(height: 6),
              Text(
                'How would you like to track your food?',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
              ),

              const SizedBox(height: 24),

              // ── Method cards ───────────────────────────────────────────────
              _MethodCard(
                method: MealInputMethod.text,
                selected: _selected,
                icon: Icons.edit_note_rounded,
                iconColor: colors.primary,
                bgColor: colors.primary.withOpacity(0.10),
                label: 'Text',
                subtitle: 'Type your meal details manually',
                onTap: () => setState(() => _selected = MealInputMethod.text),
              ),
              const SizedBox(height: 14),
              _MethodCard(
                method: MealInputMethod.photo,
                selected: _selected,
                icon: Icons.camera_alt_outlined,
                iconColor: colors.secondary,
                bgColor: colors.secondary.withOpacity(0.10),
                label: 'Photo',
                subtitle: 'Snap a picture for instant analysis',
                onTap: () => setState(() => _selected = MealInputMethod.photo),
              ),
              const SizedBox(height: 14),
              _MethodCard(
                method: MealInputMethod.barcode,
                selected: _selected,
                icon: Icons.qr_code_scanner_rounded,
                iconColor: colors.tertiary,
                bgColor: colors.tertiary.withOpacity(0.10),
                label: 'Barcode',
                subtitle: 'Scan packaged food labels',
                onTap: () =>
                    setState(() => _selected = MealInputMethod.barcode),
              ),
              const SizedBox(height: 14),
              _MethodCard(
                method: MealInputMethod.voice,
                selected: _selected,
                icon: Icons.mic_outlined,
                iconColor: Colors.redAccent,
                bgColor: Colors.redAccent.withOpacity(0.10),
                label: 'Voice',
                subtitle: 'Describe your meal out loud',
                onTap: () => setState(() => _selected = MealInputMethod.voice),
              ),

              const SizedBox(height: 28),

              // ── Analyze button ─────────────────────────────────────────────
              _AnalyzeButton(
                isLoading: controller.isLoading,
                onTap: () => _onAnalyzeTap(context, controller),
              ),

              if (controller.error != null) ...[
                const SizedBox(height: 10),
                Text(
                  controller.error!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.error,
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // ── Quick Log Favorites ────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quick Log Favorites',
                    style: theme.textTheme.headlineMedium,
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'View All',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colors.primary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              ..._favorites.map(
                (fav) => _FavoriteRow(
                  item: fav,
                  onAdd: () => _quickLog(context, controller, fav),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ── Handlers ───────────────────────────────────────────────────────────────
  void _onAnalyzeTap(BuildContext context, MealController controller) {
    switch (_selected) {
      case MealInputMethod.text:
        _showTextSheet(context, controller);
        break;
      case MealInputMethod.photo:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Photo — coming soon')));
        break;
      case MealInputMethod.barcode:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Barcode — coming soon')));
        break;
      case MealInputMethod.voice:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Voice — coming soon')));
        break;
    }
  }

  void _showTextSheet(BuildContext context, MealController controller) {
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
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Describe your meal', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 16),
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'e.g. Grilled chicken with rice and salad...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  if (_descCtrl.text.isNotEmpty) {
                    controller.analyzeMeal(_descCtrl.text);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Analyze'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _quickLog(
    BuildContext context,
    MealController controller,
    _FavItem fav,
  ) {
    controller.addFavoriteMeal(
      FavoriteMealModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: fav.name,
        calories: fav.kcal,
        protein: 0,
      ),
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${fav.name} logged!')));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _MethodCard extends StatelessWidget {
  final MealInputMethod method;
  final MealInputMethod selected;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _MethodCard({
    required this.method,
    required this.selected,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isActive = method == selected;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? colors.primary : theme.dividerColor,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon bubble
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalyzeButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _AnalyzeButton({required this.isLoading, required this.onTap});

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
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Analyze with AI',
                    style: text.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _FavoriteRow extends StatelessWidget {
  final _FavItem item;
  final VoidCallback onAdd;

  const _FavoriteRow({required this.item, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor, width: 1),
      ),
      child: Row(
        children: [
          // ── Meal image ────────────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              item.image,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 56,
                height: 56,
                color: colors.primary.withOpacity(0.08),
                child: Icon(
                  Icons.restaurant_menu_rounded,
                  color: colors.primary,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // ── Info ──────────────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${item.kcal} kcal • ${item.mealType}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          // ── + button ──────────────────────────────────────────────────────
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colors.primary, width: 1.5),
              ),
              child: Icon(Icons.add, color: colors.primary, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Internal data ─────────────────────────────────────────────────────────────
class _FavItem {
  final String name;
  final int kcal;
  final String mealType;
  final String image;

  const _FavItem({
    required this.name,
    required this.kcal,
    required this.mealType,
    required this.image,
  });
}
