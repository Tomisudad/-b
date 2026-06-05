import 'dart:math';
import 'package:flutter/material.dart';

class PlaybackTrackPainter extends CustomPainter {
  final double playedFraction; // 0.0 to 1.0
  final String routeName;

  PlaybackTrackPainter({required this.playedFraction, this.routeName = '成都→都江堰'});

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
    for (int i = 0; i < 8; i++) {
      final y = (h / 8) * i;
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // Generate track points
    final points = <Offset>[];
    final elevs = <double>[];
    for (int i = 0; i <= w.toInt(); i++) {
      final x = i.toDouble();
      final progress = i / w;
      final baseY = h * 0.6;
      final elevation =
          sin(progress * pi * 2.5) * (h * 0.22) + cos(progress * 5) * (h * 0.06);
      final y = baseY - elevation;
      points.add(Offset(x, y));
      elevs.add(elevation);
    }

    // Played portion: orange (#F57C00) lineWidth 3
    final playedPaint = Paint()
      ..color = const Color(0xFFF57C00)
      ..strokeWidth = 3
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

    // Unplayed portion: white semi-transparent (rgba 0.15)
    final unplayedPaint = Paint()
      ..color = const Color(0x26FFFFFF)
      ..strokeWidth = 2
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

    // Current position dot
    if (playedFraction > 0) {
      final idx = (playedFraction * (points.length - 1)).round().clamp(0, points.length - 1);
      final pos = points[idx];

      // Glow
      canvas.drawCircle(pos, 18, Paint()..color = const Color(0x33F57C00));
      // Core dot
      canvas.drawCircle(pos, 10, Paint()..color = const Color(0xFFF57C00));
    }

    // Labels
    final labelStyle = TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12, fontWeight: FontWeight.bold);
    final rp = TextPainter(text: TextSpan(text: '路书回放 · $routeName', style: labelStyle), textDirection: TextDirection.ltr);
    rp.layout();
    rp.paint(canvas, Offset(w - rp.width - 16, 10));

    final tp = TextPainter(text: TextSpan(text: '轨迹', style: labelStyle), textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(16, 10));
  }

  @override
  bool shouldRepaint(covariant PlaybackTrackPainter oldDelegate) {
    return oldDelegate.playedFraction != playedFraction || oldDelegate.routeName != routeName;
  }
}
