import 'package:flutter/material.dart';

/// 去野 App 主题配置 — 严格对照 HTML 原型 Tailwind 配置
/// 原型: https://tomisudad.github.io/-b/
class AppTheme {
  // ── 品牌色（与 HTML tailwind.config 完全一致）─────────────────────
  static const Color primary = Color(0xFF5A6F45); // 橄榄绿
  static const Color accent = Color(0xFFF57C00);  // 活力橙
  static const Color bg = Color(0xFFF8F7F4);      // 米白背景
  static const Color dark = Color(0xFF333333);    // 深灰文字
  static const Color darkNav = Color(0xFF121212); // 深色导航
  static const Color cardBg = Color(0xFFFFFFFF);  // 卡片白
  static const Color divider = Color(0xFFE5E7EB); // 灰色分割线

  // 扩展语义色
  static const Color primaryOverlay = Color(0xB25A6F45); // primary 70% 叠加
  static const Color accent10 = Color(0x1AF57C00);
  static const Color primary10 = Color(0x1A5A6F45);
  static const Color white10 = Color(0x1AFFFFFF);
  static const Color white20 = Color(0x33FFFFFF);
  static const Color white40 = Color(0x66FFFFFF);
  static const Color white60 = Color(0x99FFFFFF);
  static const Color green600 = Color(0xFF16A34A);
  static const Color redText = Color(0xFFD94A4A);
  static const Color redBg = Color(0x33F57C00); // warn background
  static const Color missBg = Color(0x1AD94A4A);

  // ── 圆角 ─────────────────────────────────────────────────────
  static const double rCard = 32.0;  // .rounded-card（装备卡片等）
  static const double rCard24 = 24.0; // 大部分卡片实际使用
  static const double rBtn = 12.0;    // 按钮圆角
  static const double rChip = 12.0;   // 芯片圆角
  static const double rFull = 999.0;  // 胶囊/全圆

  // ── 阴影 ─────────────────────────────────────────────────────
  /// card-shadow: 0 4px 12px rgba(0,0,0,0.06)
  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x0F000000),
    blurRadius: 12,
    offset: Offset(0, 4),
  );

  static List<BoxShadow> get cardShadowList => [cardShadow];

  // ── 字号（严格对照 HTML 规范）─────────────────────────────────
  static const double fsTitle = 28.0;  // 标题 28px bold
  static const double fsBody = 15.0;   // 正文 15px
  static const double fsAux = 13.0;    // 辅助 13px
  static const double fsLabel = 11.0;  // 标签 11px

  // 额外常用字号
  static const double fsHero = 48.0;   // 大数字 48px（速度等）
  static const double fs2xl = 24.0;    // 24px
  static const double fsXl = 20.0;     // 20px
  static const double fsLg = 18.0;     // 18px
  static const double fsSm = 14.0;     // 14px
  static const double fsXs = 12.0;     // 12px

  // ── 字重 ─────────────────────────────────────────────────────
  static const FontWeight wBold = FontWeight.w700;
  static const FontWeight wSemi = FontWeight.w600;
  static const FontWeight wMedium = FontWeight.w500;
  static const FontWeight wThin = FontWeight.w100;

  // ── 触控 ─────────────────────────────────────────────────────
  static const double touchMin = 44.0;

  // ── Material ThemeData ───────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: false,
      fontFamily: 'PingFang SC',
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: accent,
        surface: cardBg,
        error: redText,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: dark,
          fontSize: fsBody,
          fontWeight: wSemi,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rCard24),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(rBtn),
          ),
          textStyle: const TextStyle(
            fontSize: fsLg,
            fontWeight: wBold,
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: fsTitle, fontWeight: wBold, color: dark),
        headlineMedium: TextStyle(fontSize: fs2xl, fontWeight: wBold, color: dark),
        titleLarge: TextStyle(fontSize: fsXl, fontWeight: wBold, color: dark),
        titleMedium: TextStyle(fontSize: fsLg, fontWeight: wSemi, color: dark),
        bodyLarge: TextStyle(fontSize: fsBody, color: dark),
        bodyMedium: TextStyle(fontSize: fsAux, color: dark),
        bodySmall: TextStyle(fontSize: fsSm, color: dark),
        labelSmall: TextStyle(fontSize: fsLabel, fontWeight: wMedium),
      ),
    );
  }

  /// 模拟 HTML btn-press:active 按下缩放效果
  static const Duration pressDuration = Duration(milliseconds: 100);
  static const double pressScale = 0.97;

  /// 装备芯片样式映射（对照 HTML .equip-chip.ok / .warn / .miss）
  static ChipStyle equipChipStyle(String status) {
    switch (status) {
      case 'ok':
        return const ChipStyle(
          bg: Color(0xFFF4F7F2),
          border: Color(0x4D5A6F45),
        );
      case 'attention':
        return const ChipStyle(
          bg: Color(0xFFFFF9F4),
          border: Color(0x4DF57C00),
        );
      case 'missing':
        return const ChipStyle(
          bg: Color(0xFFFFF6F6),
          border: Color(0x4DD94A4A),
        );
      default:
        return const ChipStyle(bg: bg, border: Colors.transparent);
    }
  }
}

/// 装备芯片样式
class ChipStyle {
  final Color bg;
  final Color border;
  const ChipStyle({required this.bg, required this.border});
}
