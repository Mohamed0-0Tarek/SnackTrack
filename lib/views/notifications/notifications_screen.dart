import 'package:flutter/material.dart';
import 'package:snacktrack/core/widgets/divider.dart';
import 'package:snacktrack/models/notification_model.dart';
import 'package:snacktrack/services/notification_service.dart';
import 'package:snacktrack/views/notifications/widgets/notification_card.dart';
import 'package:snacktrack/views/notifications/widgets/notification_tile.dart';
import 'package:snacktrack/views/notifications/widgets/section_label.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Instantiated directly (same lightweight-service pattern the screen
  // already leaned toward) rather than via Provider — there's no
  // NotificationController elsewhere in the app to hang this off of.
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F1629)
          : const Color(0xFFF4F4F4),
      body: SafeArea(
        child: StreamBuilder<List<NotifItem>>(
          stream: _notificationService.watchNotifications(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Couldn\'t load notifications. Pull down to try again.',
                    textAlign: TextAlign.center,
                    style: tt.bodyMedium?.copyWith(
                      color: scheme.onSurface.withAlpha(140),
                    ),
                  ),
                ),
              );
            }

            final all = snapshot.data ?? const <NotifItem>[];
            final todayNotifs = all.where((n) => n.isToday).toList();
            final previousNotifs = all.where((n) => !n.isToday).toList();

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // ── AppBar ─────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1A2236)
                              : Colors.black87,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: all.any((n) => n.isUnread)
                          ? () => _notificationService.markAllAsRead(
                              all
                                  .where((n) => n.isUnread)
                                  .map((n) => n.id)
                                  .toList(),
                            )
                          : null,
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

                // ── Title ──────────────────────────────────────────────
                Text(
                  'Activity Feed',
                  style: tt.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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

                if (all.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Center(
                      child: Text(
                        'No notifications yet.',
                        style: tt.bodyMedium?.copyWith(
                          color: scheme.onSurface.withAlpha(140),
                        ),
                      ),
                    ),
                  ),

                // ── TODAY ──────────────────────────────────────────────
                if (todayNotifs.isNotEmpty) ...[
                  SectionLabel(label: 'TODAY', scheme: scheme, tt: tt),
                  const SizedBox(height: 8),
                  NotifCard(
                    isDark: isDark,
                    child: Column(
                      children: todayNotifs.asMap().entries.map((e) {
                        final i = e.key;
                        final item = e.value;
                        return Column(
                          children: [
                            NotifTile(
                              item: item,
                              isDark: isDark,
                              scheme: scheme,
                              tt: tt,
                              onTap: () =>
                                  _notificationService.markAsRead(item.id),
                            ),
                            if (i < todayNotifs.length - 1)
                              AppDivider(isDark: isDark),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // ── PREVIOUS ───────────────────────────────────────────
                if (previousNotifs.isNotEmpty) ...[
                  SectionLabel(label: 'PREVIOUS', scheme: scheme, tt: tt),
                  const SizedBox(height: 8),
                  NotifCard(
                    isDark: isDark,
                    child: Column(
                      children: previousNotifs.asMap().entries.map((e) {
                        final i = e.key;
                        final item = e.value;
                        return Column(
                          children: [
                            NotifTile(
                              item: item,
                              isDark: isDark,
                              scheme: scheme,
                              tt: tt,
                              onTap: () =>
                                  _notificationService.markAsRead(item.id),
                            ),
                            if (i < previousNotifs.length - 1)
                              AppDivider(isDark: isDark),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
