import 'package:flutter/material.dart';
import 'package:health_assistant/core/widgets/custom_button.dart';
import 'package:health_assistant/views/accessibility/accessibility_screen.dart';
import 'package:health_assistant/views/profile/widgets/menu_item.dart';
import 'package:health_assistant/views/profile/widgets/stat_card.dart';
import 'package:health_assistant/views/privacy/privacy_screen.dart';
import 'package:health_assistant/views/support/support_screen.dart';
import 'package:provider/provider.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/auth_controller.dart';
import '../settings/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileController>().loadFromStorage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileController>().profile;
    final auth = context.read<AuthController>();
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            // ── Avatar ──────────────────────────────────────────────────────
            Center(
              child: SizedBox(
                height: 150,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: scheme.primary, width: 2),
                      ),
                    ),
                    Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        'assets/images/person.png',
                        width: 104,
                        height: 104,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.secondary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'PREMIUM',
                          style: tt.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── Name + bio ───────────────────────────────────────────────────
            Center(
              child: Text(
                profile?.name ?? 'Alex Thorne',
                style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                profile?.bio ?? 'Professional Herpetologist',
                style: tt.bodySmall?.copyWith(
                  color: scheme.onSurface.withAlpha(128),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Stats row ────
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Active Streak
                  Expanded(
                    child: StatCard(
                      label: 'ACTIVE STREAK',
                      labelColor: scheme.primary,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${profile?.activeStreak ?? 12}',
                                style: tt.displayMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 36,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text('days', style: tt.bodyMedium),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: List.generate(
                              5,
                              (i) => Container(
                                margin: const EdgeInsets.only(right: 4),
                                width: 20,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: i < 3
                                      ? scheme.primary
                                      : scheme.primary.withAlpha(50),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Total Tracked
                  Expanded(
                    child: StatCard(
                      label: 'TOTAL TRACKED',
                      labelColor: scheme.secondary,
                      hasBorder: true,
                      borderColor: scheme.secondary,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${profile?.entries ?? 148}',
                                style: tt.displayMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 36,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text('entries', style: tt.bodyMedium),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text('⭐ ', style: TextStyle(fontSize: 11)),
                              Text(
                                'Top 5% Global',
                                style: tt.labelSmall?.copyWith(
                                  color: scheme.secondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Menu items —
            MenuItem(
              icon: Icons.settings_outlined,
              label: 'Settings',
              iconColor: scheme.primary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AppSettingsScreen()),
              ),
            ),
            const SizedBox(height: 10),
            MenuItem(
              icon: Icons.accessibility_new_outlined,
              label: 'Accessibility',
              iconColor: scheme.primary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AccessibilityScreen()),
              ),
            ),
            const SizedBox(height: 10),
            MenuItem(
              icon: Icons.shield_outlined,
              label: 'Privacy',
              iconColor: scheme.primary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DataPrivacyScreen()),
              ),
            ),
            const SizedBox(height: 10),
            MenuItem(
              icon: Icons.help_outline_rounded,
              label: 'Support',
              iconColor: scheme.primary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SupportScreen()),
              ),
            ),

            const SizedBox(height: 32),

            // ── Logout ───────────────────────────────────────────────────────
            CustomButton(
              icon: Icons.logout_rounded,
              label: 'Logout',
              onPressed: auth.logout,
              outlined: true,
              color: Colors.red,
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
