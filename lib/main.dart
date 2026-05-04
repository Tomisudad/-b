import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/scenario_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/checklist_provider.dart';
import 'providers/trip_provider.dart';
import 'services/location_service.dart';
import 'services/no_moto_service.dart';
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

/// 隐私授权 Key
const _consentKey = 'quye_privacy_consent';

Future<bool> hasUserConsented() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_consentKey) ?? false;
}

Future<void> setUserConsented() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_consentKey, true);
}

class QuYeApp extends StatelessWidget {
  const QuYeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '去野 | 读万卷书，行万里路',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const PrivacyGate(),
    );
  }
}

/// 首次启动隐私授权门控
class PrivacyGate extends StatefulWidget {
  const PrivacyGate({super.key});

  @override
  State<PrivacyGate> createState() => _PrivacyGateState();
}

class _PrivacyGateState extends State<PrivacyGate> {
  bool _loading = true;
  bool _consented = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    // 加载禁摩数据库
    await NoMotoService.instance.load();

    final ok = await hasUserConsented();
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
  Widget build(BuildContext context) {
    // 加载中
    if (_loading) {
      return Scaffold(
        backgroundColor: AppTheme.secondaryBg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // 已授权 → 进主界面
    if (_consented) {
      return const MainShell();
    }

    // 未授权 → 展示隐私弹窗
    return Scaffold(
      backgroundColor: AppTheme.secondaryBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(flex: 1),
              // Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E7D32).withOpacity(0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('⛰️', style: TextStyle(fontSize: 36)),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '去野',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2E7D32).withOpacity(0.85),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '去野，去探索',
                style: TextStyle(fontSize: 15, color: AppTheme.textSecondary, letterSpacing: 2),
              ),

              const Spacer(flex: 1),

              // 隐私提示卡片
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.divider, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shield_outlined, size: 20, color: const Color(0xFF2E7D32).withOpacity(0.7)),
                        const SizedBox(width: 6),
                        const Text('隐私与权限说明', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const _PrivacyBullet('📍 位置信息：用于轨迹记录、路线导航、SOS 求助定位'),
                    const SizedBox(height: 10),
                    const _PrivacyBullet('📱 设备信息：用于改善服务稳定性和兼容性'),
                    const SizedBox(height: 10),
                    const _PrivacyBullet('👥 社交互动：组队位置仅在您同意后与队友共享'),
                    const SizedBox(height: 10),
                    const _PrivacyBullet('🔒 数据安全：所有数据加密传输，符合《个人信息保护法》'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPage())),
                          child: const Text('《隐私政策》', style: TextStyle(fontSize: 13, color: Color(0xFF2E7D32), fontWeight: FontWeight.w500)),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserAgreementPage())),
                          child: const Text('《用户协议》', style: TextStyle(fontSize: 13, color: Color(0xFF2E7D32), fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 按钮组
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _onAgree,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: const Text('同意并继续', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('无法继续使用'),
                        content: const Text('您需要同意隐私政策才能使用去野。我们承诺保护您的隐私数据安全。'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('我知道了')),
                        ],
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    side: const BorderSide(color: AppTheme.divider),
                  ),
                  child: const Text('暂不同意', style: TextStyle(fontSize: 14)),
                ),
              ),

              const Spacer(flex: 1),

              const Text(
                '您可以在"我的 → 设置"中随时查看和管理隐私授权',
                style: TextStyle(fontSize: 12, color: AppTheme.textAux),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrivacyBullet extends StatelessWidget {
  final String text;
  const _PrivacyBullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
    );
  }
}
