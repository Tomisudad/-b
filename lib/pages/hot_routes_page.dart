import 'package:flutter/material.dart';
import '../config/app_config.dart';

class HotRoutesPage extends StatelessWidget {
  const HotRoutesPage({super.key});

  static final _routes = [
    {
      'name': '西湖环湖经典',
      'likes': 2341,
      'walkers': 890,
      'stars': 4.8,
      'distanceKm': 12.5,
      'climb': 80,
      'durationMinutes': 60,
      'difficulty': 2,
    },
    {
      'name': '千岛湖绿道',
      'likes': 1890,
      'walkers': 620,
      'stars': 4.9,
      'distanceKm': 35.0,
      'climb': 350,
      'durationMinutes': 150,
      'difficulty': 3,
    },
    {
      'name': '龙井北坡',
      'likes': 1560,
      'walkers': 410,
      'stars': 4.6,
      'distanceKm': 2.5,
      'climb': 220,
      'durationMinutes': 25,
      'difficulty': 4,
    },
    {
      'name': '赣北G318段',
      'likes': 3200,
      'walkers': 150,
      'stars': 4.7,
      'distanceKm': 180.0,
      'climb': 3200,
      'durationMinutes': 480,
      'difficulty': 4,
    },
  ];

  String _diffLabel(int d) {
    const labels = ['', '轻松', '适中', '有挑战', '困难', '极限'];
    return d >= 0 && d < labels.length ? labels[d] : '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('热门路线'),
        backgroundColor: Colors.white,
        foregroundColor: AppConfig.textPrimary,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _routes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final r = _routes[i];
          final stars = (r['stars'] as double).toStringAsFixed(1);
          final dist = (r['distanceKm'] as double);
          final climb = r['climb'];
          final dur = r['durationMinutes'];
          final diff = r['difficulty'];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: AppConfig.cyclePrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.route, color: AppConfig.cyclePrimary, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(r['name'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
                    const SizedBox(height: 4),
                    Row(children: [
                      ...List.generate(5, (j) => Icon(j < (diff as int) ? Icons.star : Icons.star_border, size: 12, color: Colors.amber)),
                      const SizedBox(width: 4),
                      Text(_diffLabel(diff as int), style: const TextStyle(fontSize: 11, color: AppConfig.textSecondary)),
                    ]),
                    const SizedBox(height: 4),
                    Text('${dist.toStringAsFixed(dist == dist.truncateToDouble() ? 0 : 1)}km · 爬升${climb as int}m · ${dur as int}分钟',
                        style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.thumb_up, size: 13, color: AppConfig.textSecondary),
                      const SizedBox(width: 3),
                      Text('${r['likes']}', style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
                      const SizedBox(width: 10),
                      const Icon(Icons.people, size: 13, color: AppConfig.textSecondary),
                      const SizedBox(width: 3),
                      Text('${r['walkers']}人走过', style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
                      const Spacer(),
                      Text('★ $stars', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFFFFB300))),
                    ]),
                  ])),
                ]),
              ),
            ),
          );
        },
      ),
    );
  }
}
