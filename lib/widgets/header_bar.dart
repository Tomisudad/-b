import 'package:flutter/material.dart';
import '../config/theme.dart';

/// 头部导航栏 — 严格对照 HTML updateHeader()
/// 首页：左侧树叶图标 + "去野"，右侧天气按钮
/// 子页面：返回按钮 + 页面标题 + 占位空白
class HeaderBar extends StatelessWidget {
  final bool isSubPage;
  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onWeatherTap;

  const HeaderBar({
    Key? key,
    this.isSubPage = false,
    this.title = '',
    this.onBack,
    this.onWeatherTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: AppTheme.bg.withOpacity(0.9),
      child: SafeArea(
        bottom: false,
        child: isSubPage ? _buildSubPageHeader() : _buildHomeHeader(),
      ),
    );
  }

  /// 首页头部
  Widget _buildHomeHeader() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.eco, color: AppTheme.primary, size: 28),
              const SizedBox(width: 8),
              const Text(
                '去野',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: AppTheme.wBold,
                  letterSpacing: -0.5,
                  color: AppTheme.dark,
                ),
              ),
            ],
          ),
          // 天气按钮
          GestureDetector(
            onTap: onWeatherTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                boxShadow: AppTheme.cardShadowList,
              ),
              child: Row(
                children: const [
                  Icon(Icons.wb_sunny, color: AppTheme.accent, size: 18),
                  SizedBox(width: 6),
                  Text(
                    '24°',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: AppTheme.wSemi,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  /// 子页面头部
  Widget _buildSubPageHeader() => Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: AppTheme.cardShadowList,
              ),
              child: const Icon(Icons.chevron_left,
                  color: AppTheme.dark, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: AppTheme.wSemi,
                color: AppTheme.dark,
              ),
            ),
          ),
          const SizedBox(width: 40), // 占位，保持标题居中
        ],
      );
}
