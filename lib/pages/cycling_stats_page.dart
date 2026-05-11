import 'package:flutter/material.dart';
import '../config/app_config.dart';

/// V7.5 骑行统计仪表盘
class CyclingStatsPage extends StatefulWidget {
  const CyclingStatsPage({super.key});
  @override
  State<CyclingStatsPage> createState() => _CyclingStatsPageState();
}

class _CyclingStatsPageState extends State<CyclingStatsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  final _allStats = _StatsData(
    totalKm: 2847.3, totalRides: 156, totalHours: 127.5,
    totalClimb: 31240, avgSpeed: 22.3, maxSpeed: 58.7,
    longestRide: 186.4, streakDays: 12,
  );
  final _monthStats = _StatsData(
    totalKm: 423.6, totalRides: 18, totalHours: 18.3,
    totalClimb: 4720, avgSpeed: 23.1, maxSpeed: 52.4,
    longestRide: 98.5, streakDays: 8,
  );
  final _weekStats = _StatsData(
    totalKm: 87.2, totalRides: 4, totalHours: 3.8,
    totalClimb: 890, avgSpeed: 22.9, maxSpeed: 45.3,
    longestRide: 32.6, streakDays: 4,
  );

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }
  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(
        backgroundColor: AppConfig.cardBg,
        title: const Text('📊 骑行统计', style: TextStyle(
            fontSize: 17, fontWeight: FontWeight.w700,
            color: AppConfig.textPrimary)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: TabBar(
            controller: _tabCtrl,
            labelColor: AppConfig.textPrimary,
            unselectedLabelColor: AppConfig.textSecondary,
            indicatorColor: AppConfig.primary,
            tabs: const [
              Tab(text: '本周'), Tab(text: '本月'), Tab(text: '全部')
            ],
          ),
        ),
      ),
      body: TabBarView(controller: _tabCtrl, children: [
        _buildDashboard(_weekStats),
        _buildDashboard(_monthStats),
        _buildDashboard(_allStats),
      ]),
    );
  }

  Widget _buildDashboard(_StatsData s) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConfig.pageMargin),
      child: Column(children: [
        _buildStatGrid(s),
        const SizedBox(height: 16),
        _buildWeekDayHeatmap(),
        const SizedBox(height: 16),
        _buildTopRides(),
        const SizedBox(height: 100),
      ]),
    );
  }

  Widget _buildStatGrid(_StatsData s) {
    final items = [
      _StatItem('总里程', '${s.totalKm.toStringAsFixed(1)} km',
          Icons.route, AppConfig.primary),
      _StatItem('总次数', '${s.totalRides} 次',
          Icons.repeat, const Color(0xFFE67E22)),
      _StatItem('总时长', '${s.totalHours.toStringAsFixed(1)} h',
          Icons.timer, const Color(0xFF3498DB)),
      _StatItem('总爬升', '${s.totalClimb} m',
          Icons.trending_up, const Color(0xFFE74C3C)),
      _StatItem('均速', '${s.avgSpeed.toStringAsFixed(1)} km/h',
          Icons.speed, const Color(0xFF9B59B6)),
      _StatItem('最长', '${s.longestRide.toStringAsFixed(1)} km',
          Icons.flag, const Color(0xFFF39C12)),
    ];
    return GridView.count(
      crossAxisCount: 3, shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10, crossAxisSpacing: 10,
      childAspectRatio: 1.1,
      children: items.map((i) => Container(
        decoration: BoxDecoration(
          color: AppConfig.cardBg,
          borderRadius: BorderRadius.circular(AppConfig.cardRadius),
          boxShadow: AppConfig.cardShadow,
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(i.icon, size: 22, color: i.color),
          const SizedBox(height: 6),
          Text(i.value, style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w700, color: i.color)),
          Text(i.label, style: const TextStyle(
              fontSize: 10, color: AppConfig.textSecondary)),
        ]),
      )).toList(),
    );
  }

  Widget _buildWeekDayHeatmap() {
    final days = ['一', '二', '三', '四', '五', '六', '日'];
    final vals = [32, 0, 28, 45, 0, 87, 52];
    final mx = vals.reduce((a, b) => a > b ? a : b);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppConfig.cardBg,
          borderRadius: BorderRadius.circular(AppConfig.cardRadius),
          boxShadow: AppConfig.cardShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('本周活动热力图', style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600,
            color: AppConfig.textPrimary)),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (i) {
            final intensity = mx > 0 ? vals[i] / mx : 0.0;
            final alpha = (0.15 + intensity * 0.85);
            return Column(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppConfig.primary.withOpacity(alpha),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(child: Text('${vals[i]}', style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600,
                    color: intensity > 0.5
                        ? Colors.white : AppConfig.textPrimary))),
              ),
              const SizedBox(height: 4),
              Text(days[i], style: const TextStyle(
                  fontSize: 10, color: AppConfig.textSecondary)),
            ]);
          }),
        ),
      ]),
    );
  }

  Widget _buildTopRides() {
    final rides = [
      ('环西湖骑行', '42.6 km', '2.4 h', '🏆 最佳', AppConfig.primary),
      ('千岛湖探幽', '140.0 km', '7.2 h', '🔥 最远', const Color(0xFFE74C3C)),
      ('龙井爬坡', '18.5 km', '1.1 h', '⛰ 最虐', const Color(0xFFE67E22)),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Top 3 骑行', style: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600,
          color: AppConfig.textPrimary)),
      const SizedBox(height: 10),
      ...rides.map((r) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppConfig.cardBg,
            borderRadius: BorderRadius.circular(AppConfig.cardRadius),
            boxShadow: AppConfig.cardShadow),
        child: Row(children: [
          Icon(Icons.emoji_events, size: 22, color: r.$5),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(r.$1, style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: AppConfig.textPrimary)),
            Text(r.$2, style: const TextStyle(
                fontSize: 11, color: AppConfig.textSecondary)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: r.$5.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6)),
            child: Text(r.$4, style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w600, color: r.$5)),
          ),
        ]),
      )),
    ]);
  }
}

class _StatsData {
  final double totalKm, totalHours, avgSpeed, maxSpeed, longestRide;
  final int totalRides, totalClimb, streakDays;
  const _StatsData({
    required this.totalKm, required this.totalRides,
    required this.totalHours, required this.totalClimb,
    required this.avgSpeed, required this.maxSpeed,
    required this.longestRide, required this.streakDays,
  });
}

class _StatItem {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatItem(this.label, this.value, this.icon, this.color);
}