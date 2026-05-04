import 'package:flutter/material.dart';
import 'dart:ui';

import 'config/app_config.dart';
import 'pages/home_page.dart';
import 'pages/teams_page.dart';
import 'pages/profile_page.dart';

/// 主框架 - 3 Tab（路线/组队/我的）+ 毛玻璃底部导航
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _pages = const <Widget>[
    HomePage(),
    TeamsListPage(),
    ProfilePage(),
  ];

  static const _labels  = ['路线', '组队', '我的'];
  static const _icons   = [Icons.map_outlined, Icons.group_work_outlined, Icons.person_outlined];
  static const _activeColors = [AppConfig.cyclePrimary, AppConfig.motoPrimary, AppConfig.drivePrimary];

  @override
  Widget build(BuildContext context) {
    final activeColor = _activeColors[_currentIndex];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: AppConfig.glassBlur, sigmaY: AppConfig.glassBlur),
          child: Container(
            height: AppConfig.bottomNavHeight + MediaQuery.of(context).padding.bottom,
            decoration: const BoxDecoration(
              color: AppConfig.glassBg,
              border: Border(top: BorderSide(color: AppConfig.divider, width: 0.5)),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
              selectedItemColor: activeColor,
              unselectedItemColor: AppConfig.textSecondary,
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedFontSize: AppConfig.captionSize,
              unselectedFontSize: AppConfig.captionSize,
              items: List.generate(3, (i) => BottomNavigationBarItem(
                icon: Icon(_icons[i], size: AppConfig.navIconSize),
                label: _labels[i],
              )),
            ),
          ),
        ),
      ),
    );
  }
}
