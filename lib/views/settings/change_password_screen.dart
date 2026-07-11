import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:snacktrack/controllers/auth_controller.dart';
import 'package:snacktrack/core/constants/app_colors.dart';
import 'package:snacktrack/views/auth/widgets/error_banner.dart';
import 'package:snacktrack/views/auth/widgets/gradient_button.dart';
import 'package:snacktrack/views/settings/widgets/section_card_wrapper.dart';
import 'package:snacktrack/views/settings/widgets/section_header.dart';

// ─────────────────────────────────────────────────────────────────────────────
// change_password_screen.dart
// Allows an authenticated user to change their password. Firebase requires
// reauthentication first — the user enters their current password, then the
// new password twice. On success the screen shows a confirmation and pops.
// ─────────────────────────────────────────────────────────────────────────────

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _success = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await context.read<AuthController>().changePassword(
        currentPassword: _currentCtrl.text.trim(),
        newPassword: _newCtrl.text.trim(),
      );
      if (mounted && context.read<AuthController>().error == null) {
        setState(() => _success = true);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final primary = isDark ? CyberCortexColors.primary : LuminaColors.primary;
    final second = isDark
        ? CyberCortexColors.secondary
        : LuminaColors.secondary;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F1629)
          : const Color(0xFFF4F4F4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
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
                    'Change Password',
                    style: tt.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Form card ───────────────────────────────────────────
              SectionCard(
                isDark: isDark,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      icon: Icons.lock_outline_rounded,
                      label: 'Update Password',
                      iconColor: scheme.primary,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Enter your current password and a new password.',
                      style: tt.bodySmall?.copyWith(
                        color: scheme.onSurface.withAlpha(120),
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (_success)
                      _buildSuccessView(tt, scheme, primary, second)
                    else
                      _buildForm(auth, primary, second, tt, scheme),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm(
    AuthController auth,
    Color primary,
    Color secondary,
    TextTheme tt,
    ColorScheme scheme,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPasswordField(
            controller: _currentCtrl,
            hint: 'Current password',
            obscure: _obscureCurrent,
            toggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
            validator: (v) =>
                v == null || v.isEmpty ? 'Enter your current password' : null,
          ),
          const SizedBox(height: 16),
          _buildPasswordField(
            controller: _newCtrl,
            hint: 'New password',
            obscure: _obscureNew,
            toggle: () => setState(() => _obscureNew = !_obscureNew),
            validator: (v) =>
                v == null || v.length < 6 ? 'Min 6 characters' : null,
          ),
          const SizedBox(height: 16),
          _buildPasswordField(
            controller: _confirmCtrl,
            hint: 'Confirm new password',
            obscure: _obscureConfirm,
            toggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
            validator: (v) =>
                v != _newCtrl.text.trim() ? 'Passwords do not match' : null,
          ),

          if (auth.error != null) ...[
            const SizedBox(height: 12),
            ErrorBanner(message: auth.error!),
          ],

          const SizedBox(height: 20),
          GradientButton(
            label: 'Update Password',
            isLoading: auth.isLoading,
            primary: primary,
            secondary: secondary,
            onTap: _submit,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(
    TextTheme tt,
    ColorScheme scheme,
    Color primary,
    Color secondary,
  ) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Icon(
          Icons.check_circle_outline_rounded,
          color: scheme.primary,
          size: 56,
        ),
        const SizedBox(height: 16),
        Text(
          'Password Updated',
          style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Your password has been changed successfully.',
          style: tt.bodyMedium?.copyWith(
            color: scheme.onSurface.withAlpha(160),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        GradientButton(
          label: 'Done',
          isLoading: false,
          primary: primary,
          secondary: secondary,
          onTap: () => context.pop(),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback toggle,
    required String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 20,
          ),
          onPressed: toggle,
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
