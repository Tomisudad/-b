import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../providers/app_state.dart';
import 'package:provider/provider.dart';
import '../widgets/weather_card.dart';
import '../widgets/slider_depart.dart';
import '../widgets/route_card.dart';
import '../widgets/equipment_card.dart';
import '../widgets/repair_card.dart';
import '../widgets/header_bar.dart';
import '../widgets/bottom_nav.dart';
import 'depart_modal.dart';
import '../widgets/create_route_modal.dart';

/// 首页 — 严格对照 HTML renderHome()
/// 天气卡片 + 滑动出发 + 路线列表 + 装备卡片 + 维修手册
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<SliderDepartState> _sliderKey =
      GlobalKey<SliderDepartState>();

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 从子页面返回时重置滑块
    _sliderKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 头部导航栏（首页模式）
        HeaderBar(
          isSubPage: false,
          onWeatherTap: () {
            context.read<AppState>().openSub('天气详情', 'weather');
          },
        ),

        // 可滚动内容区
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            children: [
              const SizedBox(height: 16),

              // 1. 天气卡片
              WeatherCard(
                onTap: () {
                  context.read<AppState>().openSub('天气详情', 'weather');
                },
              ),
              const SizedBox(height: 16),

              // 2. 滑动出发按钮
              SliderDepart(
                key: _sliderKey,
                onTrigger: () {
                  // 滑动触发出发流程 → 打开出发面板
                  showDepartModal(context);
                },
              ),
              const SizedBox(height: 16),

              // 3. 我的路线卡片
              Consumer<AppState>(
                builder: (context, state, _) => RouteCard(
                  routes: state.routes,
                  onRouteTap: (name) {
                    state.setSelectedRoute(name);
                    state.openSub(name, 'route-detail');
                  },
                  onQuickDepart: (name) {
                    state.setSelectedRoute(name);
                    // 直接打开出发确认面板
                    showDepartConfirm(context);
                  },
                  onNewRoute: () {
                    showCreateRouteModal(context);
                  },
                ),
              ),
              const SizedBox(height: 16),

              // 4. 出发装备卡片
              EquipmentCard(
                onTap: () {
                  context.read<AppState>().openSub('装备清单', 'equip');
                },
              ),
              const SizedBox(height: 16),

              // 5. 维修手册卡片
              RepairCard(
                onTap: () {
                  context.read<AppState>().openSub('维修手册', 'repair');
                },
              ),
              const SizedBox(height: 100), // 底部留白给导航栏
            ],
          ),
        ),
      ],
    );
  }
}
