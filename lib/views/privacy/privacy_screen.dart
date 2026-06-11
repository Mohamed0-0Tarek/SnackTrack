import 'package:flutter/material.dart';
import 'package:health_assistant/core/widgets/divider.dart';
import 'package:health_assistant/views/privacy/widgets/badge.dart';
import 'package:health_assistant/views/privacy/widgets/certification_badge.dart';
import 'package:health_assistant/views/privacy/widgets/control_card.dart';
import 'package:health_assistant/views/privacy/widgets/export_button.dart';
import 'package:health_assistant/views/privacy/widgets/toggle_title.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';

class DataPrivacyScreen extends StatefulWidget {
  const DataPrivacyScreen({super.key});

  @override
  State<DataPrivacyScreen> createState() => _DataPrivacyScreenState();
}

class _DataPrivacyScreenState extends State<DataPrivacyScreen> {
  bool _anonymousAnalytics = true;
  bool _geoTracking        = false;
  bool _aiTrainingModel    = true;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt     = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [

            // ── AppBar ────────────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A2236) : Colors.black87,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 16),
                  ),
                ),
                Icon(Icons.notifications_outlined,
                    color: scheme.onSurface, size: 26),
              ],
            ),

            const SizedBox(height: 20),

            // ── Hero card ─────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2236) : const Color(0xFF0F1629),
                borderRadius: BorderRadius.circular(20),
                border: Border(
                  left: BorderSide(color: scheme.primary, width: 3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data & Privacy',
                    style: tt.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Your biometric data is encrypted and managed with bank-grade security protocols. You are in full control of your digital footprint.',
                    style: tt.bodySmall?.copyWith(
                        color: Colors.white60, height: 1.6),
                  ),
                  const SizedBox(height: 16),
                  // Badges
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      PrivBadge(
                        icon: Icons.shield_outlined,
                        label: 'AES-256 ENCRYPTED',
                        color: scheme.primary,
                      ),
                      PrivBadge(
                        icon: Icons.lock_outline_rounded,
                        label: 'GDPR COMPLIANT',
                        color: scheme.secondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Privacy Controls ──────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Privacy Controls',
                    style: tt.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Text(
                  'ACTIVE PROTECTION',
                  style: tt.labelSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            ControlCard(
              isDark: isDark,
              child: Column(
                children: [
                  ToggleTile(
                    icon: Icons.visibility_off_outlined,
                    iconColor: scheme.primary,
                    title: 'Anonymous Analytics',
                    subtitle:
                        'Help improve NutriFit with anonymized usage data.',
                    value: _anonymousAnalytics,
                    onChanged: (v) =>
                        setState(() => _anonymousAnalytics = v),
                    isDark: isDark,
                  ),
                  AppDivider(isDark: isDark),
                  ToggleTile(
                    icon: Icons.gps_fixed_rounded,
                    iconColor: scheme.secondary,
                    title: 'Precision Geo-Tracking',
                    subtitle:
                        'Use high-accuracy GPS for workout mapping.',
                    value: _geoTracking,
                    onChanged: (v) =>
                        setState(() => _geoTracking = v),
                    isDark: isDark,
                  ),
                  AppDivider(isDark: isDark),
                  ToggleTile(
                    icon: Icons.psychology_outlined,
                    iconColor: scheme.primary,
                    title: 'AI Training Model',
                    subtitle:
                        'Allow AI to learn from your specific nutritional patterns.',
                    value: _aiTrainingModel,
                    onChanged: (v) =>
                        setState(() => _aiTrainingModel = v),
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Security Certifications ───────────────────────────────────────
            Text(
              'SECURITY CERTIFICATION',
              style: tt.labelSmall?.copyWith(
                color: scheme.onSurface.withAlpha(120),
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                CertBadge(icon: Icons.verified_user_outlined,  label: 'ISO 27001'),
                CertBadge(icon: Icons.health_and_safety_outlined, label: 'HIPAA READY'),
                CertBadge(icon: Icons.security_outlined,       label: 'SOC 2 TYPE II'),
                CertBadge(icon: Icons.shield_outlined,         label: '256-BIT'),
              ],
            ),

            const SizedBox(height: 28),

            // ── Data Archives ─────────────────────────────────────────────────
            Text('Data Archives',
                style:
                    tt.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            ControlCard(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Export My Data',
                      style: tt.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(
                    'Request a complete archive of your biometric, nutritional, and workout history.',
                    style: tt.bodySmall?.copyWith(
                        color:
                            scheme.onSurface.withAlpha(120),
                        height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ExportButton(
                          icon: Icons.code_rounded,
                          label: 'JSON',
                          isDark: isDark,
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ExportButton(
                          icon: Icons.grid_on_rounded,
                          label: 'CSV',
                          isDark: isDark,
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Danger Zone ───────────────────────────────────────────────────
            Text(
              'Danger Zone',
              style: tt.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12),

            ControlCard(
              isDark: isDark,
              borderColor: Colors.red.withAlpha(120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Delete Account',
                      style: tt.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(
                    'Once deleted, your data cannot be recovered. This action is permanent and immediate.',
                    style: tt.bodySmall?.copyWith(
                        color:
                            scheme.onSurface.withAlpha(120),
                        height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: Material(
                      color: Colors.red.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => _showDeleteDialog(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          child: Center(
                            child: Text(
                              'Delete Account',
                              style: tt.labelLarge?.copyWith(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Footer note ───────────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 14,
                    color: scheme.onSurface.withAlpha(120)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'SnackTrack uses decentralized encryption keys. Our staff cannot access your raw biometric logs even if requested. Your privacy is mathematically guaranteed.',
                    style: tt.bodySmall?.copyWith(
                      color: scheme.onSurface.withAlpha(120),
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Account',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure? This action is permanent and cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: scheme.onSurface)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthController>().logout();
            },
            child: const Text('Delete',
                style: TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}