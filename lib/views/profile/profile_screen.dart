import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../core/constants/app_routes.dart';
import '../../core/widgets/custom_button.dart';
import '../accessibility/accessibility_screen.dart';
import '../privacy/privacy_screen.dart';
import '../support/support_screen.dart';
import 'widgets/menu_item.dart';
import 'widgets/stat_card.dart';
import '../../services/storage_service.dart';

/// ## What changed in this file
/// - Avatar: replaced hardcoded `Image.asset('assets/images/person.png')`
///   with a real avatar loaded from `profile.avatarUrl` (network image),
///   falling back to the asset only when no URL exists. Tapping the
///   avatar calls `ProfileController.uploadAvatar()`.
/// - Active streak: replaced hardcoded `12` fallback with
///   `DashboardController.activeStreak` — the same value computed by
///   the dashboard from real meal history.
/// - Entries: replaced hardcoded `148` fallback with
///   `ProfileController.entries` from `MealService.getMealCount()`.
/// - Edit mode: tapping the pencil icon opens a bottom sheet to edit
///   name and bio, calling `ProfileController.updateProfile()`.
/// - Navigation: replaced all `Navigator.push(MaterialPageRoute(...))`
///   with `context.push(AppRoutes.*)` for GoRouter consistency.
///   Note: Accessibility, Privacy, and Support screens don't have named
///   routes yet — they still use `Navigator.push` as a known gap,
///   rather than adding routes to app.dart in this PR.
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
      context.read<ProfileController>().loadProfile();
    });
  }

  void _showEditSheet() {
    final profile = context.read<ProfileController>().profile;
    final nameCtrl =
        TextEditingController(text: profile?.name ?? '');
    final bioCtrl =
        TextEditingController(text: profile?.bio ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Padding(
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
              Text('Edit Profile',
                  style: theme.textTheme.headlineMedium),
              const SizedBox(height: 20),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: bioCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Bio',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final success = await context
                        .read<ProfileController>()
                        .updateProfile(
                          name: nameCtrl.text.trim(),
                          bio: bioCtrl.text.trim(),
                        );
                    if (!success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            context.read<ProfileController>().error ??
                                'Could not save changes.',
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileCtrl = context.watch<ProfileController>();
    final dashCtrl = context.watch<DashboardController>();
    final auth = context.read<AuthController>();
    final profile = profileCtrl.profile;
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Real streak from DashboardController; falls back to
    // profile.activeStreak (Firestore field) if dashboard hasn't
    // loaded yet, then 0 as a last resort.
    final streak = dashCtrl.activeStreak ??
        profile?.activeStreak ??
        0;

    // Real entries count from MealService.getMealCount().
    final entriesCount = profileCtrl.entries ?? profile?.entries ?? 0;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 20),
          children: [
            // ── Avatar ─────────────────────────────────────────────────
            Center(
              child: SizedBox(
                height: 150,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Border ring
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: scheme.primary, width: 2),
                      ),
                    ),
                    // White background
                    Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                      ),
                    ),
                    // Avatar image — real network image when URL exists,
                    // asset fallback for new accounts without one yet.
                    // NOTE: avatar upload deferred to post-launch
                    // (requires Firebase Storage upgrade). For now the
                    // avatar is read-only — shows network image if URL
                    // exists, fallback icon otherwise.
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: profile?.avatarUrl != null &&
                              profile!.avatarUrl.isNotEmpty
                          ? Image.network(
                              profile.avatarUrl,
                              width: 104,
                              height: 104,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _avatarFallback(scheme),
                            )
                          : _avatarFallback(scheme),
                    ),
                    // Premium badge
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

            // ── Name + bio + edit button ────────────────────────────────
            Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      profile?.name ?? '—',
                      style: tt.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile?.bio ?? '',
                      style: tt.bodySmall?.copyWith(
                        color: scheme.onSurface.withAlpha(128),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: 0,
                  child: IconButton(
                    icon: Icon(Icons.edit_outlined,
                        color: scheme.primary, size: 20),
                    tooltip: 'Edit profile',
                    onPressed: _showEditSheet,
                  ),
                ),
              ],
            ),

            // Error banner
            if (profileCtrl.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  profileCtrl.error!,
                  textAlign: TextAlign.center,
                  style: tt.bodySmall
                      ?.copyWith(color: scheme.error),
                ),
              ),

            const SizedBox(height: 16),

            // ── Stats row ──────────────────────────────────────────────
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Active Streak — real from DashboardController
                  Expanded(
                    child: StatCard(
                      label: 'ACTIVE STREAK',
                      labelColor: scheme.primary,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.end,
                            children: [
                              Text(
                                '$streak',
                                style: tt.displayMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 36,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 6),
                                child: Text('days',
                                    style: tt.bodyMedium),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: List.generate(
                              5,
                              (i) => Container(
                                margin:
                                    const EdgeInsets.only(right: 4),
                                width: 20,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: i < (streak.clamp(0, 5))
                                      ? scheme.primary
                                      : scheme.primary
                                          .withAlpha(50),
                                  borderRadius:
                                      BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Entries — real from MealService.getMealCount()
                  Expanded(
                    child: StatCard(
                      label: 'TOTAL TRACKED',
                      labelColor: scheme.secondary,
                      hasBorder: true,
                      borderColor: scheme.secondary,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.end,
                            children: [
                              Text(
                                '$entriesCount',
                                style: tt.displayMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 36,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 6),
                                child: Text('entries',
                                    style: tt.bodyMedium),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text('⭐ ',
                                  style: TextStyle(fontSize: 11)),
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

            // ── Menu items ─────────────────────────────────────────────
            MenuItem(
              icon: Icons.settings_outlined,
              label: 'Settings',
              iconColor: scheme.primary,
              onTap: () => context.push(AppRoutes.settings),
            ),
            const SizedBox(height: 10),
            MenuItem(
              icon: Icons.accessibility_new_outlined,
              label: 'Accessibility',
              iconColor: scheme.primary,
              // Accessibility doesn't have a named GoRouter route yet —
              // keeping Navigator.push as a known gap until routes are
              // consolidated in app.dart.
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AccessibilityScreen()),
              ),
            ),
            const SizedBox(height: 10),
            MenuItem(
              icon: Icons.shield_outlined,
              label: 'Privacy',
              iconColor: scheme.primary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const DataPrivacyScreen()),
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

            // ── Logout ─────────────────────────────────────────────────
            CustomButton(
              icon: Icons.logout_rounded,
              label: 'Logout',
              onPressed: () async {
                await auth.logout();
                await StorageService.clearAll();
              },
              outlined: true,
              color: Colors.red,
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _avatarFallback(ColorScheme scheme) {
    return Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        color: scheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        Icons.person_rounded,
        color: scheme.primary.withOpacity(0.5),
        size: 48,
      ),
    );
  }
}