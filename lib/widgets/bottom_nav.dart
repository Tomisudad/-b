import 'package:flutter/material.dart';
import '../config/theme.dart';

/// 底部导航栏 — 严格对照 HTML footer nav
/// 深色背景 + 圆角32px + 三个Tab：首页/记录/我的
class BottomNavBar extends StatelessWidget {
  final int activeTab;
  final void Function(int tab)? onTabChanged;

  const BottomNavBar({
    Key? key,
    required this.activeTab,
    this.onTabChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkNav,
        borderRadius: BorderRadius.circular(AppTheme.rCard),
        boxShadow: AppTheme.cardShadowList,
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home, '首页'),
          _buildNavItem(1, Icons.access_time, '记录'),
          _buildNavItem(2, Icons.person, '我的'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isActive = activeTab == index;
    final color = isActive ? AppTheme.accent : Colors.white.withOpacity(0.6);

    return GestureDetector(
      onTap: () => onTabChanged?.call(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: isActive ? AppTheme.wSemi : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
