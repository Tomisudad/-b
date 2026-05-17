import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../config/scenario_config.dart';
import '../models/route_model.dart';
import '../providers/trip_provider.dart';
import 'navigation_page.dart';
import 'departure/gpx_import_step.dart';
import 'departure/map_pin_step.dart';
import 'departure/smart_recommend_step.dart';

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
    _estMinutes = (dist / 20 * 60).round() + climb * 2 ~/ 100;
  }

  @override
  Widget build(BuildContext context) {
    switch (_step) {
      case _FlowStep.method: return _buildMethodPage();
      case _FlowStep.smartRecommend: return SmartRecommendStep(
        onBack: () => setState(() => _step = _FlowStep.method),
        onUseRoute: (name, dist, climb, dur) {
          setState(() {
            _routeName = name;
            _totalDistance = dist;
            _totalClimb = climb;
            _estMinutes = dur;
            _step = _FlowStep.confirm;
          });
        },
      );
      case _FlowStep.mapPin: return MapPinStep(
        scenario: _scenario,
        onBack: () => setState(() => _step = _FlowStep.method),
        onNext: (waypoints, dist, climb, dur) {
          // 转换 WaypointData → _Waypoint
          _waypoints.clear();
          for (final wp in waypoints) {
            _waypoints.add(_Waypoint(x: wp.x, y: wp.y, note: wp.note, supplyType: wp.supplyType));
          }
          setState(() {
            _totalDistance = dist;
            _totalClimb = climb;
            _estMinutes = dur;
            _step = _FlowStep.routeInfo;
          });
        },
      );
      case _FlowStep.gpxImport: return GpxImportStep(onBack: () => setState(() => _step = _FlowStep.method), onImportSuccess: _handleGpxFile);
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
              AppConfig.accentOrange, () => setState(() => _step = _FlowStep.gpxImport),
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


  // ==================== 4.3 导入 GPX ====================


  void _handleGpxFile() {
    // Mock: 模拟成功导入（SnackBar 由 GpxImportStep 内部处理）
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
              if (checkedCount < eqItems.length) ...[const SizedBox(height: 4), Text('还有${eqItems.length - checkedCount}项装备未检查，建议确认后出发', style: const TextStyle(fontSize: 11, color: AppConfig.accentOrange))],
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
                const Icon(Icons.cloud_download_outlined, size: 18, color: AppConfig.accentBlue),
                const SizedBox(width: 6),
                const Text('离线地图', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() => _offlineReady = !_offlineReady),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(_offlineReady ? '已下载 ✅' : '未下载 ⚠️', style: TextStyle(fontSize: 12, color: _offlineReady ? AppConfig.cyclePrimary : AppConfig.accentOrange)),
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
                decoration: BoxDecoration(color: AppConfig.accentOrange.withOpacity(0.08), borderRadius: BorderRadius.circular(4)),
                child: const Text('⚠️ 路线区域未下载，建议下载离线地图', style: TextStyle(fontSize: 11, color: AppConfig.accentOrange)),
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
                const Icon(Icons.group_add_outlined, size: 18, color: AppConfig.accentOrange),
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
                        color: !_isSolo ? AppConfig.accentOrange.withOpacity(0.06) : AppConfig.cardBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: !_isSolo ? AppConfig.accentOrange : AppConfig.divider, width: !_isSolo ? 1.5 : 0.8),
                      ),
                      child: Column(children: [
                        Icon(Icons.group, size: 22, color: !_isSolo ? AppConfig.accentOrange : AppConfig.textSecondary),
                        const SizedBox(height: 4),
                        Text('组队出行', style: TextStyle(fontSize: 13, fontWeight: !_isSolo ? FontWeight.w600 : FontWeight.w400, color: !_isSolo ? AppConfig.accentOrange : AppConfig.textSecondary)),
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
                  child: Text('⚠ 还有${eqItems.length - checkedCount}项装备未检查', style: const TextStyle(fontSize: 13, color: AppConfig.accentOrange)),
                ),
              if (!_offlineReady)
                const Text('⚠ 离线地图未下载', style: TextStyle(fontSize: 13, color: AppConfig.accentOrange)),
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
