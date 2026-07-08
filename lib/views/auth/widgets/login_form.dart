import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snacktrack/controllers/auth_controller.dart';
import 'package:snacktrack/core/constants/app_colors.dart';
import 'package:snacktrack/core/constants/app_routes.dart';
import 'package:snacktrack/core/widgets/custom_text_field.dart';
import 'package:snacktrack/views/auth/widgets/error_banner.dart';
import 'package:snacktrack/views/auth/widgets/gradient_button.dart';
import 'package:snacktrack/views/auth/widgets/or_divider.dart';
import 'package:snacktrack/views/auth/widgets/social_button.dart';
import 'package:provider/provider.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await context.read<AuthController>().signIn(
        _emailCtrl.text.trim(),
        _passCtrl.text.trim(),
      );
      if (mounted && context.read<AuthController>().error == null) {
        context.go(AppRoutes.main);
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
          const SizedBox(height: 14),
          CustomTextField(
            hint: 'Password',
            controller: _passCtrl,
            prefixIcon: Icons.lock_outline_rounded,
            obscure: _obscure,
            validator: (v) =>
                v == null || v.length < 6 ? 'Min 6 characters' : null,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: Text(
                'Forgot password?',
                style: tt.labelMedium?.copyWith(color: primary),
              ),
            ),
          ),
          if (controller.error != null) ...[
            ErrorBanner(message: controller.error!),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 8),
          GradientButton(
            label: 'Login',
            isLoading: controller.isLoading,
            primary: primary,
            secondary: second,
            onTap: _submit,
          ),
          const SizedBox(height: 24),
          OrDivider(scheme: scheme, tt: tt),
          const SizedBox(height: 24),
          SocialButton(
            icon: Icons.g_mobiledata_rounded,
            label: 'Continue with Google',
            isDark: isDark,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
