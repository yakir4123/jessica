import 'dart:math';

import 'package:flutter/cupertino.dart';

class _PartialArcPainter extends CustomPainter {
  final Color borderColor;
  final double borderWidth;
  final double arcFraction;

  _PartialArcPainter({
    required this.borderColor,
    required this.borderWidth,
    required this.arcFraction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: Offset(radius, radius), radius: radius);
    const startAngle = -pi / 2; // Start at the top
    final sweepAngle = 2 * pi * arcFraction; // Sweep angle based on fraction

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}