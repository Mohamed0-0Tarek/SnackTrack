// ── Data model ─────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';

class NotifItem {
  final IconData    icon;
  final Color?      iconBg;
  final String      title;
  final String      body;
  final String      time;
  final List<String> tags;
  bool              isUnread;

  NotifItem({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.body,
    required this.time,
    required this.tags,
    required this.isUnread,
  });
}