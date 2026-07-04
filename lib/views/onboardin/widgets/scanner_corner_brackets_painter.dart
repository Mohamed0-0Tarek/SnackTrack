import 'package:flutter/material.dart';

class ScannerCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    const len = 24.0;
    const pad = 16.0;

    // Top-left
    canvas.drawLine(Offset(pad, pad + len), Offset(pad, pad), paint);
    canvas.drawLine(Offset(pad, pad), Offset(pad + len, pad), paint);
    // Top-right
    canvas.drawLine(
        Offset(size.width - pad - len, pad), Offset(size.width - pad, pad), paint);
    canvas.drawLine(
        Offset(size.width - pad, pad), Offset(size.width - pad, pad + len), paint);
    // Bottom-left
    canvas.drawLine(
        Offset(pad, size.height - pad - len), Offset(pad, size.height - pad), paint);
    canvas.drawLine(
        Offset(pad, size.height - pad), Offset(pad + len, size.height - pad), paint);
    // Bottom-right
    canvas.drawLine(
        Offset(size.width - pad - len, size.height - pad),
        Offset(size.width - pad, size.height - pad), paint);
    canvas.drawLine(
        Offset(size.width - pad, size.height - pad - len),
        Offset(size.width - pad, size.height - pad), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}