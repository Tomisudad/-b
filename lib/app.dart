import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';

import 'providers/scenario_provider.dart';
import 'config/scenario_config.dart';
import 'pages/home_page.dart';
import 'pages/teams_page.dart';
import 'pages/community_page.dart';
import 'pages/profile_page.dart';

/// 主框架 - 4Tab 底部导航 + 顶部场景切换 + 毛玻璃效果
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _pages = <Widget>[
    const HomePage(),
    const TeamsListPage(),
    const CommunityPage(),
    const ProfilePage(),
  ];

  static const _labels = ['首页', '组队', '社区', '我的'];
  static const _icons = [Icons.explore_outlined, Icons.group_work_outlined, Icons.groups_outlined, Icons.person_outlined];

  @override
  Widget build(BuildContext context) {
    final scenario = context.watch<ScenarioProvider>().scenario;
    final sceneColor = ScenarioConfig.of(scenario).primaryColor;

    return Scaffold(
      body: Column(
        children: [
          _buildSceneTabs(sceneColor),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
          ),
        ],
      ),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              border: const Border(top: BorderSide(color: Color(0xFFE5E5E5), width: 0.5)),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
              selectedItemColor: sceneColor,
              unselectedItemColor: const Color(0xFFB2B2B2),
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: const TextStyle(fontSize: 11, fontFamily: 'PingFang SC'),
              unselectedLabelStyle: const TextStyle(fontSize: 11, fontFamily: 'PingFang SC'),
              items: List.generate(4, (i) => BottomNavigationBarItem(
                icon: Icon(_icons[i], size: 24),
                label: _labels[i],
              )),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSceneTabs(Color currentSceneColor) {
    final prov = context.read<ScenarioProvider>();
    final current = prov.scenario;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E5E5), width: 0.5)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: OutdoorScenario.values.map((s) {
              final cfg = ScenarioConfig.of(s);
              final isActive = s == current;
              final color = isActive ? currentSceneColor : const Color(0xFF888888);
              return Expanded(
                child: GestureDetector(
                  onTap: () => prov.scenario = s,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? currentSceneColor.withOpacity(0.06) : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(cfg.label, style: TextStyle(
                          fontSize: 15,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                          color: color,
                        )),
                        if (isActive)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Container(width: 16, height: 3,
                              decoration: BoxDecoration(color: currentSceneColor, borderRadius: BorderRadius.circular(2))),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
