import 'package:flutter/material.dart';
import '../config/app_config.dart';

/// V7.5 成就勋章系统
class MyAchievementsPage extends StatelessWidget {
  const MyAchievementsPage({super.key});

  static const _badges = [
    _Badge('🏅', '一公里', '完成第一次一公里骑行', true, _BadgeCat.milestone),
    _Badge('🥇', '十公里', '单次骑行超过10公里', true, _BadgeCat.milestone),
    _Badge('🏆', '百公里', '单次骑行超过100公里', true, _BadgeCat.milestone),
    _Badge('👑', '千公里', '累计骑行1000公里', true, _BadgeCat.milestone),
    _Badge('⛰️', '爬升达人', '累计爬升超过5000米', true, _BadgeCat.milestone),
    _Badge('🔥', '连续7天', '连续7天骑行打卡', true, _BadgeCat.streak),
    _Badge('🌍', '探索者', '在5个不同区县骑行', true, _BadgeCat.explore),
    _Badge('🌟', '秋名山', '骑行到达海拔1000米', true, _BadgeCat.explore),
    _Badge('🏝️', '夜骑勇士', '在晚上完成骑行', true, _BadgeCat.challenge),
    _Badge('🌧️', '风雨无阻', '在雨天完成骑行', true, _BadgeCat.challenge),
    _Badge('👤', '伙伴一起', '第一次组队骑行', false, _BadgeCat.social),
    _Badge('📸', '记录者', '完成10条骑行记录', false, _BadgeCat.social),
  ];

  List<_Badge> get _earned => _badges.where((b) => b.earned).toList();
  List<_Badge> get _locked => _badges.where((b) => !b.earned).toList();

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(
        backgroundColor: AppConfig.cardBg,
        title: const Text('🏅 我的成就', style: TextStyle(
            fontSize: 17, fontWeight: FontWeight.w700,
            color: AppConfig.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConfig.pageMargin),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildSummary(_earned.length, _badges.length),
          const SizedBox(height: 20),
          const Text('已获得', style: TextStyle(fontSize: 14,
              fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
          const SizedBox(height: 10),
          _buildBadgeGrid(ctx, _earned),
          const SizedBox(height: 20),
          const Text('待解锁', style: TextStyle(fontSize: 14,
              fontWeight: FontWeight.w600, color: AppConfig.textSecondary)),
          const SizedBox(height: 10),
          _buildBadgeGrid(ctx, _locked),
          const SizedBox(height: 100),
        ]),
      ),
    );
  }

  Widget _buildSummary(int earned, int total) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2ECC71), Color(0xFF27AE60)]),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(children: [
        const Text('你已获得', style: TextStyle(fontSize: 13, color: Colors.white70)),
        const SizedBox(height: 8),
        RichText(text: TextSpan(children: [
          TextSpan(text: '$earned', style: const TextStyle(
              fontSize: 40, fontWeight: FontWeight.w800, color: Colors.white)),
          TextSpan(text: ' / $total', style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.w400, color: Colors.white70)),
        ])),
        const SizedBox(height: 4),
        const Text('枚勋章', style: TextStyle(fontSize: 12, color: Colors.white60)),
        const SizedBox(height: 12),
        const LinearProgressIndicator(
          value: 10 / 12, backgroundColor: Colors.white24,
          color: Colors.white, minHeight: 4,
          borderRadius: BorderRadius.all(Radius.circular(2)),
        ),
      ]),
    );
  }

  Widget _buildBadgeGrid(BuildContext localCtx, List<_Badge> badges) {
    if (badges.isEmpty) return const Center(child: Padding(
      padding: EdgeInsets.all(32),
      child: Text('暂无勋章', style: TextStyle(
          fontSize: 13, color: AppConfig.textSecondary)),
    ));
    final w = (MediaQuery.sizeOf(localCtx).width - AppConfig.pageMargin * 2 - 24) / 3;
    return Wrap(spacing: 12, runSpacing: 12,
      children: badges.map((b) => SizedBox(
        width: w,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppConfig.cardBg,
            borderRadius: BorderRadius.circular(AppConfig.cardRadius),
            boxShadow: AppConfig.cardShadow,
          ),
          child: Column(children: [
            Text(b.emoji, style: TextStyle(
                fontSize: 28,
                color: b.earned ? null : Colors.black26)),
            const SizedBox(height: 8),
            Text(b.title, textAlign: TextAlign.center, style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: b.earned ? AppConfig.textPrimary : AppConfig.textSecondary)),
            const SizedBox(height: 4),
            Text(b.desc, textAlign: TextAlign.center,
                maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 10, color: AppConfig.textSecondary)),
          ]),
        ),
      )).toList(),
    );
  }
}

enum _BadgeCat { milestone, streak, explore, challenge, social }

class _Badge {
  final String emoji, title, desc;
  final bool earned;
  final _BadgeCat cat;
  const _Badge(this.emoji, this.title, this.desc, this.earned, this.cat);
}