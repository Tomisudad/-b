import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/scenario_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/checklist_provider.dart';
import 'providers/trip_provider.dart';
import 'services/location_service.dart';
import 'config/app_config.dart';
import 'theme/app_theme.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ScenarioProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChecklistProvider()),
        ChangeNotifierProvider(create: (_) => TripProvider()..loadFromStorage()),
        ChangeNotifierProvider(create: (_) => LocationService.instance),
      ],
      child: const QuYeApp(),
    ),
  );
}

// ===== 隐私授权 Key =====
const _consentKey = 'quye_privacy_consent';

Future<bool> hasUserConsented() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_consentKey) ?? false;
}

Future<void> setUserConsented() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_consentKey, true);
}

// ===== App 入口 =====
class QuYeApp extends StatelessWidget {
  const QuYeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.pageTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashGate(),
    );
  }
}

// ============================================================
// V5.1 启动页 + 隐私门控
// ============================================================
class SplashGate extends StatefulWidget {
  const SplashGate({super.key});

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> with SingleTickerProviderStateMixin {
  bool _loading = true;
  bool _consented = true; // 默认已授权，避免闪烁；异步判断后再决定
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    _fadeAnim = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn));
    _progressAnim = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeInOut,
    ));

    _bootstrap();
  }

  Future<void> _bootstrap() async {
    _animCtrl.forward();

    // 后台加载数据
    final ok = await hasUserConsented();

    // 动画至少播满 ~1.2s
    final elapsed = _animCtrl.lastElapsedDuration ?? Duration.zero;
    if (elapsed < const Duration(milliseconds: 1200)) {
      await Future.delayed(const Duration(milliseconds: 1200) - elapsed);
    }

    if (!mounted) return;
    setState(() {
      _loading = false;
      _consented = ok;
    });
  }

  void _onAgree() async {
    await setUserConsented();
    if (!mounted) return;
    setState(() => _consented = true);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  // ============ Build ============

  @override
  Widget build(BuildContext context) {
    if (_loading) return _buildSplash();
    if (_consented) return const MainShell();
    return _buildPrivacyGate();
  }

  // ==================== V5.1 启动页 ====================
  Widget _buildSplash() {
    return AnimatedBuilder(
      animation: _animCtrl,
      builder: (context, _) {
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(gradient: splashGradient),
            child: Opacity(
              opacity: _fadeAnim.value.clamp(0.0, 1.0),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // 山形 Logo — 自定义绘制金色线条山形
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CustomPaint(painter: _MountainLogoPainter()),
                    ),

                    const SizedBox(height: 32),

                    // "去野" 28sp w700 白色 带金色渐变光泽
                    ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return const LinearGradient(
                          colors: [AppConfig.goldStart, AppConfig.goldEnd],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.srcATop,
                      child: const Text(
                        AppConfig.appName,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 4,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 副标题
                    Text(
                      AppConfig.tagline,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppConfig.textSecondary,
                        letterSpacing: 2,
                      ),
                    ),

                    const Spacer(flex: 2),

                    // 金色进度条
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 60),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: _progressAnim.value,
                          backgroundColor: Colors.white.withOpacity(0.15),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppConfig.goldEnd),
                          minHeight: 3,
                        ),
                      ),
                    ),

                    const Spacer(flex: 1),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ==================== V5.1 隐私弹窗 ====================
  Widget _buildPrivacyGate() {
    return Scaffold(
      backgroundColor: AppConfig.textPrimary,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              color: AppConfig.cardBg,
              borderRadius: BorderRadius.circular(AppConfig.dialogRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 40,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                Row(
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(
                        color: AppConfig.cyclePrimary, shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        '隐私与权限说明',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppConfig.textPrimary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // V5.1 简化说明
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppConfig.bgMain,
                    borderRadius: BorderRadius.circular(AppConfig.cardRadius),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('📍', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '位置信息用于记录轨迹、导航和紧急求助，不共享给第三方。',
                          style: TextStyle(fontSize: 14, color: AppConfig.textPrimary, height: 1.6),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 政策链接
                const Row(
                  children: [
                    Text(
                      '《隐私政策》',
                      style: TextStyle(fontSize: 13, color: AppConfig.textSecondary, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(width: 16),
                    Text(
                      '《用户协议》',
                      style: TextStyle(fontSize: 13, color: AppConfig.textSecondary, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // 同意按钮 (金色渐变)
                SizedBox(
                  width: double.infinity,
                  height: AppConfig.primaryBtnH,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: goldGradient,
                      borderRadius: BorderRadius.all(Radius.circular(AppConfig.buttonRadius)),
                    ),
                    child: ElevatedButton(
                      onPressed: _onAgree,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.buttonRadius)),
                      ),
                      child: const Text(
                        '同意并继续',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppConfig.textInverse),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 不同意按钮 (灰色描边)
                SizedBox(
                  width: double.infinity,
                  height: AppConfig.secondaryBtnH,
                  child: OutlinedButton(
                    onPressed: () => _showDeclineDialog(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppConfig.textSecondary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.buttonRadius)),
                      side: const BorderSide(color: AppConfig.divider),
                    ),
                    child: const Text('不同意并退出', style: TextStyle(fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeclineDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.dialogRadius)),
        title: const Text('无法继续使用', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('您需要同意隐私政策才能使用去野。\n我们承诺保护您的隐私数据安全。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('我知道了')),
        ],
      ),
    );
  }
}

// ============================================================
// V5.1 山形 Logo (金色线条描边)
// ============================================================
class _MountainLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppConfig.goldStart
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // 中间大山
    final path = Path()
      ..moveTo(w * 0.20, h * 0.85)
      ..lineTo(w * 0.50, h * 0.18)
      ..lineTo(w * 0.80, h * 0.85);

    canvas.drawPath(path, paint);

    // 左侧小山坡
    final pathLeft = Path()
      ..moveTo(0, h * 0.85)
      ..lineTo(w * 0.28, h * 0.45)
      ..lineTo(w * 0.45, h * 0.85);

    final paintLeft = Paint()
      ..color = AppConfig.goldStart.withOpacity(0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(pathLeft, paintLeft);

    // 雪线 — 山顶小横线
    final snowPaint = Paint()
      ..color = AppConfig.goldStart.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(w * 0.42, h * 0.32),
      Offset(w * 0.58, h * 0.32),
      snowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
