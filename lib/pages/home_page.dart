import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../config/scenario_config.dart';
import '../providers/scenario_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/checklist_provider.dart';
import '../providers/trip_provider.dart';
import 'route_library_page.dart';
import 'offline_maps_page.dart';
import 'checklist_page.dart';
import 'departure_page.dart';
import 'navigation_page.dart';
import 'search_page.dart';

// ============================================================
// 首页 V2.0 — 出发前决策与准备面板
// 无地图/无指南针/无SOS/无广告/无内容推荐
// ============================================================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ===== 场景下拉 =====
  final LayerLink _sceneLayer = LayerLink();
  OverlayEntry? _sceneOverlay;
  bool _sceneOpen = false;

  // ===== 统计数据（从 provider 真实读取） =====
  int _routeCount = 0;
  String _latestRouteName = '';
  double _latestDistance = 0;
  int _offlineRegions = 0;

  // ===== 装备 =====
  int _checkedItems = 0;
  int _totalItems = 0;
  List<String> _missingItems = [];
  double _equipProgress = 0;

  // ===== 旅行建议条件 =====
  bool _hasRainWarning = false;
  bool _equipIncomplete = false;
  bool _offlineMissing = false;

  // ===== 出行计划 =====
  String? _plannedDate;
  String? _plannedRouteName;

  // ===== 补给数据 =====
  int _supplyCount = 0;
  String _supplyLabel = '';

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    final trip = context.read<TripProvider>();
    final routes = trip.completedTrips;
    _routeCount = routes.length;

    if (routes.isNotEmpty) {
      _latestRouteName = routes.last.name;
      _latestDistance = routes.last.totalDistanceKm;
    } else {
      _latestRouteName = '';
      _latestDistance = 0;
    }

    _offlineRegions = 3; // mock

    // 装备
    final chk = context.read<ChecklistProvider>();
    _totalItems = chk.totalItems;
    _checkedItems = chk.checkedItems;
    _missingItems = chk.missingItems.take(3).toList();
    _equipProgress = _totalItems > 0 ? _checkedItems / _totalItems : 0;
    _equipIncomplete = _missingItems.isNotEmpty;

    // 旅行建议条件
    _hasRainWarning = _checkRainWarning();
    _offlineMissing = _offlineRegions == 0;
  }

  bool _checkRainWarning() {
    // mock: 模拟后天有雨
    return true;
  }

  // ==================== 场景下拉 ====================
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
          GestureDetector(
            onTap: () {
              _closeSceneOverlay();
              setState(() {});
            },
            behavior: HitTestBehavior.translucent,
            child: Container(color: Colors.transparent),
          ),
          Positioned(
            width: 180,
            child: CompositedTransformFollower(
              link: _sceneLayer,
              showWhenUnlinked: false,
              offset: const Offset(0, 48),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppConfig.cardBg,
                    borderRadius: BorderRadius.circular(12),
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
                            borderRadius: BorderRadius.circular(12),
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
    final auth = context.watch<AuthProvider>();
    final isLogged = auth.isLoggedIn;

    // 补给按场景适配
    switch (scenario) {
      case OutdoorScenario.cycle:
        _supplyCount = 8;
        _supplyLabel = '补水点3 · 维修点2 · 餐饮3';
        break;
      case OutdoorScenario.moto:
        _supplyCount = 12;
        _supplyLabel = '加油站5 · 维修点3 · 摩旅驿站4';
        break;
      case OutdoorScenario.drive:
        _supplyCount = 15;
        _supplyLabel = '停车场5 · 营地5 · 充电桩5';
    }

    // 出行计划 mock
    _plannedDate = null;
    _plannedRouteName = null;

    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(cfg),
            Expanded(
              child: Stack(
                children: [
                  // 滚动内容
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppConfig.pageMargin, AppConfig.pageMargin,
                      AppConfig.pageMargin, AppConfig.primaryBtnH + 32,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ===== 3.2 用户数据快览 =====
                        _buildUserSnapshot(cfg.primaryColor, isLogged, auth),
                        const SizedBox(height: AppConfig.cardGap),

                        // ===== 3.3 出行建议 =====
                        _buildTravelSuggestion(cfg.primaryColor),
                        const SizedBox(height: AppConfig.sectionGap),

                        // ===== 3.4 规划区 =====
                        _sectionGoldBar('📋 规划'),
                        const SizedBox(height: AppConfig.cardGap),

                        _routePlanCard(cfg),
                        const SizedBox(height: AppConfig.cardGap),
                        _travelGuideCard(cfg),
                        const SizedBox(height: AppConfig.cardGap),
                        _offlineMapCard(cfg),

                        // ===== 3.5 准备区 =====
                        const SizedBox(height: AppConfig.sectionGap),
                        _sectionGoldBar('✅ 准备'),
                        const SizedBox(height: AppConfig.cardGap),

                        _equipmentCard(cfg.primaryColor),
                        const SizedBox(height: AppConfig.cardGap),
                        _weatherSection(cfg.primaryColor),

                        // ===== 3.6 增补卡片 =====
                        const SizedBox(height: AppConfig.sectionGap),
                        _supplyCard(cfg),
                        const SizedBox(height: AppConfig.cardGap),
                        _travelPlanCard(cfg),
                        const SizedBox(height: AppConfig.cardGap),
                        _seeOthersCard(cfg.primaryColor),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),

                  // ===== 3.7 固定在底部的出发行程按钮 =====
                  Positioned(
                    left: AppConfig.pageMargin,
                    right: AppConfig.pageMargin,
                    bottom: 8,
                    child: _departButton(cfg),
                  ),

                  // ===== 3.8 快速开始 FAB =====
                  if (isLogged && _routeCount > 0)
                    Positioned(
                      right: AppConfig.pageMargin,
                      bottom: AppConfig.primaryBtnH + 16,
                      child: _quickStartFab(cfg.primaryColor),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 3.1 顶部操作栏 ====================
  Widget _buildTopBar(ScenarioConfig cfg) {
    final scenario = context.watch<ScenarioProvider>().scenario;
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
      decoration: const BoxDecoration(
        color: AppConfig.glassBg,
        border: Border(bottom: BorderSide(color: AppConfig.divider, width: 0.5)),
      ),
      child: Row(
        children: [
          // 场景下拉
          CompositedTransformTarget(
            link: _sceneLayer,
            child: GestureDetector(
              onTap: () {
                _toggleSceneOverlay();
                setState(() {});
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(scenario.emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 6),
                  Text(cfg.label, style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w600,
                    color: cfg.primaryColor,
                  )),
                  const SizedBox(width: 2),
                  Icon(Icons.arrow_drop_down, size: 20, color: cfg.primaryColor),
                ],
              ),
            ),
          ),
          const Spacer(),
          // 搜索
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => const SearchPage(),
            )),
            child: const Icon(Icons.search, size: 22, color: AppConfig.textSecondary),
          ),
        ],
      ),
    );
  }

  // ==================== 3.2 用户数据快览 ====================
  Widget _buildUserSnapshot(Color primaryColor, bool isLogged, AuthProvider auth) {
    if (!isLogged) {
      return GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('登录功能开发中')),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDeco(),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person_outline, size: 24, color: primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '点击登录，开启你的出行记录',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: primaryColor),
                ),
              ),
              const Icon(Icons.chevron_right, size: 20, color: AppConfig.textSecondary),
            ],
          ),
        ),
      );
    }

    final trips = context.watch<TripProvider>();
    double totalKm = 0;
    double totalClimb = 0;
    for (final t in trips.completedTrips) {
      totalKm += t.totalDistanceKm;
    }
    // mock climb & districts
    totalClimb = totalKm * 0.022;

    return GestureDetector(
      onTap: () {
        // 切换到"我的"Tab 由外部控制，这里简单 snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('前往个人中心')),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDeco(),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: primaryColor.withOpacity(0.12),
              child: Text(auth.user.nickname.isNotEmpty ? auth.user.nickname[0] : '?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: primaryColor),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(auth.user.nickname.isNotEmpty ? auth.user.nickname : '探险者', style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600, color: AppConfig.textPrimary,
                  )),
                  const SizedBox(height: 4),
                  Text(
                    '累计 ${totalKm.toStringAsFixed(0)}km · 爬升 ${totalClimb.toStringAsFixed(0)}km · 点亮 ${(_routeCount ~/ 3)}区县',
                    style: const TextStyle(fontSize: 13, color: AppConfig.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_rankLabel(totalKm)} · ${_medalCount(totalKm)}枚勋章',
                    style: TextStyle(fontSize: 12, color: primaryColor.withOpacity(0.8)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: AppConfig.textSecondary),
          ],
        ),
      ),
    );
  }

  String _rankLabel(double km) {
    if (km > 5000) return '征服者(金)';
    if (km > 2000) return '探险家(银)';
    if (km > 500) return '探险者(银)';
    return '新手(铜)';
  }

  int _medalCount(double km) {
    if (km > 5000) return 8;
    if (km > 2000) return 5;
    if (km > 500) return 3;
    return 1;
  }

  // ==================== 3.3 出行建议 ====================
  Widget _buildTravelSuggestion(Color primaryColor) {
    String text;
    Color textColor;

    if (_hasRainWarning) {
      text = '后天有雨，建议今天或明天出发';
      textColor = AppConfig.sosRed;
    } else if (_equipIncomplete) {
      text = '核心装备未完成，出发前请检查';
      textColor = AppConfig.motoPrimary;
    } else if (_offlineMissing) {
      text = '建议下载离线地图，无网络也能导航';
      textColor = AppConfig.motoPrimary;
    } else {
      text = '条件良好，适合出发 ✅';
      textColor = primaryColor;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco(),
      child: Row(
        children: [
          Text('💡', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 3.4 规划 - 路线规划 ====================
  Widget _routePlanCard(ScenarioConfig cfg) {
    if (_routeCount == 0) {
      return _emptyPlanCard(
        icon: Icons.route_outlined,
        color: cfg.primaryColor,
        title: '路线规划',
        illustration: '🗺️',
        hint: '还没有自己的路线',
        lines: const ['在地图上打点创建路线', '导入 GPX 文件', '从历史轨迹快速生成'],
        buttonLabel: '开始创建',
        onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => const DeparturePage(),
        )),
      );
    }

    return _filledPlanCard(
      icon: Icons.route_outlined,
      color: cfg.primaryColor,
      title: '路线规划',
      summary: '$_routeCount条路线',
      detail: _latestRouteName.isNotEmpty ? '$_latestRouteName · ${_latestDistance.toStringAsFixed(0)}km' : '查看所有路线',
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => const RouteLibraryPage(),
      )),
    );
  }

  // ==================== 3.4 规划 - 出行攻略 ====================
  Widget _travelGuideCard(ScenarioConfig cfg) {
    // mock: 无攻略
    return _emptyPlanCard(
      icon: Icons.menu_book_outlined,
      color: cfg.primaryColor,
      title: '出行攻略',
      illustration: '📒',
      hint: '添加衣食住行攻略',
      lines: const ['记录沿途美食、住宿、路况', '关联路线，出行时随时查看'],
      buttonLabel: '添加攻略',
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('出行攻略模块开发中')),
        );
      },
    );
  }

  // ==================== 3.4 规划 - 离线地图 ====================
  Widget _offlineMapCard(ScenarioConfig cfg) {
    if (_offlineRegions > 0) {
      return _filledPlanCard(
        icon: Icons.cloud_download_outlined,
        color: cfg.primaryColor,
        title: '离线地图',
        summary: '$_offlineRegions个区域可用',
        detail: '管理已下载区域',
        onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => const OfflineMapsPage(),
        )),
      );
    }

    return _emptyPlanCard(
      icon: Icons.cloud_download_outlined,
      color: cfg.primaryColor,
      title: '离线地图',
      illustration: '📥',
      hint: '暂无离线地图',
      lines: const ['下载离线地图后，无网络也能导航', '节省流量，户外更安心'],
      buttonLabel: '去下载',
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => const OfflineMapsPage(),
      )),
    );
  }

  // ==================== 3.5 准备 - 装备卡片 ====================
  Widget _equipmentCard(Color primaryColor) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => const ChecklistPage(),
      )),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDeco(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.checklist_outlined, size: 22, color: primaryColor),
                const SizedBox(width: 8),
                const Text('装备检查', style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600, color: AppConfig.textPrimary,
                )),
                const Spacer(),
                const Icon(Icons.chevron_right, size: 20, color: AppConfig.textSecondary),
              ],
            ),
            const SizedBox(height: 12),

            // 进度条
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: _equipProgress,
                backgroundColor: const Color(0xFFEDEDED),
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              '核心装备 ${_checkedItems}/${_totalItems} (${(_equipProgress * 100).toStringAsFixed(0)}%)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: primaryColor),
            ),

            if (_missingItems.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 14, color: AppConfig.sosRed),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '未完成：${_missingItems.join('、')}${_missingItems.length < (context.read<ChecklistProvider>().missingItems.length) ? ' 等${context.read<ChecklistProvider>().missingItems.length}项' : ''}',
                      style: const TextStyle(fontSize: 12, color: AppConfig.sosRed),
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ==================== 3.5 准备 - 天气卡片 ====================
  Widget _weatherSection(Color primaryColor) {
    final days = [
      _WDay('今天', '☀️', '28°', '微风 2级', false),
      _WDay('明天', '⛅', '24°', '西北 3级', false),
      _WDay('后天', '🌧️', '18°', '东北 4级', _hasRainWarning),
    ];

    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('天气详情开发中')),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDeco(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.wb_sunny_outlined, size: 20, color: primaryColor),
                const SizedBox(width: 8),
                const Text('📍 杭州', style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600, color: AppConfig.textPrimary,
                )),
                const Spacer(),
                const Text('查看详细预报 →', style: TextStyle(
                  fontSize: 12, color: AppConfig.textSecondary,
                )),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: days.map((d) {
                return Expanded(
                  child: Column(
                    children: [
                      Text(d.label, style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
                      const SizedBox(height: 4),
                      Text(d.emoji, style: TextStyle(fontSize: 26)),
                      const SizedBox(height: 4),
                      Text(d.temp, style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600, color: AppConfig.textPrimary,
                      )),
                      const SizedBox(height: 2),
                      Text(d.wind, style: TextStyle(
                        fontSize: 11,
                        color: d.warning ? AppConfig.sosRed : AppConfig.textSecondary,
                      ), maxLines: 1, overflow: TextOverflow.ellipsis),
                      if (d.warning) ...[
                        const SizedBox(height: 2),
                        Text('⚠️ 大雨', style: const TextStyle(
                          fontSize: 10, color: AppConfig.sosRed, fontWeight: FontWeight.w500,
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

  // ==================== 3.6 沿途补给卡片 ====================
  Widget _supplyCard(ScenarioConfig cfg) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('补给分布页开发中')),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDeco(),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: cfg.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.local_gas_station_outlined, size: 24, color: cfg.primaryColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('沿途补给', style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600, color: AppConfig.textPrimary,
                  )),
                  const SizedBox(height: 4),
                  Text(_supplyLabel, style: const TextStyle(
                    fontSize: 13, color: AppConfig.textSecondary,
                  )),
                ],
              ),
            ),
            Text('$_supplyCount个', style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500, color: cfg.primaryColor,
            )),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 20, color: AppConfig.textSecondary),
          ],
        ),
      ),
    );
  }

  // ==================== 3.6 出行计划卡片 ====================
  Widget _travelPlanCard(ScenarioConfig cfg) {
    if (_plannedDate != null && _plannedRouteName != null) {
      return GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDeco(),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: cfg.primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.calendar_today_outlined, size: 22, color: cfg.primaryColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('出行计划', style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600, color: AppConfig.textPrimary,
                    )),
                    const SizedBox(height: 4),
                    Text('$_plannedRouteName · $_plannedDate', style: const TextStyle(
                      fontSize: 13, color: AppConfig.textSecondary,
                    )),
                    const SizedBox(height: 2),
                    Text('${_latestDistance.toStringAsFixed(0)}km · 预估${(_latestDistance / 80).ceil()}天', style: const TextStyle(
                      fontSize: 12, color: AppConfig.textSecondary,
                    )),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 20, color: AppConfig.textSecondary),
            ],
          ),
        ),
      );
    }

    if (_latestRouteName.isNotEmpty) {
      return GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDeco(),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: cfg.primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.calendar_today_outlined, size: 22, color: cfg.primaryColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('出行计划', style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600, color: AppConfig.textPrimary,
                    )),
                    const SizedBox(height: 4),
                    Text('$_latestRouteName', style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500, color: AppConfig.textPrimary,
                    )),
                    const SizedBox(height: 2),
                    Text('暂未设置出发日期', style: const TextStyle(
                      fontSize: 12, color: AppConfig.textSecondary,
                    )),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 20, color: AppConfig.textSecondary),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDeco(),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: cfg.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.calendar_today_outlined, size: 22, color: cfg.primaryColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('出行计划', style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600, color: AppConfig.textPrimary,
                  )),
                  SizedBox(height: 4),
                  Text('还没有出行计划，去规划一条路线吧', style: TextStyle(
                    fontSize: 13, color: AppConfig.textSecondary,
                  )),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: AppConfig.textSecondary),
          ],
        ),
      ),
    );
  }

  // ==================== 3.6 看看别人怎么走 ====================
  Widget _seeOthersCard(Color primaryColor) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => const RouteLibraryPage(),
      )),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDeco(),
        child: Row(
          children: [
            Text('👀', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('看看别人怎么走', style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600, color: AppConfig.textPrimary,
                  )),
                  const SizedBox(height: 4),
                  Text('浏览公开路线，获取灵感', style: const TextStyle(
                    fontSize: 13, color: AppConfig.textSecondary,
                  )),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('去看看', style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: primaryColor,
              )),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 3.7 出发行程按钮（固定） ====================
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
              blurRadius: 12,
              offset: const Offset(0, 4),
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

  // ==================== 3.8 快速开始 FAB ====================
  Widget _quickStartFab(Color primaryColor) {
    return GestureDetector(
      onTap: () {
        final scenario = context.read<ScenarioProvider>().scenario;
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => NavigationPage(scenario: scenario),
        ));
      },
      child: Container(
        width: 52, height: 52,
        decoration: BoxDecoration(
          color: primaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.35),
              blurRadius: 12, offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Text('⚡', style: TextStyle(fontSize: 24, color: AppConfig.textInverse)),
        ),
      ),
    );
  }

  // ==================== Helpers ====================

  BoxDecoration _cardDeco() {
    return BoxDecoration(
      color: AppConfig.cardBg,
      borderRadius: BorderRadius.circular(AppConfig.cardRadius),
      boxShadow: AppConfig.cardShadow,
    );
  }

  /// Section 金色竖条
  Widget _sectionGoldBar(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Row(
        children: [
          Container(
            width: 4, height: 20,
            decoration: BoxDecoration(
              color: AppConfig.goldEnd,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.w700, color: AppConfig.textPrimary,
          )),
        ],
      ),
    );
  }

  // --- 规划卡片（空状态） ---
  Widget _emptyPlanCard({
    required IconData icon,
    required Color color,
    required String title,
    required String illustration,
    required String hint,
    required List<String> lines,
    required String buttonLabel,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDeco(),
        child: Row(
          children: [
            // 左图标区
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600, color: AppConfig.textPrimary,
                  )),
                  const SizedBox(height: 6),
                  Center(
                    child: Column(
                      children: [
                        Text(illustration, style: TextStyle(fontSize: 28)),
                        const SizedBox(height: 6),
                        Text(hint, style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500, color: AppConfig.textPrimary,
                        )),
                        const SizedBox(height: 4),
                        ...lines.map((l) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(l, style: const TextStyle(
                            fontSize: 12, color: AppConfig.textSecondary,
                          )),
                        )),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: onTap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(buttonLabel, style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600, color: color,
                            )),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 20, color: AppConfig.textSecondary),
          ],
        ),
      ),
    );
  }

  // --- 规划卡片（已填充） ---
  Widget _filledPlanCard({
    required IconData icon,
    required Color color,
    required String title,
    required String summary,
    required String detail,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDeco(),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 24, color: color),
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
                  Text(summary, style: const TextStyle(
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

  // ==================== 导航方法（供外部组件使用） ====================
  void goToDeparture() {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => const DeparturePage(),
    ));
  }
}

// ===== 天气日数据 =====
class _WDay {
  final String label, emoji, temp, wind;
  final bool warning;
  const _WDay(this.label, this.emoji, this.temp, this.wind, this.warning);
}
