import 'package:flutter/material.dart';
import '../config/app_config.dart';

/// V7.3 天气详情页
class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(
        backgroundColor: AppConfig.cardBg,
        title: const Text('天气详情', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConfig.pageMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 当前天气
            _weatherCard(),
            const SizedBox(height: AppConfig.cardGap),
            // 3日预报
            _forecastSection(),
            const SizedBox(height: AppConfig.cardGap),
            // 骑行相关
            _cyclingWeatherCard(),
            const SizedBox(height: AppConfig.cardGap),
            // UV 指数
            _uvCard(),
          ],
        ),
      ),
    );
  }

  Widget _weatherCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF87CEEB), Color(0xFF4A90D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConfig.cardRadiusLg),
      ),
      child: Column(
        children: [
          const Text('杭州市', style: TextStyle(fontSize: 14, color: Colors.white70)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('25°', style: TextStyle(fontSize: 56, fontWeight: FontWeight.w300, color: Colors.white)),
              const SizedBox(width: 16),
              Column(
                children: [
                  const SizedBox(height: 8),
                  const Text('☀️', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 4),
                  const Text('晴朗', style: TextStyle(fontSize: 14, color: Colors.white70)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              _WeatherStat(icon: '🌡️', label: '体感 27°'),
              SizedBox(width: 16),
              _WeatherStat(icon: '💧', label: '湿度 58%'),
              SizedBox(width: 16),
              _WeatherStat(icon: '🌬️', label: '西南风 2级'),
              SizedBox(width: 16),
              _WeatherStat(icon: '👁️', label: '能见度 12km'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _forecastSection() {
    return _card(
      '📅 3日预报',
      Column(
        children: [
          _forecastDay('今天', '☀️', '25°', '16°', '西南风 2级', '优'),
          _divider(),
          _forecastDay('明天', '⛅', '27°', '18°', '东南风 3级', '良'),
          _divider(),
          _forecastDay('后天', '🌧️', '22°', '15°', '东北风 4级', '优'),
        ],
      ),
    );
  }

  Widget _forecastDay(String day, String icon, String high, String low, String wind, String aqi) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        SizedBox(width: 48, child: Text(day, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConfig.textPrimary))),
        Text(icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 12),
        Text(high, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
        const SizedBox(width: 4),
        Text(low, style: const TextStyle(fontSize: 14, color: AppConfig.textSecondary)),
        const Spacer(),
        Text(wind, style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
        const SizedBox(width: 8),
        Text('空气$aqi', style: const TextStyle(fontSize: 12, color: AppConfig.primary)),
      ]),
    );
  }

  Widget _cyclingWeatherCard() {
    return _card(
      '🚴 骑行天气评估',
      Column(
        children: [
          _cyclingRow('✅', '天气状况', '晴朗，适合骑行', AppConfig.primary),
          _divider(),
          _cyclingRow('✅', '风力', '2级微风，不影响骑行', AppConfig.primary),
          _divider(),
          _cyclingRow('✅', '降水', '24h内无降水', AppConfig.primary),
          _divider(),
          _cyclingRow('⚠️', '温差', '日夜温差9°，注意早晚保暖', AppConfig.warningOrange),
          _divider(),
          _cyclingRow('💡', '建议', '上午9点前出发最佳，下午注意防晒', AppConfig.primary),
        ],
      ),
    );
  }

  Widget _cyclingRow(String icon, String label, String detail, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Text('$label：', style: const TextStyle(fontSize: 13, color: AppConfig.textSecondary)),
        Text(detail, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: color)),
      ]),
    );
  }

  Widget _uvCard() {
    return _card(
      '☀️ 紫外线与日出日落',
      Column(
        children: [
          Row(
            children: [
              const Expanded(child: _UvStat(icon: '🌅', label: '日出', value: '05:12')),
              Container(width: 1, height: 30, color: AppConfig.divider),
              const Expanded(child: _UvStat(icon: '🌇', label: '日落', value: '18:47')),
            ],
          ),
          const SizedBox(height: 12),
          _divider(),
          const SizedBox(height: 8),
          Row(children: [
            const Text('紫外线指数', style: TextStyle(fontSize: 13, color: AppConfig.textSecondary)),
            const SizedBox(width: 8),
            const Text('6', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppConfig.warningOrange)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: AppConfig.warningOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: const Text('中高', style: TextStyle(fontSize: 11, color: AppConfig.warningOrange)),
            ),
            const Spacer(),
            const Text('防晒提示', style: TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
            const SizedBox(width: 4),
            const Text('SPF30+ PA+++', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppConfig.textPrimary)),
          ]),
        ],
      ),
    );
  }

  Widget _card(String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConfig.pageMargin),
      decoration: BoxDecoration(
        color: AppConfig.cardBg,
        borderRadius: BorderRadius.circular(AppConfig.cardRadiusLg),
        boxShadow: AppConfig.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, color: AppConfig.divider);
}

class _WeatherStat extends StatelessWidget {
  final String icon;
  final String label;
  const _WeatherStat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(icon, style: const TextStyle(fontSize: 16)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
    ]);
  }
}

class _UvStat extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  const _UvStat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(icon, style: const TextStyle(fontSize: 28)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
      const SizedBox(height: 2),
      Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
    ]);
  }
}