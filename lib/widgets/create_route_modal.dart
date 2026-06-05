import 'package:flutter/material.dart';
import 'package:gowild_app/providers/app_state.dart';
import 'package:provider/provider.dart';
import '../screens/depart_modal.dart';
import '../models/route_model.dart';

/// 新建路线底部面板
/// 状态1：选择创建方式
/// 状态2：地图打点规划（途经点编辑）
class CreateRouteModal extends StatefulWidget {
  const CreateRouteModal({super.key});

  @override
  State<CreateRouteModal> createState() => _CreateRouteModalState();
}

class _CreateRouteModalState extends State<CreateRouteModal> {
  bool _showPlanning = false;
  List<String> _waypoints = ['起点'];

  void _startMapPlanning() {
    setState(() {
      _showPlanning = true;
      _waypoints = ['起点'];
    });
  }

  void _addWaypoint() {
    setState(() {
      _waypoints.add('途经点${_waypoints.length}');
    });
  }

  void _updateWaypointName(int index, String name) {
    setState(() {
      _waypoints[index] = name;
    });
  }

  void _savePlannedRoute() {
    final appState = Provider.of<AppState>(context, listen: false);
    final name = _waypoints[0] == '起点' ? '新路线' : _waypoints[0];
    final dist = (_waypoints.length * 12 + (DateTime.now().millisecond % 20)).toString();
    final elev = (_waypoints.length * 150 + (DateTime.now().millisecond % 300)).toString();
    final time = (_waypoints.length * 0.8).toStringAsFixed(1);

    appState.addRoute(RouteModel(
      name: name,
      distance: '${dist}km',
      time: '${time}h',
      elevation: '${elev}m',
      difficulty: '休闲',
      waypoints: _waypoints.map((w) => Waypoint(name: w)).toList(),
    ));
    appState.setSelectedRoute(name);

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('路线 $name 已保存'), backgroundColor: const Color(0xFF5A6F45), duration: const Duration(seconds: 2)),
    );
  }

  void _simulateImportGPX() {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.addRoute(RouteModel(
      name: '导入的路线',
      distance: '45km',
      time: '2.5h',
      elevation: '600m',
      difficulty: '中级',
      waypoints: [Waypoint(name: '起点'), Waypoint(name: '途经点1'), Waypoint(name: '终点')],
    ));
    appState.setSelectedRoute('导入的路线');
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('路线已导入'), backgroundColor: Color(0xFF5A6F45), duration: Duration(seconds: 2)),
    );
  }

  void _simulateFromHistory() {
    final appState = Provider.of<AppState>(context, listen: false);
    if (appState.records.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('暂无历史记录'), backgroundColor: Colors.grey, duration: Duration(seconds: 2)),
      );
      return;
    }
    final rec = appState.records.first;
    final routeName = '${rec.name}(副本)';
    appState.addRoute(RouteModel(
      name: routeName,
      distance: rec.distance,
      time: rec.time,
      elevation: rec.climb,
      difficulty: '休闲',
      waypoints: [Waypoint(name: '起点'), Waypoint(name: '途经点1'), Waypoint(name: '终点')],
    ));
    appState.setSelectedRoute(routeName);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已从历史记录创建：$routeName'), backgroundColor: const Color(0xFF5A6F45), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showPlanning) return _buildPlanning(context);
    return _buildSelection(context);
  }

  Widget _buildSelection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _dragHandle(),
          const SizedBox(height: 16),
          const Text('新建路线', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _optionTile(context, Icons.map, '地图打点规划', _startMapPlanning),
          const SizedBox(height: 10),
          _optionTile(context, Icons.description, '导入GPX轨迹', _simulateImportGPX),
          const SizedBox(height: 10),
          _optionTile(context, Icons.history, '从历史记录创建', _simulateFromHistory),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(color: const Color(0xFFF8F7F4), borderRadius: BorderRadius.circular(16)),
              child: const Text('取消', textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanning(BuildContext context) {
    final totalDist = (_waypoints.length * 12 + (DateTime.now().millisecond % 20)).toString();
    final totalElev = (_waypoints.length * 150 + (DateTime.now().millisecond % 300)).toString();
    final totalTime = (_waypoints.length * 0.8).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _dragHandle(),
          const SizedBox(height: 12),
          const Text('地图打点规划', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('点击地图添加途经点（模拟）', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 12),

          // Map placeholder
          GestureDetector(
            onTap: _addWaypoint,
            child: Container(
              height: 144,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F7F4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🗺️', style: TextStyle(fontSize: 48)),
                    SizedBox(height: 4),
                    Text('点击模拟添加途经点', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Waypoint count header
          Text('途经点 (${_waypoints.length}个)', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),

          // Waypoint list (scrollable, max 3 items)
          ...List.generate(_waypoints.length > 3 ? 3 : _waypoints.length, (i) {
            final wp = _waypoints[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: const Color(0xFFF8F7F4), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Container(
                    width: 24, height: 24,
                    decoration: const BoxDecoration(color: Color(0xFF5A6F45), shape: BoxShape.circle),
                    child: Center(child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                      controller: TextEditingController(text: wp),
                      onChanged: (v) => _updateWaypointName(i, v),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            );
          }),
          if (_waypoints.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('...还有 ${_waypoints.length - 3} 个途经点', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ),

          // Stats row
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('总距离: ${totalDist}km', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text('爬升: ${totalElev}m', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text('预估: ${totalTime}h', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: _addWaypoint,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: const Color(0xFFF8F7F4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('＋ 添加途经点', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _savePlannedRoute,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: const Color(0xFFF57C00),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('保存路线', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(color: const Color(0xFFF8F7F4), borderRadius: BorderRadius.circular(14)),
              child: const Text('取消', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _optionTile(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFF8F7F4), borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF5A6F45)),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _dragHandle() => Center(
        child: Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4))),
      );
}

void showCreateRouteModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const CreateRouteModal(),
  ).then((_) {
    // 路线保存后（selectedRoute 已设置），打开出发确认面板
    final state = Provider.of<AppState>(context, listen: false);
    if (state.selectedRoute != null) {
      showDepartConfirm(context);
    }
  });
}
