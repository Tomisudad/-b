import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gowild_app/providers/app_state.dart';
import 'package:gowild_app/config/theme.dart';
import 'package:gowild_app/screens/home_page.dart';
import 'package:gowild_app/screens/ride_nav_page.dart';
import 'package:gowild_app/screens/playback_page.dart';
import 'package:gowild_app/screens/record_page.dart';
import 'package:gowild_app/screens/profile_page.dart';
import 'package:gowild_app/screens/equipment_page.dart';
import 'package:gowild_app/screens/weather_detail_page.dart';
import 'package:gowild_app/screens/route_detail_page.dart';
import 'package:gowild_app/screens/repair_page.dart';
import 'package:gowild_app/screens/settings_placeholder_page.dart';
import 'package:gowild_app/widgets/header_bar.dart';

class GoWildApp extends StatelessWidget {
  const GoWildApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: MaterialApp(
        title: '去野',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainShell(),
      ),
    );
  }
}

/// 主外壳 — HTML 原型使用 state.subPage 管理导航
/// 首页内置 HeaderBar + BottomNavBar，子页面由 HomePage 切换
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        // 骑行导航 / 路书回放 为全局覆盖层，优先显示
        if (state.rideActive) {
          return const RideNavPage();
        }
        if (state.subPage?.key == 'playback') {
          return const PlaybackPage();
        }

        if (state.subPage != null) {
          if (state.subPage!.key == 'weather') {
            return const WeatherDetailPage();
          }
          // 子页面：头部 + 子页面内容
          return Scaffold(
            backgroundColor: AppTheme.bg,
            body: _buildSubPageShell(state.subPage!, state),
          );
        }
        // 首页 + 底部导航栏
        final tabBody = _buildTabBody(state);
        return Scaffold(
          backgroundColor: AppTheme.bg,
          body: tabBody,
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: _buildBottomNav(context, state),
          ),
        );
      },
    );
  }

  Widget _buildSubPageShell(SubPage subPage, AppState state) {
    return SafeArea(
      child: Column(
        children: [
          // 子页面头部（带返回按钮）
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: AppTheme.bg.withOpacity(0.9),
            child: Row(
              children: [
                GestureDetector(
                  onTap: state.goBack,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: AppTheme.cardShadowList,
                    ),
                    child: const Icon(Icons.chevron_left,
                        color: AppTheme.dark, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  subPage.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: AppTheme.wSemi,
                    color: AppTheme.dark,
                  ),
                ),
              ],
            ),
          ),
          // 子页面内容
          Expanded(
            child: _buildSubPageContent(subPage.key, state),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBody(AppState state) {
    switch (state.activeTab) {
      case 1:
        // 记录页：头部 + 内容
        return Column(
          children: [
            HeaderBar(
              isSubPage: false,
              onWeatherTap: () => state.openSub('天气详情', 'weather'),
            ),
            const Expanded(child: RecordPage()),
          ],
        );
      case 2:
        // 我的页：头部 + 内容
        return Column(
          children: [
            HeaderBar(
              isSubPage: false,
              onWeatherTap: () => state.openSub('天气详情', 'weather'),
            ),
            const Expanded(child: ProfilePage()),
          ],
        );
      default:
        return const HomePage();
    }
  }

  Widget _buildSubPageContent(String key, AppState state) {
    switch (key) {
      case 'record':
        return const RecordPage();
      case 'profile':
        return const ProfilePage();
      case 'equip':
        return const EquipmentPage();
      case 'route-detail':
        return const RouteDetailPage();
      case 'repair':
        return const RepairPage();
      case 'settings':
      default:
        final title = state.subPage?.title ?? '设置';
        return SettingsPlaceholderPage(title: title);
    }
  }

  Widget _buildBottomNav(BuildContext context, AppState state) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkNav,
        borderRadius: BorderRadius.circular(AppTheme.rCard),
        boxShadow: AppTheme.cardShadowList,
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home, '首页', 0, state),
          _navItem(Icons.access_time, '记录', 1, state),
          _navItem(Icons.person, '我的', 2, state),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int tab, AppState state) {
    final active = state.activeTab == tab;
    final color = active ? AppTheme.accent : Colors.white.withOpacity(0.6);
    return GestureDetector(
      onTap: () => state.switchTab(tab),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: active ? AppTheme.wSemi : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
