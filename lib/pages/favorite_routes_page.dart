import 'package:flutter/material.dart';
import '../config/app_config.dart';

/// V7.5 收藏路线
class FavoriteRoutesPage extends StatelessWidget {
  const FavoriteRoutesPage({super.key});

  static const _routes = [
    _FR('🚴', '西湖东环线', 42.6, 620, '中等', '杭州 · 西湖'),
    _FR('🏔️', '龙井爬坡路线', 18.5, 480, '较难', '杭州 · 龙井'),
    _FR('🌲', '千岛湖环湖线', 140.0, 2100, '困难', '杭州 · 淳安'),
    _FR('🌊', '沿江滨江线', 26.8, 180, '简单', '杭州 · 钱塘'),
    _FR('🌟', '梅家坞茶园线', 35.2, 350, '中等', '杭州 · 梅家坞'),
  ];

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(
        backgroundColor: AppConfig.cardBg,
        title: const Text('⭐ 常用路线', style: TextStyle(
            fontSize: 17, fontWeight: FontWeight.w700,
            color: AppConfig.textPrimary)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppConfig.pageMargin),
        itemCount: _routes.length,
        itemBuilder: (_, i) => _buildCard(_routes[i]),
      ),
    );
  }

  Widget _buildCard(_FR r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppConfig.cardBg,
        borderRadius: BorderRadius.circular(AppConfig.cardRadius),
        boxShadow: AppConfig.cardShadow,
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: AppConfig.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
              child: Text(r.emoji, style: const TextStyle(fontSize: 22))),
        ),
        title: Text(r.name, style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600,
            color: AppConfig.textPrimary)),
        subtitle: Text(
          '📍 ${r.location}  📏 ${r.distance.toStringAsFixed(1)}km  ⛰ ${r.climb}m  🎖 ${r.difficulty}',
          style: const TextStyle(
              fontSize: 11, color: AppConfig.textSecondary),
        ),
        trailing:
            const Icon(Icons.chevron_right, color: AppConfig.textSecondary),
      ),
    );
  }
}

class _FR {
  final String emoji, name, difficulty, location;
  final double distance;
  final int climb;
  const _FR(this.emoji, this.name, this.distance, this.climb,
      this.difficulty, this.location);
}