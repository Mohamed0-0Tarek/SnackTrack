import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/ai_controller.dart';
import 'widgets/hero_section.dart';
import 'widgets/ai_message.dart';
import 'widgets/user_message.dart';
import 'widgets/insight_card.dart';
import 'widgets/input_section.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ai_coach_screen.dart
// ─────────────────────────────────────────────────────────────────────────────

class AiCoachScreen extends StatefulWidget {
  const AiCoachScreen({super.key});

  @override
  State<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends State<AiCoachScreen> {
  final TextEditingController _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      // ── AppBar: gives back arrow automatically when pushed via GoRouter ────
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: scheme.primary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            // Small gradient brain icon
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [scheme.primary, scheme.secondary],
                ),
              ),
              child: const Icon(
                Icons.psychology_outlined,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Snake AI ',
                    style: tt.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  TextSpan(
                    text: 'Coach',
                    style: tt.headlineMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // LIVE badge
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: scheme.primary.withAlpha(30),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: scheme.primary.withAlpha(100)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  'LIVE',
                  style: tt.labelSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // ── Scrollable chat body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: const [
                  SizedBox(height: 24),
                  HeroSection(),
                  SizedBox(height: 28),
                  AiMessage(
                    time: '14:02',
                    message:
                        'Analyzing your last 48 hours. Your {metabolic velocity} has increased by 12% following that Zone 2 session. How are your energy levels feeling right now?',
                  ),
                  SizedBox(height: 16),
                  UserMessage(
                    time: '14:05',
                    message:
                        'Feeling a bit depleted. I think my glycogen levels are low after the morning fast.',
                  ),
                  SizedBox(height: 16),
                  InsightCard(),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // ── Quick prompts + input bar
          InputSection(),
        ],
      ),
    );
  }
}
