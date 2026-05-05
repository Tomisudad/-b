import 'package:flutter/material.dart';
import '../config/app_config.dart';
import 'offline_maps_page.dart';

/// V5.1 我的页面 — 个人卡片 + 两列网格入口 + 设置列表
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Mock 数据
  final String _nickname = '山野行者';
  final String _signature = '去野，去探索';
  final int _level = 12;
  final double _totalKm = 2847.5;
  final int _totalClimb = 48600;
  final int _litDistricts = 47;
  final int _medalCount = 23;
  final int _trackCount = 68;
  final int _favCount = 35;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(context),
          _buildProfileCard(),
          const SizedBox(height: AppConfig.sectionGap),
          _buildMenuGrid(),
          const SizedBox(height: AppConfig.sectionGap),
          _buildSettings(context),
          const SizedBox(height: AppConfig.pageMargin),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: const BoxDecoration(
        color: AppConfig.glassBg,
        border: Border(bottom: BorderSide(color: AppConfig.divider, width: 0.5)),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppConfig.pageMargin, vertical: 10),
        child: Row(
          children: [
            Text('我的', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
            Spacer(),
          ],
        ),
      ),
    );
  }

  // ==================== 个人信息卡片 (V5.1: 头像48px) ====================
  Widget _buildProfileCard() {
    return Padding(
      padding: const EdgeInsets.all(AppConfig.pageMargin),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: splashGradient,
          borderRadius: BorderRadius.circular(AppConfig.cardRadius),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // 头像 48px
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                  ),
                  child: const CircleAvatar(
                    radius: 22,
                    backgroundColor: AppConfig.goldStart,
                    child: Text('S', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppConfig.textInverse)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(_nickname, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppConfig.textInverse)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppConfig.goldStart.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('Lv.$_level', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppConfig.goldStart)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(_signature, style: const TextStyle(fontSize: 13, color: AppConfig.textSecondary)),
                    ],
                  ),
                ),
                // 编辑入口
                const Icon(Icons.chevron_right, size: 20, color: AppConfig.textInverse),
              ],
            ),
            const SizedBox(height: 20),
            // 统计数据
            Row(
              children: [
                _statItem('${_totalKm.toStringAsFixed(0)}km', '累计里程'),
                _statItem('${(_totalClimb / 1000).toStringAsFixed(1)}km', '累计爬升'),
                _statItem('$_litDistricts', '点亮区县'),
                _statItem('$_medalCount', '勋章'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppConfig.textInverse)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: AppConfig.textSecondary)),
        ],
      ),
    );
  }

  // ==================== V5.1 功能入口两列网格 ====================
  Widget _buildMenuGrid() {
    final entries = [
      _MenuEntry('📝', '我的轨迹', '$_trackCount条', AppConfig.cyclePrimary),
      _MenuEntry('⭐', '我的收藏', '$_favCount条', AppConfig.goldEnd),
      _MenuEntry('🏅', '我的勋章', '$_medalCount枚', AppConfig.goldStart),
      _MenuEntry('🗺️', '我的地图', '$_litDistricts区县', AppConfig.drivePrimary),
      _MenuEntry('📂', '我的创作', '→', AppConfig.motoPrimary),
      _MenuEntry('📊', '年度报告', '→', AppConfig.cyclePrimary),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: AppConfig.cardGap,
        crossAxisSpacing: AppConfig.cardGap,
        childAspectRatio: 1.5,
        children: entries.map((e) => _menuCell(e)).toList(),
      ),
    );
  }

  Widget _menuCell(_MenuEntry e) {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('打开 ${e.title}'))),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppConfig.cardBg,
          borderRadius: BorderRadius.circular(AppConfig.cardRadius),
          boxShadow: AppConfig.cardShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: e.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Text(e.emoji, style: const TextStyle(fontSize: 18))),
            ),
            const SizedBox(height: 12),
            Text(e.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
            const SizedBox(height: 2),
            Text(e.subtitle, style: const TextStyle(fontSize: 11, color: AppConfig.textSecondary)),
          ],
        ),
      ),
    );
  }

  // ==================== V5.1 设置列表 ====================
  Widget _buildSettings(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text('设置', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppConfig.cardBg,
              borderRadius: BorderRadius.circular(AppConfig.cardRadius),
              boxShadow: AppConfig.cardShadow,
            ),
            child: Column(
              children: [
                _settingItem(Icons.security_outlined, '账号安全'),
                const Divider(height: 1, indent: 52),
                _settingItem(Icons.map_outlined, '离线地图管理', onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const OfflineMapsPage()));
                }),
                const Divider(height: 1, indent: 52),
                _settingItem(Icons.swap_horiz_outlined, '默认场景', trailing: '骑行'),
                const Divider(height: 1, indent: 52),
                _settingItem(Icons.notifications_outlined, '通知设置'),
                const Divider(height: 1, indent: 52),
                _settingItem(Icons.privacy_tip_outlined, '隐私管理'),
                const Divider(height: 1, indent: 52),
                _settingItem(Icons.storage_outlined, '缓存管理', trailing: '128MB'),
                const Divider(height: 1, indent: 52),
                _settingItem(Icons.info_outline, '关于去野', trailing: 'v5.1.0'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingItem(IconData icon, String title, {String? trailing, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppConfig.textPrimary),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 14, color: AppConfig.textPrimary))),
            if (trailing != null) Text(trailing, style: const TextStyle(fontSize: 13, color: AppConfig.textSecondary)),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 18, color: AppConfig.textSecondary.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }
}

class _MenuEntry {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;

  const _MenuEntry(this.emoji, this.title, this.subtitle, this.color);
}
