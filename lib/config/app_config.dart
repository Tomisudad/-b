import 'package:flutter/material.dart';

/// 去野 - 骑行深度定制版 V7.6
class AppConfig {
  AppConfig._();

  // ===== 品牌 =====
  static const String appName = '去野';
  static const String tagline = '去野，去骑行';
  static const String pageTitle = '去野 | 去野，去骑行';
  static const List<String> sloganPool = [
    '去野，去骑行',
    '每一次踩踏，都是对生活的热爱',
    '你走过的路，都在脚下发光',
    '找到你的踏频，找到你的节奏',
    '下坡控制车速，安全第一',
    '出发前检查胎压和刹车',
    '爬坡如人生，坚持就是胜利',
  ];
  static const int sloganIntervalMs = 3000;
  static const int sloganFadeMs = 500;

  // ===== 主色（V7.4 骑行聚焦）=====
  static const Color primary = Color(0xFF2ECC71);    // 骑行绿
  static const Color deepGreen = Color(0xFF1A8A3A);
  static const Color warmGold = Color(0xFFF0C040);
  static const Color warningOrange = Color(0xFFE67E22);
  static const Color sosRed = Color(0xFFE74C3C);

  // ===== 场景主色别名 =====
  static const Color cyclePrimary = Color(0xFF2ECC71);
  static const Color motoPrimary = Color(0xFFE67E22);
  static const Color drivePrimary = Color(0xFF3498DB);

  // ===== 渐变 =====
  static const Color goldStart = Color(0xFFF0C040);
  static const Color goldEnd = Color(0xFFE67E22);

  // ===== 背景与表面 =====
  static const Color bgMain = Color(0xFFF5F7FA);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color glassBg = Color(0xB8FFFFFF);   // rgba(255,255,255,0.72)
  static const Color glassBgLight = Color(0x99FFFFFF); // rgba(255,255,255,0.6)
  static const Color cardSelectedBg = Color(0xFFE8F8EF);
  static const Color splashTop = Color(0xFF1A1A2E);
  static const Color splashBot = Color(0xFF16213E);

  // ===== 文字 =====
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF9A9A9F);
  static const Color textBody = Color(0xFF2C3E50);    // 正文14sp
  static const Color textInverse = Color(0xFFFFFFFF);

  // ===== 分割线 =====
  static const Color divider = Color(0xFFEDEDED);  // 0.5px

  // ===== 毛玻璃 =====
  static const double glassBlur = 20.0;
  static const double topBarHeight = 48.0;
  static const double topBarBlur = 20.0;

  // ===== 天气胶囊 =====
  static const double weatherCapsuleRadius = 20.0;
  static const double weatherCapsulePadH = 10.0;
  static const double weatherCapsulePadV = 6.0;
  static const double weatherIconSize = 16.0;
  static const double weatherTextSize = 14.0;

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
  static const double brandToFuncGap = 24.0; // 品牌区距功能区

  // ===== 圆角 =====
  static const double cardRadius = 12.0;
  static const double cardRadiusLg = 16.0;
  static const double buttonRadius = 14.0;
  static const double inputRadius = 8.0;
  static const double dialogRadius = 16.0;
  static const double tagRadius = 6.0;
  static const double funcIconRadius = 12.0;  // 可选功能图标圆角

  // ===== 按钮 =====
  static const double primaryBtnH = 56.0;
  static const double secondaryBtnH = 44.0;

  // ===== 触控 =====
  static const double minTouchTarget = 44.0;

  // ===== 底部导航 =====
  static const double bottomNavHeight = 56.0;
  static const double centerBtnSize = 56.0;
  static const double centerBtnOffset = 12.0;
  static const double navIconSize = 24.0;
  static const double navGlowBlur = 8.0;      // 选中态发光模糊
  static const double centerBtnElevation = 16.0;
  static const double centerBtnShadowBlur = 16.0;

  // ===== 模块图标 V7.4 =====
  static const double moduleCircleSize = 56.0; // 固定入口圆形底 (兼容旧代码)
  static const double fixedEntrySize = 56.0;    // 固定入口圆形底直径
  static const double fixedIconSize = 40.0;     // 固定入口图标
  static const double funcIconSize = 64.0;      // 可选模块方块
  static const double funcInnerIconSize = 32.0; // 可选模块内图标
  static const double funcLabelSize = 12.0;

  // ===== 卡片尺寸 =====
  static const double fixedCardW = 103.0;
  static const double fixedCardH = 88.0;

  // ===== 品牌区 =====
  static const double brandChainTexPct = 0.03;  // 链条纹理透明度
  static const double brandChainSize = 120.0;   // 链条纹理约直径

  // ===== 卡片阴影 =====
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0x0F000000), // rgba(0,0,0,0.06)
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
        BoxShadow(
          color: const Color(0x66F0C040), // rgba(240,192,64,0.4)
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get cardShadowPressed => [
        BoxShadow(
          color: const Color(0x0A000000),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  static const double pressScale = 0.97;   // V7.6 卡片按压缩放

  // ===== 交互动画 =====
  static const int animMsDefault = 200;
  static const int animMsPageTrans = 300;
  static const int animMsBtnBounce = 300;  // 按钮弹性 0.95→1.0
  static const int animMsPanelSlide = 350; // 底部面板升起 ease-out

  // ===== 场景下拉 =====
  static const double sceneDropItemH = 44.0;

  // ===== 最小字号 =====
  static const double minFontSize = 12.0;

  // ===== 编辑模式颜色 =====
  static const Color editDeleteBg = Color(0xFFE74C3C);
  static const Color editDragHandle = Color(0xFFCCCCCC);

  // ===== 难度标签 V7.4 =====
  static const List<String> difficultyLabels = ['新手', '进阶', '资深', '挑战'];

  // ===== POI 分类图标 =====
  static const double poiIconSize = 20.0;
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

// ===== 天气胶囊装饰 =====
BoxDecoration get weatherCapsuleDecoration => BoxDecoration(
      color: AppConfig.glassBgLight,
      borderRadius: BorderRadius.circular(AppConfig.weatherCapsuleRadius),
      border: Border.all(color: Colors.white.withOpacity(0.3), width: 0.5),
    );
