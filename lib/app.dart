import 'package:flutter/material.dart';
import 'dart:ui';

import 'config/app_config.dart';
import 'pages/home_page.dart';
import 'pages/partner_page.dart';
import 'pages/community_page.dart';
import 'pages/profile_page.dart';

/// 主框架 - 5 Tab（首页/搭子/出发/社区/我的）+ 毛玻璃底部导航 + 中间出发按钮
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
      isScrollControlled: true,
      builder: (_) => const _DeparturePanel(),
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
          SizedBox.shrink(), // placeholder for center
          CommunityPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: Stack(
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
          // 中间出发按钮（突出12px）
          Positioned(
            top: -12,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => _onTap(2),
                child: AnimatedScale(
                  scale: _currentIndex == 2 ? 0.95 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: goldGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppConfig.goldStart.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 28),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
        child: AnimatedScale(
          scale: isSelected ? 1.0 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: AppConfig.navIconSize, color: color),
              const SizedBox(height: 2),
              Text(
                _labels[index],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 出发面板（占屏40%，毛玻璃白底，顶部圆角16px，可下拉关闭）
// ============================================================
class _DeparturePanel extends StatelessWidget {
  const _DeparturePanel();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(AppConfig.dialogRadius)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: AppConfig.glassBlur, sigmaY: AppConfig.glassBlur),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.40,
          decoration: const BoxDecoration(
            color: AppConfig.glassBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppConfig.dialogRadius)),
          ),
          child: Column(
            children: [
              // 拖拽指示条
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppConfig.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              // 标题
              const Text(
                '准备出发',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppConfig.textPrimary),
              ),
              const SizedBox(height: 20),
              // 选项列表
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
                  children: const [
                    _DepartureOption(
                      icon: Icons.route_outlined,
                      title: '选择我的路线',
                      subtitle: '从已创建的路线中选择',
                      routeName: '/route_library',
                    ),
                    SizedBox(height: 12),
                    _DepartureOption(
                      icon: Icons.edit_location_alt_outlined,
                      title: '新建路线规划',
                      subtitle: '地图打点或导入GPX',
                      routeName: '/route_plan',
                    ),
                    SizedBox(height: 12),
                    _DepartureOption(
                      icon: Icons.play_circle_outline,
                      title: '自由记录开始',
                      subtitle: '一键开始轨迹记录',
                      action: 'free_record',
                    ),
                    SizedBox(height: 12),
                    _DepartureOption(
                      icon: Icons.checklist_outlined,
                      title: '出发前检查装备',
                      subtitle: '确保装备齐全',
                      action: 'checklist',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DepartureOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? routeName;
  final String? action;

  const _DepartureOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.routeName,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppConfig.cyclePrimary;

    return Material(
      color: AppConfig.cardBg,
      borderRadius: BorderRadius.circular(AppConfig.cardRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConfig.cardRadius),
        onTap: () {
          Navigator.pop(context);
          if (routeName != null) {
            Navigator.pushNamed(context, routeName!);
          } else if (action == 'free_record') {
            // 跳转到导航页自由记录
            Navigator.pushNamed(context, '/navigation');
          } else if (action == 'checklist') {
            Navigator.pushNamed(context, '/checklist');
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppConfig.textSecondary.withOpacity(0.5), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
