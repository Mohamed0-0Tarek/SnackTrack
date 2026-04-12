import 'package:flutter/material.dart';
import 'core/widgets/bottom_nav_bar.dart';
import 'views/dashboard/dashboard_screen.dart';
import 'views/history/meal_history_screen.dart';
import 'views/meal_logging/add_meal_screen.dart';
import 'views/reports/weekly_report_screen.dart';
import 'views/profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  NavItem _current = NavItem.dashboard;

  Widget get _screen => switch (_current) {
    NavItem.dashboard => const DashboardScreen(),
    NavItem.history   => const MealHistoryScreen(),
    NavItem.addMeal   => const AddMealScreen(),
    NavItem.reports   => const WeeklyReportScreen(),
    NavItem.profile   => const ProfileScreen(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screen,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _current,
        onTap: (item) => setState(() => _current = item),
      ),
    );
  }
}
