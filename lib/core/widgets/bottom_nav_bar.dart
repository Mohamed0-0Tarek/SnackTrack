import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum NavItem { dashboard, history, addMeal, reports, profile }

class BottomNavBar extends StatelessWidget {
  final NavItem currentIndex;
  final ValueChanged<NavItem> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? CyberCortexColors.surface : LuminaColors.surface,
        border: Border(
          top: BorderSide(
            color: isDark ? CyberCortexColors.border : LuminaColors.border,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _NavBarItem(
                icon: Icons.home_rounded,
                label: 'Dashboard',
                isActive: currentIndex == NavItem.dashboard,
                onTap: () => onTap(NavItem.dashboard),
              ),
              _NavBarItem(
                icon: Icons.calendar_month_rounded,
                label: 'History',
                isActive: currentIndex == NavItem.history,
                onTap: () => onTap(NavItem.history),
              ),
              _AddMealButton(
                isActive: currentIndex == NavItem.addMeal,
                onTap: () => onTap(NavItem.addMeal),
              ),
              _NavBarItem(
                icon: Icons.bar_chart_rounded,
                label: 'Reports',
                isActive: currentIndex == NavItem.reports,
                onTap: () => onTap(NavItem.reports),
              ),
              _NavBarItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                isActive: currentIndex == NavItem.profile,
                onTap: () => onTap(NavItem.profile),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Regular nav item ───────────────────────────────────────────────────────────

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? CyberCortexColors.primary : LuminaColors.primary;
    final inactive = isDark ? CyberCortexColors.textSecondary : LuminaColors.textSecondary;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isActive ? primary.withAlpha(25) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isActive ? primary : inactive,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                color: isActive ? primary : inactive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Add Meal center button ─────────────────────────────────────────────────────

class _AddMealButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _AddMealButton({required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? CyberCortexColors.primary : LuminaColors.primary;
    final inactive = isDark ? CyberCortexColors.textSecondary : LuminaColors.textSecondary;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.black,
                size: 26,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Add Meal',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isActive ? primary : inactive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}