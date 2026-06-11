import 'package:flutter/material.dart';
import 'package:health_assistant/core/widgets/custom_button.dart';
import 'package:health_assistant/views/settings/widgets/account_title.dart';
import 'package:health_assistant/core/widgets/divider.dart';
import 'package:health_assistant/views/settings/widgets/section_card_wrapper.dart';
import 'package:health_assistant/views/settings/widgets/section_header.dart';
import 'package:health_assistant/views/settings/widgets/theme_toggle_button.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/setting_controller.dart';

class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.read<AuthController>();
    final settings = context.watch<SettingsController>();

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
                    onTap: () {},
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
