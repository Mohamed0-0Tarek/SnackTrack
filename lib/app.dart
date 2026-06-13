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
import 'controllers/setting_controller.dart';
import 'core/network/dio_client.dart';
import 'services/auth_service.dart';
import 'services/meal_service.dart';
import 'services/ai_service.dart';
import 'services/storage_service.dart';
import 'views/splash/splash_screen.dart';
import 'views/auth/sign_in_screen.dart';
import 'views/auth/sign_up_screen.dart';
import 'views/onboarding/onboarding_screen.dart';
import 'views/ai/weekly_summary_screen.dart';
import 'views/ai/ai_coach_screen.dart';
import 'views/meal_logging/meal_analysis_screen.dart';
import 'main_screen.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  // 1. Declare the controller at the State level so it persists
  late final AuthController _authController;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    
    final authService = AuthService();
    // 2. Initialize the single source of truth for auth state
    _authController = AuthController(authService);

    _router = GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: _authController, // Listening to the correct instance
      redirect: (context, state) {
        final bool loggedIn = _authController.user != null;
        final bool isSplashing = state.matchedLocation == AppRoutes.splash;
        final bool isAuthenticating = state.matchedLocation == AppRoutes.signIn || 
                                      state.matchedLocation == AppRoutes.signUp;

        final bool isOnboarded = _authController.user?.objective != null;

        if (isSplashing) return null;

        if (!loggedIn) {
          return isAuthenticating ? null : AppRoutes.signIn;
        }

        if (!isOnboarded) {
          return state.matchedLocation == AppRoutes.onboard ? null : AppRoutes.onboard;
        }

        if (isAuthenticating || state.matchedLocation == AppRoutes.onboard) {
          return AppRoutes.main;
        }

        return null;
      },
      routes: [
        GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
        GoRoute(path: AppRoutes.signIn, builder: (_, __) => const SignInScreen()),
        GoRoute(path: AppRoutes.signUp, builder: (_, __) => const SignUpScreen()),
        GoRoute(path: AppRoutes.onboard, builder: (_, __) => const OnboardingScreen()),
        GoRoute(path: AppRoutes.main, builder: (_, __) => const MainScreen(initialIndex: 0)),
        GoRoute(path: AppRoutes.profile, builder: (_, __) => const MainScreen(initialIndex: 4)),
        GoRoute(path: AppRoutes.aiCoach, builder: (_, __) => const AiCoachScreen()),
        GoRoute(path: AppRoutes.mealHistory, builder: (_, __) => const MainScreen(initialIndex: 1)),
        GoRoute(path: AppRoutes.analysis, builder: (_, __) => const MealAnalysisScreen()),
        GoRoute(path: AppRoutes.weeklySummary, builder: (_, __) => const WeeklySummaryScreen()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dio = DioClient();
    final mealService = MealService(dio);
    final aiService = AiService(dio);

    return MultiProvider(
      providers: [
        // 3. Use .value to provide the exact instance managed by this State
        ChangeNotifierProvider<AuthController>.value(value: _authController),
        ChangeNotifierProvider(create: (_) => MealController(mealService)),
        ChangeNotifierProvider(create: (_) => DashboardController(mealService)),
        ChangeNotifierProvider(create: (_) => AiController(aiService)),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => HistoryController(mealService)),
        ChangeNotifierProvider(create: (_) => SettingsController()),
      ],
      child: Consumer<SettingsController>(
        builder: (context, settings, _) => MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'SnackTrack',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          routerConfig: _router,
        ),
      ),
    );
  }
}