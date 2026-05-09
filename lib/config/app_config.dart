import 'package:flutter/material.dart';

/// 去野 - 应用全局配置 V5.0
class AppConfig {
  AppConfig._();

  // ===== 品牌 =====
  static const String appName = '去野';
  static const String tagline = '去野，去探索';
  static const String pageTitle = '去野 | 去野，去探索';

  // ===== 主题色 =====
  static const Color cyclePrimary = Color(0xFF2ECC71);
  static const Color motoPrimary  = Color(0xFFE67E22);
  static const Color drivePrimary = Color(0xFF3498DB);

  // ===== 渐变 =====
  static const Color goldStart = Color(0xFFF0C040);
  static const Color goldEnd   = Color(0xFFE67E22);

  // ===== 功能色 =====
  static const Color sosRed = Color(0xFFE74C3C);

  // ===== 背景与表面 =====
  static const Color bgMain    = Color(0xFFF5F7FA);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color glassBg   = Color(0xB8FFFFFF);
  static const Color splashTop = Color(0xFF1A1A2E);
  static const Color splashBot = Color(0xFF16213E);

  // ===== 文字 =====
  static const Color textPrimary   = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF9A9A9F);
  static const Color textInverse   = Color(0xFFFFFFFF);

  // ===== 分割线 =====
  static const Color divider = Color(0xFFEDEDED);

  // ===== 轨迹线 =====
  static const Color trackGold = Color(0xFFF0C040);

  // ===== 毛玻璃 =====
  static const double glassBlur = 20.0;

  // ===== 字体层级 V5.0 =====
  static const String fontFamily  = 'PingFang SC';
  static const double brandSize    = 24.0;
  static const double pageTitleSize = 18.0;
  static const double bodySize     = 14.0;
  static const double captionSize  = 12.0;
  static const double navLabelSize = 12.0;

  // ===== 字重 =====
  static const FontWeight w700 = FontWeight.w700;
  static const FontWeight w400 = FontWeight.w400;

  // ===== 间距 =====
  static const double pageMargin = 20.0;
  static const double cardGap    = 12.0;
  static const double sectionGap = 24.0;

  // ===== 圆角 =====
  static const double cardRadius    = 12.0;
  static const double cardRadiusLg  = 16.0;
  static const double buttonRadius  = 14.0;
  static const double inputRadius   = 8.0;
  static const double dialogRadius  = 16.0;
  static const double tagRadius     = 6.0;

  // ===== 按钮 =====
  static const double primaryBtnH   = 56.0;
  static const double secondaryBtnH = 44.0;

  // ===== 触控 =====
  static const double minTouchTarget = 44.0;

  // ===== 底部导航 =====
  static const double bottomNavHeight = 56.0;
  static const double centerBtnSize   = 56.0;
  static const double centerBtnOffset = 12.0;

  // ===== 图标 =====
  static const double funcIconSize  = 40.0;
  static const double funcCircleSize = 56.0;
  static const double navIconSize   = 24.0;

  // ===== 卡片阴影 V5.0: 0 4px 12px rgba(0,0,0,0.06) =====
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // ===== 出发按钮阴影 =====
  static List<BoxShadow> get goldBtnShadow => [
    BoxShadow(
      color: AppConfig.goldStart.withOpacity(0.4),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  // ===== 卡片按压态 (V6.5 Fix 13) =====
  static List<BoxShadow> get cardShadowPressed => [
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.04),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];
  static const double pressScale = 0.98;

  // ===== 交互动画 =====
  static const int    animMsDefault    = 200;
  static const int    animMsPageTrans  = 300;

  // ===== 场景下拉 =====
  static const double sceneDropItemH = 44.0;

  // ===== 最小字号 =====
  static const double minFontSize = 12.0;
}

// ===== 全局渐变 =====
const LinearGradient goldGradient = LinearGradient(
  colors: [AppConfig.goldStart, AppConfig.goldEnd],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient splashGradient = LinearGradient(
  colors: [AppConfig.splashTop, AppConfig.splashBot],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);
