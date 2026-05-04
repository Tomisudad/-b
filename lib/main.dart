import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/scenario_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/checklist_provider.dart';
import 'providers/trip_provider.dart';
import 'services/location_service.dart';
import 'services/no_moto_service.dart';
import 'config/app_config.dart';
import 'theme/app_theme.dart';
import 'app.dart';
import 'pages/privacy_page.dart';
import 'pages/user_agreement_page.dart';

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

// ===== 启动 + 隐私门控 =====
class SplashGate extends StatefulWidget {
  const SplashGate({super.key});

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> with SingleTickerProviderStateMixin {
  bool _loading = true;
  bool _consented = false;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _fadeAnim    = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn));
    _progressAnim = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut));

    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // 启动动画
    _animCtrl.forward();

    // 后台加载禁摩数据 + 检查隐私授权
    await NoMotoService.instance.load();
    final ok = await hasUserConsented();

    // 动画至少播满
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
    // ---- 启动动画 ----
    if (_loading) {
      return _buildSplash();
    }

    // ---- 已授权 → 进主界面 ----
    if (_consented) {
      return const MainShell();
    }

    // ---- 未授权 → 隐私弹窗 ----
    return _buildPrivacyGate();
  }

  // ==================== 启动页 ====================
  Widget _buildSplash() {
    return AnimatedBuilder(
      animation: _animCtrl,
      builder: (context, _) {
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppConfig.splashTop, AppConfig.splashBot],
              ),
            ),
            child: Opacity(
              opacity: _fadeAnim.value.clamp(0.0, 1.0),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // 山形 Logo（纯占位文字模拟线条风格）
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppConfig.goldStart,
                          width: 2.5,
                        ),
                      ),
                      child: const Center(
                        child: Text('⛰️', style: TextStyle(fontSize: 44)),
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      AppConfig.appName,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppConfig.textInverse,
                        letterSpacing: 4,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      AppConfig.tagline,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppConfig.textSecondary,
                        letterSpacing: 2,
                      ),
                    ),

                    const Spacer(flex: 2),

                    // 进度条
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

  // ==================== 隐私弹窗 ====================
  Widget _buildPrivacyGate() {
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      body: Stack(
        children: [
          // 暗色背景
          Container(color: AppConfig.splashTop.withOpacity(0.96)),
          // 居中毛玻璃卡片
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppConfig.cardBg,
                  borderRadius: BorderRadius.circular(AppConfig.dialogRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 32,
                      offset: const Offset(0, 8),
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
                        const Text(
                          '隐私与权限说明',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppConfig.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    const _PrivacyItem(icon: '📍', text: '位置信息：用于轨迹记录、路线导航、SOS 求助定位'),
                    const SizedBox(height: 12),
                    const _PrivacyItem(icon: '📱', text: '设备信息：用于改善服务稳定性和兼容性'),
                    const SizedBox(height: 12),
                    const _PrivacyItem(icon: '🔒', text: '数据安全：所有数据加密传输，符合《个人信息保护法》'),

                    const SizedBox(height: 20),

                    // 政策链接
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPage())),
                          child: const Text('《隐私政策》', style: TextStyle(fontSize: 13, color: AppConfig.cyclePrimary, fontWeight: FontWeight.w500)),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserAgreementPage())),
                          child: const Text('《用户协议》', style: TextStyle(fontSize: 13, color: AppConfig.cyclePrimary, fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 按钮组
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
                          child: const Text('同意并继续',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppConfig.textInverse),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

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
        ],
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
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('我知道了'),
          ),
        ],
      ),
    );
  }
}

// ===== 隐私项 =====
class _PrivacyItem extends StatelessWidget {
  final String icon, text;
  const _PrivacyItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 14, color: AppConfig.textSecondary, height: 1.5)),
        ),
      ],
    );
  }
}
