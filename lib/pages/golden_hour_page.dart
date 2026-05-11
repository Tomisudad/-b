import 'package:flutter/material.dart';
import '../config/app_config.dart';

/// V7.5 黄金时刻 — 日出日落、蓝调、金色时刻
class GoldenHourPage extends StatelessWidget {
  const GoldenHourPage({super.key});

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(
        backgroundColor: AppConfig.cardBg,
        title: const Text('🌅 黄金时刻', style: TextStyle(
            fontSize: 17, fontWeight: FontWeight.w700,
            color: AppConfig.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConfig.pageMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTodayCard(),
            const SizedBox(height: 20),
            const Text('本周预报', style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600,
                color: AppConfig.textPrimary)),
            const SizedBox(height: 10),
            ..._buildWeekRows(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFF7C948), Color(0xFF3498DB)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: [
        const Text('今天 5月10日',
            style: TextStyle(fontSize: 12, color: Colors.white70)),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _buildTimeBlock('🌅', '日出', '05:12', '蓝调时刻'),
          _buildTimeBlock('☀️', '金色时刻', '05:42-06:36', '最佳拍摄'),
          _buildTimeBlock('🌇', '日落', '18:46', '金色时刻'),
        ]),
      ]),
    );
  }

  Widget _buildTimeBlock(String emoji, String label, String time, String sub) {
    return Column(children: [
      Text(emoji, style: const TextStyle(fontSize: 28)),
      const SizedBox(height: 6),
      Text(time, style: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(
          fontSize: 11, color: Colors.white70)),
      Text(sub, style: const TextStyle(
          fontSize: 9, color: Colors.white54)),
    ]);
  }

  List<Widget> _buildWeekRows() {
    final now = DateTime.now();
    final days = ['今天', '明天', '周二', '周三', '周四', '周五', '周六'];
    final baseHour = 5;
    return List.generate(7, (i) {
      final d = now.add(Duration(days: i));
      final sunrise = '${(baseHour + i % 3).toString().padLeft(2, '0')}:${(12 + i * 3).toString().padLeft(2, '0')}';
      final sunset = '${(18 + i % 2).toString().padLeft(2, '0')}:${(46 - i * 2).toString().padLeft(2, '0')}';
      final isToday = i == 0;
      return Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isToday
              ? AppConfig.primary.withOpacity(0.05)
              : AppConfig.cardBg,
          borderRadius: BorderRadius.circular(AppConfig.cardRadius),
          boxShadow: isToday ? null : AppConfig.cardShadow,
          border: isToday
              ? Border.all(color: AppConfig.primary.withOpacity(0.2))
              : null,
        ),
        child: Row(children: [
          Text('${d.month}/${d.day} ${days[i]}',
              style: TextStyle(fontSize: 13,
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                  color: AppConfig.textPrimary)),
          const Spacer(),
          const Icon(Icons.wb_twilight, size: 16,
              color: Color(0xFFF39C12)),
          const SizedBox(width: 4),
          Text(sunrise, style: const TextStyle(
              fontSize: 13, color: AppConfig.textPrimary)),
          const SizedBox(width: 16),
          const Icon(Icons.wb_sunny, size: 16,
              color: Color(0xFFE74C3C)),
          const SizedBox(width: 4),
          Text(sunset, style: const TextStyle(
              fontSize: 13, color: AppConfig.textPrimary)),
        ]),
      );
    });
  }
}