import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../config/theme.dart';

/// 路线详情页 — 严格对照 HTML renderSub() route-detail
class RouteDetailPage extends StatelessWidget {
  const RouteDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        // 从当前 subPage.title 获取路线名
        final routeName = state.subPage?.title ?? '';
        final route = state.routes.cast<RouteModel?>().firstWhere(
              (r) => r?.name == routeName,
              orElse: () => state.routes.isNotEmpty ? state.routes.first : null,
            );

        if (route == null) {
          return const Center(child: Text('未找到路线'));
        }

        final waypoints = route.waypoints ?? [];
        final segments = _buildSegments(waypoints);

        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 4),
                  // 路线概览卡片
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(AppTheme.rCard24),
                      boxShadow: AppTheme.cardShadowList,
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(route.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: AppTheme.wBold)),
                        const SizedBox(height: 8),
                        Text(
                          '${route.distance} · ${route.time} · ${route.elevation}'
                          '${waypoints.isNotEmpty ? ' · ${waypoints.length}个途经点' : ''}',
                          style: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 分段详情
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(AppTheme.rCard24),
                      boxShadow: AppTheme.cardShadowList,
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('📍 分段详情',
                            style: TextStyle(
                                fontSize: 18, fontWeight: AppTheme.wBold)),
                        const SizedBox(height: 4),
                        ...segments.map((s) => _SegmentItem(segment: s)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // 底部出发按钮
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    state.quickDepart(route.name);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('🚴 用此路线出发'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Map<String, String>> _buildSegments(List<Waypoint> waypoints) {
    final List<Map<String, String>> segments = [];
    if (waypoints.isEmpty) {
      segments.add({'color': 'bg-green-500', 'name': '起点', 'desc': '出发'});
      segments.add({'color': 'bg-blue-500', 'name': '终点', 'desc': '到达'});
      return segments;
    }
    for (int i = 0; i < waypoints.length; i++) {
      final wp = waypoints[i];
      if (i == 0) {
        segments.add({'color': 'green', 'name': wp.name, 'desc': '起点 · 出发'});
      } else if (i == waypoints.length - 1) {
        segments.add({'color': 'blue', 'name': wp.name, 'desc': '终点 · 到达'});
      } else {
        segments.add({'color': 'orange', 'name': wp.name, 'desc': '途经点 · 经过'});
      }
    }
    return segments;
  }
}

class _SegmentItem extends StatelessWidget {
  final Map<String, String> segment;

  const _SegmentItem({required this.segment});

  Color _dotColor() {
    switch (segment['color']) {
      case 'green':
        return const Color(0xFF22C55E);
      case 'blue':
        return const Color(0xFF3B82F6);
      case 'orange':
      default:
        return AppTheme.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _dotColor(),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(segment['name'] ?? '',
                  style: const TextStyle(fontWeight: AppTheme.wBold, fontSize: 15)),
              Text(segment['desc'] ?? '',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
            ],
          ),
        ],
      ),
    );
  }
}
