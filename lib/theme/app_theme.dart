import 'package:flutter/material.dart';

import '../config/app_config.dart';

class AppTheme {
  AppTheme._();

  static const Color primaryBg = AppConfig.bgPrimary;
  static const Color secondaryBg = AppConfig.bgSecondary;
  static const Color textPrimary = AppConfig.textPrimary;
  static const Color textSecondary = AppConfig.textSecondary;
  static const Color textAux = AppConfig.textAux;
  static const Color divider = AppConfig.divider;
  static const Color warning = AppConfig.warning;

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: primaryBg,
    colorScheme: const ColorScheme.light(
      surface: AppConfig.bgPrimary,
      onSurface: AppConfig.textPrimary,
      outline: AppConfig.divider,
      error: AppConfig.warning,
    ),

    // 字体
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 20, fontWeight: FontWeight.w500,
        color: textPrimary, fontFamily: 'PingFang SC',
      ),
      bodyLarge: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w400,
        color: textPrimary, fontFamily: 'PingFang SC',
      ),
      bodyMedium: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w400,
        color: textSecondary, fontFamily: 'PingFang SC',
      ),
      bodySmall: TextStyle(
        fontSize: 12, fontWeight: FontWeight.w400,
        color: textAux, fontFamily: 'PingFang SC',
      ),
      labelMedium: TextStyle(
        fontSize: 11, fontWeight: FontWeight.w400,
        color: textAux, fontFamily: 'PingFang SC',
      ),
    ),

    // 分割线
    dividerTheme: const DividerThemeData(color: divider, thickness: 0.5, space: 0),

    // 卡片
    cardTheme: CardTheme(
      color: primaryBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConfig.cardRadius),
        side: const BorderSide(color: divider, width: 0.5),
      ),
      margin: EdgeInsets.zero,
    ),

    // 按钮
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: AppConfig.cyclePrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConfig.buttonRadius),
        ),
        minimumSize: const Size(double.infinity, AppConfig.browseButtonHeight),
        textStyle: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'PingFang SC',
        ),
      ),
    ),

    // 输入框
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: secondaryBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConfig.inputRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConfig.inputRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConfig.inputRadius),
        borderSide: const BorderSide(color: AppConfig.cyclePrimary, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),

    // 底部导航
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: primaryBg,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(fontSize: 11, fontFamily: 'PingFang SC'),
      unselectedLabelStyle: TextStyle(fontSize: 11, fontFamily: 'PingFang SC'),
    ),

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryBg,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0.5,
      titleTextStyle: TextStyle(
        fontSize: 20, fontWeight: FontWeight.w500,
        color: textPrimary, fontFamily: 'PingFang SC',
      ),
    ),
  );
}
