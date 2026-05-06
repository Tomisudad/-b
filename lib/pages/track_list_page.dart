import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../config/scenario_config.dart';

/// V5.2 轨迹记录模块 — 纯数据管理，无记录开始按钮
/// 记录入口仅通过底部 + 按钮进入
class TrackListPage extends StatefulWidget {
  const TrackListPage({super.key});

  @override
  State<TrackListPage> createState() => _TrackListPageState();
}

class _TrackListPageState extends State<TrackListPage> {
  String _search = '';
  final List<_TrackEntry> _tracks = _mockTracks();
  bool _sortRecent = true;

  static List<_TrackEntry> _mockTracks() => [
    _TrackEntry('环西湖骑行', OutdoorScenario.cycle, DateTime(2026, 5, 1), 28.5, 560, 450, 2.5),
    _TrackEntry('午潮山越野', OutdoorScenario.cycle, DateTime(2026, 4, 28), 15.2, 380, 520, 1.8),
    _TrackEntry('龙井爬坡训练', OutdoorScenario.cycle, DateTime(2026, 4, 25), 8.4, 210, 310, 0.9),
    _TrackEntry('临安摩托车跑山', OutdoorScenario.moto, DateTime(2026, 4, 20), 95.0, 210, 1800, 4.2),
    _TrackEntry('德清自驾露营', OutdoorScenario.drive, DateTime(2026, 4, 15), 120.0, 180, 1200, 6.5),
    _TrackEntry('西溪湿地散步', OutdoorScenario.cycle, DateTime(2026, 4, 10), 12.0, 320, 80, 1.2),
    _TrackEntry('皖浙天路骑行', OutdoorScenario.cycle, DateTime(2026, 4, 5), 65.0, 310, 1800, 3.8),
    _TrackEntry('太湖东山骑行', OutdoorScenario.cycle, DateTime(2026, 4, 1), 42.0, 280, 650, 2.2),
  ];

  List<_TrackEntry> get _filtered {
    var list = _tracks.toList();
    if (_search.isNotEmpty) {
      list = list.where((t) => t.name.contains(_search)).toList();
    }
    list.sort((a, b) => _sortRecent ? b.date.compareTo(a.date) : a.date.compareTo(b.date));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(
        title: const Text('我的轨迹', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: Icon(_sortRecent ? Icons.access_time : Icons.access_time_outlined),
            tooltip: _sortRecent ? '最近优先' : '最早优先',
            onPressed: () => setState(() => _sortRecent = !_sortRecent),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppConfig.pageMargin, 0, AppConfig.pageMargin, 12),
            child: TextField(
              decoration: InputDecoration(
                hintText: '搜索轨迹...',
                prefixIcon: const Icon(Icons.search, size: 20, color: AppConfig.textSecondary),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? _emptyState()
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppConfig.cardGap),
                    itemBuilder: (_, i) => _buildTrackCard(filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackCard(_TrackEntry t) {
    final color = t.scene.primaryColor;
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _TrackDetailPage(track: t, allTracks: _tracks))),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppConfig.cardBg,
          borderRadius: BorderRadius.circular(AppConfig.cardRadius),
          boxShadow: AppConfig.cardShadow,
        ),
        child: Row(
          children: [
            // 缩略轨迹线装饰
            Container(
              width: 3, height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.8), color.withOpacity(0.2)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(t.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(t.scene.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: color)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _metaChip(Icons.route_outlined, '${t.distanceKm.toStringAsFixed(1)}km'),
                      const SizedBox(width: 12),
                      _metaChip(Icons.trending_up, '${t.climb}m'),
                      const SizedBox(width: 12),
                      _metaChip(Icons.speed, '${t.avgSpeedKmh.toStringAsFixed(1)}km/h'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${t.date.month}月${t.date.day}日',
                    style: const TextStyle(fontSize: 11, color: AppConfig.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppConfig.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _metaChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppConfig.textSecondary.withOpacity(0.6)),
        const SizedBox(width: 3),
        Text(text, style: TextStyle(fontSize: 12, color: AppConfig.textSecondary.withOpacity(0.85))),
      ],
    );
  }

  Widget _emptyState() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: AppConfig.cyclePrimary.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.timeline_outlined, size: 36, color: AppConfig.cyclePrimary),
        ),
        const SizedBox(height: 16),
        const Text('还没有轨迹记录', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
        const SizedBox(height: 6),
        const Text('点击底部 + 按钮开始记录', style: TextStyle(fontSize: 13, color: AppConfig.textSecondary)),
      ],
    ),
  );
}

/// 轨迹详情页
class _TrackDetailPage extends StatelessWidget {
  final _TrackEntry track;
  final List<_TrackEntry> allTracks;
  const _TrackDetailPage({required this.track, required this.allTracks});

  @override
  Widget build(BuildContext context) {
    final color = track.scene.primaryColor;
    final sameRoute = allTracks.where((t) => t.name == track.name && t != track).toList();

    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(
        title: Text(track.name),
        actions: [
          IconButton(icon: const Icon(Icons.ios_share), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConfig.pageMargin),
        children: [
          // 轨迹地图占位
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppConfig.cardRadius),
              border: Border.all(color: color.withOpacity(0.15)),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.map_outlined, size: 44, color: color.withOpacity(0.3)),
                  const SizedBox(height: 8),
                  Text('轨迹地图预览', style: TextStyle(fontSize: 13, color: color.withOpacity(0.4))),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppConfig.cardGap),
          // 数据面板
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), boxShadow: AppConfig.cardShadow),
            child: Column(
              children: [
                Row(
                  children: [
                    _statBox('总距离', '${track.distanceKm.toStringAsFixed(1)} km', color),
                    Container(width: 1, height: 36, color: AppConfig.divider),
                    _statBox('用时', _fmtHours(track.durationHours), color),
                    Container(width: 1, height: 36, color: AppConfig.divider),
                    _statBox('爬升', '${track.climb} m', color),
                    Container(width: 1, height: 36, color: AppConfig.divider),
                    _statBox('均速', '${track.avgSpeedKmh.toStringAsFixed(1)} km/h', color),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConfig.cardGap),
          // 感悟时间轴
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), boxShadow: AppConfig.cardShadow),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('行程感悟', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
                const SizedBox(height: 10),
                _timelineItem('☀️', '0.0km', '出发！天气晴好，心情不错。', color),
                _timelineItem('😌', '5.2km', '进入林道，空气很清新。', color),
                _timelineItem('🤯', '12.0km', '垭口的风景太震撼了，必须停下来拍。', color),
                _timelineItem('🧘', '20.5km', '一个人在路上，有种说不出的平静。', color),
                _timelineItem('🏁', '${track.distanceKm.toStringAsFixed(1)}km', '到达终点，完成。', color),
              ],
            ),
          ),
          if (sameRoute.isNotEmpty) ...[
            const SizedBox(height: AppConfig.cardGap),
            // 重复挑战对比
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), boxShadow: AppConfig.cardShadow),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('重复挑战对比', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
                  const SizedBox(height: 10),
                  ...sameRoute.map((s) {
                    final faster = s.avgSpeedKmh > track.avgSpeedKmh;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Text('${s.date.month}/${s.date.day}', style: const TextStyle(fontSize: 13, color: AppConfig.textSecondary)),
                          const SizedBox(width: 12),
                          Text('${s.distanceKm.toStringAsFixed(1)}km', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
                          const SizedBox(width: 12),
                          Icon(faster ? Icons.arrow_upward : Icons.arrow_downward, size: 14, color: faster ? AppConfig.cyclePrimary : AppConfig.motoPrimary),
                          Text(
                            '${s.avgSpeedKmh.toStringAsFixed(1)}km/h',
                            style: TextStyle(fontSize: 13, color: faster ? AppConfig.cyclePrimary : AppConfig.motoPrimary),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppConfig.sectionGap),
          // 操作按钮（无出发）
          Row(
            children: [
              Expanded(child: _actionBtn(Icons.edit_outlined, '编辑', color, () {})),
              const SizedBox(width: 8),
              Expanded(child: _actionBtn(Icons.link, '关联路线', color, () {})),
              const SizedBox(width: 8),
              Expanded(child: _actionBtn(Icons.ios_share, '导出GPX', color, () {})),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: AppConfig.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _timelineItem(String icon, String km, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Container(
            width: 1,
            height: 50,
            decoration: BoxDecoration(gradient: LinearGradient(
              colors: [color.withOpacity(0.4), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(km, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
                const SizedBox(height: 2),
                Text(text, style: const TextStyle(fontSize: 13, color: AppConfig.textPrimary, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label, Color color, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        foregroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.buttonRadius)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  static String _fmtHours(double h) {
    if (h >= 24) return '${(h / 24).round()}天';
    final hr = h.floor();
    final min = ((h - hr) * 60).round();
    return min > 0 ? '${hr}h${min}min' : '${hr}h';
  }
}

class _TrackEntry {
  final String name;
  final OutdoorScenario scene;
  final DateTime date;
  final double distanceKm;
  final double durationHours;
  final int climb;
  final double avgSpeedKmh;

  const _TrackEntry(this.name, this.scene, this.date, this.distanceKm, this.durationHours, this.climb, this.avgSpeedKmh);
}
