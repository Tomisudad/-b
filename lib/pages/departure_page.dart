import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../config/scenario_config.dart';
import '../providers/trip_provider.dart';
import 'navigation_page.dart';

/// V5.5 新建路线并出发 — 完整流程
/// Step: method → mapPin/gpxImport → routeInfo → confirm → navigate
enum _FlowStep { method, mapPin, gpxImport, routeInfo, confirm, navigating }

class DeparturePage extends StatefulWidget {
  const DeparturePage({super.key});

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

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = _routeName;
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
      case _FlowStep.mapPin: return _buildMapPinPage();
      case _FlowStep.gpxImport: return _buildGpxImportPage();
      case _FlowStep.routeInfo: return _buildRouteInfoPage();
      case _FlowStep.confirm: return _buildConfirmPage();
      case _FlowStep.navigating:
        return NavigationPage(scenario: _scenario, routeName: _routeName);
    }
  }

  // ==================== 4.1 创建方式选择 ====================
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

  // ==================== 4.5 出发确认页 ====================
  Widget _buildConfirmPage() {
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(title: const Text('出发确认')),
      body: ListView(
        padding: const EdgeInsets.all(AppConfig.pageMargin),
        children: [
          // 路线摘要
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), boxShadow: AppConfig.cardShadow),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_routeName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
              const SizedBox(height: 12),
              // 地图缩略
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: _scenario.primaryColor.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _scenario.primaryColor.withOpacity(0.1)),
                ),
                child: _waypoints.isNotEmpty
                    ? CustomPaint(painter: _RoutePreviewPainter(_waypoints, _scenario.primaryColor))
                    : const Center(child: Text('静态路线预览', style: TextStyle(fontSize: 13, color: AppConfig.textSecondary))),
              ),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _confirmData('总距离', '${_totalDistance.toStringAsFixed(1)} km'),
                _confirmData('爬 升', '${_totalClimb} m'),
                _confirmData('预计用时', '${(_estMinutes ~/ 60)}h${_estMinutes % 60}min'),
              ]),
            ]),
          ),

          const SizedBox(height: AppConfig.cardGap),

          // 实时天气
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), boxShadow: AppConfig.cardShadow),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Icon(Icons.wb_sunny_outlined, size: 18, color: AppConfig.goldEnd),
                SizedBox(width: 6),
                Text('实时天气', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
                Spacer(),
                Text('查看详情 >', style: TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
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

          // 装备摘要
          if (_linkedChecklist != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), boxShadow: AppConfig.cardShadow),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Row(children: [
                  Icon(Icons.checklist_outlined, size: 18, color: AppConfig.cyclePrimary),
                  SizedBox(width: 6),
                  Text('装备检查', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
                ]),
                const SizedBox(height: 8),
                Text(_linkedChecklist!, style: const TextStyle(fontSize: 13, color: AppConfig.textSecondary)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppConfig.motoPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: const Text('⚠ 2 项未检查', style: TextStyle(fontSize: 11, color: AppConfig.motoPrimary)),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
                    child: const Text('去检查装备', style: TextStyle(fontSize: 13)),
                  ),
                ),
              ]),
            ),

          const SizedBox(height: AppConfig.cardGap),

          // 离线地图
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), boxShadow: AppConfig.cardShadow),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Icon(Icons.cloud_download_outlined, size: 18, color: AppConfig.drivePrimary),
                SizedBox(width: 6),
                Text('离线地图', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
              ]),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppConfig.sosRed.withOpacity(0.08), borderRadius: BorderRadius.circular(4)),
                child: const Text('⚠ 浙江省离线地图未下载，建议提前下载', style: TextStyle(fontSize: 11, color: AppConfig.sosRed)),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
                  child: const Text('下载离线地图', style: TextStyle(fontSize: 13)),
                ),
              ),
            ]),
          ),

          const SizedBox(height: AppConfig.cardGap),

          // 组队（可选）
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), boxShadow: AppConfig.cardShadow),
              child: const Row(children: [
                Icon(Icons.group_add_outlined, size: 18, color: AppConfig.motoPrimary),
                SizedBox(width: 6),
                Expanded(child: Text('组队选项（可跳过）', style: TextStyle(fontSize: 14, color: AppConfig.textPrimary))),
                Text('选人组队', style: TextStyle(fontSize: 13, color: AppConfig.cyclePrimary)),
                SizedBox(width: 4),
                Icon(Icons.chevron_right, size: 16, color: AppConfig.textSecondary),
              ]),
            ),
          ),

          const SizedBox(height: AppConfig.sectionGap),

          // ▶️ 开始导航
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
    // 软提示
    if (_linkedChecklist != null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.dialogRadius)),
          title: const Text('出发提醒', style: TextStyle(fontWeight: FontWeight.w700)),
          content: const Text('装备有未完成项，离线地图未下载。\n建议检查/下载后出发，确认出发？'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
            TextButton(
              onPressed: () { Navigator.pop(ctx); _startNavigation(); },
              child: const Text('确认出发', style: TextStyle(color: AppConfig.goldStart, fontWeight: FontWeight.w600)),
            ),
          ],
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
  bool isSupplyPoint;

  _Waypoint({required this.x, required this.y, this.note, this.supplyType, this.isSupplyPoint = false});
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
