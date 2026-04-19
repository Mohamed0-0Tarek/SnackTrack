import 'package:flutter/material.dart';

class InputSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  QuickChip(label: 'Analyze my dinner 🍕'),
                  const SizedBox(width: 10),
                  QuickChip(label: 'Adjust macros for leg day 🏋'),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(
              children: [
                Icon(
                  Icons.attach_file_rounded,
                  color: scheme.onSurface.withAlpha(120),
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    style: tt.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Consult the Oracle...',
                      hintStyle: tt.bodyMedium?.copyWith(
                        color: scheme.onSurface.withAlpha(80),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.mic_none_rounded,
                  color: scheme.onSurface.withAlpha(120),
                  size: 22,
                ),
                const SizedBox(width: 10),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: scheme.onPrimary,
                    size: 20,
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

class QuickChip extends StatelessWidget {
  final String label;
  const QuickChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
