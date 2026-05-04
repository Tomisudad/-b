import 'package:flutter/material.dart';
import 'dart:ui';

import 'config/app_config.dart';
import 'pages/home_page.dart';
import 'pages/partner_page.dart';
import 'pages/community_page.dart';
import 'pages/profile_page.dart';
import 'pages/route_library_page.dart';
import 'pages/checklist_page.dart';
import 'pages/departure_page.dart';

/// 主框架 - V5.0 5 Tab 底部导航 + 中间金色出发按钮 + 出发方式选择面板
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _labels = ['首页', '搭子', '', '社区', '我的'];
  static const _icons = [
    Icons.home_outlined,
    Icons.people_outline_rounded,
    Icons.add,
    Icons.forum_outlined,
    Icons.person_outline_rounded,
  ];
  static const _activeIcons = [
    Icons.home_rounded,
    Icons.people_rounded,
    Icons.add,
    Icons.forum_rounded,
    Icons.person_rounded,
  ];

  void _onTap(int index) {
    if (index == 2) {
      _showDeparturePanel();
      return;
    }
    setState(() => _currentIndex = index);
  }

  void _showDeparturePanel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (_) => const _DepartureSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomePage(),
          PartnerPage(),
          SizedBox.shrink(),
          CommunityPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(bottomPadding),
    );
  }

  Widget _buildBottomNav(double bottomPadding) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 毛玻璃底部栏
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: AppConfig.glassBlur, sigmaY: AppConfig.glassBlur),
            child: Container(
              height: AppConfig.bottomNavHeight + bottomPadding,
              decoration: const BoxDecoration(
                color: AppConfig.glassBg,
                border: Border(top: BorderSide(color: AppConfig.divider, width: 0.5)),
              ),
              child: Padding(
                padding: EdgeInsets.only(bottom: bottomPadding),
                child: Row(
                  children: [
                    _buildNavItem(0),
                    _buildNavItem(1),
                    const Spacer(),
                    _buildNavItem(3),
                    _buildNavItem(4),
                  ],
                ),
              ),
            ),
          ),
        ),
        // 中间黄金出发按钮 突出 12px
        Positioned(
          top: -AppConfig.centerBtnOffset,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: () => _onTap(2),
              child: AnimatedScale(
                scale: _currentIndex == 2 ? AppConfig.pressScale : 1.0,
                duration: const Duration(milliseconds: 150),
                child: Container(
                  width: AppConfig.centerBtnSize,
                  height: AppConfig.centerBtnSize,
                  decoration: BoxDecoration(
                    gradient: goldGradient,
                    shape: BoxShape.circle,
                    boxShadow: AppConfig.goldBtnShadow,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(int index) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppConfig.cyclePrimary : AppConfig.textSecondary;
    final icon = isSelected ? _activeIcons[index] : _icons[index];

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: AppConfig.navIconSize, color: color),
            const SizedBox(height: 2),
            Text(
              _labels[index],
              style: TextStyle(
                fontSize: AppConfig.navLabelSize,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// V5.0 出发方式选择面板
// ============================================================
class _DepartureSheet extends StatelessWidget {
  const _DepartureSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppConfig.dialogRadius)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: AppConfig.glassBlur, sigmaY: AppConfig.glassBlur),
          child: Container(
            decoration: const BoxDecoration(
              color: AppConfig.glassBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppConfig.dialogRadius)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 拖动关闭指示条
                const SizedBox(height: 12),
                Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: AppConfig.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                // 标题
                const Text(
                  '选择出发方式',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConfig.textPrimary),
                ),
                const SizedBox(height: 20),
                // 四个选项 — 一次性全展示，不滚动
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
                  child: Column(
                    children: [
                      _buildOption(context, '🗺️', '选择我的路线', '从已规划的路线出发', () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const RouteLibraryPage()));
                      }),
                      const SizedBox(height: 8),
                      _buildOption(context, '✏️', '新建路线规划', '地图打点或导入GPX', () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/route_plan');
                      }),
                      const SizedBox(height: 8),
                      _buildOption(context, '▶️', '自由记录开始', '一键开始轨迹记录', () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const DeparturePage()));
                      }),
                      const SizedBox(height: 8),
                      _buildOption(context, '🛠️', '出发前检查装备', '确认装备是否齐全', () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ChecklistPage()));
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // 关闭按钮
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
                  child: SizedBox(
                    width: double.infinity,
                    height: AppConfig.secondaryBtnH,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('关闭', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppConfig.textSecondary)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context, String emoji, String title, String desc, VoidCallback onTap) {
    return Material(
      color: AppConfig.cardBg,
      borderRadius: BorderRadius.circular(AppConfig.cardRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConfig.cardRadius),
        onTap: onTap,
        child: Container(
          height: AppConfig.primaryBtnH,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppConfig.cyclePrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
                    const SizedBox(height: 2),
                    Text(desc, style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 18, color: AppConfig.textSecondary.withOpacity(0.4)),
            ],
          ),
        ),
      ),
    );
  }
}
