import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/ai_controller.dart';
import 'widgets/hero_section.dart';
import 'widgets/ai_message.dart';
import 'widgets/user_message.dart';

/// ## What changed in this file
/// Previously the entire chat body was hardcoded static widgets —
/// `AiMessage`, `UserMessage`, and `InsightCard` were all `const`
/// literals with no connection to `AiController`. The input bar had a
/// `TextField` that didn't actually send anything.
///
/// Now:
/// - `initState` calls `AiController.loadConversation()` to restore
///   the last persisted conversation from Firestore.
/// - The message list is built from `controller.messages` — real data.
/// - The send button calls `AiController.sendMessage()`.
/// - A typing indicator shows while `controller.isLoading`.
/// - The clear button starts a fresh conversation via `clearChat()`.
class AiCoachScreen extends StatefulWidget {
  const AiCoachScreen({super.key});

  @override
  State<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends State<AiCoachScreen> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AiController>().loadConversation();
    });
  }

  @override
  void dispose() {
    _input.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _send() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    _input.clear();
    await context.read<AiController>().sendMessage(text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AiController>();
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
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
          // Clear chat button
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: scheme.onSurface.withAlpha(120),
              size: 22,
            ),
            tooltip: 'New conversation',
            onPressed: controller.isLoading ? null : () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Start new conversation?'),
                  content: const Text(
                    'This will clear the current chat. Your history is saved in your account.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.read<AiController>().clearChat();
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
            },
          ),
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
          // ── Chat body ──────────────────────────────────────────────────
          Expanded(
            child: controller.isLoadingHistory
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 24),
                    itemCount: _itemCount(controller),
                    itemBuilder: (_, i) => _buildItem(context, controller, i),
                  ),
          ),

          // ── Error banner ───────────────────────────────────────────────
          if (controller.error != null)
            Container(
              color: scheme.error.withAlpha(20),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.error_outline,
                      color: scheme.error, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      controller.error!,
                      style:
                          tt.bodySmall?.copyWith(color: scheme.error),
                    ),
                  ),
                ],
              ),
            ),

          // ── Input bar ─────────────────────────────────────────────────
          _InputBar(
            controller: _input,
            isLoading: controller.isLoading,
            onSend: _send,
            quickPrompts: const [
              'Analyze my nutrition today 🍕',
              'Adjust macros for leg day 🏋',
            ],
          ),
        ],
      ),
    );
  }

  int _itemCount(AiController controller) {
    // Hero section + messages + optional typing indicator
    int count = 1 + controller.messages.length;
    if (controller.isLoading) count++;
    return count;
  }

  Widget _buildItem(
      BuildContext context, AiController controller, int index) {
    // Index 0 is always the hero section
    if (index == 0) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 28),
        child: HeroSection(),
      );
    }

    final msgIndex = index - 1;

    // Last item: typing indicator when AI is responding
    if (controller.isLoading && msgIndex == controller.messages.length) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: _TypingIndicator(),
      );
    }

    final msg = controller.messages[msgIndex];
    final time = _formatTime(DateTime.now());
    final isUser = msg['role'] == 'user';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: isUser
          ? UserMessage(time: time, message: msg['content'] ?? '')
          : AiMessage(time: time, message: msg['content'] ?? ''),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ── Typing indicator ──────────────────────────────────────────────────────────
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _opacity = Tween(begin: 0.3, end: 1.0).animate(_anim);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        Text(
          'SNAKE AI',
          style: tt.labelSmall?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(width: 8),
        FadeTransition(
          opacity: _opacity,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border:
                  Border(left: BorderSide(color: scheme.primary, width: 3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (i) => AnimatedBuilder(
                  animation: _anim,
                  builder: (_, __) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: scheme.primary.withOpacity(
                        ((_anim.value + i * 0.33) % 1.0).clamp(0.3, 1.0),
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Input bar ─────────────────────────────────────────────────────────────────
class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSend;
  final List<String> quickPrompts;

  const _InputBar({
    required this.controller,
    required this.isLoading,
    required this.onSend,
    required this.quickPrompts,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border:
            Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Column(
        children: [
          // Quick prompt chips
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: quickPrompts
                    .map((label) => Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: _QuickChip(
                            label: label,
                            onTap: () {
                              controller.text = label;
                              onSend();
                            },
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
          // Text field + send button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: tt.bodyMedium,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => isLoading ? null : onSend(),
                    decoration: InputDecoration(
                      hintText: 'Consult the Oracle…',
                      hintStyle: tt.bodyMedium?.copyWith(
                        color: scheme.onSurface.withAlpha(80),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: isLoading ? null : onSend,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isLoading
                          ? scheme.primary.withAlpha(80)
                          : scheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(10),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            Icons.arrow_forward_rounded,
                            color: scheme.onPrimary,
                            size: 20,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: scheme.primary.withAlpha(100)),
            color: scheme.primary.withAlpha(15),
          ),
          child: Text(
            label,
            style: tt.labelMedium?.copyWith(color: scheme.primary),
          ),
        ),
      ),
    );
  }
}
