import 'package:flutter/material.dart';

/// 去野 - 应用全局配置
class AppConfig {
  AppConfig._();

  // ===== 品牌 =====
  static const String appName = '去野';
  static const String tagline = '去野，去探索';
  static const String pageTitle = '去野 | 去野，去探索';

  // ===== 主题色 =====
  static const Color cyclePrimary = Color(0xFF2ECC71);    // 骑行绿
  static const Color motoPrimary  = Color(0xFFE67E22);     // 摩旅橙
  static const Color drivePrimary = Color(0xFF3498DB);    // 自驾蓝

  // ===== 渐变 =====
  static const Color goldStart = Color(0xFFF0C040);        // 金色渐变起点
  static const Color goldEnd   = Color(0xFFE67E22);        // 金色渐变终点

  // ===== 功能色 =====
  static const Color sosRed = Color(0xFFE74C3C);           // SOS红

  // ===== 背景与表面 =====
  static const Color bgMain      = Color(0xFFF5F7FA);      // 主背景浅灰
  static const Color cardBg      = Color(0xFFFFFFFF);      // 卡片白
  static const Color glassBg     = Color(0xB8FFFFFF);      // 毛玻璃 rgba(255,255,255,0.72)
  static const Color splashTop   = Color(0xFF1A1A2E);      // 启动页渐变Top
  static const Color splashBot   = Color(0xFF16213E);      // 启动页渐变Bot

  // ===== 文字 =====
  static const Color textPrimary   = Color(0xFF1A1A2E);    // 主文字深色
  static const Color textSecondary = Color(0xFF8E8E93);    // 辅助灰
  static const Color textInverse   = Color(0xFFFFFFFF);    // 反白

  // ===== 分割线 =====
  static const Color divider = Color(0xFFE8E8ED);

  // ===== 毛玻璃参数 =====
  static const double glassBlur = 20.0;

  // ===== 字体层级 =====
  static const String fontFamily  = 'PingFang SC';
  static const double titleLarge  = 28.0;
  static const double titleMedium = 20.0;
  static const double titleSmall  = 18.0;
  static const double bodySize    = 16.0;
  static const double subSize     = 14.0;
  static const double captionSize = 12.0;

  // ===== 字重 =====
  static const FontWeight w700 = FontWeight.w700;
  static const FontWeight w400 = FontWeight.w400;

  // ===== 间距 =====
  static const double pageMargin  = 20.0;
  static const double cardGap     = 12.0;
  static const double sectionGap  = 24.0;

  // ===== 圆角 =====
  static const double cardRadius   = 12.0;
  static const double buttonRadius = 14.0;
  static const double inputRadius  = 8.0;
  static const double dialogRadius = 16.0;

  // ===== 按钮高度 =====
  static const double primaryBtnH   = 56.0;
  static const double secondaryBtnH = 44.0;

  // ===== 触控最小区域 =====
  static const double minTouchTarget = 44.0;

  // ===== 底部导航 =====
  static const double bottomNavHeight = 56.0;

  // ===== 最小字号 =====
  static const double minFontSize = 14.0;

  // ===== 图标尺寸 =====
  static const double cardIconSize = 28.0;
  static const double navIconSize  = 24.0;

  // ===== 卡片阴影 =====
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.06),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  // ===== 按钮动画 =====
  static const double pressScale = 0.95;

  // ===== 场景下拉项高 =====
  static const double sceneDropItemH = 44.0;

  // ===== 篝火（社区） =====
  static const int bonfireStartHour = 20;
  static const int bonfireEndHour   = 23;
}

// ===== 金色渐变（主按钮等） =====
const LinearGradient goldGradient = LinearGradient(
  colors: [AppConfig.goldStart, AppConfig.goldEnd],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
