import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool outlined;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.outlined  = false,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: outlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _child(primary),
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _child(Colors.black),
            ),
    );
  }

  Widget _child(Color color) => isLoading
      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: color, strokeWidth: 2))
      : Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: color));
}
