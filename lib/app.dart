import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'controllers/auth_controller.dart';
import 'controllers/meal_controller.dart';
import 'controllers/dashboard_controller.dart';
import 'controllers/ai_controller.dart';
import 'controllers/profile_controller.dart';
import 'controllers/history_controller.dart';
import 'core/network/dio_client.dart';
import 'services/auth_service.dart';
import 'services/meal_service.dart';
import 'services/ai_service.dart';
import 'views/splash/splash_screen.dart';
import 'views/auth/auth_screen.dart';
import 'views/meal_logging/meal_analysis_screen.dart';
import 'main_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final dio = DioClient();
    final authService = AuthService(dio);
    final mealService = MealService(dio);
    final aiService = AiService(dio);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController(authService)),
        ChangeNotifierProvider(create: (_) => MealController(mealService)),
        ChangeNotifierProvider(create: (_) => DashboardController(mealService)),
        ChangeNotifierProvider(create: (_) => AiController(aiService)),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => HistoryController(mealService)),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'SnakeTrack',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        routerConfig: _router,
      ),
    );
  }
}

final _router = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
    GoRoute(path: AppRoutes.auth, builder: (_, __) => const AuthScreen()),
    GoRoute(
      path: AppRoutes.main,
      builder: (_, __) => const MainScreen(initialIndex: 0),
    ),
    GoRoute(
      path: AppRoutes.mealHistory,
      builder: (_, __) => const MainScreen(initialIndex: 1),
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (_, __) => const MainScreen(initialIndex: 4),
    ),
    GoRoute(
      path: AppRoutes.analysis,
      builder: (_, __) => const MealAnalysisScreen(),
    ),
  ],
);
