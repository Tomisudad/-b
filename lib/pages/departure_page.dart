import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../config/scenario_config.dart';
import '../models/route_model.dart';
import '../providers/trip_provider.dart';
import 'navigation_page.dart';

/// V6.1 新建路线并出发 — 完整流程
/// Step: method → smartRecommend → mapPin/gpxImport → routeInfo → confirm → navigate
enum _FlowStep { method, smartRecommend, mapPin, gpxImport, routeInfo, confirm, navigating }

class DeparturePage extends StatefulWidget {
  final RouteModel? fromRoute;
  const DeparturePage({super.key, this.fromRoute});

  @override
  State<DeparturePage> createState() => _DeparturePageState();
}

class _DeparturePageState extends State<DeparturePage> {
  _FlowStep _step = _FlowStep.method;
  OutdoorScenario _scenario = OutdoorScenario.cycle;
  RouteDifficulty _difficulty = RouteDifficulty.medium;

  // 地图打点数据
  final List<_Waypoint> _waypoints = [];
  String _routeName = '未命名路线';
  final TextEditingController _nameCtrl = TextEditingController(text: '未命名路线');
  final TextEditingController _noteCtrl = TextEditingController();
  bool _isPublic = true;
  String? _linkedChecklist;

  // 路线计算结果
  double _totalDistance = 0;
  int _totalClimb = 0;
  int _estMinutes = 0;

  // V6.1: 智能推荐偏好
  _SmartTarget _smartTarget = _SmartTarget.scenic;
  final Set<_SmartScenery> _smartScenery = {};
  _SmartSurface _smartSurface = _SmartSurface.paved;
  bool _smartNeedWater = true;
  bool _smartNeedViewpoint = true;
  int _smartMaxHour = 4;
  _SmartResult? _smartResult;
  bool _offlineReady = false;
  bool _isSolo = true;

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = _routeName;
    final r = widget.fromRoute;
    if (r != null) {
      _routeName = r.name;
      _scenario = r.scenario;
      _difficulty = switch (r.difficulty) { 1 => RouteDifficulty.easy, 2 => RouteDifficulty.medium, 3 => RouteDifficulty.hard, _ => RouteDifficulty.extreme };
      _totalDistance = r.distanceKm;
      _totalClimb = r.totalClimb;
      _estMinutes = r.durationMinutes;
      _nameCtrl.text = r.name;
      _step = _FlowStep.confirm;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  // ===== Mock 数据 =====
  void _recalcRoute() {
    if (_waypoints.length < 2) {
      _totalDistance = 0; _totalClimb = 0; _estMinutes = 0;
      return;
    }
    final rng = Random(_waypoints.length * 42);
    double dist = 0;
    int climb = 0;
    for (int i = 1; i < _waypoints.length; i++) {
      final seg = 3.0 + rng.nextDouble() * 25.0;
      dist += seg;
      climb += (rng.nextInt(200) + 30);
    }
    _totalDistance = dist;
    _totalClimb = climb;
    _estMinutes = (dist / (_scenario == OutdoorScenario.cycle ? 20 : _scenario == OutdoorScenario.moto ? 50 : 60) * 60).round() + climb * 2 ~/ 100;
  }

  @override
  Widget build(BuildContext context) {
    switch (_step) {
      case _FlowStep.method: return _buildMethodPage();
      case _FlowStep.smartRecommend: return _buildSmartRecommendPage();
      case _FlowStep.mapPin: return _buildMapPinPage();
      case _FlowStep.gpxImport: return _buildGpxImportPage();
      case _FlowStep.routeInfo: return _buildRouteInfoPage();
      case _FlowStep.confirm: return _buildConfirmPage();
      case _FlowStep.navigating:
        return NavigationPage(scenario: _scenario, routeName: _routeName);
    }
  }

  // ==================== V6.1 创建方式选择 (3 种: 智能推荐/地图打点/导入GPX) ====================
  Widget _buildMethodPage() {
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(title: const Text('新建路线并出发')),
      body: Padding(
        padding: const EdgeInsets.all(AppConfig.pageMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text('选择创建方式', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
            const SizedBox(height: 24),
            _methodCard(
              '🧠', '智能推荐', '设置偏好，自动生成最优路线',
              AppConfig.goldStart, () => setState(() => _step = _FlowStep.smartRecommend),
            ),
            const SizedBox(height: 16),
            _methodCard(
              '🗺️', '地图打点规划', '在图上长按添加途经点，拖拽调整顺序',
              AppConfig.cyclePrimary, () => setState(() => _step = _FlowStep.mapPin),
            ),
            const SizedBox(height: 16),
            _methodCard(
              '📂', '导入GPX轨迹', '从本地文件、链接或扫码导入',
              AppConfig.motoPrimary, () => setState(() => _step = _FlowStep.gpxImport),
            ),
          ],
        ),
      ),
    );
  }

  Widget _methodCard(String emoji, String title, String desc, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppConfig.cardBg,
          borderRadius: BorderRadius.circular(AppConfig.cardRadiusLg),
          boxShadow: AppConfig.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
                  const SizedBox(height: 4),
                  Text(desc, style: const TextStyle(fontSize: 13, color: AppConfig.textSecondary, height: 1.3)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  // ==================== V6.1 智能推荐 ====================
  Widget _buildSmartRecommendPage() {
    final hasResult = _smartResult != null;
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(
        title: Text(hasResult ? '推荐路线' : '智能推荐'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() { _smartResult = null; _step = _FlowStep.method; }),
        ),
      ),
      body: hasResult ? _buildSmartResult() : _buildSmartPreferences(),
    );
  }

  Widget _buildSmartPreferences() {
    return ListView(
      padding: const EdgeInsets.all(AppConfig.pageMargin),
      children: [
        // 目标类型
        const Text('路线目标', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
        const SizedBox(height: 4),
        const Text('选择你最看重的路线特性', style: TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: _SmartTarget.values.map((t) {
          final sel = _smartTarget == t;
          return GestureDetector(
            onTap: () => setState(() => _smartTarget = t),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: sel ? AppConfig.goldStart.withOpacity(0.1) : AppConfig.cardBg,
                borderRadius: BorderRadius.circular(AppConfig.tagRadius),
                border: Border.all(color: sel ? AppConfig.goldStart : AppConfig.divider),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [Text(t.emoji, style: const TextStyle(fontSize: 16)), const SizedBox(width: 6), Text(t.label, style: TextStyle(fontSize: 13, fontWeight: sel ? FontWeight.w600 : FontWeight.w400, color: sel ? AppConfig.goldStart : AppConfig.textPrimary))]),
            ),
          );
        }).toList()),

        const SizedBox(height: 16),
        // 风景偏好
        const Text('风景偏好（可多选）', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: _SmartScenery.values.map((s) {
          final sel = _smartScenery.contains(s);
          return GestureDetector(
            onTap: () => setState(() => sel ? _smartScenery.remove(s) : _smartScenery.add(s)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: sel ? s.color.withOpacity(0.1) : AppConfig.cardBg,
                borderRadius: BorderRadius.circular(AppConfig.tagRadius),
                border: Border.all(color: sel ? s.color : AppConfig.divider),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [Text(s.emoji, style: const TextStyle(fontSize: 14)), const SizedBox(width: 5), Text(s.label, style: TextStyle(fontSize: 12, fontWeight: sel ? FontWeight.w600 : FontWeight.w400, color: sel ? s.color : AppConfig.textPrimary))]),
            ),
          );
        }).toList()),

        const SizedBox(height: 16),
        // 路面偏好
        const Text('路面偏好', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
        const SizedBox(height: 8),
        Row(children: _SmartSurface.values.map((s) {
          final sel = _smartSurface == s;
          return Expanded(child: Padding(padding: EdgeInsets.only(right: s == _SmartSurface.values.last ? 0 : 8), child: GestureDetector(
            onTap: () => setState(() => _smartSurface = s),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: sel ? AppConfig.goldStart.withOpacity(0.1) : AppConfig.cardBg,
                borderRadius: BorderRadius.circular(AppConfig.tagRadius),
                border: Border.all(color: sel ? AppConfig.goldStart : AppConfig.divider),
              ),
              child: Column(children: [Icon(s.icon, size: 20, color: sel ? AppConfig.goldStart : AppConfig.textSecondary), const SizedBox(height: 4), Text(s.label, style: TextStyle(fontSize: 11, fontWeight: sel ? FontWeight.w600 : FontWeight.w400, color: sel ? AppConfig.goldStart : AppConfig.textPrimary))]),
            ),
          )));
}).toList()),

        const SizedBox(height: 16),
        // 途经需求
        const Text('途经需求', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
        const SizedBox(height: 8),
        Row(children: [
          _toggleChip('💧 补给站', _smartNeedWater, (v) => setState(() => _smartNeedWater = v)),
          const SizedBox(width: 8),
          _toggleChip('📷 观景点', _smartNeedViewpoint, (v) => setState(() => _smartNeedViewpoint = v)),
        ]),

        const SizedBox(height: 16),
        // 体能参数
        const Text('体能参数', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), border: Border.all(color: AppConfig.divider)),
          child: Column(children: [
            Row(children: [
              const Text('最长骑行时间', style: TextStyle(fontSize: 13, color: AppConfig.textSecondary)),
              const Spacer(),
              Text('${_smartMaxHour} 小时', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
            ]),
            Slider(
              value: _smartMaxHour.toDouble(),
              min: 1, max: 10, divisions: 9,
              activeColor: AppConfig.goldStart,
              label: '$_smartMaxHour 小时',
              onChanged: (v) => setState(() => _smartMaxHour = v.round()),
            ),
          ]),
        ),

        const SizedBox(height: 20),
        // 生成按钮
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _genSmartRoute,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.buttonRadius)),
              backgroundColor: AppConfig.goldStart,
            ),
            child: const Text('生成推荐路线', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ),
        const SizedBox(height: 8),
        Text('基于你的偏好自动生成最优路线，< 500ms', style: const TextStyle(fontSize: 11, color: AppConfig.textSecondary), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _toggleChip(String label, bool value, ValueChanged<bool> onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: value ? AppConfig.goldStart.withOpacity(0.08) : AppConfig.cardBg,
          borderRadius: BorderRadius.circular(AppConfig.tagRadius),
          border: Border.all(color: value ? AppConfig.goldStart.withOpacity(0.3) : AppConfig.divider),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(width: 16, height: 16, child: Checkbox(value: value, onChanged: (v) => onChanged(v ?? false), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, activeColor: AppConfig.goldStart, side: const BorderSide(color: AppConfig.divider))),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, color: value ? AppConfig.goldStart : AppConfig.textSecondary)),
        ]),
      ),
    );
  }

  void _genSmartRoute() {
    // V6.1 mock: 模拟推荐路线
    String name, desc;
    double dist; int cl, dur; List<String> ps;
    switch (_smartTarget) {
      case _SmartTarget.shortest:
        name = '龙井-梅家坞捷径'; desc = '最短路径，18.5km，避开拥堵路段'; dist = 18.5; cl = 280; dur = 55; ps = ['龙井村', '梅家坞', '云栖竹径']; break;
      case _SmartTarget.scenic:
        name = '西湖秘境环线'; desc = '途经3处观景台、2处茶园，风景评分 ⭐4.8'; dist = 26.8; cl = 420; dur = 90; ps = ['杨公堤', '茅家埠', '龙井茶园', '九溪烟树']; break;
      case _SmartTarget.challenge:
        name = '龙井北坡挑战线'; desc = '连续爬坡 6km，坡度最高 15%，适合进阶骑手'; dist = 22.3; cl = 680; dur = 85; ps = ['龙井北坡', '中天竺', '灵隐']; break;
      case _SmartTarget.eco:
        name = '龙井休闲缓坡线'; desc = '缓坡为主，全程坡度 < 5%，适合休闲骑行'; dist = 19.2; cl = 180; dur = 65; ps = ['虎跑路', '满觉陇', '六和塔']; break;
    }
    setState(() {
      _smartResult = _SmartResult(name: name, desc: desc, distanceKm: dist, climb: cl, durationMin: dur, pois: ps);
    });
  }

  Widget _buildSmartResult() {
    final r = _smartResult!;
    return ListView(padding: const EdgeInsets.all(AppConfig.pageMargin), children: [
      // Route summary card
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppConfig.cardBg,
          borderRadius: BorderRadius.circular(AppConfig.cardRadiusLg),
          boxShadow: AppConfig.cardShadow,
          border: Border.all(color: AppConfig.goldStart.withOpacity(0.2)),
        ),
        child: Column(children: [
          Container(width: 64, height: 64, decoration: BoxDecoration(color: AppConfig.goldStart.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.route, size: 32, color: AppConfig.goldStart)),
          const SizedBox(height: 12),
          Text(r.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
          const SizedBox(height: 4),
          Text(r.desc, style: const TextStyle(fontSize: 13, color: AppConfig.textSecondary), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _dataCol('距离', '${r.distanceKm.toStringAsFixed(1)} km', AppConfig.textPrimary),
            _dataCol('爬升', '${r.climb} m', AppConfig.motoPrimary),
            _dataCol('用时', '${(r.durationMin ~/ 60)}h${r.durationMin % 60}min', AppConfig.cyclePrimary),
          ]),
          const SizedBox(height: 14),
          // POI tags
          Wrap(spacing: 6, runSpacing: 6, children: r.pois.map((p) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppConfig.goldStart.withOpacity(0.08), borderRadius: BorderRadius.circular(AppConfig.tagRadius)), child: Text(p, style: const TextStyle(fontSize: 12, color: AppConfig.goldStart)))).toList()),
        ]),
      ),

      const SizedBox(height: 16),
      Text('偏好设置: ${_smartTarget.label} · ${_smartScenery.map((s) => s.label).join('、')} · ${_smartSurface.label}', style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary)),

      const SizedBox(height: 16),
      Row(children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => setState(() => _smartResult = null),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.buttonRadius)), side: const BorderSide(color: AppConfig.divider), foregroundColor: AppConfig.textPrimary),
            child: const Text('重新调整', style: TextStyle(fontSize: 14)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              _routeName = r.name;
              _totalDistance = r.distanceKm;
              _totalClimb = r.climb;
              _estMinutes = r.durationMin;
              setState(() => _step = _FlowStep.confirm);
            },
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.buttonRadius)), backgroundColor: AppConfig.goldStart, foregroundColor: Colors.white),
            child: const Text('使用此路线', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ),
      ]),
    ]);
  }

  // ==================== 4.2 地图打点创建 ====================
  Widget _buildMapPinPage() {
    _recalcRoute();
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(
        title: const Text('地图打点规划'),
        actions: [
          TextButton(onPressed: () => setState(() { _waypoints.clear(); _recalcRoute(); }), child: const Text('清空', style: TextStyle(color: AppConfig.textSecondary))),
        ],
      ),
      body: Column(
        children: [
          // 地图区域 (mock)
          Container(
            height: 280,
            decoration: BoxDecoration(
              color: AppConfig.bgMain,
              border: Border.all(color: AppConfig.divider),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: _RoutePreviewPainter(_waypoints, _scenario.primaryColor)),
                ),
                ..._waypoints.asMap().entries.map((e) {
                  final i = e.key;
                  final wp = e.value;
                  final left = wp.x * 280;
                  final top = wp.y * 280;
                  return Positioned(
                    left: left - 18, top: top - 18,
                    child: GestureDetector(
                      onTap: () => _editWaypoint(i),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: i == 0 ? AppConfig.cyclePrimary : i == _waypoints.length - 1 ? AppConfig.sosRed : AppConfig.goldStart,
                          shape: BoxShape.circle,
                          boxShadow: const [BoxShadow(color: Color(0x30000000), blurRadius: 4, offset: Offset(0, 2))],
                        ),
                        child: Center(
                          child: Text(
                            i == 0 ? '起' : i == _waypoints.length - 1 ? '终' : '${i}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          // 长按提示
          Container(
            width: double.infinity, padding: const EdgeInsets.all(10),
            color: AppConfig.cyclePrimary.withOpacity(0.06),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.touch_app, size: 16, color: AppConfig.cyclePrimary.withOpacity(0.6)),
                const SizedBox(width: 6),
                const Text('长按地图添加途经点 · 拖拽点调整顺序', style: TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
              ],
            ),
          ),
          // 路线数据
          if (_waypoints.isNotEmpty)
            Container(
              width: double.infinity, padding: const EdgeInsets.all(14),
              color: AppConfig.cardBg,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _dataCol('总距离', '${_totalDistance.toStringAsFixed(1)} km', AppConfig.textPrimary),
                  _dataCol('爬升', '${_totalClimb} m', AppConfig.motoPrimary),
                  _dataCol('坡度', '${_totalDistance > 0 ? (_totalClimb / (_totalDistance * 10)).toStringAsFixed(1) : "0"}%', AppConfig.drivePrimary),
                  _dataCol('预计', '${(_estMinutes ~/ 60)}h${_estMinutes % 60}min', AppConfig.cyclePrimary),
                ],
              ),
            ),
          // 途经点列表
          Expanded(
            child: _waypoints.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.map_outlined, size: 48, color: AppConfig.textSecondary.withOpacity(0.3)),
                        const SizedBox(height: 12),
                        const Text('长按地图添加途经点', style: TextStyle(fontSize: 14, color: AppConfig.textSecondary)),
                      ],
                    ),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin, vertical: 8),
                    itemCount: _waypoints.length,
                    onReorder: (oldI, newI) {
                      setState(() {
                        if (newI > oldI) newI--;
                        final item = _waypoints.removeAt(oldI);
                        _waypoints.insert(newI, item);
                        _recalcRoute();
                      });
                    },
                    itemBuilder: (_, i) {
                      final wp = _waypoints[i];
                      return Container(
                        key: ValueKey('wp_${i}'),
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius),
                        ),
                        child: ListTile(
                          dense: true,
                          leading: Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              color: i == 0 ? AppConfig.cyclePrimary.withOpacity(0.1) : i == _waypoints.length - 1 ? AppConfig.sosRed.withOpacity(0.1) : AppConfig.goldStart.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(child: Text('${i + 1}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: i == 0 ? AppConfig.cyclePrimary : i == _waypoints.length - 1 ? AppConfig.sosRed : AppConfig.goldStart))),
                          ),
                          title: Text(wp.note ?? '途经点 ${i + 1}', style: const TextStyle(fontSize: 14, color: AppConfig.textPrimary)),
                          subtitle: wp.supplyType != null ? Text(wp.supplyType!, style: const TextStyle(fontSize: 11, color: AppConfig.cyclePrimary)) : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(icon: const Icon(Icons.edit_outlined, size: 16), onPressed: () => _editWaypoint(i), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                              wp.supplyType == null
                                  ? IconButton(icon: const Icon(Icons.add_location_outlined, size: 16), onPressed: () => _addSupply(i), padding: EdgeInsets.zero, constraints: const BoxConstraints())
                                  : IconButton(icon: const Icon(Icons.close, size: 16), onPressed: () => setState(() { wp.supplyType = null; }), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                              const Icon(Icons.drag_handle, size: 16, color: AppConfig.textSecondary),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _waypoints.length >= 2
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppConfig.pageMargin, 8, AppConfig.pageMargin, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _addRandomPoint(),
                        child: const Text('添加途经点'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.buttonRadius)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => setState(() => _step = _FlowStep.routeInfo),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: AppConfig.goldStart,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.buttonRadius)),
                        ),
                        child: const Text('下一步 →', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppConfig.pageMargin),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _addQuickRoute(),
                    child: const Text('快速添加途经点示例', style: TextStyle(fontSize: 14)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.buttonRadius)),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _dataCol(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppConfig.textSecondary)),
        const SizedBox(height: 3),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }

  void _addRandomPoint() {
    final rng = Random();
    setState(() {
      _waypoints.add(_Waypoint(
        x: 0.1 + rng.nextDouble() * 0.8,
        y: 0.15 + rng.nextDouble() * 0.7,
      ));
      _recalcRoute();
    });
  }

  void _addQuickRoute() {
    setState(() {
      _waypoints.clear();
      _waypoints.addAll([
        _Waypoint(x: 0.12, y: 0.55, note: '起点'),
        _Waypoint(x: 0.28, y: 0.40, note: '第一段上升'),
        _Waypoint(x: 0.45, y: 0.22, note: '垭口', supplyType: '补水点'),
        _Waypoint(x: 0.58, y: 0.35, note: '观景台'),
        _Waypoint(x: 0.72, y: 0.60, note: '补给站', supplyType: '加油站'),
        _Waypoint(x: 0.88, y: 0.50, note: '终点'),
      ]);
      _recalcRoute();
    });
  }

  void _editWaypoint(int index) {
    final wp = _waypoints[index];
    final ctrl = TextEditingController(text: wp.note ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.dialogRadius)),
        title: Text('编辑途经点 ${index + 1}'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: '备注...')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(onPressed: () { setState(() => wp.note = ctrl.text.isEmpty ? null : ctrl.text); Navigator.pop(ctx); }, child: const Text('保存')),
        ],
      ),
    );
  }

  void _addSupply(int index) {
    final wp = _waypoints[index];
    final cfg = ScenarioConfig.of(_scenario);
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.vertical(top: Radius.circular(AppConfig.dialogRadius))),
        child: SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(height: 12),
            Container(width: 32, height: 4, decoration: BoxDecoration(color: AppConfig.divider, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 12),
            const Text('标记为补给点', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ...cfg.supplyCategories.map((cat) => ListTile(
              leading: Icon(Icons.location_on, color: _scenario.primaryColor),
              title: Text(cat),
              onTap: () { setState(() => wp.supplyType = cat); Navigator.pop(context); },
            )),
          ]),
        ),
      ),
    );
  }

  // ==================== 4.3 导入 GPX ====================
  Widget _buildGpxImportPage() {
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(title: const Text('导入GPX轨迹')),
      body: Padding(
        padding: const EdgeInsets.all(AppConfig.pageMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('导入方式', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
            const SizedBox(height: 20),
            _methodCard('📁', '选择本地文件', '支持 .gpx 格式', AppConfig.cyclePrimary, () => _handleGpxFile()),
            const SizedBox(height: 12),
            _methodCard('🔗', '粘贴链接', '输入GPX文件的URL', AppConfig.drivePrimary, () => _handleGpxUrl()),
            const SizedBox(height: 12),
            _methodCard('📷', '扫码导入', '扫描二维码获取轨迹', AppConfig.motoPrimary, () => _handleGpxScan()),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => setState(() => _step = _FlowStep.method),
                child: const Text('← 返回', style: TextStyle(fontSize: 14, color: AppConfig.textSecondary)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleGpxFile() {
    // Mock: 模拟成功导入
    setState(() {
      _waypoints.clear();
      _waypoints.addAll([
        _Waypoint(x: 0.10, y: 0.50, note: '导入起点'),
        _Waypoint(x: 0.25, y: 0.42),
        _Waypoint(x: 0.40, y: 0.30, note: '爬坡段'),
        _Waypoint(x: 0.55, y: 0.25, note: '垭口'),
        _Waypoint(x: 0.70, y: 0.40),
        _Waypoint(x: 0.85, y: 0.55, note: '导入终点'),
      ]);
      _recalcRoute();
      _step = _FlowStep.routeInfo;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('GPX 文件解析成功！'), backgroundColor: AppConfig.cyclePrimary),
    );
  }

  void _handleGpxUrl() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.dialogRadius)),
        title: const Text('输入 GPX 链接'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'https://...')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(onPressed: () { Navigator.pop(ctx); _handleGpxFile(); }, child: const Text('确认')),
        ],
      ),
    );
  }

  void _handleGpxScan() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('扫码功能开发中，已模拟成功'), backgroundColor: AppConfig.motoPrimary),
    );
    _handleGpxFile();
  }

  // ==================== 4.4 路线信息编辑 ====================
  Widget _buildRouteInfoPage() {
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(title: const Text('路线信息')),
      body: ListView(
        padding: const EdgeInsets.all(AppConfig.pageMargin),
        children: [
          // 路线预览
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: _scenario.primaryColor.withOpacity(0.04),
              borderRadius: BorderRadius.circular(AppConfig.cardRadius),
              border: Border.all(color: _scenario.primaryColor.withOpacity(0.12)),
            ),
            child: _waypoints.isNotEmpty
                ? CustomPaint(painter: _RoutePreviewPainter(_waypoints, _scenario.primaryColor))
                : Center(child: Text('${_totalDistance.toStringAsFixed(1)}km · ↑${_totalClimb}m', style: const TextStyle(fontSize: 13, color: AppConfig.textSecondary))),
          ),
          const SizedBox(height: AppConfig.cardGap),
          // 名称
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: '路线名称'),
            onChanged: (v) => _routeName = v.isEmpty ? '未命名路线' : v,
          ),
          const SizedBox(height: AppConfig.cardGap),
          // 场景 & 难度
          Row(
            children: [
              Expanded(child: _sceneSelector()),
              const SizedBox(width: 12),
              Expanded(child: _difficultySelector()),
            ],
          ),
          const SizedBox(height: AppConfig.cardGap),
          // 补给点汇总
          _buildSupplySummary(),
          const SizedBox(height: AppConfig.cardGap),
          // 注意事项
          TextField(
            controller: _noteCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: '注意事项',
              hintText: '自由填写路线提示、安全提醒...',
            ),
          ),
          const SizedBox(height: AppConfig.cardGap),
          // 关联装备
          _buildChecklistLink(),
          const SizedBox(height: AppConfig.sectionGap),
          // 公开/私密
          SwitchListTile(
            title: const Text('公开路线', style: TextStyle(fontSize: 14, color: AppConfig.textPrimary)),
            subtitle: const Text('公开后可被社区发现', style: TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
            value: _isPublic,
            onChanged: (v) => setState(() => _isPublic = v),
            activeColor: AppConfig.cyclePrimary,
          ),
          const SizedBox(height: AppConfig.sectionGap),
          // 完成按钮
          SizedBox(
            width: double.infinity, height: AppConfig.primaryBtnH,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: goldGradient,
                borderRadius: BorderRadius.all(Radius.circular(AppConfig.buttonRadius)),
              ),
              child: ElevatedButton(
                onPressed: () => setState(() => _step = _FlowStep.confirm),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.buttonRadius)),
                ),
                child: const Text('完成，查看出发确认 →', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppConfig.textInverse)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sceneSelector() {
    return GestureDetector(
      onTap: () => _showPicker('出行场景', OutdoorScenario.values.map((s) => (s.emoji + ' ' + s.label, s)).toList(), _scenario, (v) => setState(() => _scenario = v)),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), border: Border.all(color: AppConfig.divider)),
        child: Row(
          children: [
            Text(_scenario.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(_scenario.label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _scenario.primaryColor)),
            const Spacer(),
            const Icon(Icons.arrow_drop_down, size: 20, color: AppConfig.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _difficultySelector() {
    return GestureDetector(
      onTap: () => _showPicker('难度', RouteDifficulty.values.map((d) => (d.label, d)).toList(), _difficulty, (v) => setState(() => _difficulty = v)),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), border: Border.all(color: AppConfig.divider)),
        child: Row(
          children: [
            Text(_difficulty.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
            const Spacer(),
            const Icon(Icons.arrow_drop_down, size: 20, color: AppConfig.textSecondary),
          ],
        ),
      ),
    );
  }

  void _showPicker<T>(String title, List<(String, T)> items, T current, void Function(T) onPick) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.vertical(top: Radius.circular(AppConfig.dialogRadius))),
        child: SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppConfig.textSecondary)),
            const SizedBox(height: 8),
            ...items.map((item) {
              final sel = item.$2 == current;
              return ListTile(
                dense: true,
                title: Text(item.$1, style: TextStyle(fontWeight: sel ? FontWeight.w600 : FontWeight.w400, color: AppConfig.textPrimary)),
                trailing: sel ? const Icon(Icons.check, size: 18, color: AppConfig.cyclePrimary) : null,
                onTap: () { onPick(item.$2); Navigator.pop(context); },
              );
            }),
          ]),
        ),
      ),
    );
  }

  Widget _buildSupplySummary() {
    final supplies = _waypoints.where((wp) => wp.supplyType != null).toList();
    if (supplies.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), boxShadow: AppConfig.cardShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('补给点', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppConfig.textSecondary)),
        const SizedBox(height: 6),
        ...supplies.map((wp) => Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: AppConfig.bgMain, borderRadius: BorderRadius.circular(6)),
          child: Row(children: [
            Icon(Icons.location_on, size: 14, color: _scenario.primaryColor),
            const SizedBox(width: 6),
            Text(wp.note ?? '补给点', style: const TextStyle(fontSize: 13, color: AppConfig.textPrimary)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: _scenario.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: Text(wp.supplyType!, style: TextStyle(fontSize: 10, color: _scenario.primaryColor)),
            ),
          ]),
        )),
      ]),
    );
  }

  Widget _buildChecklistLink() {
    return GestureDetector(
      onTap: () => _pickChecklist(),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), border: Border.all(color: AppConfig.divider)),
        child: Row(children: [
          const Icon(Icons.checklist_outlined, size: 20, color: AppConfig.textSecondary),
          const SizedBox(width: 10),
          Expanded(child: Text(
            _linkedChecklist ?? '关联装备清单（可选）',
            style: TextStyle(fontSize: 14, color: _linkedChecklist != null ? AppConfig.cyclePrimary : AppConfig.textSecondary),
          )),
          const Icon(Icons.chevron_right, size: 18, color: AppConfig.textSecondary),
        ]),
      ),
    );
  }

  void _pickChecklist() {
    // Mock checklist picker
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.vertical(top: Radius.circular(AppConfig.dialogRadius))),
        child: SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(height: 12),
            const Text('选择装备清单', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...ScenarioConfig.all.map((cfg) => ListTile(
              leading: Text(cfg.scenario.emoji, style: const TextStyle(fontSize: 20)),
              title: Text(cfg.label + '装备'),
              subtitle: Text('${cfg.flatEquipmentItems.length} 项'),
              onTap: () { setState(() => _linkedChecklist = cfg.label + '装备'); Navigator.pop(context); },
            )),
            ListTile(
              title: const Text('不关联', style: TextStyle(color: AppConfig.textSecondary)),
              onTap: () { setState(() => _linkedChecklist = null); Navigator.pop(context); },
            ),
          ]),
        ),
      ),
    );
  }

  // ==================== V6.5 出发确认页 (2.3) ====================
  Widget _buildConfirmPage() {
    final cfg = ScenarioConfig.of(_scenario);
    final eqItems = cfg.flatEquipmentItems.take(5).toList();
    final checkedCount = (widget.fromRoute != null) ? 3 : 4;

    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(title: const Text('出发确认')),
      body: ListView(
        padding: const EdgeInsets.all(AppConfig.pageMargin),
        children: [
          // ── 路线摘要 ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), boxShadow: AppConfig.cardShadow),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_routeName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
              if (_difficulty != RouteDifficulty.easy) ...[const SizedBox(height: 4), Text(_difficulty.label + '路线', style: TextStyle(fontSize: 13, color: _scenario.primaryColor))],
              const SizedBox(height: 12),
              // V6.5: 地图缩略图 180px
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: _scenario.primaryColor.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _scenario.primaryColor.withOpacity(0.1)),
                ),
                child: _waypoints.isNotEmpty
                    ? CustomPaint(painter: _RoutePreviewPainter(_waypoints, _scenario.primaryColor))
                    : Center(
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.route, size: 32, color: _scenario.primaryColor.withOpacity(0.3)),
                          const SizedBox(height: 6),
                          Text('${_totalDistance.toStringAsFixed(1)}km · ↑${_totalClimb}m', style: const TextStyle(fontSize: 13, color: AppConfig.textSecondary)),
                        ]),
                      ),
              ),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _confirmData('总距离', '${_totalDistance.toStringAsFixed(1)} km'),
                _confirmData('爬 升', '${_totalClimb} m'),
                _confirmData('预计用时', '${(_estMinutes ~/ 60)}h${_estMinutes % 60}min'),
              ]),
              const Divider(height: 24, color: AppConfig.divider),
              // 场景标签 + 难度
              Wrap(spacing: 8, children: [
                _infoTag('${_scenario.emoji} ${_scenario.label}', _scenario.primaryColor),
                _infoTag(_difficulty.label, AppConfig.textPrimary),
              ]),
            ]),
          ),

          const SizedBox(height: AppConfig.cardGap),

          // ── 实时天气 + 未来3小时 ──
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), boxShadow: AppConfig.cardShadow),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.wb_sunny_outlined, size: 18, color: AppConfig.goldEnd),
                const SizedBox(width: 6),
                const Text('实时天气', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
                const Spacer(),
                GestureDetector(
                  onTap: () {},
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('未来3小时预报', style: TextStyle(fontSize: 12, color: AppConfig.cyclePrimary)),
                    SizedBox(width: 2),
                    Icon(Icons.chevron_right, size: 14, color: AppConfig.cyclePrimary),
                  ]),
                ),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                _weatherBlock('现在', '☀️', '28°', '晴'),
                Container(width: 1, height: 40, color: AppConfig.divider),
                _weatherBlock('+1h', '⛅', '27°', '多云'),
                Container(width: 1, height: 40, color: AppConfig.divider),
                _weatherBlock('+2h', '⛅', '26°', '多云'),
                Container(width: 1, height: 40, color: AppConfig.divider),
                _weatherBlock('+3h', '☁️', '25°', '阴'),
              ]),
            ]),
          ),

          const SizedBox(height: AppConfig.cardGap),

          // ── V6.5: 装备检查摘要 ──
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), boxShadow: AppConfig.cardShadow),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.checklist_outlined, size: 18, color: AppConfig.cyclePrimary),
                const SizedBox(width: 6),
                const Text('装备检查', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
                const Spacer(),
                // V6.5: 核心装备 X/Y 已检查
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppConfig.cyclePrimary.withOpacity(0.08), borderRadius: BorderRadius.circular(4)),
                  child: Text('$checkedCount/${eqItems.length} 已检查', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppConfig.cyclePrimary)),
                ),
              ]),
              const SizedBox(height: 8),
              if (_linkedChecklist != null)
                Text(_linkedChecklist!, style: const TextStyle(fontSize: 13, color: AppConfig.textSecondary)),
              if (_linkedChecklist == null)
                const Text('未关联装备清单', style: TextStyle(fontSize: 13, color: AppConfig.textSecondary)),
              const SizedBox(height: 8),
              // V6.5: 具体装备项 (最多5项)
              ...List.generate(eqItems.length, (i) {
                final checked = i < checkedCount;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(children: [
                    Icon(checked ? Icons.check_circle : Icons.radio_button_unchecked, size: 14, color: checked ? AppConfig.cyclePrimary : AppConfig.textSecondary.withOpacity(0.4)),
                    const SizedBox(width: 8),
                    Text(eqItems[i], style: TextStyle(fontSize: 13, color: checked ? AppConfig.textPrimary : AppConfig.textSecondary, decoration: checked ? null : TextDecoration.lineThrough)),
                  ]),
                );
              }),
              // V6.5: 提醒文字
              if (checkedCount < eqItems.length) ...[const SizedBox(height: 4), Text('还有${eqItems.length - checkedCount}项装备未检查，建议确认后出发', style: const TextStyle(fontSize: 11, color: AppConfig.motoPrimary))],
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
                  child: Text(_linkedChecklist != null ? '去检查装备' : '去设置装备清单', style: const TextStyle(fontSize: 13)),
                ),
              ),
            ]),
          ),

          const SizedBox(height: AppConfig.cardGap),

          // ── V6.5: 离线地图 (条件样式) ──
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), boxShadow: AppConfig.cardShadow),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.cloud_download_outlined, size: 18, color: AppConfig.drivePrimary),
                const SizedBox(width: 6),
                const Text('离线地图', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() => _offlineReady = !_offlineReady),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(_offlineReady ? '已下载 ✅' : '未下载 ⚠️', style: TextStyle(fontSize: 12, color: _offlineReady ? AppConfig.cyclePrimary : AppConfig.motoPrimary)),
                    const SizedBox(width: 2),
                    Icon(Icons.swap_horiz, size: 12, color: AppConfig.textSecondary.withOpacity(0.3)),
                  ]),
                ),
              ]),
              const SizedBox(height: 6),
              if (_offlineReady)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppConfig.cyclePrimary.withOpacity(0.08), borderRadius: BorderRadius.circular(4)),
                  child: const Text('✅ 离线地图已就绪，无网络也能正常导航', style: TextStyle(fontSize: 11, color: AppConfig.cyclePrimary)),
                )
              else ...[Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppConfig.motoPrimary.withOpacity(0.08), borderRadius: BorderRadius.circular(4)),
                child: const Text('⚠️ 路线区域未下载，建议下载离线地图', style: TextStyle(fontSize: 11, color: AppConfig.motoPrimary)),
              ), const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => setState(() => _offlineReady = true),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
                  child: const Text('去下载', style: TextStyle(fontSize: 13)),
                ),
              )],
            ]),
          ),

          const SizedBox(height: AppConfig.cardGap),

          // ── V6.5: 组队选项 ──
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), boxShadow: AppConfig.cardShadow),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.group_add_outlined, size: 18, color: AppConfig.motoPrimary),
                const SizedBox(width: 6),
                const Text('出行方式', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
                const Spacer(),
                Text('可跳过', style: TextStyle(fontSize: 11, color: AppConfig.textSecondary.withOpacity(0.5))),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isSolo = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _isSolo ? AppConfig.cyclePrimary.withOpacity(0.06) : AppConfig.cardBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _isSolo ? AppConfig.cyclePrimary : AppConfig.divider, width: _isSolo ? 1.5 : 0.8),
                      ),
                      child: Column(children: [
                        Icon(Icons.person, size: 22, color: _isSolo ? AppConfig.cyclePrimary : AppConfig.textSecondary),
                        const SizedBox(height: 4),
                        Text('独自出行', style: TextStyle(fontSize: 13, fontWeight: _isSolo ? FontWeight.w600 : FontWeight.w400, color: _isSolo ? AppConfig.cyclePrimary : AppConfig.textSecondary)),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isSolo = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: !_isSolo ? AppConfig.motoPrimary.withOpacity(0.06) : AppConfig.cardBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: !_isSolo ? AppConfig.motoPrimary : AppConfig.divider, width: !_isSolo ? 1.5 : 0.8),
                      ),
                      child: Column(children: [
                        Icon(Icons.group, size: 22, color: !_isSolo ? AppConfig.motoPrimary : AppConfig.textSecondary),
                        const SizedBox(height: 4),
                        Text('组队出行', style: TextStyle(fontSize: 13, fontWeight: !_isSolo ? FontWeight.w600 : FontWeight.w400, color: !_isSolo ? AppConfig.motoPrimary : AppConfig.textSecondary)),
                      ]),
                    ),
                  ),
                ),
              ]),
            ]),
          ),

          const SizedBox(height: AppConfig.sectionGap),

          // ── V6.5: ▶️ 开始导航 (金色渐变按钮) ──
          GestureDetector(
            onTap: _onStartNavigation,
            child: Container(
              width: double.infinity, height: AppConfig.primaryBtnH,
              decoration: BoxDecoration(
                gradient: goldGradient,
                borderRadius: BorderRadius.circular(AppConfig.buttonRadius),
                boxShadow: [BoxShadow(color: AppConfig.goldStart.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.play_arrow, size: 28, color: AppConfig.textInverse),
                SizedBox(width: 6),
                Text('▶️ 开始导航', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppConfig.textInverse)),
              ]),
            ),
          ),

          const SizedBox(height: AppConfig.cardGap),

          SizedBox(
            width: double.infinity, height: AppConfig.secondaryBtnH,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.share_outlined, size: 16),
              label: const Text('分享路线给好友'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppConfig.textSecondary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.buttonRadius)),
                side: const BorderSide(color: AppConfig.divider),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _confirmData(String label, String value) {
    return Column(children: [
      Text(label, style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
      const SizedBox(height: 3),
      Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
    ]);
  }

  Widget _infoTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
    );
  }

  Widget _weatherBlock(String time, String icon, String temp, String desc) {
    return Expanded(
      child: Column(children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(temp, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
        Text(desc, style: const TextStyle(fontSize: 10, color: AppConfig.textSecondary)),
        Text(time, style: const TextStyle(fontSize: 10, color: AppConfig.textSecondary)),
      ]),
    );
  }

  void _onStartNavigation() {
    // V6.5: 软校验 — modal bottom sheet (非阻断)
    final eqItems = ScenarioConfig.of(_scenario).flatEquipmentItems.take(5).toList();
    final checkedCount = (widget.fromRoute != null) ? 3 : 4;
    final hasWarnings = (checkedCount < eqItems.length) || !_offlineReady;

    if (hasWarnings) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => Container(
          decoration: const BoxDecoration(
            color: AppConfig.cardBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppConfig.dialogRadius)),
          ),
          padding: const EdgeInsets.all(20),
          child: SafeArea(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 32, height: 4, decoration: BoxDecoration(color: AppConfig.divider, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              const Icon(Icons.info_outline, size: 36, color: AppConfig.goldStart),
              const SizedBox(height: 12),
              const Text('出发前建议检查', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
              const SizedBox(height: 8),
              if (checkedCount < eqItems.length)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('⚠ 还有${eqItems.length - checkedCount}项装备未检查', style: const TextStyle(fontSize: 13, color: AppConfig.motoPrimary)),
                ),
              if (!_offlineReady)
                const Text('⚠ 离线地图未下载', style: TextStyle(fontSize: 13, color: AppConfig.motoPrimary)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () { Navigator.pop(context); _startNavigation(); },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    backgroundColor: AppConfig.goldStart,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.buttonRadius)),
                  ),
                  child: const Text('确认出发', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    side: const BorderSide(color: AppConfig.divider),
                    foregroundColor: AppConfig.textSecondary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.buttonRadius)),
                  ),
                  child: const Text('去检查/下载', style: TextStyle(fontSize: 14)),
                ),
              ),
            ]),
          ),
        ),
      );
      return;
    }
    _startNavigation();
  }

  void _startNavigation() {
    final prov = context.read<TripProvider>();
    prov.createTrip(_routeName, _scenario);
    setState(() => _step = _FlowStep.navigating);
  }
}

// ===== 途经点 =====
class _Waypoint {
  double x, y;
  String? note;
  String? supplyType;
  bool isSupplyPoint = false;

  _Waypoint({required this.x, required this.y, this.note, this.supplyType});
}

// ===== 路线预览绘制 =====
class _RoutePreviewPainter extends CustomPainter {
  final List<_Waypoint> points;
  final Color color;
  _RoutePreviewPainter(this.points, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    // 路线线
    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(points.first.x * size.width, points.first.y * size.height);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].x * size.width, points[i].y * size.height);
    }
    canvas.drawPath(path, paint);

    // 点
    for (int i = 0; i < points.length; i++) {
      final wp = points[i];
      final dotPaint = Paint()..color = i == 0 ? Colors.green : i == points.length - 1 ? AppConfig.sosRed : color..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(wp.x * size.width, wp.y * size.height),
        i == 0 || i == points.length - 1 ? 5 : 3.5,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RoutePreviewPainter oldDelegate) => oldDelegate.points != points;
}

// ===== V6.1 智能推荐类型 =====
enum _SmartTarget {
  shortest, scenic, challenge, eco;
  String get label => switch (this) {
    _SmartTarget.shortest => '最短路径',
    _SmartTarget.scenic => '最美风景',
    _SmartTarget.challenge => '挑战爬坡',
    _SmartTarget.eco => '省力优先',
  };
  String get emoji => switch (this) {
    _SmartTarget.shortest => '⚡',
    _SmartTarget.scenic => '🏞️',
    _SmartTarget.challenge => '🏔️',
    _SmartTarget.eco => '🍃',
  };
}

enum _SmartScenery {
  lake, mountain, teaField, temple, ancientTown, coastline, forest, city;
  String get label => switch (this) {
    _SmartScenery.lake => '湖景',
    _SmartScenery.mountain => '山景',
    _SmartScenery.teaField => '茶园',
    _SmartScenery.temple => '寺庙',
    _SmartScenery.ancientTown => '古镇',
    _SmartScenery.coastline => '海岸线',
    _SmartScenery.forest => '森林',
    _SmartScenery.city => '城市',
  };
  String get emoji => switch (this) {
    _SmartScenery.lake => '🌊',
    _SmartScenery.mountain => '⛰️',
    _SmartScenery.teaField => '🍵',
    _SmartScenery.temple => '🛕',
    _SmartScenery.ancientTown => '🏘️',
    _SmartScenery.coastline => '🏖️',
    _SmartScenery.forest => '🌲',
    _SmartScenery.city => '🏙️',
  };
  Color get color => switch (this) {
    _SmartScenery.lake => const Color(0xFF3B82F6),
    _SmartScenery.mountain => const Color(0xFF6B7280),
    _SmartScenery.teaField => const Color(0xFF059669),
    _SmartScenery.temple => const Color(0xFFD97706),
    _SmartScenery.ancientTown => const Color(0xFF92400E),
    _SmartScenery.coastline => const Color(0xFF0EA5E9),
    _SmartScenery.forest => const Color(0xFF166534),
    _SmartScenery.city => const Color(0xFF6366F1),
  };
}

enum _SmartSurface {
  paved, mixed, trail;
  String get label => switch (this) {
    _SmartSurface.paved => '铺装路面',
    _SmartSurface.mixed => '混合路面',
    _SmartSurface.trail => '野道',
  };
  IconData get icon => switch (this) {
    _SmartSurface.paved => Icons.route,
    _SmartSurface.mixed => Icons.terrain,
    _SmartSurface.trail => Icons.landscape,
  };
}

class _SmartResult {
  final String name;
  final String desc;
  final double distanceKm;
  final int climb;
  final int durationMin;
  final List<String> pois;
  const _SmartResult({required this.name, required this.desc, required this.distanceKm, required this.climb, required this.durationMin, required this.pois});
}
