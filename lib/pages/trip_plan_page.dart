import 'package:flutter/material.dart';
import '../config/app_config.dart';

/// V7.5 出行计划
class TripPlanPage extends StatefulWidget {
  const TripPlanPage({super.key});
  @override
  State<TripPlanPage> createState() => _TripPlanPageState();
}

class _TripPlanPageState extends State<TripPlanPage> {
  final _plans = <_TripPlan>[
    _TripPlan('🚴', '环西湖骑行', '2026-05-15', '西湖东环线', 42.6, '即将出发'),
    _TripPlan('🏔️', '莫干山顶', '2026-05-24', '莫干山北线', 68.3, '计划中'),
    _TripPlan('🌲', '千岛湖探幽', '2026-06-08', '千岛湖环线', 140.0, '计划中'),
  ];

  List<_TripPlan> get _upcoming => _plans
    .where((p) => p.date.compareTo('2026-05-10') >= 0).toList()
    ..sort((a, b) => a.date.compareTo(b.date));

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(
        backgroundColor: AppConfig.cardBg,
        title: const Text('📅 出行计划', style: TextStyle(
            fontSize: 17, fontWeight: FontWeight.w700,
            color: AppConfig.textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppConfig.primary),
            onPressed: () {
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(content: Text('新建计划功能开发中')));
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConfig.pageMargin),
        children: [
          const Text('即将出发', style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600,
              color: AppConfig.primary)),
          const SizedBox(height: 10),
          ..._upcoming.map(_buildCard),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildCard(_TripPlan p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppConfig.cardBg,
        borderRadius: BorderRadius.circular(AppConfig.cardRadius),
        boxShadow: AppConfig.cardShadow,
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: AppConfig.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(p.emoji, style: const TextStyle(fontSize: 22)),
          ),
        ),
        title: Text(p.title, style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600,
            color: AppConfig.textPrimary)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('📅 ${p.date}  📍 ${p.route}', style: const TextStyle(
                fontSize: 11, color: AppConfig.textSecondary)),
            Text('距离: ${p.distance.toStringAsFixed(1)} km',
                style: const TextStyle(
                    fontSize: 11, color: AppConfig.textSecondary)),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppConfig.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(p.status, style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w500,
              color: AppConfig.primary)),
        ),
      ),
    );
  }
}

class _TripPlan {
  final String emoji, title, date, route, status;
  final double distance;
  const _TripPlan(this.emoji, this.title, this.date, this.route,
      this.distance, this.status);
}