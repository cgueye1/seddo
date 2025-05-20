import 'dart:ui';

import 'package:flutter/material.dart';

class DottedBorderPainter extends CustomPainter {
  final Color color;
  final double borderRadius;

  DottedBorderPainter({required this.color, this.borderRadius = 12.0});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = color
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    // Dessiner des traits pointillés
    const double dashWidth = 5;
    const double dashSpace = 3;

    final Path path = Path();

    // Créer un path qui suit le border radius
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    path.addRRect(RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)));

    // Convertir le path en traits pointillés
    final Path dashPath = Path();

    final PathMetrics pathMetrics = path.computeMetrics();
    for (final PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;
      bool draw = true;

      while (distance < pathMetric.length) {
        final double length = draw ? dashWidth : dashSpace;
        if (draw) {
          dashPath.addPath(
            pathMetric.extractPath(distance, distance + length),
            Offset.zero,
          );
        }
        distance += length;
        draw = !draw;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class DottedBorder extends StatelessWidget {
  final Widget child;
  final Color color;
  final double borderRadius;

  const DottedBorder({
    super.key,
    required this.child,
    required this.color,
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.transparent),
      ),
      child: CustomPaint(
        painter: DottedBorderPainter(color: color, borderRadius: borderRadius),
        child: Padding(padding: const EdgeInsets.all(1.5), child: child),
      ),
    );
  }
}
