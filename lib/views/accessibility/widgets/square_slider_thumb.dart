import 'package:flutter/material.dart';

class SquareThumbShape extends SliderComponentShape {
  final double size;
  const SquareThumbShape({this.size = 20});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size(size, size);

  @override
  void paint(PaintingContext context, Offset center,
      {required Animation<double> activationAnimation,
      required Animation<double> enableAnimation,
      required bool isDiscrete,
      required TextPainter labelPainter,
      required RenderBox parentBox,
      required SliderThemeData sliderTheme,
      required TextDirection textDirection,
      required double value,
      required double textScaleFactor,
      required Size sizeWithOverflow}) {
    final canvas = context.canvas;

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: center.translate(0, 1), width: size, height: size),
        const Radius.circular(5),
      ),
      shadowPaint,
    );

    // White square
    final paint = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: size, height: size),
        const Radius.circular(5),
      ),
      paint,
    );

    // Border
    final borderPaint = Paint()
      ..color = sliderTheme.activeTrackColor ?? Colors.cyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: size, height: size),
        const Radius.circular(5),
      ),
      borderPaint,
    );
  }
}