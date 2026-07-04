import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// onboarding_screen.dart  (the "Define Your Trajectory" profile setup screen)
// Step 2 of 4 in the onboarding flow.
// Follows project theme conventions — colorScheme, textTheme, cardColor,
// dividerColor, brightness checks — identical to profile_screen.dart
// ─────────────────────────────────────────────────────────────────────────────

enum _Objective { weightLoss, muscleGain, maintenance }

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  _Objective? _selected;
  double _age     = 28;
  double _weight  = 74.5;
  double _height  = 182;
  bool   _loading = false;

  Future<void> _submit() async {
  if (_selected == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please select your primary objective to proceed.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  setState(() => _loading = true);

  try {
    final authController = context.read<AuthController>();

    // Parse out UI strings safely
    String objectiveStr;
    switch (_selected!) {
      case _Objective.weightLoss:
        objectiveStr = 'loss weight';
        break;
      case _Objective.muscleGain:
        objectiveStr = 'build muscle';
        break;
      case _Objective.maintenance:
        objectiveStr = 'maintenance';
        break;
    }

    // Call your single central source of truth instead of mutating databases raw from UI views
    await authController.synchronizeOnboardingProfile(
      age: _age.round(),
      weight: double.parse(_weight.toStringAsFixed(1)),
      height: _height,
      objective: objectiveStr,
    );


  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save parameters: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _loading = false);
    }
  }
}
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt     = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [

            // ── Fixed top section (progress + logo)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo + step counter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SnackTrack', // Fixed brand typo
                        style: tt.headlineMedium?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'STEP 02 OF 04',
                        style: tt.labelSmall?.copyWith(
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 2 / 4,
                      minHeight: 4,
                      backgroundColor: scheme.primary.withAlpha(30),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(scheme.primary),
                    ),
                  ),
                ],
              ),
            ),

            // ── Scrollable body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Hero text
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Define Your\n',
                            style: tt.displayLarge?.copyWith(
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          TextSpan(
                            text: 'Trajectory',
                            style: tt.displayLarge?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Our AI Oracle requires your physiological coordinates to calculate the optimal metabolic path.',
                      style: tt.bodyMedium?.copyWith(
                        color: scheme.onSurface.withAlpha(160),
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Objective section
                    Text(
                      'Select Primary Objective',
                      style: tt.headlineMedium?.copyWith(
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(height: 14),

                    _ObjectiveCard(
                      objective: _Objective.weightLoss,
                      selected: _selected,
                      icon: Icons.trending_down_rounded,
                      title: 'Weight loss',
                      body:
                          'Aggressive fat oxidation with muscle preservation protocols.',
                      onTap: () =>
                          setState(() => _selected = _Objective.weightLoss),
                    ),
                    const SizedBox(height: 10),
                    _ObjectiveCard(
                      objective: _Objective.muscleGain,
                      selected: _selected,
                      icon: Icons.fitness_center_rounded,
                      title: 'Muscle gain',
                      body:
                          'Hypertrophy-focused nutrient partitioning and surplus tracking.',
                      onTap: () =>
                          setState(() => _selected = _Objective.muscleGain),
                    ),
                    const SizedBox(height: 10),
                    _ObjectiveCard(
                      objective: _Objective.maintenance,
                      selected: _selected,
                      icon: Icons.balance_rounded,
                      title: 'Maintenance',
                      body:
                          'Sustainable metabolic equilibrium for long-term health.',
                      onTap: () =>
                          setState(() => _selected = _Objective.maintenance),
                    ),

                    const SizedBox(height: 32),

                    // ── Physiological data section
                    Text(
                      'Physiological Data',
                      style: tt.headlineMedium?.copyWith(
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _PhysioSlider(
                      label: 'AGE',
                      value: _age,
                      display: '${_age.round()} YRS',
                      min: 16,
                      max: 80,
                      onChanged: (v) => setState(() => _age = v),
                    ),
                    const SizedBox(height: 20),
                    _PhysioSlider(
                      label: 'CURRENT WEIGHT',
                      value: _weight,
                      display: '${_weight.toStringAsFixed(1)} KG',
                      min: 40,
                      max: 150,
                      onChanged: (v) => setState(() => _weight = v),
                    ),
                    const SizedBox(height: 20),
                    _PhysioSlider(
                      label: 'HEIGHT',
                      value: _height,
                      display: '${_height.round()} CM',
                      min: 140,
                      max: 220,
                      onChanged: (v) => setState(() => _height = v),
                    ),

                    const SizedBox(height: 20),

                    // ── AI Insight box
                    _AiInsightBox(),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // ── Fixed bottom CTA
            _BottomActions(loading: _loading, onSync: _submit),
          ],
        ),
      ),
    );
  }
}

// ─── Objective Card ───────────────────────────────────────────────────────────
class _ObjectiveCard extends StatelessWidget {
  final _Objective  objective;
  final _Objective? selected;
  final IconData    icon;
  final String      title;
  final String      body;
  final VoidCallback onTap;

  const _ObjectiveCard({
    required this.objective,
    required this.selected,
    required this.icon,
    required this.title,
    required this.body,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme    = Theme.of(context).colorScheme;
    final tt        = Theme.of(context).textTheme;
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final isSelected = selected == objective;

    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? scheme.primary : Theme.of(context).dividerColor,
              width: isSelected ? 1.5 : 1,
            ),
            color: isSelected
                ? scheme.primary.withAlpha(isDark ? 25 : 15)
                : Theme.of(context).cardColor,
          ),
          child: Row(
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: isSelected
                      ? scheme.primary.withAlpha(40)
                      : scheme.onSurface.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? scheme.primary
                      : scheme.onSurface.withAlpha(140),
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: tt.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isSelected ? scheme.primary : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(body, style: tt.bodySmall?.copyWith(height: 1.4)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 20, height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? scheme.primary
                        : Theme.of(context).dividerColor,
                    width: 1.5,
                  ),
                  color: isSelected ? scheme.primary : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 12)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Physio Slider ────────────────────────────────────────────────────────────
class _PhysioSlider extends StatelessWidget {
  final String label;
  final double value;
  final String display;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _PhysioSlider({
    required this.label,
    required this.value,
    required this.display,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt     = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: tt.labelSmall?.copyWith(letterSpacing: 1.5),
            ),
            Text(
              display,
              style: tt.displayMedium?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor:   scheme.primary,
            inactiveTrackColor: scheme.primary.withAlpha(30),
            thumbColor:         scheme.primary,
            overlayColor:       scheme.primary.withAlpha(30),
            trackHeight:        4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

// ─── AI Insight Box ───────────────────────────────────────────────────────────
class _AiInsightBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt     = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? scheme.secondary.withAlpha(25)
            : scheme.secondary.withAlpha(15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.secondary.withAlpha(80)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: scheme.secondary.withAlpha(40),
              shape: BoxShape.circle,
            ),
            child:
                Icon(Icons.psychology_outlined, color: scheme.secondary, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: tt.bodySmall?.copyWith(height: 1.5),
                children: [
                  TextSpan(
                    text: 'AI INSIGHT: ',
                    style: TextStyle(
                      color: scheme.secondary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const TextSpan(
                    text:
                        'These stats indicate a highly active metabolism. We recommend a high-protein baseline.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Actions ───────────────────────────────────────────────────────────
class _BottomActions extends StatelessWidget {
  final bool loading;
  final VoidCallback onSync;

  const _BottomActions({required this.loading, required this.onSync});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt     = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Column(
        children: [
          // Sync button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: loading ? null : onSync,
              borderRadius: BorderRadius.circular(14),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [scheme.primary, scheme.secondary],
                    begin: Alignment.centerLeft,
                    end:   Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.primary.withAlpha(80),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: Center(
                    child: loading
                        ? const SizedBox(
                            width: 22, height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Synchronize Profile',
                                style: tt.labelLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded,
                                  color: Colors.white, size: 18),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Skip
          
        ],
      ),
    );
  }
}