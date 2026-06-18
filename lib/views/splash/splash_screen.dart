import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_routes.dart';
import '../../controllers/auth_controller.dart';

/// Splash screen, now driven by real Firebase auth state instead of a
/// Hive token check.
///
/// The old version did:
///   final token = StorageService.getToken();
///   context.go(token != null ? AppRoutes.main : AppRoutes.signIn);
///
/// That's wrong for two reasons: (1) a Hive token can outlive a Firebase
/// session being revoked/expired elsewhere, and (2) it duplicates the
/// session-of-truth that AuthController/GoRouter's redirect already owns.
///
/// Now this screen just waits for AuthController to finish its first
/// authStateChanges tick, then lets app.dart's redirect callback decide
/// where to go — this screen itself doesn't pick a destination anymore,
/// it just shows the splash UI until the router is ready to redirect.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();

    // Once Firebase has reported its initial auth state, leave the splash
    // route. GoRouter's redirect callback in app.dart will then send the
    // user to /sign-in, /onboarding, or /main as appropriate — this
    // screen doesn't need that logic duplicated here.
    if (authController.isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(AppRoutes.main);
      });
    }

    return Scaffold(
      body: Center(
        child: Text(
          'SnackTrack',
          style: Theme.of(context).textTheme.displayLarge,
        ),
      ),
    );
  }
}
