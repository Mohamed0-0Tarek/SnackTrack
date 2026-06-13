import 'package:flutter/material.dart';
import 'package:health_assistant/views/support/widgets/knowledge_title.dart';
import 'package:health_assistant/views/support/widgets/video_card.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _searchCtrl = TextEditingController();

  final List<String> _popularTags = ['Data Sync', 'Security', 'Pro Subscription'];

  final List<Map<String, dynamic>> _knowledgeBase = [
    {
      'icon': Icons.rocket_launch_outlined,
      'color': Color(0xFF00B4DB),
      'title': 'Getting Started',
      'subtitle': 'Everything you need to know to get up and running with NutriFit.',
    },
    {
      'icon': Icons.person_outline_rounded,
      'color': Color(0xFF6A3DE8),
      'title': 'Account & Safety',
      'subtitle': 'Manage your profile, security settings, and privacy preferences.',
    },
    {
      'icon': Icons.receipt_long_outlined,
      'color': Color(0xFF00B4DB),
      'title': 'Billing',
      'subtitle': 'Questions about invoices, plans, and subscription management.',
    },
    {
      'icon': Icons.code_rounded,
      'color': Color(0xFF6A3DE8),
      'title': 'API & Webhooks',
      'subtitle': 'Technical documentation for developers and integrations.',
    },
  ];

  final List<Map<String, dynamic>> _videos = [
    {
      'title': 'Mastering the Meal Analysis Engine',
      'subtitle': 'Learn how to configure advanced AI analysis for precision nutrition data.',
      'duration': '12:45',
      'color': Color(0xFF0A2A2A),
    },
    {
      'title': 'Visualizing Growth Trends',
      'subtitle': 'Deep dive into our custom visualization tools and reporting features.',
      'duration': '08:20',
      'color': Color(0xFF0A1A2A),
    },
    {
      'title': 'Setting Up Custom Meal Plans',
      'subtitle': 'Step-by-step guide to connecting NutriFit to your existing workflow.',
      'duration': '15:10',
      'color': Color(0xFF1A1A2A),
    },
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt     = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [

            // ── AppBar ─────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A2236) : Colors.black87,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 16),
                    ),
                  ),
                  Icon(Icons.notifications_outlined,
                      color: scheme.onSurface, size: 26),
                ],
              ),
            ),

            // ── Hero search card ───────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF00B4DB), Color(0xFF6A3DE8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How can we\nhelp?',
                    style: tt.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Search bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(70),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, color: Colors.white70, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Search for documentation...',
                              hintStyle: TextStyle(color: Colors.white54, fontSize: 13),
                              isDense: true,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Popular tags
                  Row(
                    children: [
                      Text(
                        'Popular:',
                        style: tt.labelSmall?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _popularTags.map((tag) => GestureDetector(
                            onTap: () => _searchCtrl.text = tag,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(70),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                tag,
                                style: tt.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          )).toList(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Knowledge Base ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Knowledge Base',
                      style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: [
                        Text('View All',
                            style: tt.labelMedium?.copyWith(
                                color: scheme.primary,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded,
                            size: 16, color: scheme.primary),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Explore categories to find detailed documentation',
                style: tt.bodySmall?.copyWith(
                    color: scheme.onSurface.withAlpha(120)),
              ),
            ),

            const SizedBox(height: 16),

            // Knowledge items
            ..._knowledgeBase.map((item) => KnowledgeTile(
                  icon: item['icon'] as IconData,
                  iconColor: item['color'] as Color,
                  title: item['title'] as String,
                  subtitle: item['subtitle'] as String,
                  isDark: isDark,
                  onTap: () {},
                )),

            const SizedBox(height: 28),

            // ── Video Masterclass ──────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1629),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.play_circle_outline_rounded,
                          color: Color(0xFF00B4DB), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'VIDEO SERIES',
                        style: tt.labelSmall?.copyWith(
                          color: const Color(0xFF00B4DB),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Video Masterclass',
                    style: tt.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Watch all button
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.play_arrow_rounded,
                              color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Watch All Tutorials',
                            style: tt.labelMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Video cards
                  ..._videos.map((v) => VideoCard(
                        title: v['title'] as String,
                        subtitle: v['subtitle'] as String,
                        duration: v['duration'] as String,
                        bgColor: v['color'] as Color,
                        onTap: () {},
                      )),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Still need assistance ──────────────────────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2236) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: scheme.onSurface.withAlpha(50),
                  width: 1,
                ),
                boxShadow: isDark ? null : [
                  BoxShadow(
                    color: Colors.black.withAlpha(100),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Still need assistance?',
                    style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Our expert support team is available 24/7 to help you with any technical challenges or account questions.',
                    style: tt.bodySmall?.copyWith(
                        color: scheme.onSurface.withAlpha(120),
                        height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  // Submit ticket button
                  Material(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.confirmation_number_outlined,
                                color: Colors.black, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              'Submit Support Ticket',
                              style: tt.labelLarge?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Live chat button
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: scheme.onSurface.withAlpha(120),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Live Chat',
                            style: tt.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Join Community ─────────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2236) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: scheme.onSurface.withAlpha(50),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Join our Community',
                    style: tt.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Connect with other SnackTrack users, share tips, and get inspired by successful workflows.',
                    style: tt.bodySmall?.copyWith(
                        color: scheme.onSurface.withAlpha(120),
                        height: 1.5),
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: [
                        Text(
                          'Join the Discord',
                          style: tt.labelMedium?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.open_in_new_rounded,
                            size: 14, color: scheme.primary),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}