import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../config/theme.dart';

/// 我的页面 — 严格对照 HTML renderProfile()
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: 16),
            // 头像区域
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0x1A5A6F45),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('🚴', style: TextStyle(fontSize: 48)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('骑行达人',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _statItem('${state.totalKm}', '总公里'),
                      const SizedBox(width: 40),
                      _statItem('${state.totalRides}', '总骑行'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 成就勋章
            Container(
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(AppTheme.rCard24),
                boxShadow: AppTheme.cardShadowList,
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('成就勋章',
                      style: TextStyle(fontSize: 18, fontWeight: AppTheme.wBold)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _badge('🚀', '破百'),
                      _badge('⛰️', '爬升王'),
                      _badge('🌙', '夜骑侠'),
                      _badge('🔥', '连续7天'),
                      _badge('💯', '百公里'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 设置列表
            Container(
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(AppTheme.rCard24),
                boxShadow: AppTheme.cardShadowList,
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('设置',
                      style: TextStyle(fontSize: 18, fontWeight: AppTheme.wBold)),
                  const SizedBox(height: 4),
                  _settingItem(context, '账号安全'),
                  _settingItem(context, '离线地图'),
                  _settingItem(context, '通知提醒'),
                  _settingItem(context, '隐私设置'),
                  _settingItem(context, '关于去野', isLast: true),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        );
      },
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
      ],
    );
  }

  Widget _badge(String icon, String name) {
    return Builder(builder: (context) {
      return GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(name), duration: const Duration(seconds: 2)),
          );
        },
        child: SizedBox(
          width: 56,
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 30)),
              const SizedBox(height: 4),
              Text(name, style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
            ],
          ),
        ),
      );
    });
  }

  Widget _settingItem(BuildContext context, String title, {bool isLast = false}) {
    return GestureDetector(
      onTap: () {
        context.read<AppState>().openSub(title, 'settings');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 15)),
            const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}
