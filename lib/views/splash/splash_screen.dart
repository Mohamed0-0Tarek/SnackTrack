import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_routes.dart';
import '../../services/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final token = StorageService.getToken();
    context.go(token != null ? AppRoutes.main : AppRoutes.profile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('NutriFit AI', style: Theme.of(context).textTheme.displayLarge),
      ),
    );
  }
}
