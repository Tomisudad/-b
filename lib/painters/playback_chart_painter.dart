import 'dart:math';
import 'package:flutter/material.dart';

class PlaybackChartPainter extends CustomPainter {
  final double playedFraction; // 0.0 to 1.0
  final String chartType; // 'elev' or 'speed'

  PlaybackChartPainter({required this.playedFraction, required this.chartType});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Dark background (#121212)
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFF121212));

    // Faint grid (rgba 255,255,255,0.04)
    final gridPaint = Paint()
      ..color = const Color(0x0AFFFFFF)
      ..strokeWidth = 1;
    for (int i = 0; i < 4; i++) {
      final y = (h / 4) * i;
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // Generate chart data points
    final points = <Offset>[];
    for (int i = 0; i <= w.toInt(); i++) {
      final x = i.toDouble();
      final progress = i / w;
      final baseY = h * 0.5;
      double value;
      if (chartType == 'elev') {
        value = sin(progress * pi * 2.5) * (h * 0.4) + cos(progress * 5) * (h * 0.1);
      } else {
        // Speed curve
        value = 18 + sin(progress * pi * 2) * 8 + cos(progress * 3) * 4;
      }
      final y = baseY - value;
      points.add(Offset(x, y));
    }

    // Played portion: orange (#F57C00)
    final playedPaint = Paint()
      ..color = const Color(0xFFF57C00)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final playedPath = Path();
    final playedX = playedFraction * w;
    bool started = false;
    for (final p in points) {
      if (p.dx <= playedX) {
        if (!started) {
          playedPath.moveTo(p.dx, p.dy);
          started = true;
        } else {
          playedPath.lineTo(p.dx, p.dy);
        }
      }
    }
    if (started) canvas.drawPath(playedPath, playedPaint);

    // Unplayed portion: white semi-transparent
    final unplayedPaint = Paint()
      ..color = const Color(0x1EFFFFFF)  // rgba 0.12
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final unplayedPath = Path();
    started = false;
    for (final p in points) {
      if (p.dx >= playedX) {
        if (!started) {
          unplayedPath.moveTo(p.dx, p.dy);
          started = true;
        } else {
          unplayedPath.lineTo(p.dx, p.dy);
        }
      }
    }
    if (started) canvas.drawPath(unplayedPath, unplayedPaint);

    // Label
    final labelStyle = TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11);
    final label = chartType == 'elev' ? '高程曲线' : '速度曲线';
    final tp = TextPainter(text: TextSpan(text: label, style: labelStyle), textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(16, 6));
  }

  @override
  bool shouldRepaint(covariant PlaybackChartPainter oldDelegate) {
    return oldDelegate.playedFraction != playedFraction || oldDelegate.chartType != chartType;
  }
}
