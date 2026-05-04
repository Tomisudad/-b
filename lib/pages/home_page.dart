import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../config/scenario_config.dart';
import '../providers/scenario_provider.dart';
import '../providers/checklist_provider.dart';
import '../providers/trip_provider.dart';
import 'route_library_page.dart';
import 'offline_maps_page.dart';
import 'checklist_page.dart';
import 'departure_page.dart';

// ============================================================
// 首页（出发前决策与准备） — 无地图/无指南针/无SOS
// ============================================================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ===== 下拉状态 =====
  final LayerLink _sceneLayer = LayerLink();
  OverlayEntry? _sceneOverlay;
  bool _sceneOpen = false;

  // ===== 统计数据 =====
  int _routeCount = 0;
  String _latestRouteSummary = '';
  int _offlineRegions = 0;

  // ===== 装备 =====
  int _checkedItems = 0;
  int _totalItems = 0;
  List<String> _missingItems = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    final trip = context.read<TripProvider>();
    final routes = trip.completedTrips;
    _routeCount = routes.length;
    _latestRouteSummary = routes.isNotEmpty
        ? '${routes.last.name}  ${routes.last.totalDistanceKm.toStringAsFixed(0)}km'
        : '';

    _offlineRegions = 3; // mock: 离线地图暂时mock

    final chk = context.read<ChecklistProvider>();
    _totalItems = chk.totalItems;
    _checkedItems = chk.checkedItems;
    _missingItems = chk.missingItems.take(3).toList();
  }

  void _toggleSceneOverlay() {
    if (_sceneOpen) {
      _closeSceneOverlay();
      return;
    }
    _sceneOpen = true;
    _sceneOverlay = _createSceneOverlay();
    Overlay.of(context).insert(_sceneOverlay!);
  }

  void _closeSceneOverlay() {
    _sceneOverlay?.remove();
    _sceneOverlay = null;
    _sceneOpen = false;
  }

  OverlayEntry _createSceneOverlay() {
    final prov = context.read<ScenarioProvider>();
    final current = prov.scenario;

    return OverlayEntry(builder: (ctx) {
      return Stack(
        children: [
          // 透明遮罩（点击关闭）
          GestureDetector(
            onTap: () {
              _closeSceneOverlay();
              setState(() {});
            },
            behavior: HitTestBehavior.translucent,
            child: Container(color: Colors.transparent),
          ),
          // 下拉定位
          Positioned(
            width: 180,
            child: CompositedTransformFollower(
              link: _sceneLayer,
              showWhenUnlinked: false,
              offset: const Offset(0, 48),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(8),
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppConfig.cardBg,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: AppConfig.cardShadow,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: OutdoorScenario.values.map((s) {
                      final cfg = ScenarioConfig.of(s);
                      final isActive = s == current;
                      return GestureDetector(
                        onTap: () {
                          prov.scenario = s;
                          _closeSceneOverlay();
                          setState(() => _refresh());
                        },
                        child: Container(
                          height: AppConfig.sceneDropItemH,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isActive ? cfg.primaryColor.withOpacity(0.08) : null,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Text(s.emoji, style: const TextStyle(fontSize: 18)),
                              const SizedBox(width: 10),
                              Text(cfg.label, style: TextStyle(
                                fontSize: 15,
                                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                                color: isActive ? cfg.primaryColor : AppConfig.textPrimary,
                              )),
                              const Spacer(),
                              if (isActive)
                                Icon(Icons.check, size: 18, color: cfg.primaryColor),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  // ==================== Build ====================
  @override
  Widget build(BuildContext context) {
    final scenario = context.watch<ScenarioProvider>().scenario;
    final cfg = ScenarioConfig.of(scenario);

    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(cfg),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(AppConfig.pageMargin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== 规划区 =====
                    _sectionTitle('规划'),
                    const SizedBox(height: AppConfig.cardGap),

                    _planCard(
                      icon: Icons.route_outlined,
                      iconColor: cfg.primaryColor,
                      title: '路线规划',
                      subtitle: _routeCount > 0
                          ? '我的路线($_routeCount条)'
                          : '暂无路线',
                      detail: _latestRouteSummary.isNotEmpty
                          ? _latestRouteSummary
                          : (_routeCount > 0 ? '查看所有路线' : '创建第一条路线'),
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => const RouteLibraryPage(),
                      )),
                    ),

                    const SizedBox(height: AppConfig.cardGap),

                    _planCard(
                      icon: Icons.menu_book_outlined,
                      title: '出行攻略',
                      subtitle: '衣食住行全攻略',
                      detail: '添加衣食住行攻略',
                      iconColor: cfg.primaryColor,
                      onTap: () {
                        // TODO: 攻略编辑页
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('出行攻略模块开发中')),
                        );
                      },
                    ),

                    const SizedBox(height: AppConfig.cardGap),

                    _planCard(
                      icon: Icons.cloud_download_outlined,
                      title: '离线地图',
                      subtitle: '$_offlineRegions个区域可用',
                      detail: '管理已下载区域',
                      iconColor: cfg.primaryColor,
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => const OfflineMapsPage(),
                      )),
                    ),

                    // ===== 准备区 =====
                    const SizedBox(height: AppConfig.sectionGap),
                    _sectionTitle('准备'),
                    const SizedBox(height: AppConfig.cardGap),

                    _prepCard(
                      icon: Icons.checklist_outlined,
                      iconColor: cfg.primaryColor,
                      title: '装备检查',
                      subtitle: '已检查:$_checkedItems/$_totalItems 项',
                      warning: _missingItems.isNotEmpty
                          ? '未完成: ${_missingItems.join('、')}'
                          : null,
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => const ChecklistPage(),
                      )),
                    ),

                    const SizedBox(height: AppConfig.cardGap),

                    // 天气卡片
                    _weatherCard(cfg.primaryColor),

                    // ===== 出发行程按钮 =====
                    const SizedBox(height: AppConfig.sectionGap),
                    _departButton(cfg),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Top Bar ====================
  Widget _buildTopBar(ScenarioConfig cfg) {
    final scenario = context.watch<ScenarioProvider>().scenario;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin, vertical: 8),
      decoration: const BoxDecoration(
        color: AppConfig.glassBg,
        border: Border(bottom: BorderSide(color: AppConfig.divider, width: 0.5)),
      ),
      child: Row(
        children: [
          // ---- 场景下拉 ----
          CompositedTransformTarget(
            link: _sceneLayer,
            child: GestureDetector(
              onTap: () { _toggleSceneOverlay(); setState(() {}); },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(scenario.emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 6),
                  Text(cfg.label, style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w700,
                    color: cfg.primaryColor,
                  )),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down, size: 20, color: cfg.primaryColor),
                ],
              ),
            ),
          ),
          const Spacer(),
          // ---- 搜索 ----
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('搜索功能开发中')),
              );
            },
            child: const Icon(Icons.search, size: 24, color: AppConfig.textSecondary),
          ),
        ],
      ),
    );
  }

  // ==================== Section Title ====================
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 0),
      child: Text(text, style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppConfig.textSecondary,
        letterSpacing: 1,
      )),
    );
  }

  // ==================== 规划卡片 ====================
  Widget _planCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String detail,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppConfig.cardBg,
          borderRadius: BorderRadius.circular(AppConfig.cardRadius),
          boxShadow: AppConfig.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: AppConfig.cardIconSize, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600, color: AppConfig.textPrimary,
                      )),
                      const Spacer(),
                      const Icon(Icons.chevron_right, size: 20, color: AppConfig.textSecondary),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500, color: AppConfig.textPrimary,
                  )),
                  const SizedBox(height: 2),
                  Text(detail, style: const TextStyle(
                    fontSize: 12, color: AppConfig.textSecondary,
                  ), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 准备卡片 ====================
  Widget _prepCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    String? warning,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppConfig.cardBg,
          borderRadius: BorderRadius.circular(AppConfig.cardRadius),
          boxShadow: AppConfig.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: AppConfig.cardIconSize, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600, color: AppConfig.textPrimary,
                      )),
                      const Spacer(),
                      const Icon(Icons.chevron_right, size: 20, color: AppConfig.textSecondary),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500, color: AppConfig.textPrimary,
                  )),
                  if (warning != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 14, color: AppConfig.sosRed),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(warning, style: const TextStyle(
                            fontSize: 12, color: AppConfig.sosRed,
                          ), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 天气卡片 ====================
  Widget _weatherCard(Color primaryColor) {
    // Mock 天气数据
    final now     = DateTime.now();
    final today   = now;
    final tomorrow = now.add(const Duration(days: 1));
    final dayAfter = now.add(const Duration(days: 2));

    final days = [
      _WeatherDay('今天', today, '☀️', '28°', '微风 2级', null),
      _WeatherDay('明天', tomorrow, '⛅', '24°', '西北 3级', null),
      _WeatherDay('后天', dayAfter, '🌧️', '18°', '东北 4级', '大雨预警'),
    ];

    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('天气详情开发中')),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppConfig.cardBg,
          borderRadius: BorderRadius.circular(AppConfig.cardRadius),
          boxShadow: AppConfig.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.wb_sunny_outlined, size: 20, color: primaryColor),
                const SizedBox(width: 6),
                const Text('未来天气', style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600, color: AppConfig.textPrimary,
                )),
                const Spacer(),
                const Icon(Icons.chevron_right, size: 20, color: AppConfig.textSecondary),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: days.map((d) {
                return Expanded(
                  child: Column(
                    children: [
                      Text(d.label, style: const TextStyle(
                        fontSize: 12, color: AppConfig.textSecondary,
                      )),
                      const SizedBox(height: 4),
                      Text(d.emoji, style: const TextStyle(fontSize: 24)),
                      const SizedBox(height: 4),
                      Text(d.temp, style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600, color: AppConfig.textPrimary,
                      )),
                      const SizedBox(height: 2),
                      Text(d.wind, style: const TextStyle(
                        fontSize: 11, color: AppConfig.textSecondary,
                      ), maxLines: 1),
                      if (d.warning != null) ...[
                        const SizedBox(height: 2),
                        Text(d.warning!, style: const TextStyle(
                          fontSize: 11, color: AppConfig.sosRed, fontWeight: FontWeight.w500,
                        )),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 出发行程主按钮 ====================
  Widget _departButton(ScenarioConfig cfg) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => const DeparturePage(),
        ));
      },
      child: Container(
        width: double.infinity,
        height: AppConfig.primaryBtnH,
        decoration: BoxDecoration(
          gradient: goldGradient,
          borderRadius: BorderRadius.circular(AppConfig.buttonRadius),
          boxShadow: [
            BoxShadow(
              color: AppConfig.goldStart.withOpacity(0.3),
              blurRadius: 12, offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Text('出发行程', style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w700, color: AppConfig.textInverse,
          )),
        ),
      ),
    );
  }
}

// ===== 天气日 =====
class _WeatherDay {
  final String label, emoji, temp, wind;
  final String? warning;
  final DateTime date;
  const _WeatherDay(this.label, this.date, this.emoji, this.temp, this.wind, this.warning);
}
