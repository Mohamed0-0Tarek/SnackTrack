import 'package:flutter/material.dart';

class VideoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String duration;
  final Color bgColor;
  final VoidCallback onTap;

  const VideoCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail area
            Stack(
              children: [
                Container(
                  height: 130,
                  decoration: BoxDecoration(
                    color: bgColor.withOpacity(0.8),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.play_circle_filled_rounded,
                      color: Colors.white.withOpacity(0.4),
                      size: 48,
                    ),
                  ),
                ),
                // Duration badge
                Positioned(
                  bottom: 8,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      duration,
                      style: tt.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Text
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: tt.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: tt.bodySmall?.copyWith(
                      color: Colors.white54,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
