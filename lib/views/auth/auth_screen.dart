import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_routes.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl     = TextEditingController();
  bool _isLogin       = true;

  @override
  void dispose() {
    _emailCtrl.dispose(); _passwordCtrl.dispose(); _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final controller = context.read<AuthController>();
    final success = _isLogin
        ? await controller.login(_emailCtrl.text, _passwordCtrl.text)
        : await controller.signup(_nameCtrl.text, _emailCtrl.text, _passwordCtrl.text);
    if (success && mounted) context.go(AppRoutes.main);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AuthController>();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_isLogin ? 'Welcome Back' : 'Create Account',
                  style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 32),
              if (!_isLogin) ...[
                CustomTextField(hint: 'Name', controller: _nameCtrl, prefixIcon: Icons.person_outline),
                const SizedBox(height: 12),
              ],
              CustomTextField(hint: 'Email',    controller: _emailCtrl,    prefixIcon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              CustomTextField(hint: 'Password', controller: _passwordCtrl, prefixIcon: Icons.lock_outline, obscure: true),
              if (controller.error != null) ...[
                const SizedBox(height: 12),
                Text(controller.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 24),
              CustomButton(label: _isLogin ? 'Login' : 'Sign Up', onPressed: _submit, isLoading: controller.isLoading),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(_isLogin ? 'Don\'t have an account? Sign Up' : 'Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
