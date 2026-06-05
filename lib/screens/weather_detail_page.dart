import 'package:flutter/material.dart';
import '../config/theme.dart';

/// 天气详情页 — 严格对照 HTML renderSub() weather
class WeatherDetailPage extends StatelessWidget {
  const WeatherDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const SizedBox(height: 4),
        // 天气主卡片 - 橄榄绿背景
        Container(
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(AppTheme.rCard),
            boxShadow: AppTheme.cardShadowList,
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('成都 · 当前天气',
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('24°',
                      style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  const Icon(Icons.wb_sunny, color: Colors.white, size: 40),
                ],
              ),
              const SizedBox(height: 4),
              const Text('晴 · 东南风2级',
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 20),
              // 四格气象数据
              Row(
                children: [
                  _weatherDataItem('湿度', '58%'),
                  _weatherDataItem('UV指数', '中等'),
                  _weatherDataItem('气压', '1012hPa'),
                  _weatherDataItem('日落', '19:24'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 未来3小时预报
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
              const Text('未来3小时',
                  style: TextStyle(fontWeight: AppTheme.wBold, fontSize: 16)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _hourlyItem('现在', '☀️', '24°'),
                  _hourlyItem('1h后', '☀️', '25°'),
                  _hourlyItem('2h后', '⛅', '23°'),
                  _hourlyItem('3h后', '⛅', '22°'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _weatherDataItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 13)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _hourlyItem(String time, String icon, String temp) {
    return Column(
      children: [
        Text(time, style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
        const SizedBox(height: 8),
        Text(icon, style: const TextStyle(fontSize: 30)),
        const SizedBox(height: 4),
        Text(temp,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
