import 'package:flutter/material.dart';

class AppDivider extends StatelessWidget {
  final bool isDark;

  const AppDivider({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      color: isDark
          ? Colors.white.withAlpha(20)
          : Colors.black.withAlpha(20),
    );
  }
}