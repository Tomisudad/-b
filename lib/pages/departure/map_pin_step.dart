import 'dart:math';
import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../config/scenario_config.dart';

// ===== 途经点 =====
class WaypointData {
  double x, y;
  String? note;
  String? supplyType;
  bool isSupplyPoint = false;

  WaypointData({required this.x, required this.y, this.note, this.supplyType});
}

// ===== 路线预览绘制 =====
class _RoutePreviewPainter extends CustomPainter {
  final List<WaypointData> points;
  final Color color;
  _RoutePreviewPainter(this.points, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

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

    for (int i = 0; i < points.length; i++) {
      final wp = points[i];
      final dotPaint = Paint()
        ..color = i == 0 ? Colors.green : i == points.length - 1 ? AppConfig.sosRed : color
        ..style = PaintingStyle.fill;
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

/// 地图打点规划步骤 — 独立 StatefulWidget
class MapPinStep extends StatefulWidget {
  final OutdoorScenario scenario;
  final VoidCallback onBack;
  final void Function(List<WaypointData> waypoints, double dist, int climb, int dur) onNext;

  const MapPinStep({super.key, required this.scenario, required this.onBack, required this.onNext});

  @override
  State<MapPinStep> createState() => _MapPinStepState();
}

class _MapPinStepState extends State<MapPinStep> {
  final List<WaypointData> _waypoints = [];
  double _totalDistance = 0;
  int _totalClimb = 0;
  int _estMinutes = 0;

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

  void _addRandomPoint() {
    final rng = Random();
    setState(() {
      _waypoints.add(WaypointData(
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
        WaypointData(x: 0.12, y: 0.55, note: '起点'),
        WaypointData(x: 0.28, y: 0.40, note: '第一段上升'),
        WaypointData(x: 0.45, y: 0.22, note: '垭口', supplyType: '补水点'),
        WaypointData(x: 0.58, y: 0.35, note: '观景台'),
        WaypointData(x: 0.72, y: 0.60, note: '补给站', supplyType: '加油站'),
        WaypointData(x: 0.88, y: 0.50, note: '终点'),
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
    final cfg = ScenarioConfig.of(widget.scenario);
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
              leading: Icon(Icons.location_on, color: widget.scenario.primaryColor),
              title: Text(cat),
              onTap: () { setState(() => wp.supplyType = cat); Navigator.pop(context); },
            )),
          ]),
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

  @override
  Widget build(BuildContext context) {
    _recalcRoute();
    final sc = widget.scenario;
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onBack),
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
                  child: CustomPaint(painter: _RoutePreviewPainter(_waypoints, sc.primaryColor)),
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
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.touch_app, size: 16, color: AppConfig.cyclePrimary),
                SizedBox(width: 6),
                Text('长按地图添加途经点 · 拖拽点调整顺序', style: TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
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
                  _dataCol('爬升', '${_totalClimb} m', AppConfig.accentOrange),
                  _dataCol('坡度', '${_totalDistance > 0 ? (_totalClimb / (_totalDistance * 10)).toStringAsFixed(1) : "0"}%', AppConfig.accentBlue),
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
                        onPressed: _addRandomPoint,
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
                        onPressed: () => widget.onNext(_waypoints, _totalDistance, _totalClimb, _estMinutes),
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
                    onPressed: _addQuickRoute,
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
}