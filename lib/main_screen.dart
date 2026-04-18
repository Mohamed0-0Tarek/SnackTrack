import 'package:flutter/material.dart';
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

class _MainScreenState extends State<MainScreen> {
  late NavItem _current;

  @override
  void initState() {
    super.initState();
    _current = NavItem.values[widget.initialIndex];
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
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: Theme.of(context).primaryColor,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: _screen,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _current,
        onTap: (item) => setState(() => _current = item),
      ),
    );
  }
}
