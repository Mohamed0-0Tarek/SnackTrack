import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../controllers/meal_controller.dart';
import '../../core/constants/app_routes.dart';
import '../../services/voice_input_service.dart';

/// ## What changed in this file
/// 1. After a successful `analyzeMeal()` call, this screen now actually
///    navigates to `MealAnalysisScreen` (via `AppRoutes.analysis`) —
///    previously nothing happened after analysis finished, so a
///    successful AI call had no visible effect.
/// 2. "Quick Log Favorites" now loads REAL recent meal names from
///    Firestore via `MealController.getQuickFavorites()`, replacing the
///    hardcoded `_FavItem` list (fake names, fake calories, fake asset
///    paths that don't exist in the project).
/// 3. Tapping a favorite re-runs the real AI analysis on that meal name
///    and navigates to the analysis screen — same path as manual entry —
///    rather than inventing a calorie count for a "favorite" that
///    doesn't actually carry stored nutrition data.
class AddMealScreen extends StatefulWidget {
  const AddMealScreen({super.key});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final _descCtrl = TextEditingController();

  MealInputMethod _selected = MealInputMethod.text;

  List<String> _favoriteNames = [];
  bool _favoritesLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final controller = context.read<MealController>();
    try {
      final names = await controller.getQuickFavorites();
      if (mounted) {
        setState(() {
          _favoriteNames = names;
          _favoritesLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _favoritesLoading = false);
    }
  }

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
                bgColor: colors.primary.withValues(alpha: 0.10),
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
                bgColor: colors.secondary.withValues(alpha: 0.10),
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
                bgColor: colors.tertiary.withValues(alpha: 0.10),
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
                bgColor: Colors.redAccent.withValues(alpha: 0.10),
                label: 'Voice',
                subtitle: 'Describe your meal out loud',
                onTap: () => setState(() => _selected = MealInputMethod.voice),
              ),

              const SizedBox(height: 28),

              // ── Analyze button ─────────────────────────────────────────────
              _AnalyzeButton(
                isLoading: controller.isAnalyzing,
                onTap: () => _onAnalyzeTap(context, controller),
              ),

              if (controller.analysisError != null) ...[
                const SizedBox(height: 10),
                Text(
                  controller.analysisError!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.error,
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // ── Quick Log Favorites ────────────────────────────────────────
              Text(
                'Quick Log Favorites',
                style: theme.textTheme.headlineMedium,
              ),

              const SizedBox(height: 12),

              if (_favoritesLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_favoriteNames.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    "Log a few meals and they'll show up here for quick re-logging.",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                )
              else
                ..._favoriteNames.map(
                  (name) => _FavoriteRow(
                    name: name,
                    onTap: () => _quickLogFavorite(context, controller, name),
                  ),
                ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ── Handlers ───────────────────────────────────────────────────────────

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
        _startVoiceInput(context, controller);
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
                onPressed: () => _submitAnalysis(ctx, context, controller),
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

  /// Closes the bottom sheet, runs the real AI analysis, then — only on
  /// success — navigates to MealAnalysisScreen. On failure the sheet is
  /// already closed, so the error surfaces back on this screen via a
  /// SnackBar (controller.analysisError is also shown inline in build()).
  Future<void> _submitAnalysis(
    BuildContext sheetContext,
    BuildContext screenContext,
    MealController controller,
  ) async {
    final description = _descCtrl.text.trim();
    if (description.isEmpty) return;

    Navigator.pop(sheetContext);

    final success = await controller.analyzeMeal(description);
    _descCtrl.clear();

    if (!screenContext.mounted) return;

    if (success) {
      screenContext.push(AppRoutes.analysis);
    } else {
      ScaffoldMessenger.of(screenContext).showSnackBar(
        SnackBar(
          content: Text(controller.analysisError ?? 'Could not analyze meal.'),
        ),
      );
    }
  }

  /// Re-runs AI analysis on a previously-logged meal name and navigates
  /// to the same analysis screen as manual entry. This is intentionally
  /// a real analysis call, not a cached calorie lookup — Firestore only
  /// stores the name for "recent distinct meals", not full nutrition
  /// data we could safely reuse without re-checking serving size etc.
  Future<void> _quickLogFavorite(
    BuildContext context,
    MealController controller,
    String name,
  ) async {
    final success = await controller.analyzeMeal(name);
    if (!context.mounted) return;

    if (success) {
      context.push(AppRoutes.analysis);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.analysisError ?? 'Could not analyze meal.'),
        ),
      );
    }
  }

  // ── Voice Input ─────────────────────────────────────────────────────────

  void _startVoiceInput(BuildContext screenContext, MealController controller) {
    showModalBottomSheet(
      context: screenContext,
      isScrollControlled: true,
      builder: (ctx) => _VoiceInputSheet(
        onAnalyze: (transcript) async {
          Navigator.pop(ctx);
          final success = await controller.analyzeMeal(transcript);
          if (!screenContext.mounted) return;
          if (success) {
            screenContext.push(AppRoutes.analysis);
          } else {
            ScaffoldMessenger.of(screenContext).showSnackBar(
              SnackBar(content: Text(controller.analysisError ?? 'Could not analyze meal.')),
            );
          }
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Voice Input Widget
// ─────────────────────────────────────────────────────────────────────────────

class _VoiceInputSheet extends StatefulWidget {
  final void Function(String transcript) onAnalyze;
  const _VoiceInputSheet({required this.onAnalyze});

  @override
  State<_VoiceInputSheet> createState() => _VoiceInputSheetState();
}

class _VoiceInputSheetState extends State<_VoiceInputSheet>
    with SingleTickerProviderStateMixin {
  final VoiceInputService _service = VoiceInputService();

  bool _ready = false;
  String _transcript = '';
  String? _error;
  late AnimationController _animCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulse = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut),
    );
    _initAndListen();
  }

  Future<void> _initAndListen() async {
    final available = await _service.initialize();
    if (!available) {
      setState(() => _error = 'Speech recognition not available.');
      return;
    }
    setState(() => _ready = true);
    _animCtrl.repeat(reverse: true);
    await _service.startListening('en_US');

    _service.transcriptStream.listen(
      (transcript) {
        if (mounted) setState(() => _transcript = transcript);
      },
      onError: (e) {
        if (mounted) setState(() => _error = 'Error: $e');
      },
    );
  }

  @override
  void dispose() {
    _service.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tt = theme.textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pulsing mic icon
          ScaleTransition(
            scale: _pulse,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _ready ? Colors.red.withAlpha(30) : theme.dividerColor,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                _ready ? Icons.mic : Icons.mic_off,
                color: _ready ? Colors.red : theme.hintColor,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Status / error
          if (_error != null)
            Text(_error!, style: tt.bodySmall?.copyWith(color: Colors.red))
          else if (!_ready)
            Text('Initialising…', style: tt.bodySmall)
          else
            Text(
              _transcript.isEmpty ? 'Listening…' : 'Heard:',
              style: tt.bodySmall,
            ),

          // Transcript
          if (_transcript.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Text(
                _transcript,
                style: tt.bodyMedium,
              ),
            ),

          const SizedBox(height: 8),

          // Buttons
          Row(
            children: [
              if (_ready)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final nav = Navigator.of(context);
                      await _service.stopListening();
                      nav.pop();
                    },
                    child: const Text('Cancel'),
                  ),
                ),
              if (_ready && _transcript.isNotEmpty) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onAnalyze(_transcript);
                    },
                    child: const Text('Analyze'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
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

/// Real quick-favorite row driven by an actual meal name from Firestore
/// (MealController.getQuickFavorites()), not a fabricated _FavItem with
/// a fake calorie count and a hardcoded asset path that doesn't exist in
/// the project's assets.
class _FavoriteRow extends StatelessWidget {
  final String name;
  final VoidCallback onTap;

  const _FavoriteRow({required this.name, required this.onTap});

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
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.restaurant_menu_rounded,
              color: colors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              name,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: onTap,
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
