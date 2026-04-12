import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/auth_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileController>().profile;
    final auth    = context.read<AuthController>();
    final scheme  = Theme.of(context).colorScheme;
    final tt      = Theme.of(context).textTheme;
    final isDark  = Theme.of(context).brightness == Brightness.dark;

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
                      width: 120, height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: scheme.primary, width: 2),
                      ),
                    ),
                    Container(
                      width: 112, height: 112,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        'assets/images/person.png',
                        width: 104, height: 104,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                style: tt.bodySmall?.copyWith(color: scheme.onSurface.withAlpha(128)),
              ),
            ),

            const SizedBox(height: 16),

            // ── Stats row — IntrinsicHeight makes both cards equal height ────
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch, // ← stretch to tallest
                children: [

                  // Active Streak
                  Expanded(
                    child: _StatCard(
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
                            children: List.generate(5, (i) => Container(
                              margin: const EdgeInsets.only(right: 4),
                              width: 20, height: 4,
                              decoration: BoxDecoration(
                                color: i < 3
                                    ? scheme.primary
                                    : scheme.primary.withAlpha(50),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            )),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Total Tracked
                  Expanded(
                    child: _StatCard(
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

            // ── Menu items — Material + InkWell fixes tap detection ──────────
            _MenuItem(
              icon: Icons.settings_outlined,
              label: 'Settings',
              iconColor: scheme.primary,
              onTap: () {
                // TODO: navigate to settings screen
              },
            ),
            const SizedBox(height: 10),
            _MenuItem(
              icon: Icons.shield_outlined,
              label: 'Privacy',
              iconColor: scheme.secondary,
              onTap: () {
                // TODO: navigate to privacy screen
              },
            ),
            const SizedBox(height: 10),
            _MenuItem(
              icon: Icons.help_outline_rounded,
              label: 'Support',
              iconColor: scheme.primary,
              onTap: () {
                // TODO: navigate to support screen
              },
            ),

            const SizedBox(height: 32),

            // ── Logout ───────────────────────────────────────────────────────
            OutlinedButton.icon(
              onPressed: auth.logout,
              icon: const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
              label: const Text(
                'Logout',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red, width: 1),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ── Stat card ──────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String  label;
  final Color   labelColor;
  final Widget  child;
  final bool    hasBorder;
  final Color?  borderColor;

  const _StatCard({
    required this.label,
    required this.labelColor,
    required this.child,
    this.hasBorder   = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2236) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: hasBorder
            ? Border.all(color: borderColor ?? Colors.transparent, width: 1.5)
            : null,
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: labelColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

// ── Menu item — Material + InkWell for reliable tap ───────────────────────────
class _MenuItem extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final Color        iconColor;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(                              // ← Material needed for InkWell
      color: isDark ? const Color(0xFF1A2236) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(                             // ← InkWell is reliably tappable
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.withAlpha(150),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}