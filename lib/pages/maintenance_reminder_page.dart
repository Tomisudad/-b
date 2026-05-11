import 'package:flutter/material.dart';
import '../config/app_config.dart';

/// V7.5 保养提醒
class MaintenanceReminderPage extends StatelessWidget {
  const MaintenanceReminderPage({super.key});

  static final _reminders = [
    _Reminder('🔗', '链条上油', '每200-300km上油一次', '2 天后', true, 200, 185),
    _Reminder('🛞', '轮胎检查', '检查胎压、磨损、裂缝', '5 天后', true, 500, 420),
    _Reminder('🧴', '刹车检查', '检查来令片磨损、刹车线张力', '7 天后', false, 800, 780),
    _Reminder('⚙️', '变速调校', '检查变速精准度、线管润滑', '14 天后', false, 1000, 920),
    _Reminder('📦', '整车检查', '全车螺丝拧紧、轴承受润', '30 天后', false, 2000, 1850),
  ];

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(
        backgroundColor: AppConfig.cardBg,
        title: const Text('🔧 保养提醒', style: TextStyle(
            fontSize: 17, fontWeight: FontWeight.w700,
            color: AppConfig.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConfig.pageMargin),
        child: Column(children: [
          _buildOverview(),
          const SizedBox(height: 16),
          ..._reminders.map((r) => _buildCard(r)),
          const SizedBox(height: 100),
        ]),
      ),
    );
  }

  Widget _buildOverview() {
    final urgent = _reminders.where((r) => r.urgent).length;
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConfig.cardBg,
        borderRadius: BorderRadius.circular(AppConfig.cardRadius),
        boxShadow: AppConfig.cardShadow,
      ),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFE74C3C).withOpacity(0.1),
            borderRadius: BorderRadius.circular(24)),
          child: const Center(
            child: Icon(Icons.warning_amber_rounded,
                color: Color(0xFFE74C3C), size: 24)),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$urgent 项待处理', style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700,
              color: AppConfig.textPrimary)),
          const Text('定期保养确保骑行安全',
              style: TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
        ]),
      ]),
    );
  }

  Widget _buildCard(_Reminder r) {
    final pct = r.intervalKm > 0 ? r.currentKm / r.intervalKm : 0.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppConfig.cardBg,
        borderRadius: BorderRadius.circular(AppConfig.cardRadius),
        boxShadow: AppConfig.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(r.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(child: Text(r.title, style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600,
                  color: AppConfig.textPrimary))),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: r.urgent
                      ? const Color(0xFFE74C3C).withOpacity(0.1)
                      : Colors.grey.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(r.due, style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w600,
                    color: r.urgent
                        ? const Color(0xFFE74C3C)
                        : AppConfig.textSecondary)),
              ),
            ]),
            const SizedBox(height: 8),
            Text(r.desc, style: const TextStyle(
                fontSize: 12, color: AppConfig.textSecondary)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct.clamp(0.0, 1.0),
                backgroundColor: Colors.grey.withOpacity(0.1),
                color: r.urgent
                    ? const Color(0xFFE74C3C)
                    : AppConfig.primary,
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 4),
            Text('已骑行 ${r.currentKm} / ${r.intervalKm} km',
                style: const TextStyle(
                    fontSize: 10, color: AppConfig.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _Reminder {
  final String emoji, title, desc, due;
  final bool urgent;
  final int intervalKm, currentKm;
  const _Reminder(this.emoji, this.title, this.desc, this.due,
      this.urgent, this.intervalKm, this.currentKm);
}