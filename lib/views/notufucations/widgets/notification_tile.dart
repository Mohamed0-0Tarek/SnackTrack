import 'package:flutter/material.dart'; // example
import 'package:health_assistant/models/notification_model.dart';

class NotifTile extends StatelessWidget {
  final NotifItem   item;
  final bool         isDark;
  final ColorScheme  scheme;
  final TextTheme    tt;
  final VoidCallback onTap;

  const NotifTile({super.key, 
    required this.item,
    required this.isDark,
    required this.scheme,
    required this.tt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isColored = item.iconBg != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Icon
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: isColored
                      ? item.iconBg
                      : scheme.onSurface.withAlpha(30),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  item.icon,
                  color: isColored
                      ? Colors.white
                      : scheme.onSurface.withAlpha(128),
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Title + time row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: tt.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            Text(
                              item.time,
                              style: tt.labelSmall?.copyWith(
                                color: scheme.onSurface.withAlpha(102),
                              ),
                            ),
                            if (item.isUnread) ...[
                              const SizedBox(width: 6),
                              Container(
                                width: 8, height: 8,
                                decoration: BoxDecoration(
                                  color: scheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    // Body
                    Text(
                      item.body,
                      style: tt.bodySmall?.copyWith(
                        color: scheme.onSurface.withAlpha(140),
                        height: 1.5,
                      ),
                    ),

                    // Tags
                    if (item.tags.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        children: item.tags.map((tag) {
                          final isHighPriority = tag == 'HIGH PRIORITY';
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isHighPriority
                                  ? scheme.onSurface.withAlpha(30)
                                  : scheme.primary.withAlpha(26),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              tag,
                              style: tt.labelSmall?.copyWith(
                                color: isHighPriority
                                    ? scheme.onSurface.withAlpha(153)
                                    : scheme.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                                letterSpacing: 0.5,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}