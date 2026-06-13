import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_assistant/core/widgets/ai_coach_fab.dart';
import 'package:health_assistant/views/notufucations/notifications_screen.dart';
import 'core/constants/app_routes.dart';
import 'core/widgets/bottom_nav_bar.dart';
import 'views/dashboard/dashboard_screen.dart';
import 'views/history/meal_history_screen.dart';
import 'views/meal_logging/add_meal_screen.dart';
import 'views/reports/weekly_report_screen.dart';
import 'views/profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, required this.initialIndex});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late NavItem _current;

  // Animation controller for the FAB pulse effect
  late final AnimationController _fabPulse;
  late final Animation<double> _fabScale;

  @override
  void initState() {
    super.initState();
    _current = NavItem.values[widget.initialIndex];

    _fabPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _fabScale = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _fabPulse, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _fabPulse.dispose();
    super.dispose();
  }

  Widget get _screen => switch (_current) {
    NavItem.dashboard => const DashboardScreen(),
    NavItem.history => const MealHistoryScreen(),
    NavItem.addMeal => const AddMealScreen(),
    NavItem.reports => const WeeklyReportScreen(),
    NavItem.profile => const ProfileScreen(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage("assets/images/person.png"),
              fit: BoxFit.fill,
            ),
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        title: Text(
          'SnakeTrack',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_none_outlined,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),

      body: _screen,

      // ── Floating Action Button → AI Coach ──────────────────────────────────
      floatingActionButton: ScaleTransition(
        scale: _fabScale,
        child: AiCoachFab(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      bottomNavigationBar: BottomNavBar(
        currentIndex: _current,
        onTap: (item) => setState(() => _current = item),
      ),
    );
  }
}
