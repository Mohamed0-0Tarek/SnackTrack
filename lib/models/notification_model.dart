// ── Data model ─────────────────────────────────────────────────────────────
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Firestore schema: users/{uid}/notifications/{notifId}
///   title, body, time (Timestamp), tags (List<String>), isUnread (bool),
///   type (String, optional — defaults to 'system')
///
/// `icon` / `iconBg` used to be required constructor params, which could
/// never come from Firestore. They're now computed getters derived from
/// `type`, so a document only needs the fields above.
class NotifItem {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final List<String> tags;
  final String type;
  bool isUnread;

  NotifItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.tags,
    required this.isUnread,
    this.type = 'system',
  });

  static const Map<String, IconData> _icons = {
    'coach': Icons.psychology_outlined,
    'hydration': Icons.water_drop_outlined,
    'achievement': Icons.emoji_events_outlined,
    'sync': Icons.sync_rounded,
    'community': Icons.people_outline_rounded,
    'system': Icons.notifications_outlined,
  };

  // Types not listed here fall back to the neutral/uncolored tile style
  // (same look the old hardcoded `iconBg: null` entries had).
  static const Map<String, Color> _iconColors = {
    'coach': Color(0xFF6A3DE8),
    'hydration': Color(0xFF00B4DB),
    'achievement': Color(0xFF00B4DB),
  };

  IconData get icon => _icons[type] ?? Icons.notifications_outlined;
  Color? get iconBg => _iconColors[type];

  /// Relative time string, e.g. "2m ago" — replaces the old hardcoded
  /// literal strings now that we have a real timestamp to derive it from.
  String get time {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${timestamp.month}/${timestamp.day}/${timestamp.year}';
  }

  bool get isToday {
    final now = DateTime.now();
    return timestamp.year == now.year &&
        timestamp.month == now.month &&
        timestamp.day == now.day;
  }

  factory NotifItem.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return NotifItem(
      id: doc.id,
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      timestamp: (data['time'] as Timestamp?)?.toDate() ?? DateTime.now(),
      tags: List<String>.from(data['tags'] as List? ?? const []),
      isUnread: data['isUnread'] as bool? ?? false,
      type: data['type'] as String? ?? 'system',
    );
  }

  Map<String, dynamic> toFirestoreMap() => {
        'title': title,
        'body': body,
        'time': Timestamp.fromDate(timestamp),
        'tags': tags,
        'isUnread': isUnread,
        'type': type,
      };
}
