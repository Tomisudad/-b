import 'dart:math';
import 'package:flutter/material.dart';

class NavMapPainter extends CustomPainter {
  final double playProgress; // 0.0 to 1.0, where the animated pulse dot is on the track

  NavMapPainter({this.playProgress = 0.5});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Dark background (#1a1d22)
    final bgPaint = Paint()..color = const Color(0xFF1a1d22);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    // Grid lines (rgba 255,255,255,0.06)
    final gridPaint = Paint()
      ..color = const Color(0x0FFFFFFF)  // rgba 255,255,255,0.06
      ..strokeWidth = 1;

    for (int i = 0; i < 20; i++) {
      final y = (h / 20) * i;
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }
    for (int i = 0; i < 15; i++) {
      final x = (w / 15) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }

    // Green track line (#5A6F45 solid 3px)
    final trackPath = Path();
    trackPath.moveTo(w * 0.1, h * 0.7);
    trackPath.quadraticBezierTo(w * 0.4, h * 0.3, w * 0.55, h * 0.4);
    trackPath.quadraticBezierTo(w * 0.7, h * 0.5, w * 0.9, h * 0.35);

    final trackPaint = Paint()
      ..color = const Color(0xFF5A6F45)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(trackPath, trackPaint);

    // Orange dashed line (#F57C00)
    final dashPath = Path();
    dashPath.moveTo(w * 0.55, h * 0.4);
    dashPath.quadraticBezierTo(w * 0.65, h * 0.48, w * 0.75, h * 0.38);

    final dashPaint = Paint()
      ..color = const Color(0xFFF57C00)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw dashed line manually
    _drawDashedPath(canvas, dashPath, dashPaint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final start = metric.getTangentForOffset(distance);
        final end = metric.getTangentForOffset(
          (distance + 6).clamp(0, metric.length),
        );
        if (start != null && end != null) {
          canvas.drawLine(start.position, end.position, paint);
        }
        distance += 10; // dash + gap
      }
    }
  }

  @override
  bool shouldRepaint(covariant NavMapPainter oldDelegate) {
    return oldDelegate.playProgress != playProgress;
  }
}
