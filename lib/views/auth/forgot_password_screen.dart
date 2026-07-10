import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:snacktrack/controllers/auth_controller.dart';
import 'package:snacktrack/core/constants/app_colors.dart';
import 'package:snacktrack/core/constants/app_routes.dart';
import 'package:snacktrack/core/widgets/custom_text_field.dart';
import 'package:snacktrack/views/auth/widgets/error_banner.dart';
import 'package:snacktrack/views/auth/widgets/gradient_button.dart';

// ─────────────────────────────────────────────────────────────────────────────
// forgot_password_screen.dart
// Allows users to request a password-reset email from Firebase Auth.
// Uses the same card-based layout and theming as the sign-in screen.
// ─────────────────────────────────────────────────────────────────────────────

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await context.read<AuthController>().sendPasswordReset(
        _emailCtrl.text.trim(),
      );
      if (mounted && context.read<AuthController>().error == null) {
        setState(() => _sent = true);
      }
    } catch (_) {
      // Error state is handled inside AuthController.
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? CyberCortexColors.primary : LuminaColors.primary;
    final second = isDark
        ? CyberCortexColors.secondary
        : LuminaColors.secondary;
    final tt = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Back button
              GestureDetector(
                onTap: () => context.pop(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_back_rounded,
                      color: scheme.onSurface.withAlpha(180),
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Back to Sign In',
                      style: tt.labelMedium?.copyWith(
                        color: scheme.onSurface.withAlpha(180),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // ── Hero text
              Text(
                'Reset Password',
                style: tt.displayLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                _sent
                    ? 'A password reset link has been sent to your email address.'
                    : 'Enter the email address associated with your account and we\'ll send you a link to reset your password.',
                style: tt.bodyMedium?.copyWith(
                  color: scheme.onSurface.withAlpha(160),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),

              // ── Form card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border(
                    left: BorderSide(color: scheme.primary, width: 3),
                  ),
                  boxShadow: isDark
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withAlpha(18),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: _sent ? _buildSuccessView(tt, scheme) : _buildForm(controller, primary, second),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm(AuthController controller, Color primary, Color secondary) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            hint: 'Email address',
            controller: _emailCtrl,
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) =>
                v == null || !v.contains('@') ? 'Enter a valid email' : null,
          ),
          if (controller.error != null) ...[
            const SizedBox(height: 12),
            ErrorBanner(message: controller.error!),
          ],
          const SizedBox(height: 20),
          GradientButton(
            label: 'Send Reset Link',
            isLoading: controller.isLoading,
            primary: primary,
            secondary: secondary,
            onTap: _submit,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(TextTheme tt, ColorScheme scheme) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Icon(
          Icons.mark_email_read_rounded,
          color: scheme.primary,
          size: 56,
        ),
        const SizedBox(height: 16),
        Text(
          'Email Sent',
          style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Check your inbox and follow the link in the email to set a new password.',
          style: tt.bodyMedium?.copyWith(
            color: scheme.onSurface.withAlpha(160),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        GradientButton(
          label: 'Back to Sign In',
          isLoading: false,
          primary: CyberCortexColors.primary,
          secondary: CyberCortexColors.secondary,
          onTap: () => context.go(AppRoutes.signIn),
        ),
      ],
    );
  }
}
