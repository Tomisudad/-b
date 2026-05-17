import 'package:flutter/material.dart';
import '../config/app_config.dart';

/// V7.6 天气联动待办卡片
/// 根据天气数据生成出发前的智能提醒
class WeatherTodoCard extends StatefulWidget {
  const WeatherTodoCard({super.key});

  @override
  State<WeatherTodoCard> createState() => _WeatherTodoCardState();
}

class _WeatherTodoCardState extends State<WeatherTodoCard> {
  final Set<int> _checked = {};

  // Mock: 天气联动待办项
  static const _items = [
    _WTodo(0, '预计明天午后有阵雨', '带雨衣或防水外套，装好手机防水袋', Icons.water_drop_outlined, Color(0xFF3498DB)),
    _WTodo(1, '紫外线指数 8（很强）', '涂抹 SPF50+ 防晒霜，戴骑行袖套', Icons.wb_sunny_outlined, Color(0xFFF39C12)),
    _WTodo(2, '气温 18°C-28°C', '早晚温差大，带一件薄风衣', Icons.thermostat_outlined, Color(0xFFE67E22)),
    _WTodo(3, '北风 3-4级，阵风6级', '逆风路段注意配速，下坡注意侧风', Icons.air_outlined, Color(0xFF7F8C8D)),
    _WTodo(4, '日落时间 18:52', '若骑行超过下午5点，请带上前后车灯', Icons.wb_twilight_outlined, Color(0xFFF0C040)),
    _WTodo(5, 'AQI 45 优', '空气质量好，适合户外骑行', Icons.eco_outlined, AppConfig.cyclePrimary),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(AppConfig.pageMargin, 0, AppConfig.pageMargin, AppConfig.cardGap),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F4FD), Color(0xFFE8F8E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConfig.cardRadius),
        border: Border.all(color: AppConfig.cyclePrimary.withOpacity(0.12)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF3498DB), Color(0xFF2ECC71)]),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.cloud_queue, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 8),
          const Text('天气出行提醒', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
          const Spacer(),
          Text('${_checked.length}/${_items.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppConfig.cyclePrimary)),
        ]),
        const SizedBox(height: 10),
        ..._items.map((item) => _buildItem(item)),
      ]),
    );
  }

  Widget _buildItem(_WTodo item) {
    final done = _checked.contains(item.id);
    return GestureDetector(
      onTap: () => setState(() {
        if (done) { _checked.remove(item.id); } else { _checked.add(item.id); }
      }),
      child: AnimatedOpacity(
        opacity: done ? 0.45 : 1.0,
        duration: const Duration(milliseconds: 250),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20, height: 20,
              margin: const EdgeInsets.only(right: 8, top: 1),
              decoration: BoxDecoration(
                color: done ? AppConfig.cyclePrimary : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: done ? AppConfig.cyclePrimary : item.color.withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              child: done ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
            ),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(item.icon, size: 12, color: item.color),
                const SizedBox(width: 4),
                Flexible(child: Text(item.title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: done ? AppConfig.textSecondary : AppConfig.textPrimary))),
              ]),
              const SizedBox(height: 2),
              Text(item.detail, style: TextStyle(fontSize: 11, color: done ? AppConfig.textSecondary.withOpacity(0.6) : AppConfig.textBody, height: 1.3)),
            ])),
          ]),
        ),
      ),
    );
  }
}

class _WTodo {
  final int id;
  final String title;
  final String detail;
  final IconData icon;
  final Color color;
  const _WTodo(this.id, this.title, this.detail, this.icon, this.color);
}