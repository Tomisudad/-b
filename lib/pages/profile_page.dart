import 'package:flutter/material.dart';
import 'dart:ui';

import '../config/app_config.dart';
import 'offline_maps_page.dart';

/// V4.0 我的页面 — 个人中心
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Mock 用户数据
  final String _nickname = '山野行者';
  final String _signature = '去野，去探索';
  final int _level = 12;
  final double _totalKm = 2847.5;
  final int _totalClimb = 48600;
  final int _litDistricts = 47;
  final int _medalCount = 23;
  final int _trackCount = 68;
  final int _favCount = 35;

  // 点亮区县 mock
  final List<_DistrictData> _districts = const [
    _DistrictData('杭州', '西湖区', true),
    _DistrictData('杭州', '余杭区', true),
    _DistrictData('杭州', '临安区', true),
    _DistrictData('湖州', '安吉县', true),
    _DistrictData('黄山', '徽州区', false),
    _DistrictData('黄山', '歙县', false),
    _DistrictData('成都', '锦江区', true),
    _DistrictData('成都', '都江堰市', true),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 毛玻璃顶栏
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: AppConfig.glassBlur, sigmaY: AppConfig.glassBlur),
              child: Container(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                decoration: const BoxDecoration(
                  color: AppConfig.glassBg,
                  border: Border(bottom: BorderSide(color: AppConfig.divider, width: 0.5)),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppConfig.pageMargin, vertical: 14),
                  child: Text('我的', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
                ),
              ),
            ),
          ),
          // ===== 个人信息卡片 =====
          _buildProfileCard(),
          const SizedBox(height: AppConfig.sectionGap),
          // ===== 功能入口 =====
          _buildMenuGrid(),
          const SizedBox(height: AppConfig.sectionGap),
          // ===== 我的地图（足迹） =====
          _buildFootprintMap(),
          const SizedBox(height: AppConfig.sectionGap),
          // ===== 经典路线进度 =====
          _buildClassicRoutes(),
          const SizedBox(height: AppConfig.sectionGap),
          // ===== 设置 =====
          _buildSettings(),
          const SizedBox(height: AppConfig.pageMargin),
        ],
      ),
    );
  }

  // ==================== 个人信息卡片 ====================
  Widget _buildProfileCard() {
    return Padding(
      padding: const EdgeInsets.all(AppConfig.pageMargin),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppConfig.splashTop, AppConfig.splashBot],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppConfig.cardRadius),
        ),
        child: Column(
          children: [
            // 头像 + 信息
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                  ),
                  child: const CircleAvatar(
                    radius: 30,
                    backgroundColor: AppConfig.goldStart,
                    child: Text('S', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppConfig.textInverse)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(_nickname, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppConfig.textInverse)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppConfig.goldStart.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('Lv.$_level',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppConfig.goldStart)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(_signature, style: const TextStyle(fontSize: 13, color: AppConfig.textSecondary)),
                    ],
                  ),
                ),
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

  // ==================== 功能入口 ====================
  Widget _buildMenuGrid() {
    final menus = [
      _MenuEntry('📝', '我的轨迹', '$_trackCount条'),
      _MenuEntry('⭐', '我的收藏', '$_favCount条'),
      _MenuEntry('🏅', '我的勋章', '$_medalCount枚'),
      _MenuEntry('🗺️', '我的地图', '$_litDistricts区县', scrollToMap: true),
      _MenuEntry('📊', '年度报告', '2025'),
      _MenuEntry('⚙️', '设置', '', scrollToSettings: true),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: AppConfig.cardGap,
        crossAxisSpacing: AppConfig.cardGap,
        childAspectRatio: 1.2,
        children: menus.map((m) {
          return GestureDetector(
            onTap: () {
              if (m.scrollToMap) {
                Scrollable.ensureVisible(context, alignment: 0.5);
              } else if (m.scrollToSettings) {
                Scrollable.ensureVisible(context, alignment: 1.0);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppConfig.cardBg,
                borderRadius: BorderRadius.circular(AppConfig.cardRadius),
                boxShadow: AppConfig.cardShadow,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(m.emoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 8),
                  Text(
                    m.title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppConfig.textPrimary),
                  ),
                  if (m.subtitle.isNotEmpty)
                    Text(m.subtitle, style: const TextStyle(fontSize: 11, color: AppConfig.textSecondary)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==================== 我的地图（足迹） ====================
  Widget _buildFootprintMap() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('我的地图', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppConfig.cardBg,
              borderRadius: BorderRadius.circular(AppConfig.cardRadius),
              boxShadow: AppConfig.cardShadow,
            ),
            child: Column(
              children: [
                // 中国地图轮廓占位
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppConfig.bgMain,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('🗺️', style: TextStyle(fontSize: 48, color: AppConfig.textPrimary.withOpacity(0.15))),
                            const SizedBox(height: 4),
                            Text(
                              '已点亮 $_litDistricts 个区县',
                              style: TextStyle(fontSize: 13, color: AppConfig.textSecondary.withOpacity(0.5)),
                            ),
                          ],
                        ),
                      ),
                      // 模拟亮点
                      ..._districts.where((d) => d.lit).take(5).toList().asMap().entries.map((e) {
                        final dx = [0.72, 0.70, 0.68, 0.65, 0.40][e.key];
                        final dy = [0.38, 0.36, 0.33, 0.35, 0.32][e.key];
                        return Positioned(
                          left: MediaQuery.of(context).size.width * dx * 0.01,
                          top: dy * 180,
                          child: Container(
                            width: 6, height: 6,
                            decoration: BoxDecoration(
                              color: AppConfig.goldStart.withOpacity(0.6),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppConfig.goldStart.withOpacity(0.3),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                // 已点亮列表
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: _districts.where((d) => d.lit).map((d) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppConfig.goldStart.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${d.city}·${d.name}',
                        style: const TextStyle(fontSize: 11, color: AppConfig.goldEnd),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 经典路线进度 ====================
  Widget _buildClassicRoutes() {
    const routes = [
      ('G318川藏线', 0.12),
      ('独库公路', 0.0),
      ('青海湖环湖', 0.65),
      ('海南环岛', 0.0),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('经典路线', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppConfig.cardBg,
              borderRadius: BorderRadius.circular(AppConfig.cardRadius),
              boxShadow: AppConfig.cardShadow,
            ),
            child: Column(
              children: routes.map((r) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(r.$1, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppConfig.textPrimary)),
                          Text(
                            r.$2 > 0 ? '${(r.$2 * 100).toInt()}%' : '未开始',
                            style: TextStyle(
                              fontSize: 12,
                              color: r.$2 > 0 ? AppConfig.cyclePrimary : AppConfig.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: r.$2,
                          backgroundColor: AppConfig.bgMain,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppConfig.goldEnd),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 设置 ====================
  Widget _buildSettings() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('设置', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
          const SizedBox(height: 12),
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
                _settingItem(Icons.info_outline, '关于去野', trailing: 'v4.0.0'),
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
      borderRadius: const BorderRadius.all(Radius.circular(0)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppConfig.textPrimary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title, style: const TextStyle(fontSize: 14, color: AppConfig.textPrimary)),
            ),
            if (trailing != null)
              Text(trailing, style: const TextStyle(fontSize: 13, color: AppConfig.textSecondary)),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 18, color: AppConfig.textSecondary.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }
}

class _DistrictData {
  final String city;
  final String name;
  final bool lit;
  const _DistrictData(this.city, this.name, this.lit);
}

class _MenuEntry {
  final String emoji;
  final String title;
  final String subtitle;
  final bool scrollToMap;
  final bool scrollToSettings;
  const _MenuEntry(this.emoji, this.title, this.subtitle, {this.scrollToMap = false, this.scrollToSettings = false});
}
