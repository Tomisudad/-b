import 'dart:ui';
import 'package:flutter/material.dart';
import '../config/app_config.dart';

/// 去野 - 应用主题 V5.0 (Material 3 亮色)
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConfig.cyclePrimary,
        brightness: Brightness.light,
        surface: AppConfig.cardBg,
      ),
      scaffoldBackgroundColor: AppConfig.bgMain,

      // ===== 字体 V5.0 =====
      fontFamily: AppConfig.fontFamily,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 24, fontWeight: FontWeight.w700,
          color: AppConfig.textPrimary, letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w700,
          color: AppConfig.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w700,
          color: AppConfig.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w400,
          color: AppConfig.textPrimary, height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w400,
          color: AppConfig.textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w400,
          color: AppConfig.textSecondary,
        ),
      ),

      // ===== 卡片 V5.0 =====
      cardTheme: CardTheme(
        color: AppConfig.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConfig.cardRadius),
        ),
        margin: EdgeInsets.zero,
      ),

      // ===== AppBar =====
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConfig.glassBg,
        foregroundColor: AppConfig.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w700,
          color: AppConfig.textPrimary,
        ),
      ),

      // ===== 按钮 =====
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConfig.buttonRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConfig.buttonRadius),
          ),
          side: const BorderSide(color: AppConfig.divider),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),

      // ===== 输入框 =====
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConfig.bgMain,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.inputRadius),
          borderSide: const BorderSide(color: AppConfig.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.inputRadius),
          borderSide: const BorderSide(color: AppConfig.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.inputRadius),
          borderSide: const BorderSide(color: AppConfig.cyclePrimary),
        ),
      ),

      // ===== Divider =====
      dividerTheme: const DividerThemeData(
        color: AppConfig.divider, thickness: 0.5, space: 0,
      ),

      // ===== 底部导航 =====
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
      ),
    );
  }
}

/// 毛玻璃容器
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final bool topBorder;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.height,
    this.topBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: AppConfig.glassBlur, sigmaY: AppConfig.glassBlur),
        child: Container(
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: AppConfig.glassBg,
            border: Border(
              top: topBorder ? const BorderSide(color: AppConfig.divider, width: 0.5) : BorderSide.none,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
