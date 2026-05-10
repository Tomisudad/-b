import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../config/app_config.dart';

/// V7.4 Top Bar — Logo + Flowing Slogan + Weather Capsule
/// 高度48px，毛玻璃背景 rgba(255,255,255,0.72)，blur(20px)
class QuYeTopBar extends StatefulWidget {
  final VoidCallback? onLogoTap;
  final VoidCallback? onWeatherTap;

  const QuYeTopBar({super.key, this.onLogoTap, this.onWeatherTap});

  @override
  State<QuYeTopBar> createState() => _QuYeTopBarState();
}

class _QuYeTopBarState extends State<QuYeTopBar> with SingleTickerProviderStateMixin {
  int _sloganIndex = 0;
  late AnimationController _sloganCtrl;
  late Animation<double> _fadeAnim;
  bool _animating = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _sloganCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppConfig.sloganFadeMs),
    );
    _fadeAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sloganCtrl, curve: Curves.easeInOut),
    );
    _sloganCtrl.value = 1.0;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(
      const Duration(milliseconds: AppConfig.sloganIntervalMs),
      (_) => _nextSlogan(),
    );
  }

  void _nextSlogan() {
    if (_animating) return;
    _animating = true;
    _sloganCtrl.reverse().then((_) {
      if (!mounted) return;
      setState(() {
        _sloganIndex = (_sloganIndex + 1) % AppConfig.sloganPool.length;
      });
      _sloganCtrl.forward().then((_) {
        _animating = false;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sloganCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: AppConfig.topBarBlur, sigmaY: AppConfig.topBarBlur),
        child: Container(
          height: AppConfig.topBarHeight + topPadding,
          padding: EdgeInsets.only(top: topPadding),
          decoration: const BoxDecoration(
            color: AppConfig.glassBg,
            border: Border(bottom: BorderSide(color: AppConfig.divider, width: 0.5)),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              // Logo — 28x28，双层重叠图标
              GestureDetector(
                onTap: widget.onLogoTap,
                child: SizedBox(
                  width: 28, height: 28,
                  child: CustomPaint(painter: _QuYeLogoPainter()),
                ),
              ),
              const SizedBox(width: 10),
              // Flowing Slogan
              Expanded(
                child: AnimatedBuilder(
                  animation: _sloganCtrl,
                  builder: (context, _) => Opacity(
                    opacity: _fadeAnim.value,
                    child: AnimatedSwitcher(
                      duration: Duration.zero,
                      child: Text(
                        AppConfig.sloganPool[_sloganIndex],
                        key: ValueKey(_sloganIndex),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppConfig.textPrimary,
                          fontFamily: AppConfig.fontFamily,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Weather Capsule
              GestureDetector(
                onTap: widget.onWeatherTap,
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConfig.weatherCapsulePadH,
                    vertical: AppConfig.weatherCapsulePadV,
                  ),
                  decoration: weatherCapsuleDecoration,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.wb_sunny_outlined, size: AppConfig.weatherIconSize, color: AppConfig.warmGold),
                      SizedBox(width: 4),
                      Text(
                        '26°',
                        style: TextStyle(
                          fontSize: AppConfig.weatherTextSize,
                          color: AppConfig.textPrimary,
                          fontWeight: FontWeight.w500,
                          fontFamily: AppConfig.fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// V7.4 Logo Painter — 骑行头盔+太阳剪影(金) + 等高线山峦(深绿→骑行绿)
class _QuYeLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 背景：等高线山峦（深绿 #1A8A3A → 骑行绿 #2ECC71）
    final mtnGradient = LinearGradient(
      colors: [AppConfig.deepGreen, AppConfig.primary],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    final mtnRect = Rect.fromLTWH(0, 0, w, h);
    final mtnPaint = Paint()..shader = mtnGradient.createShader(mtnRect);

    // 山峦路径 — 简单双峰+等高线纹理
    final path = Path()
      ..moveTo(0, h * 0.9)
      ..lineTo(w * 0.3, h * 0.4)
      ..lineTo(w * 0.55, h * 0.7)
      ..lineTo(w * 0.8, h * 0.25)
      ..lineTo(w, h * 0.75)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(path, mtnPaint);

    // 等高线纹理（3条横线）
    final linePaint = Paint()
      ..color = AppConfig.primary.withOpacity(0.3)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, h * 0.55), Offset(w * 0.55, h * 0.55), linePaint);
    canvas.drawLine(Offset(0, h * 0.65), Offset(w, h * 0.65), linePaint);
    canvas.drawLine(Offset(w * 0.2, h * 0.75), Offset(w, h * 0.75), linePaint);

    // 前景：骑行头盔 + 太阳
    final goldPaint = Paint()
      ..color = AppConfig.warmGold
      ..style = PaintingStyle.fill;

    // 太阳（左上角小圆）
    canvas.drawCircle(Offset(w * 0.72, h * 0.28), w * 0.12, goldPaint);

    // 头盔（简化形状）
    final helmetPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final helmetPath = Path()
      ..moveTo(w * 0.38, h * 0.7)
      ..quadraticBezierTo(w * 0.38, h * 0.5, w * 0.5, h * 0.42)
      ..quadraticBezierTo(w * 0.62, h * 0.5, w * 0.62, h * 0.7)
      ..lineTo(w * 0.65, h * 0.8)
      ..lineTo(w * 0.35, h * 0.8)
      ..close();
    canvas.drawPath(helmetPath, helmetPaint);

    // 头盔轮廓
    final helmetStroke = Paint()
      ..color = AppConfig.warmGold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(helmetPath, helmetStroke);

    // 头盔顶部金色条纹
    canvas.drawLine(
      Offset(w * 0.42, h * 0.46),
      Offset(w * 0.58, h * 0.46),
      Paint()..color = AppConfig.warmGold..strokeWidth = 1.5..style = PaintingStyle.stroke,
    );

    // 呼吸灯小圆点（金色发光）
    final glowPaint = Paint()
      ..color = AppConfig.warmGold
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
    canvas.drawCircle(Offset(w * 0.72, h * 0.28), w * 0.08, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}