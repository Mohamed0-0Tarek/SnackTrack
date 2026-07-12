import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'controllers/auth_controller.dart';
import 'controllers/meal_controller.dart';
import 'controllers/dashboard_controller.dart';
import 'controllers/weekly_report_controller.dart';
import 'services/weekly_report_service.dart';
import 'controllers/ai_controller.dart';
import 'controllers/profile_controller.dart';
import 'views/settings/settings_screen.dart';
import 'controllers/history_controller.dart';
import 'controllers/setting_controller.dart';
import 'controllers/water_controller.dart';
import 'controllers/weight_controller.dart';
import 'controllers/recipe_controller.dart';
import 'services/firebase_auth_service.dart';
import 'services/meal_service.dart';
import 'services/ai_service.dart';
import 'services/water_service.dart';
import 'services/weight_service.dart';
import 'services/recipe_service.dart';
import 'views/splash/splash_screen.dart';
import 'views/auth/sign_in_screen.dart';
import 'views/auth/sign_up_screen.dart';
import 'views/auth/forgot_password_screen.dart';
import 'views/settings/change_password_screen.dart';
import 'views/weight/weight_tracking_screen.dart';
import 'views/recipes/recipe_list_screen.dart';
import 'views/recipes/recipe_form_screen.dart';
import 'views/recipes/recipe_detail_screen.dart';
import 'views/onboarding/onboarding_screen.dart';
import 'views/ai/weekly_summary_screen.dart';
import 'views/ai/ai_coach_screen.dart';
import 'views/meal_logging/meal_analysis_screen.dart';
import 'main_screen.dart';

/// App root.
///
/// Changes from the previous version:
/// - DioClient is gone. Nothing in this project talks to a REST backend
///   anymore — MealService and AiService both take Firestore/HTTP-to-LLM
///   dependencies directly instead of a shared Dio instance.
/// - AuthService -> FirebaseAuthService. The redirect callback's logic is
///   UNCHANGED — it still reads `_authController.user` — but that field is
///   now reliably populated by AuthController's internal authStateChanges
///   listener, including on cold start, which is the actual bug fix.
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

/// Maps the persisted `SettingController.textSize` slider value
/// (0 = Compact, 1 = Standard, 2 = Enlarged) to an actual text scale
/// factor. Single source of truth — if the scale ever needs tuning,
/// it changes here once, not in every screen that reads textSize.
double _textScaleForSetting(double textSize) {
  switch (textSize.round()) {
    case 0:
      return 0.9;
    case 2:
      return 1.25;
    default:
      return 1.0;
  }
}

/// Applies the accessibility-driven theme transforms on top of a base
/// light/dark [ThemeData], in one place, so `theme:`/`darkTheme:` below
/// stay a single line each instead of duplicating this branching twice.
ThemeData _accessibilityTheme(ThemeData base, SettingController settings) {
  var theme = base;
  if (settings.highContrast) theme = AppTheme.highContrast(theme);
  if (settings.adaptiveAssist) {
    theme = AppTheme.reducedMotion(theme);
    theme = AppTheme.largerTapTargets(theme);
  }
  return theme;
}

class _AppState extends State<App> with WidgetsBindingObserver {
  late final AuthController _authController;
  late final MealService _mealService;
  late final AiService _aiService;
  late final MealController _mealController;
  late final SettingController _settingController;
  late final WeeklyReportService _weeklyReportService;
  late final WaterService _waterService;
  late final WaterController _waterController;
  late final WeightService _weightService;
  late final WeightController _weightController;
  late final RecipeService _recipeService;
  late final RecipeController _recipeController;
  late final GoRouter _router;

  String? _lastKnownUid;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final authService = FirebaseAuthService();
    _authController = AuthController(authService);

    _mealService = MealService();
    _aiService = AiService();
    _mealController = MealController(_mealService, _aiService);
    _weeklyReportService = WeeklyReportService();
    _waterService = WaterService();
    _waterController = WaterController(_waterService);
    _weightService = WeightService();
    _weightController = WeightController(_weightService);
    _recipeService = RecipeService();
    _recipeController = RecipeController(_recipeService, _aiService);
    _settingController = SettingController();

    // SettingController's constructor calls loadSettings() once, but at
    // cold start Firebase auth may not have resolved yet — that call
    // would only load Hive/defaults, not Firestore. Reload settings
    // whenever auth transitions from signed-out to signed-in, so the
    // Firestore sync actually runs once a uid is available.
    _authController.addListener(_onAuthChanged);

    _router = GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: _authController,
      redirect: (context, state) {
        // Don't redirect until the first authStateChanges event has
        // landed — otherwise a logged-in user briefly looks logged-out
        // on cold start and gets bounced to /sign-in incorrectly.
        if (!_authController.isInitialized) return null;

        final bool loggedIn = _authController.user != null;
        final bool isSplashing = state.matchedLocation == AppRoutes.splash;
        final bool isAuthenticating = state.matchedLocation == AppRoutes.signIn ||
            state.matchedLocation == AppRoutes.signUp ||
            state.matchedLocation == AppRoutes.forgotPassword;

        final bool isOnboarded = _authController.user?.objective != null;

        if (isSplashing) {
          if (!loggedIn) return AppRoutes.signIn;
          if (!isOnboarded) return AppRoutes.onboard;
          return AppRoutes.main;
        }

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
        GoRoute(path: AppRoutes.forgotPassword, builder: (_, __) => const ForgotPasswordScreen()),
        GoRoute(path: AppRoutes.onboard, builder: (_, __) => const OnboardingScreen()),
        GoRoute(path: AppRoutes.main, builder: (_, __) => const MainScreen(initialIndex: 0)),
        GoRoute(path: AppRoutes.profile, builder: (_, __) => const MainScreen(initialIndex: 4)),
        GoRoute(path: AppRoutes.aiCoach, builder: (_, __) => const AiCoachScreen()),
        GoRoute(path: AppRoutes.mealHistory, builder: (_, __) => const MainScreen(initialIndex: 1)),
        GoRoute(path: AppRoutes.analysis, builder: (_, __) => const MealAnalysisScreen()),
        GoRoute(path: AppRoutes.weeklySummary, builder: (_, __) => const WeeklySummaryScreen()),
        GoRoute(path: AppRoutes.settings, builder: (_, __) => const AppSettingsScreen()),
        GoRoute(path: AppRoutes.changePassword, builder: (_, __) => const ChangePasswordScreen()),
        GoRoute(path: AppRoutes.weightTracking, builder: (_, __) => const WeightTrackingScreen()),
        GoRoute(path: AppRoutes.recipeList, builder: (_, __) => const RecipeListScreen()),
        GoRoute(path: AppRoutes.recipeCreate, builder: (_, context) {
          final recipe = context.extra as dynamic;
          return RecipeFormScreen(recipe: recipe);
        }),
        GoRoute(
          path: '${AppRoutes.recipeDetail}/:id',
          builder: (_, state) => RecipeDetailScreen(recipeId: state.pathParameters['id']!),
        ),
      ],
    );
  }

  void _onAuthChanged() {
    final currentUid = _authController.user?.id;
    if (currentUid != null && currentUid != _lastKnownUid) {
      // Transitioned into a signed-in state (or switched accounts) —
      // reload settings so the Firestore sync runs with a real uid.
      _settingController.loadSettings();
      _syncPendingMeals();
    }
    _lastKnownUid = currentUid;
  }

  /// Attempts to flush any offline-queued meals to Firestore.
  void _syncPendingMeals() {
    try {
      _mealController.syncPendingMeals();
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncPendingMeals();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authController.removeListener(_onAuthChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>.value(value: _authController),
        ChangeNotifierProvider<MealController>.value(value: _mealController),
        ChangeNotifierProvider(create: (_) => DashboardController(_mealService, _aiService)),
        ChangeNotifierProvider(create: (_) => AiController(_aiService)),
        ChangeNotifierProvider(create: (_) => WeeklyReportController(_weeklyReportService, _aiService)),
        ChangeNotifierProvider(create: (_) => ProfileController(_mealService)),
        ChangeNotifierProvider(create: (_) => HistoryController(_mealService)),
        ChangeNotifierProvider<SettingController>.value(value: _settingController),
        ChangeNotifierProvider<WaterController>.value(value: _waterController),
        ChangeNotifierProvider<WeightController>.value(value: _weightController),
        ChangeNotifierProvider<RecipeController>.value(value: _recipeController),
      ],
      child: Consumer<SettingController>(
        builder: (context, settings, _) => MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'SnackTrack',
          theme: _accessibilityTheme(AppTheme.light, settings),
          darkTheme: _accessibilityTheme(AppTheme.dark, settings),
          themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          routerConfig: _router,
          builder: (context, child) {
            final scale = _textScaleForSetting(settings.textSize);
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(scale),
                disableAnimations: settings.adaptiveAssist,
              ),
              child: child!,
            );
          },
        ),
      ),
    );
  }
}