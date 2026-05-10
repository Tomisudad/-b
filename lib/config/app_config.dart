import 'package:flutter/material.dart';

/// 去野 - 骑行深度定制版 V7.3
class AppConfig {
  AppConfig._();

  // ===== 品牌 =====
  static const String appName = '去野';
  static const String tagline = '去野，去骑行';
  static const String pageTitle = '去野 | 去野，去骑行';

  // ===== 主色 =====
  static const Color primary = Color(0xFF2ECC71);    // 骑行绿
  static const Color deepGreen = Color(0xFF1A8A3A);
  static const Color warmGold = Color(0xFFF0C040);
  static const Color warningOrange = Color(0xFFE67E22);
  static const Color sosRed = Color(0xFFE74C3C);

  // ===== 场景主色别名 (兼容旧代码) =====
  static const Color cyclePrimary = Color(0xFF2ECC71);
  static const Color motoPrimary = Color(0xFFE67E22);
  static const Color drivePrimary = Color(0xFF3498DB);

  // ===== 渐变 =====
  static const Color goldStart = Color(0xFFF0C040);
  static const Color goldEnd = Color(0xFFE67E22);

  // ===== 背景与表面 =====
  static const Color bgMain = Color(0xFFF5F7FA);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color glassBg = Color(0xB8FFFFFF);
  static const Color cardSelectedBg = Color(0xFFE8F8EF);
  static const Color splashTop = Color(0xFF1A1A2E);
  static const Color splashBot = Color(0xFF16213E);

  // ===== 文字 =====
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF9A9A9F);
  static const Color textInverse = Color(0xFFFFFFFF);

  // ===== 分割线 =====
  static const Color divider = Color(0xFFEDEDED);

  // ===== 毛玻璃 =====
  static const double glassBlur = 20.0;

  // ===== 字体 =====
  static const String fontFamily = 'PingFang SC';
  static const double brandSize = 24.0;
  static const double pageTitleSize = 18.0;
  static const double bodySize = 14.0;
  static const double captionSize = 12.0;
  static const double navLabelSize = 12.0;

  // ===== 字重 =====
  static const FontWeight w700 = FontWeight.w700;
  static const FontWeight w400 = FontWeight.w400;

  // ===== 间距 =====
  static const double pageMargin = 20.0;
  static const double cardGap = 12.0;
  static const double sectionGap = 24.0;

  // ===== 圆角 =====
  static const double cardRadius = 12.0;
  static const double cardRadiusLg = 16.0;
  static const double buttonRadius = 14.0;
  static const double inputRadius = 8.0;
  static const double dialogRadius = 16.0;
  static const double tagRadius = 6.0;

  // ===== 按钮 =====
  static const double primaryBtnH = 56.0;
  static const double secondaryBtnH = 44.0;

  // ===== 触控 =====
  static const double minTouchTarget = 44.0;

  // ===== 底部导航 =====
  static const double bottomNavHeight = 56.0;
  static const double centerBtnSize = 56.0;
  static const double centerBtnOffset = 12.0;

  // ===== 模块图标 V7.3 =====
  static const double moduleCircleSize = 56.0;  // 固定入口圆形底
  static const double moduleIconSize = 64.0;    // 可选模块方块
  static const double funcIconSize = 40.0;
  static const double navIconSize = 24.0;

  // ===== Slogan 动画 =====
  static const int sloganIntervalMs = 3000;
  static const int sloganFadeMs = 500;

  // ===== 卡片阴影 =====
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF000000).withOpacity(0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get goldBtnShadow => [
        BoxShadow(
          color: const Color(0x1A000000),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get cardShadowPressed => [
        BoxShadow(
          color: const Color(0xFF000000).withOpacity(0.04),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  static const double pressScale = 0.98;

  // ===== 交互动画 =====
  static const int animMsDefault = 200;
  static const int animMsPageTrans = 300;

  // ===== 场景下拉 =====
  static const double sceneDropItemH = 44.0;

  // ===== 最小字号 =====
  static const double minFontSize = 12.0;

  // ===== 编辑模式颜色 =====
  static const Color editDeleteBg = Color(0xFFE74C3C);
  static const Color editDragHandle = Color(0xFFCCCCCC);
}

// ===== 全局渐变 =====
const LinearGradient goldGradient = LinearGradient(
  colors: [AppConfig.goldStart, AppConfig.goldEnd],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient greenGradient = LinearGradient(
  colors: [AppConfig.primary, AppConfig.deepGreen],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient splashGradient = LinearGradient(
  colors: [AppConfig.splashTop, AppConfig.splashBot],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);