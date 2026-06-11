import 'package:flutter/material.dart';
import 'package:health_assistant/views/accessibility/widgets/reusable_card.dart';
import 'package:health_assistant/views/accessibility/widgets/square_slider_thumb.dart';
import 'package:health_assistant/views/accessibility/widgets/voice_sensitivity_option.dart';

class AccessibilityScreen extends StatefulWidget {
  const AccessibilityScreen({super.key});

  @override
  State<AccessibilityScreen> createState() => _AccessibilityScreenState();
}

class _AccessibilityScreenState extends State<AccessibilityScreen> {
  double _textSize       = 1; // 0=Compact, 1=Standard, 2=Enlarged
  bool   _highContrast   = false;
  int    _voiceSensitivity = 1; // 0=Quiet, 1=Balanced, 2=Highly Reactive
  bool   _adaptiveAssist = false;

  String get _textSizeLabel => ['COMPACT', 'STANDARD', 'ENLARGED'][_textSize.round()];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt     = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1629) : const Color(0xFFF4F4F4),
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

            const SizedBox(height: 24),

            // ── Title ────────────────────────────────────────────────────────
            Text(
              'Accessibility',
              style: tt.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Customize your experience for better visibility and ease of use. These settings apply across the entire application.',
              style: tt.bodyMedium?.copyWith(
                color: scheme.onSurface.withAlpha(100),
                height: 1.6,
              ),
            ),

            const SizedBox(height: 28),

            // ── Text Size card ───────────────────────────────────────────────
            ReCard(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF0F1629)
                              : const Color(0xFFF0F0F0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Tt',
                            style: tt.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Text size',
                                style: tt.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 3),
                            Text(
                              'Adjust the scale of all interface text.',
                              style: tt.bodySmall?.copyWith(
                                  color: scheme.onSurface.withAlpha(100),
                                  height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Slider row
                  Row(
                    children: [
                      Text('A',
                          style: tt.bodySmall?.copyWith(
                              color: scheme.onSurface.withAlpha(100),
                              fontSize: 12)),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 4,
                            thumbShape: SquareThumbShape(),
                            overlayShape:
                                const RoundSliderOverlayShape(overlayRadius: 16),
                            activeTrackColor: scheme.primary,
                            inactiveTrackColor:
                                scheme.primary.withAlpha(100),
                            thumbColor: Colors.white,
                          ),
                          child: Slider(
                            value: _textSize,
                            min: 0, max: 2, divisions: 2,
                            onChanged: (v) =>
                                setState(() => _textSize = v),
                          ),
                        ),
                      ),
                      Text('A',
                          style: tt.bodyLarge?.copyWith(
                              color: scheme.onSurface.withAlpha(100),
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),

                  // Labels
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: ['COMPACT', 'STANDARD', 'ENLARGED']
                          .map((l) => Text(
                                l,
                                style: tt.labelSmall?.copyWith(
                                  color: l == _textSizeLabel
                                      ? scheme.primary
                                      : scheme.onSurface.withAlpha(90),
                                  fontWeight: l == _textSizeLabel
                                      ? FontWeight.bold
                                      : FontWeight.w400,
                                  fontSize: 10,
                                  letterSpacing: 0.8,
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── High Contrast card ───────────────────────────────────────────
            ReCard(
              isDark: isDark,
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0F1629)
                          : const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.contrast_rounded,
                        color: scheme.onSurface, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('High contrast mode',
                            style: tt.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 3),
                        Text(
                          'Increases visual distinction between elements.',
                          style: tt.bodySmall?.copyWith(
                              color: scheme.onSurface.withAlpha(100),
                              height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Switch(
                    value: _highContrast,
                    onChanged: (v) => setState(() => _highContrast = v),
                    activeThumbColor: scheme.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Voice Input Sensitivity card ─────────────────────────────────
            ReCard(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: scheme.secondary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.mic_rounded,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Voice input sensitivity',
                                style: tt.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 3),
                            Text(
                              'Refine how the app listens for commands.',
                              style: tt.bodySmall?.copyWith(
                                  color: scheme.onSurface.withAlpha(100),
                                  height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // 3-option selector
                  Row(
                    children: [
                      VoiceOption(
                        icon: Icons.favorite_border_rounded,
                        label: 'QUIET',
                        index: 0,
                        selected: _voiceSensitivity,
                        scheme: scheme,
                        isDark: isDark,
                        onTap: () => setState(() => _voiceSensitivity = 0),
                      ),
                      const SizedBox(width: 8),
                      VoiceOption(
                        icon: Icons.balance_rounded,
                        label: 'BALANCED',
                        index: 1,
                        selected: _voiceSensitivity,
                        scheme: scheme,
                        isDark: isDark,
                        onTap: () => setState(() => _voiceSensitivity = 1),
                      ),
                      const SizedBox(width: 8),
                      VoiceOption(
                        icon: Icons.bolt_rounded,
                        label: 'HIGHLY\nREACTIVE',
                        index: 2,
                        selected: _voiceSensitivity,
                        scheme: scheme,
                        isDark: isDark,
                        onTap: () => setState(() => _voiceSensitivity = 2),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Info note
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0F1629)
                          : const Color(0xFFF4F4F4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 14,
                            color: scheme.onSurface.withAlpha(100)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Increased sensitivity may capture background noise in loud environments.',
                            style: tt.bodySmall?.copyWith(
                              color: scheme.onSurface.withAlpha(100),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Adaptive Assist card ─────────────────────────────────────────
            Container(
              width: double.infinity,
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
                    'Adaptive Assist',
                    style: tt.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Turn on automatic UI adjustments based on your usage patterns to minimize navigation fatigue.',
                    style: tt.bodySmall?.copyWith(
                        color: Colors.white70, height: 1.6),
                  ),
                  const SizedBox(height: 18),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _adaptiveAssist = !_adaptiveAssist),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 13),
                      decoration: BoxDecoration(
                        color: _adaptiveAssist
                            ? Colors.white
                            : Colors.white.withAlpha(50),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withAlpha(100),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _adaptiveAssist
                              ? 'Adaptive Mode On'
                              : 'Enable Adaptive Mode',
                          style: tt.labelLarge?.copyWith(
                            color: _adaptiveAssist
                                ? const Color(0xFF6A3DE8)
                                : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
