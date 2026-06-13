import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_routes.dart';

// ─────────────────────────────────────────────────────────────────────────────
// sign_up_screen.dart
// Same design language as sign_in_screen.dart — just different fields & copy.
// ─────────────────────────────────────────────────────────────────────────────

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  bool _obscurePass    = true;
  bool _obscureConf    = true;
  bool _loading        = false;
  bool _agreedTerms    = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedTerms) return;

    setState(() => _loading = true);
    
    try {
      // Connect to AuthController to register the user structure completely
      await context.read<AuthController>().signUp(
            _nameCtrl.text.trim(),
            _emailCtrl.text.trim(),
            _passwordCtrl.text,
          );
      
      if (mounted) {
        context.go(AppRoutes.onboard); // → onboarding / profile setup
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll(RegExp(r'\[.*\]'), '').trim()),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Top bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SnackTrack', // Fixed typo
                    style: tt.headlineMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  // Back to sign in
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => context.pop(),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: scheme.primary,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // ── Hero text
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Create Your\n',
                      style: tt.displayLarge?.copyWith(
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    TextSpan(
                      text: 'Account',
                      style: tt.displayLarge?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Initialize your metabolic profile and unlock AI-powered nutritional intelligence.',
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
                    left: BorderSide(color: scheme.secondary, width: 3),
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
                child: Form(
                  key: _formKey, // Form wrapper added
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Full name
                      _FieldLabel('FULL NAME'),
                      const SizedBox(height: 8),
                      _InputField(
                        controller: _nameCtrl,
                        hint: 'Alex Thorne',
                        icon: Icons.person_outline_rounded,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Email
                      _FieldLabel('EMAIL ADDRESS'),
                      const SizedBox(height: 8),
                      _InputField(
                        controller: _emailCtrl,
                        hint: 'name@example.com',
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email address';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Password
                      _FieldLabel('PASSWORD'),
                      const SizedBox(height: 8),
                      _InputField(
                        controller: _passwordCtrl,
                        hint: '••••••••',
                        icon: Icons.lock_outline_rounded,
                        obscure: _obscurePass,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please choose a password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePass
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: scheme.onSurface.withAlpha(100),
                            size: 18,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePass = !_obscurePass),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Confirm password
                      _FieldLabel('CONFIRM PASSWORD'),
                      const SizedBox(height: 8),
                      _InputField(
                        controller: _confirmCtrl,
                        hint: '••••••••',
                        icon: Icons.lock_outline_rounded,
                        obscure: _obscureConf,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordCtrl.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConf
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: scheme.onSurface.withAlpha(100),
                            size: 18,
                          ),
                          onPressed: () =>
                              setState(() => _obscureConf = !_obscureConf),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Terms checkbox
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () =>
                              setState(() => _agreedTerms = !_agreedTerms),
                          borderRadius: BorderRadius.circular(8),
                          child: Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 20, height: 20,
                                decoration: BoxDecoration(
                                  color: _agreedTerms
                                      ? scheme.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: _agreedTerms
                                        ? scheme.primary
                                        : Theme.of(context).dividerColor,
                                    width: 1.5,
                                  ),
                                ),
                                child: _agreedTerms
                                    ? const Icon(Icons.check,
                                        color: Colors.white, size: 13)
                                    : null,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: tt.bodySmall,
                                    children: [
                                      const TextSpan(
                                          text: 'I agree to the '),
                                      TextSpan(
                                        text: 'Terms of Service',
                                        style: TextStyle(
                                          color: scheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const TextSpan(text: ' and '),
                                      TextSpan(
                                        text: 'Privacy Policy',
                                        style: TextStyle(
                                          color: scheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // CTA button
                      _GradientButton(
                        label: 'INITIALIZE PROFILE',
                        icon: Icons.arrow_forward_rounded,
                        loading: _loading,
                        enabled: _agreedTerms,
                        onTap: _submit, // Safe internal checking handles validation
                      ),

                      const SizedBox(height: 20),

                      // Divider
                      Row(
                        children: [
                          Expanded(
                              child: Divider(
                                  color: Theme.of(context).dividerColor)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'OR CONNECT WITH',
                              style: tt.labelSmall?.copyWith(letterSpacing: 1),
                            ),
                          ),
                          Expanded(
                              child: Divider(
                                  color: Theme.of(context).dividerColor)),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Social buttons
                      Row(
                        children: [
                          Expanded(
                            child: _SocialButton(
                              label: 'Google',
                              icon: Icons.g_mobiledata_rounded,
                              onTap: () {
                                // TODO: Connect Google Sign-Up logic
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SocialButton(
                              label: 'Apple',
                              icon: Icons.apple_rounded,
                              onTap: () {
                                // TODO: Connect Apple Sign-Up logic
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Sign in link
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: tt.bodyMedium?.copyWith(
                        color: scheme.onSurface.withAlpha(160),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.pop(),
                        borderRadius: BorderRadius.circular(4),
                        child: Text(
                          'Sign in',
                          style: tt.bodyMedium?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Field label helper ───────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        letterSpacing: 1.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared widgets
// ─────────────────────────────────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt     = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: tt.bodyMedium,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: tt.bodyMedium?.copyWith(
          color: scheme.onSurface.withAlpha(80),
        ),
        prefixIcon:
            Icon(icon, color: scheme.onSurface.withAlpha(120), size: 18),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isDark
            ? scheme.surface.withAlpha(180)
            : scheme.surfaceContainerHighest.withAlpha(60),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool loading;
  final bool enabled;
  final VoidCallback onTap;

  const _GradientButton({
    required this.label,
    required this.icon,
    required this.loading,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt     = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: (loading || !enabled) ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: enabled
                  ? [scheme.primary, scheme.secondary]
                  : [
                      scheme.onSurface.withAlpha(50),
                      scheme.onSurface.withAlpha(40),
                    ],
              begin: Alignment.centerLeft,
              end:   Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: scheme.primary.withAlpha(80),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: SizedBox(
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
                          label,
                          style: tt.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(icon, color: Colors.white, size: 18),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt     = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? scheme.surface.withAlpha(180) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: scheme.onSurface.withAlpha(180), size: 20),
              const SizedBox(width: 6),
              Text(label,
                  style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}