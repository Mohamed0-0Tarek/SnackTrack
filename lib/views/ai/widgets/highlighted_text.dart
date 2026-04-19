import 'package:flutter/material.dart';

class HighlightedText extends StatelessWidget {
  final String raw;
  final TextStyle baseStyle;
  final TextStyle highlightStyle;

  const HighlightedText({
    required this.raw,
    required this.baseStyle,
    required this.highlightStyle,
  });

  @override
  Widget build(BuildContext context) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\{([^}]+)\}');
    int last = 0;
    for (final match in regex.allMatches(raw)) {
      if (match.start > last) {
        spans.add(
          TextSpan(text: raw.substring(last, match.start), style: baseStyle),
        );
      }
      spans.add(TextSpan(text: match.group(1), style: highlightStyle));
      last = match.end;
    }
    if (last < raw.length) {
      spans.add(TextSpan(text: raw.substring(last), style: baseStyle));
    }
    return RichText(text: TextSpan(children: spans));
  }
}
