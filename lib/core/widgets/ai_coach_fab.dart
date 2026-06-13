import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_assistant/core/constants/app_routes.dart';

class AiCoachFab extends StatelessWidget {
  const AiCoachFab({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => context.push(AppRoutes.aiCoach),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [scheme.primary, scheme.secondary],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withAlpha(100),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.psychology_outlined,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              'AI Coach',
              style: tt.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
