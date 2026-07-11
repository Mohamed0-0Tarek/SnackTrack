import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snacktrack/core/widgets/custom_button.dart';
import 'package:snacktrack/views/settings/widgets/account_title.dart';
import 'package:snacktrack/core/widgets/divider.dart';
import 'package:snacktrack/views/settings/widgets/section_card_wrapper.dart';
import 'package:snacktrack/views/settings/widgets/section_header.dart';
import 'package:snacktrack/views/settings/widgets/theme_toggle_button.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/setting_controller.dart';
import '../../core/constants/app_routes.dart';

class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.read<AuthController>();
    final settings = context.watch<SettingController>();

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F1629)
          : const Color(0xFFF4F4F4),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Custom AppBar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // ← Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1A2236)
                              : Colors.black87,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Settings',
                      style: tt.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.notifications_outlined,
                  color: scheme.onSurface,
                  size: 26,
                ),
              ],
            ),
            SizedBox(height: 20),
            // ── Premium card ──────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF00B4DB), Color(0xFF6A3DE8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified, color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'PREMIUM ACTIVE',
                        style: tt.labelSmall?.copyWith(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'SnackTrack Plus\nMember',
                    style: tt.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'You have full access to AI meal analysis, advanced reports, and personalized nutrition coaching.',
                    style: tt.bodySmall?.copyWith(
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    label: 'Manage Subscription',
                    onPressed: () {},
                    outlined: true,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Appearance card ───────────────────────────────────────────────
            SectionCard(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    icon: Icons.wb_sunny_outlined,
                    label: 'Appearance',
                    iconColor: const Color(0xFF00B4DB),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Choose how NutriFit looks on your device.',
                    style: tt.bodySmall?.copyWith(
                      color: scheme.onSurface.withAlpha(120),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Light / Dark toggle buttons
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0F1629)
                          : const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        ThemeToggleBtn(
                          label: 'Light',
                          icon: Icons.wb_sunny_outlined,
                          isSelected: !settings.isDarkMode,
                          isDark: isDark,
                          onTap: () => settings.setDarkMode(false),
                        ),
                        ThemeToggleBtn(
                          label: 'Dark',
                          icon: Icons.nightlight_round,
                          isSelected: settings.isDarkMode,
                          isDark: isDark,
                          onTap: () => settings.setDarkMode(true),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Notifications card ────────────────────────────────────────────
            SectionCard(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    iconColor: scheme.secondary,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Adjust alert frequency for activity updates.',
                    style: tt.bodySmall?.copyWith(
                      color: scheme.onSurface.withAlpha(120),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Slider
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 7,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 14,
                      ),
                      activeTrackColor: scheme.primary,
                      inactiveTrackColor: scheme.primary.withAlpha(38),
                      thumbColor: scheme.primary,
                    ),
                    child: Slider(
                      value: settings.notifFrequency,
                      min: 0,
                      max: 2,
                      divisions: 2,
                      onChanged: (v) => settings.setNotifFrequency(v),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: ['QUIET', 'STANDARD', 'FREQUENT']
                          .map(
                            (label) => Text(
                              label,
                              style: tt.labelSmall?.copyWith(
                                color: scheme.onSurface.withAlpha(120),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                                fontSize: 10,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Nutrition Goals card ───────────────────────────────────────
            SectionCard(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    icon: Icons.restaurant_outlined,
                    label: 'Nutrition Goals',
                    iconColor: const Color(0xFF00B4DB),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Set your daily targets for calories, macros, and hydration.',
                    style: tt.bodySmall?.copyWith(
                      color: scheme.onSurface.withAlpha(120),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _GoalRow(
                    icon: Icons.local_fire_department_outlined,
                    iconColor: const Color(0xFFFF6B35),
                    label: 'Calories',
                    value: '${settings.goalCalories} kcal',
                    isDark: isDark,
                    onTap: () => _editGoal(
                      context,
                      title: 'Daily Calorie Goal',
                      unit: 'kcal',
                      initialValue: settings.goalCalories.toDouble(),
                      min: 1000,
                      max: 5000,
                      divisions: 80,
                      decimals: 0,
                      onSaved: (v) => settings.setGoalCalories(v.round()),
                    ),
                  ),
                  AppDivider(isDark: isDark),
                  _GoalRow(
                    icon: Icons.fitness_center_outlined,
                    iconColor: const Color(0xFF6A3DE8),
                    label: 'Protein',
                    value: '${settings.goalProtein.round()} g',
                    isDark: isDark,
                    onTap: () => _editGoal(
                      context,
                      title: 'Daily Protein Goal',
                      unit: 'g',
                      initialValue: settings.goalProtein,
                      min: 30,
                      max: 300,
                      divisions: 54,
                      decimals: 0,
                      onSaved: (v) => settings.setGoalProtein(v),
                    ),
                  ),
                  AppDivider(isDark: isDark),
                  _GoalRow(
                    icon: Icons.grain_rounded,
                    iconColor: const Color(0xFF00B4DB),
                    label: 'Carbs',
                    value: '${settings.goalCarbs.round()} g',
                    isDark: isDark,
                    onTap: () => _editGoal(
                      context,
                      title: 'Daily Carbs Goal',
                      unit: 'g',
                      initialValue: settings.goalCarbs,
                      min: 30,
                      max: 600,
                      divisions: 114,
                      decimals: 0,
                      onSaved: (v) => settings.setGoalCarbs(v),
                    ),
                  ),
                  AppDivider(isDark: isDark),
                  _GoalRow(
                    icon: Icons.water_drop_outlined,
                    iconColor: const Color(0xFF4CAF50),
                    label: 'Fat',
                    value: '${settings.goalFat.round()} g',
                    isDark: isDark,
                    onTap: () => _editGoal(
                      context,
                      title: 'Daily Fat Goal',
                      unit: 'g',
                      initialValue: settings.goalFat,
                      min: 20,
                      max: 200,
                      divisions: 36,
                      decimals: 0,
                      onSaved: (v) => settings.setGoalFat(v),
                    ),
                  ),
                  AppDivider(isDark: isDark),
                  _GoalRow(
                    icon: Icons.water_outlined,
                    iconColor: const Color(0xFF2196F3),
                    label: 'Water',
                    value: '${settings.goalWaterMl} ml',
                    isDark: isDark,
                    onTap: () => _editGoal(
                      context,
                      title: 'Daily Water Goal',
                      unit: 'ml',
                      initialValue: settings.goalWaterMl.toDouble(),
                      min: 1000,
                      max: 5000,
                      divisions: 40,
                      decimals: 0,
                      onSaved: (v) => settings.setGoalWaterMl(v.round()),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Health Tracking card ────────────────────────────────────────
            SectionCard(
              isDark: isDark,
              child: Column(
                children: [
                  SectionHeader(
                    icon: Icons.favorite_outline,
                    label: 'Health Tracking',
                    iconColor: const Color(0xFF4CAF50),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Monitor your weight, measurements, and progress over time.',
                    style: tt.bodySmall?.copyWith(
                      color: scheme.onSurface.withAlpha(120),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _GoalRow(
                    icon: Icons.monitor_weight_outlined,
                    iconColor: const Color(0xFF6A3DE8),
                    label: 'Weight Tracking',
                    value: '',
                    isDark: isDark,
                    onTap: () => context.push(AppRoutes.weightTracking),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Security & account card ───────────────────────────────────────
            SectionCard(
              isDark: isDark,
              child: Column(
                children: [
                  // Two-Factor Auth
                  AccountTile(
                    icon: Icons.security_outlined,
                    iconColor: const Color(0xFF00B4DB),
                    title: 'Two-Factor Authentication',
                    subtitle: 'Enhanced security for your account',
                    isDark: isDark,
                    trailing: Text(
                      'Enabled',
                      style: tt.labelMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {},
                  ),
                  AppDivider(isDark: isDark),

                  // Change Password
                  AccountTile(
                    icon: Icons.lock_outline_rounded,
                    iconColor: const Color(0xFF6A3DE8),
                    title: 'Change Password',
                    subtitle: 'Update your account credentials',
                    isDark: isDark,
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: scheme.onSurface.withAlpha(120),
                    ),
                    onTap: () => context.push(AppRoutes.changePassword),
                  ),
                  AppDivider(isDark: isDark),
                  // Log Out
                  AccountTile(
                    icon: Icons.logout_rounded,
                    iconColor: Colors.red,
                    title: 'Log Out',
                    subtitle: 'End your current session',
                    titleColor: Colors.red,
                    isDark: isDark,
                    trailing: const SizedBox.shrink(),
                    onTap: auth.logout,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Version footer ────────────────────────────────────────────────
            Center(
              child: Text(
                'SnackTrack V1.0.0 • BUILD 1001',
                style: tt.labelSmall?.copyWith(
                  color: scheme.onSurface.withAlpha(120),
                  letterSpacing: 1.2,
                  fontSize: 10,
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ─── Goal Row ────────────────────────────────────────────────────────────────

class _GoalRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool isDark;
  final VoidCallback onTap;

  const _GoalRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                value,
                style: tt.bodyMedium?.copyWith(
                  color: scheme.onSurface.withAlpha(160),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.onSurface.withAlpha(120),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Goal Edit Dialog ────────────────────────────────────────────────────────

Future<void> _editGoal(
  BuildContext context, {
  required String title,
  required String unit,
  required double initialValue,
  required double min,
  required double max,
  required int divisions,
  required int decimals,
  required void Function(double) onSaved,
}) async {
  double value = initialValue;

  final result = await showDialog<double>(
    context: context,
    builder: (ctx) {
      final scheme = Theme.of(ctx).colorScheme;
      final tt = Theme.of(ctx).textTheme;

      return StatefulBuilder(
        builder: (ctx, setState) {
          final display = decimals == 0
              ? value.round().toString()
              : value.toStringAsFixed(decimals);

          return AlertDialog(
            backgroundColor: Theme.of(ctx).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              title,
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$display $unit',
                  style: tt.headlineMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SliderTheme(
                  data: SliderTheme.of(ctx).copyWith(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 7,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 14,
                    ),
                    activeTrackColor: scheme.primary,
                    inactiveTrackColor: scheme.primary.withAlpha(38),
                    thumbColor: scheme.primary,
                  ),
                  child: Slider(
                    value: value,
                    min: min,
                    max: max,
                    divisions: divisions,
                    onChanged: (v) => setState(() => value = v),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${min.round()} $unit',
                      style: tt.labelSmall?.copyWith(
                        color: scheme.onSurface.withAlpha(120),
                      ),
                    ),
                    Text(
                      '${max.round()} $unit',
                      style: tt.labelSmall?.copyWith(
                        color: scheme.onSurface.withAlpha(120),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Cancel',
                  style: tt.labelLarge?.copyWith(
                    color: scheme.onSurface.withAlpha(160),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, value),
                child: Text(
                  'Save',
                  style: tt.labelLarge?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );

  if (result != null) onSaved(result);
}
