import 'dart:ui';

/// 去野 - 应用全局配置
class AppConfig {
  AppConfig._();

  // ===== 品牌 =====
  static const String appName = '去野';
  static const String tagline = '读万卷书，行万里路';
  static const String pageTitle = '去野 | 读万卷书，行万里路';

  // ===== 配色（微信式克制留白） =====
  static const Color bgPrimary = Color(0xFFFFFFFF);       // #FFFFFF
  static const Color bgSecondary = Color(0xFFF6F6F6);     // #F6F6F6
  static const Color textPrimary = Color(0xFF1A1A1A);     // #1A1A1A
  static const Color textSecondary = Color(0xFF888888);   // #888888
  static const Color textAux = Color(0xFFB2B2B2);         // #B2B2B2
  static const Color divider = Color(0xFFE5E5E5);         // #E5E5E5
  static const Color warning = Color(0xFFD32F2F);         // #D32F2F

  // ===== 场景主色 =====
  static const Color cyclePrimary = Color(0xFF2E7D32);    // 骑行
  static const Color motoPrimary = Color(0xFFE65100);     // 摩旅
  static const Color drivePrimary = Color(0xFF5D4037);    // 自驾

  // ===== 字体 =====
  static const String fontFamily = 'PingFang SC';
  static const double titleSize = 20.0;
  static const double bodySize = 16.0;
  static const double subSize = 14.0;
  static const double miniSize = 12.0;
  static const double captionSize = 11.0;

  // ===== 间距 =====
  static const double pageMargin = 16.0;
  static const double cardGap = 12.0;
  static const double listGap = 16.0;

  // ===== 按钮高度 =====
  static const double browseButtonHeight = 48.0;
  static const double driveButtonHeight = 56.0;

  // ===== 圆角 =====
  static const double cardRadius = 8.0;
  static const double buttonRadius = 8.0;
  static const double inputRadius = 6.0;
  static const double dialogRadius = 12.0;

  // ===== 图标 =====
  static const double navIconSize = 24.0;
  static const double listIconSize = 20.0;

  // ===== 触控 =====
  static const double minTouchTarget = 48.0;

  // ===== 篝火 =====
  static const int bonfireStartHour = 20;
  static const int bonfireEndHour = 23;

  // ===== 对比度 =====
  static const double minContrastRatio = 4.5;
}
