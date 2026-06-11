import 'package:flutter/material.dart';
import 'package:health_assistant/core/widgets/divider.dart';
import 'package:health_assistant/models/notification_model.dart';
import 'package:health_assistant/views/notufucations/widgets/notification_card.dart';
import 'package:health_assistant/views/notufucations/widgets/notification_tile.dart';
import 'package:health_assistant/views/notufucations/widgets/section_label.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<NotifItem> _todayNotifs = [
    NotifItem(
      icon: Icons.psychology_outlined,
      iconBg: Color(0xFF6A3DE8),
      title: 'Coach Insight',
      body:
          'Your metabolic rate is peaking after that morning session. Consider a protein-rich snack within the next 30 minutes.',
      time: '2m ago',
      tags: ['METABOLISM', 'HIGH PRIORITY'],
      isUnread: false,
    ),
    NotifItem(
      icon: Icons.water_drop_outlined,
      iconBg: Color(0xFF00B4DB),
      title: 'Hydration Alert',
      body:
          "You've only tracked 400ml today. Reach your goal of 2.5L to maintain peak focus.",
      time: '1h ago',
      tags: [],
      isUnread: false,
    ),
    NotifItem(
      icon: Icons.emoji_events_outlined,
      iconBg: Color(0xFF00B4DB),
      title: 'Goal Achievement',
      body:
          '7-Day Streak Unlocked! You\'ve maintained your macros for a full week. New badge added to profile.',
      time: '4h ago',
      tags: [],
      isUnread: true,
    ),
  ];

  final List<NotifItem> _previousNotifs = [
    NotifItem(
      icon: Icons.sync_rounded,
      iconBg: null,
      title: 'Health Sync Complete',
      body: 'All data from Apple Health has been imported successfully.',
      time: 'Yesterday',
      tags: [],
      isUnread: false,
    ),
    NotifItem(
      icon: Icons.people_outline_rounded,
      iconBg: null,
      title: 'Community Tip',
      body:
          '"Morning sun exposure helps regulate your circadian rhythm for better sleep."',
      time: '2 days ago',
      tags: [],
      isUnread: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt     = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F1629) : const Color(0xFFF4F4F4),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [

            // ── AppBar ───────────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1A2236)
                          : Colors.black87,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 16),
                  ),
                ),
                // Mark all read
                TextButton(
                  onPressed: () {
                    setState(() {
                      for (final n in _todayNotifs) {
                        n.isUnread = false;
                      }
                    });
                  },
                  child: Text(
                    'Mark all read',
                    style: tt.labelMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Title ────────────────────────────────────────────────────────
            Text(
              'Activity Feed',
              style: tt.displayMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Stay updated with your latest progress and insights.',
              style: tt.bodyMedium?.copyWith(
                color: scheme.onSurface.withAlpha(140),
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),

            // ── TODAY ────────────────────────────────────────────────────────
            SectionLabel(label: 'TODAY', scheme: scheme, tt: tt),
            const SizedBox(height: 8),
            NotifCard(
              isDark: isDark,
              child: Column(
                children: _todayNotifs.asMap().entries.map((e) {
                  final i    = e.key;
                  final item = e.value;
                  return Column(
                    children: [
                      NotifTile(
                        item: item,
                        isDark: isDark,
                        scheme: scheme,
                        tt: tt,
                        onTap: () => setState(() => item.isUnread = false),
                      ),
                      if (i < _todayNotifs.length - 1)
                        AppDivider(isDark: isDark),
                    ],
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // ── PREVIOUS ─────────────────────────────────────────────────────
            SectionLabel(label: 'PREVIOUS', scheme: scheme, tt: tt),
            const SizedBox(height: 8),
            NotifCard(
              isDark: isDark,
              child: Column(
                children: _previousNotifs.asMap().entries.map((e) {
                  final i    = e.key;
                  final item = e.value;
                  return Column(
                    children: [
                      NotifTile(
                        item: item,
                        isDark: isDark,
                        scheme: scheme,
                        tt: tt,
                        onTap: () {},
                      ),
                      if (i < _previousNotifs.length - 1)
                        AppDivider(isDark: isDark),
                    ],
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}