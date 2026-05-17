import 'package:flutter/material.dart';
import '../config/app_config.dart';

/// V7.6 自定义导航图标 — CustomPainter 实现
/// 首页: 半开门透出暖黄灯光，门框绿
/// 搭子: 两个重叠头盔剪影
/// 社区: 两个聊天气泡，一个带闪电
/// 我的: 带微笑弧线的头盔正面

class CustomNavIcon extends StatelessWidget {
  final int index;
  final bool isSelected;
  final double size;

  const CustomNavIcon({super.key, required this.index, required this.isSelected, this.size = 24});

  @override
  Widget build(BuildContext context) {
    final painter = switch (index) {
      0 => _HomeIconPainter(isSelected: isSelected),
      1 => _PartnerIconPainter(isSelected: isSelected),
      2 => _CenterIconPainter(),
      3 => _CommunityIconPainter(isSelected: isSelected),
      4 => _ProfileIconPainter(isSelected: isSelected),
      _ => _HomeIconPainter(isSelected: isSelected),
    };
    return CustomPaint(painter: painter, size: Size(size, size));
  }
}

// ===== 首页图标：半开门 + 暖黄灯光 =====
class _HomeIconPainter extends CustomPainter {
  final bool isSelected;
  _HomeIconPainter({required this.isSelected});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cs = isSelected ? const Color(0xFF2ECC71) : AppConfig.textSecondary;
    final doorFrame = Paint()
      ..color = cs
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    final doorInner = Paint()
      ..color = cs.withOpacity(isSelected ? 0.12 : 0.08)
      ..style = PaintingStyle.fill;
    final light = Paint()
      ..color = isSelected ? const Color(0xFFF0C040).withOpacity(0.6) : AppConfig.textSecondary.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    final doorOpen = Paint()
      ..color = cs.withOpacity(isSelected ? 1.0 : 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // 门框
    final doorRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.15, h * 0.15, w * 0.55, h * 0.7),
      const Radius.circular(3),
    );
    canvas.drawRRect(doorRect, doorInner);
    canvas.drawRRect(doorRect, doorFrame);

    // 暖黄灯光（半开门内透出）
    final lightPath = Path()
      ..moveTo(w * 0.6, h * 0.3)
      ..lineTo(w * 0.85, h * 0.35)
      ..lineTo(w * 0.82, h * 0.6)
      ..lineTo(w * 0.57, h * 0.55)
      ..close();
    canvas.drawPath(lightPath, light);

    // 门开启角度线
    canvas.drawLine(Offset(w * 0.15, h * 0.3), Offset(w * 0.55, h * 0.4), doorOpen);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ===== 搭子图标：两个重叠头盔剪影 =====
class _PartnerIconPainter extends CustomPainter {
  final bool isSelected;
  _PartnerIconPainter({required this.isSelected});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cs = isSelected ? const Color(0xFF2ECC71) : AppConfig.textSecondary;
    final frontHelmet = Paint()
      ..color = isSelected ? const Color(0xFFA8E6CF) : AppConfig.textSecondary.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    final backHelmet = Paint()
      ..color = isSelected ? const Color(0xFF2ECC71).withOpacity(0.5) : AppConfig.textSecondary.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    final outline = Paint()
      ..color = cs
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // 后面头盔（稍右上偏）
    final backPath = Path()
      ..moveTo(w * 0.35, h * 0.6)
      ..quadraticBezierTo(w * 0.15, h * 0.15, w * 0.45, h * 0.1)
      ..quadraticBezierTo(w * 0.75, h * 0.15, w * 0.65, h * 0.6)
      ..lineTo(w * 0.6, h * 0.7)
      ..quadraticBezierTo(w * 0.45, h * 0.8, w * 0.35, h * 0.7)
      ..close();
    canvas.drawPath(backPath, backHelmet);
    canvas.drawPath(backPath, outline);

    // 前面头盔
    final frontPath = Path()
      ..moveTo(w * 0.2, h * 0.55)
      ..quadraticBezierTo(w * 0.05, h * 0.2, w * 0.3, h * 0.15)
      ..quadraticBezierTo(w * 0.6, h * 0.2, w * 0.5, h * 0.55)
      ..lineTo(w * 0.45, h * 0.65)
      ..quadraticBezierTo(w * 0.3, h * 0.75, w * 0.2, h * 0.65)
      ..close();
    canvas.drawPath(frontPath, frontHelmet);
    canvas.drawPath(frontPath, outline);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ===== 中间按钮图标 =====
class _CenterIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // +
    canvas.drawLine(Offset(w / 2, h * 0.3), Offset(w / 2, h * 0.7), paint);
    canvas.drawLine(Offset(w * 0.3, h / 2), Offset(w * 0.7, h / 2), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ===== 社区图标：两个聊天气泡 =====
class _CommunityIconPainter extends CustomPainter {
  final bool isSelected;
  _CommunityIconPainter({required this.isSelected});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cs = isSelected ? const Color(0xFF2ECC71) : AppConfig.textSecondary;
    final bubble = Paint()
      ..color = cs
      ..style = PaintingStyle.fill;

    final bubbleTail = Paint()
      ..color = cs
      ..style = PaintingStyle.fill;
    final lightningFill = Paint()
      ..color = isSelected ? const Color(0xFFF0C040) : AppConfig.textSecondary.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // 左气泡
    final leftBubble = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.05, h * 0.15, w * 0.45, h * 0.55),
      const Radius.circular(4),
    );
    canvas.drawRRect(leftBubble, bubble);
    // 左气泡尾巴
    final leftTail = Path()
      ..moveTo(w * 0.15, h * 0.7)
      ..lineTo(w * 0.1, h * 0.82)
      ..lineTo(w * 0.25, h * 0.7);
    canvas.drawPath(leftTail, bubbleTail);

    // 右气泡（稍小）
    final rightBubble = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.55, h * 0.05, w * 0.35, h * 0.4),
      const Radius.circular(4),
    );
    canvas.drawRRect(rightBubble, bubble);
    // 右气泡尾巴
    final rightTail = Path()
      ..moveTo(w * 0.55, h * 0.45)
      ..lineTo(w * 0.5, h * 0.55)
      ..lineTo(w * 0.65, h * 0.45);
    canvas.drawPath(rightTail, bubbleTail);

    // 闪电符号（右气泡内）
    final lx = w * 0.65;
    final ly = h * 0.15;
    final lightPath = Path()
      ..moveTo(lx, ly)
      ..lineTo(lx - w * 0.07, ly + h * 0.12)
      ..lineTo(lx + w * 0.02, ly + h * 0.12)
      ..lineTo(lx - w * 0.02, ly + h * 0.22)
      ..lineTo(lx + w * 0.05, ly + h * 0.1)
      ..lineTo(lx - w * 0.04, ly + h * 0.1)
      ..close();
    canvas.drawPath(lightPath, lightningFill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ===== 我的图标：带微笑弧线的头盔正面 =====
class _ProfileIconPainter extends CustomPainter {
  final bool isSelected;
  _ProfileIconPainter({required this.isSelected});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final color = isSelected ? const Color(0xFFF0C040) : const Color(0xFF9A9A9F);
    final helmet = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    final outline = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    final smile = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // 头盔主体
    final helmetPath = Path()
      ..moveTo(w * 0.15, h * 0.55)
      ..quadraticBezierTo(w * 0.05, h * 0.25, w * 0.25, h * 0.1)
      ..quadraticBezierTo(w * 0.5, h * 0.0, w * 0.75, h * 0.1)
      ..quadraticBezierTo(w * 0.95, h * 0.25, w * 0.85, h * 0.55)
      ..lineTo(w * 0.8, h * 0.6)
      ..quadraticBezierTo(w * 0.5, h * 0.7, w * 0.2, h * 0.6)
      ..close();
    canvas.drawPath(helmetPath, helmet);
    canvas.drawPath(helmetPath, outline);

    // 微笑弧线
    final smilePath = Path()
      ..moveTo(w * 0.3, h * 0.45)
      ..quadraticBezierTo(w * 0.5, h * 0.65, w * 0.7, h * 0.45);
    canvas.drawPath(smilePath, smile);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}