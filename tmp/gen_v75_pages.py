#!/usr/bin/env python3
"""Generate all V7.5 missing pages for &#21435;&#37326; App"""

import os

BASE = r'C:\Users\14864\.qclaw\workspace-agent-34339a2d\outdoor_companion\lib\pages'

HEADER = """import 'package:flutter/material.dart';
import '../config/app_config.dart';
"""


def write_dart(name, code):
    path = os.path.join(BASE, name)
    content = HEADER + code
    with open(path, 'w', encoding='utf-8', newline='\r\n') as f:
        f.write(content)
    sz = len(content.encode('utf-8'))
    print(f'  Wrote {name} ({sz} bytes)')


# ============================================================
# 1. cycling_stats_page.dart
# ============================================================
cycling_stats = """
/// V7.5 &#39569;&#34892;&#32479;&#35745;&#20202;&#34920;&#30424;
class CyclingStatsPage extends StatefulWidget {
  const CyclingStatsPage({super.key});
  @override
  State<CyclingStatsPage> createState() => _CyclingStatsPageState();
}

class _CyclingStatsPageState extends State<CyclingStatsPage> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  final _allStats = _StatsData(totalKm: 2847.3, totalRides: 156, totalHours: 127.5, totalClimb: 31240, avgSpeed: 22.3, maxSpeed: 58.7, longestRide: 186.4, streakDays: 12);
  final _monthStats = _StatsData(totalKm: 423.6, totalRides: 18, totalHours: 18.3, totalClimb: 4720, avgSpeed: 23.1, maxSpeed: 52.4, longestRide: 98.5, streakDays: 8);
  final _weekStats = _StatsData(totalKm: 87.2, totalRides: 4, totalHours: 3.8, totalClimb: 890, avgSpeed: 22.9, maxSpeed: 45.3, longestRide: 32.6, streakDays: 4);

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(
        backgroundColor: AppConfig.cardBg,
        title: const Text('\u{1f4ca} \u{9a91}\u{884c}\u{7edf}\u{8ba1}', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: TabBar(
            controller: _tabCtrl,
            labelColor: AppConfig.textPrimary,
            unselectedLabelColor: AppConfig.textSecondary,
            indicatorColor: AppConfig.primary,
            tabs: const [Tab(text: '\u{672c}\u{5468}'), Tab(text: '\u{672c}\u{6708}'), Tab(text: '\u{5168}\u{90e8}')],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [_buildDashboard(_weekStats), _buildDashboard(_monthStats), _buildDashboard(_allStats)],
      ),
    );
  }

  Widget _buildDashboard(_StatsData s) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConfig.pageMargin),
      child: Column(children: [
        _buildStatGrid(s),
        const SizedBox(height: 16),
        _buildChartPlaceholder('\u{8ddd}\u{79bb}\u{8d8b}\u{52bf}'),
        const SizedBox(height: 16),
        _buildChartPlaceholder('\u{65f6}\u{95f4}\u{5206}\u{5e03}'),
        const SizedBox(height: 16),
        _buildWeekDayHeatmap(),
      ]),
    );
  }

  Widget _buildStatGrid(_StatsData s) {
    final items = [
      _StatItem('\u{603b}\u{91cc}\u{7a0b}', '${s.totalKm.toStringAsFixed(1)} km', Icons.route, AppConfig.primary),
      _StatItem('\u{603b}\u{6b21}\u{6570}', '${s.totalRides} \u{6b21}', Icons.repeat, const Color(0xFFE67E22)),
      _StatItem('\u{603b}\u{65f6}\u{957f}', '${s.totalHours.toStringAsFixed(1)} h', Icons.timer, const Color(0xFF3498DB)),
      _StatItem('\u{603b}\u{722c}\u{5347}', '${s.totalClimb} m', Icons.trending_up, const Color(0xFFE74C3C)),
      _StatItem('\u{5e73}\u{5747}\u{901f}\u{5ea6}', '${s.avgSpeed.toStringAsFixed(1)} km/h', Icons.speed, const Color(0xFF9B59B6)),
      _StatItem('\u{9aa4}\u{9a87}\u{65e5}\u{6570}', '${s.streakDays} \u{5929}', Icons.local_fire_department, const Color(0xFFF39C12)),
    ];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.1,
      children: items.map((i) => Container(
        decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), boxShadow: AppConfig.cardShadow),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(i.icon, size: 22, color: i.color),
          const SizedBox(height: 6),
          Text(i.value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: i.color)),
          Text(i.label, style: const TextStyle(fontSize: 10, color: AppConfig.textSecondary)),
        ]),
      )).toList(),
    );
  }

  Widget _buildChartPlaceholder(String title) {
    return Container(
      width: double.infinity, height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), boxShadow: AppConfig.cardShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
        const Expanded(child: Center(child: Text('\u{56fe}\u{8868}\u{5360}\u{4f4d}\u{2014}\u{2014}\u{63a5}\u{5165}\u{8bb0}\u{5f55}\u{540e}\u{81ea}\u{52a8}\u{751f}\u{6210}', style: TextStyle(fontSize: 12, color: AppConfig.textSecondary)))),
      ]),
    );
  }

  Widget _buildWeekDayHeatmap() {
    final days = ['\u{4e00}', '\u{4e8c}', '\u{4e09}', '\u{56db}', '\u{4e94}', '\u{516d}', '\u{65e5}'];
    final vals = [32, 0, 28, 45, 0, 87, 52];
    final mx = vals.reduce((a, b) => a > b ? a : b);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), boxShadow: AppConfig.cardShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('\u{672c}\u{5468}\u{6d3b}\u{52a8}\u{70ed}\u{529b}\u{56fe}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: List.generate(7, (i) {
          final intensity = mx > 0 ? vals[i] / mx : 0.0;
          final alpha = (0.15 + intensity * 0.85);
          return Column(children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: AppConfig.primary.withOpacity(alpha), borderRadius: BorderRadius.circular(8)), child: Center(child: Text('${vals[i]}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: intensity > 0.5 ? Colors.white : AppConfig.textPrimary)))),
            const SizedBox(height: 4),
            Text(days[i], style: const TextStyle(fontSize: 10, color: AppConfig.textSecondary)),
          ]);
        })),
      ]),
    );
  }
}

class _StatsData {
  final double totalKm;
  final int totalRides;
  final double totalHours;
  final int totalClimb;
  final double avgSpeed;
  final double maxSpeed;
  final double longestRide;
  final int streakDays;
  const _StatsData({required this.totalKm, required this.totalRides, required this.totalHours, required this.totalClimb, required this.avgSpeed, required this.maxSpeed, required this.longestRide, required this.streakDays});
}

class _StatItem {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatItem(this.label, this.value, this.icon, this.color);
}
"""


# ============================================================
# 2. my_achievements_page.dart
# ============================================================
my_achievements = """
/// V7.5 &#25104;&#23601;&#21195;&#31456;&#31995;&#32479;
class MyAchievementsPage extends StatelessWidget {
  const MyAchievementsPage({super.key});

  static const _badges = [
    _Badge('\u{1f3c5}', '\u{4e00}\u{516c}\u{91cc}', '\u{5b8c}\u{6210}\u{7b2c}\u{4e00}\u{6b21}\u{4e00}\u{516c}\u{91cc}', true, _BadgeCat.milestone),
    _Badge('\u{1f947}', '\u{5341}\u{516c}\u{91cc}', '\u{5355}\u{6b21}\u{9a91}\u{884c}\u{8d85}\u{8fc7}10\u{516c}\u{91cc}', true, _BadgeCat.milestone),
    _Badge('\u{1f3c6}', '\u{767e}\u{516c}\u{91cc}', '\u{5355}\u{6b21}\u{9a91}\u{884c}\u{8d85}\u{8fc7}100\u{516c}\u{91cc}', true, _BadgeCat.milestone),
    _Badge('\u{1f451}', '\u{5343}\u{516c}\u{91cc}', '\u{7d2f}\u{8ba1}\u{9a91}\u{884c}1000\u{516c}\u{91cc}', true, _BadgeCat.milestone),
    _Badge('\u{26f0}', '\u{722c}\u{5347}\u{8fbe}\u{4eba}', '\u{7d2f}\u{8ba1}\u{722c}\u{5347}\u{8d85}\u{8fc7}5000\u{7c73}', true, _BadgeCat.milestone),
    _Badge('\u{1f525}', '\u{8fde}\u{7eed}7\u{5929}', '\u{8fde}\u{7eed}7\u{5929}\u{9a91}\u{884c}\u{6253}\u{5361}', true, _BadgeCat.streak),
    _Badge('\u{1f30d}', '\u{63a2}\u{7d22}\u{8005}', '\u{5728}5\u{4e2a}\u{4e0d}\u{540c}\u{533a}\u{53bf}\u{9a91}\u{884c}', true, _BadgeCat.explore),
    _Badge('\u{1f31f}', '\u{79cb}\u{540d}\u{5c71}', '\u{9a91}\u{884c}\u{5230}\u{8fbe}\u{6d77}\u{62d4}1000\u{7c73}', true, _BadgeCat.explore),
    _Badge('\u{1f321}', '\u{591c}\u{9a91}\u{52c7}\u{58eb}', '\u{5728}\u{665a}\u{4e0a}\u{5b8c}\u{6210}\u{4e00}\u{6b21}\u{9a91}\u{884c}', true, _BadgeCat.challenge),
    _Badge('\u{1f327}', '\u{98ce}\u{96e8}\u{65e0}\u{963b}', '\u{5728}\u{96e8}\u{5929}\u{5b8c}\u{6210}\u{9a91}\u{884c}', true, _BadgeCat.challenge),
    _Badge('\u{1f464}', '\u{4f19}\u{4f34}\u{4e00}\u{8d77}', '\u{7b2c}\u{4e00}\u{6b21}\u{7ec4}\u{961f}\u{9a91}\u{884c}', false, _BadgeCat.social),
    _Badge('\u{1f4f8}', '\u{8bb0}\u{5f55}\u{8005}', '\u{5b8c}\u{6210}10\u{6761}\u{9a91}\u{884c}\u{8bb0}\u{5f55}', false, _BadgeCat.social),
  ];

  @override
  Widget build(BuildContext context) {
    final earned = _badges.where((b) => b.earned).toList();
    final locked = _badges.where((b) => !b.earned).toList();
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(
        backgroundColor: AppConfig.cardBg,
        title: const Text('\u{1f3c5} \u{6211}\u{7684}\u{6210}\u{5c31}', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
        actions: [TextButton(onPressed: () {}, child: const Text('\u{7edf}\u{8ba1}', style: TextStyle(fontSize: 13, color: AppConfig.textSecondary)))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConfig.pageMargin),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildSummary(earned.length, _badges.length),
          const SizedBox(height: 20),
          const Text('\u{5df2}\u{83b7}\u{5f97}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
          const SizedBox(height: 10),
          _buildBadgeGrid(earned),
          const SizedBox(height: 20),
          const Text('\u{5f85}\u{89e3}\u{9501}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConfig.textSecondary)),
          const SizedBox(height: 10),
          _buildBadgeGrid(locked),
          const SizedBox(height: 100),
        ]),
      ),
    );
  }

  Widget _buildSummary(int earned, int total) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF2ECC71), Color(0xFF27AE60)]), borderRadius: BorderRadius.circular(AppConfig.cardRadiusLg)),
      child: Column(children: [
        const Text('\u{4f60}\u{5df2}\u{83b7}\u{5f97}', style: TextStyle(fontSize: 13, color: Colors.white70)),
        const SizedBox(height: 8),
        RichText(text: TextSpan(children: [
          TextSpan(text: '$earned', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: Colors.white)),
          TextSpan(text: ' / $total', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w400, color: Colors.white70)),
        ])),
        const SizedBox(height: 4),
        const Text('\u{679a}\u{52cb}\u{7ae0}', style: TextStyle(fontSize: 12, color: Colors.white60)),
        const SizedBox(height: 12),
        LinearProgressIndicator(value: earned / total, backgroundColor: Colors.white24, color: Colors.white, minHeight: 4, borderRadius: BorderRadius.all(Radius.circular(2))),
      ]),
    );
  }

  Widget _buildBadgeGrid(List<_Badge> badges) {
    if (badges.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('\u{6682}\u{65e0}\u{52cb}\u{7ae0}', style: TextStyle(fontSize: 13, color: AppConfig.textSecondary))));
    return Wrap(spacing: 12, runSpacing: 12, children: badges.map((b) => _buildBadge(b)).toList());
  }

  Widget _buildBadge(_Badge b) {
    final active = b.earned;
    return Container(
      width: (MediaQuery.sizeOf(context).width - AppConfig.pageMargin * 2 - 24) / 3,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: active ? AppConfig.cardBg : AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), boxShadow: AppConfig.cardShadow),
      child: Column(children: [
        Text(b.emoji, style: TextStyle(fontSize: 28, color: active ? null : Colors.black26)),
        const SizedBox(height: 8),
        Text(b.title, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: active ? AppConfig.textPrimary : AppConfig.textSecondary)),
        const SizedBox(height: 4),
        Text(b.desc, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: AppConfig.textSecondary)),
      ]),
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
"""


# ============================================================
# 3. trip_plan_page.dart
# ============================================================
trip_plan = """
/// V7.5 &#20986;&#34892;&#35745;&#21010;
class TripPlanPage extends StatefulWidget {
  const TripPlanPage({super.key});
  @override
  State<TripPlanPage> createState() => _TripPlanPageState();
}

class _TripPlanPageState extends State<TripPlanPage> {
  final _plans = <_TripPlan>[
    _TripPlan(emoji: '\u{1f6b4}', title: '\u{73af}\u{897f}\u{6e56}\u{9a91}\u{884c}', date: '2026-05-15', route: '\u{897f}\u{6e56}\u{4e1c}\u{73af}\u{7ebf}', distance: 42.6, status: '\u{5373}\u{5c06}\u{51fa}\u{53d1}'),
    _TripPlan(emoji: '\u{1f3d4}', title: '\u{83ab}\u{5e72}\u{5c71}\u{767b}\u{9876}', date: '2026-05-24', route: '\u{83ab}\u{5e72}\u{5c71}\u{5317}\u{7ebf}', distance: 68.3, status: '\u{8ba1}\u{5212}\u{4e2d}'),
    _TripPlan(emoji: '\u{1f332}', title: '\u{5343}\u{5c9b}\u{6e56}\u{63a2}\u{5e7d}', date: '2026-06-08', route: '\u{5343}\u{5c9b}\u{6e56}\u{73af}\u{7ebf}', distance: 140.0, status: '\u{8ba1}\u{5212}\u{4e2d}'),
  ];

  @override
  Widget build(BuildContext context) {
    final upcoming = _plans.where((p) => p.date.compareTo('2026-05-10') >= 0).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final past = _plans.where((p) => p.date.compareTo('2026-05-10') < 0).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(
        backgroundColor: AppConfig.cardBg,
        title: const Text('\u{1f4c5} \u{51fa}\u{884c}\u{8ba1}\u{5212}', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
        actions: [IconButton(icon: const Icon(Icons.add_circle_outline, color: AppConfig.primary), onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('\u{65b0}\u{5efa}\u{8ba1}\u{5212}\u{529f}\u{80fd}\u{5f00}\u{53d1}\u{4e2d}'))); })],
      ),
      body: ListView(padding: const EdgeInsets.all(AppConfig.pageMargin), children: [
        if (upcoming.isNotEmpty) ...[
          const Text('\u{5373}\u{5c06}\u{51fa}\u{53d1}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConfig.primary)),
          const SizedBox(height: 10),
          ...upcoming.map((p) => _buildPlanCard(p, true)),
          const SizedBox(height: 24),
        ],
        if (past.isNotEmpty) ...[
          const Text('\u{5df2}\u{5b8c}\u{6210}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConfig.textSecondary)),
          const SizedBox(height: 10),
          ...past.map((p) => _buildPlanCard(p, false)),
        ],
        if (_plans.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(48), child: Text('\u{6682}\u{65e0}\u{8ba1}\u{5212}\uff0c\u{70b9}\u{51fb}\u{53f3}\u{4e0a}\u{89d2}\u{65b0}\u{5efa}', style: TextStyle(fontSize: 13, color: AppConfig.textSecondary)))),
        const SizedBox(height: 100),
      ]),
    );
  }

  Widget _buildPlanCard(_TripPlan p, bool upcoming) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), boxShadow: AppConfig.cardShadow),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: (upcoming ? AppConfig.primary : AppConfig.textSecondary).withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Center(child: Text(p.emoji, style: const TextStyle(fontSize: 22)))),
        title: Text(p.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 4),
          Text('\u{1f4c5} ${p.date}  \u{1f4cd} ${p.route}', style: const TextStyle(fontSize: 11, color: AppConfig.textSecondary)),
          Text('\u{8ddd}\u{79bb}: ${p.distance.toStringAsFixed(1)}km', style: const TextStyle(fontSize: 11, color: AppConfig.textSecondary)),
        ]),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: upcoming ? AppConfig.primary.withOpacity(0.1) : Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
          child: Text(p.status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: upcoming ? AppConfig.primary : AppConfig.textSecondary)),
        ),
      ),
    );
  }
}

class _TripPlan {
  final String emoji, title, date, route, status;
  final double distance;
  const _TripPlan({required this.emoji, required this.title, required this.date, required this.route, required this.distance, required this.status});
}
"""


# ============================================================
# 4. partner_activity_page.dart
# ============================================================
partner_activity = """
/// V7.5 &#25645;&#23376;&#21160;&#24577;
class PartnerActivityPage extends StatefulWidget {
  const PartnerActivityPage({super.key});
  @override
  State<PartnerActivityPage> createState() => _PartnerActivityPageState();
}

class _PartnerActivityPageState extends State<PartnerActivityPage> {
  final _activities = [
    _PA('Kevin', '\u{1f6b4}', '\u{73af}\u{897f}\u{6e56}\u{9a91}\u{884c}', '\u{5b8c}\u{6210}\u{4e86} 42.6km \u{9a91}\u{884c}', '2 \u{5c0f}\u{65f6}\u{524d}', '\u{2714} \u{5b8c}\u{6210}'),
    _PA('\u{5c0f}\u{660e}', '\u{1f3d4}', '\u{9f99}\u{4e95}\u{722c}\u{5761}', '\u{5373}\u{5c06}\u{51fa}\u{53d1}\u{2014}\u{2014}\u{8fd8}\u{7f3a}2\u{4eba}', '30 \u{5206}\u{949f}\u{524d}', '\u{52a0}\u{5165}'),
    _PA('\u{963f}\u{7ef4}', '\u{1f4f8}', '\u{4e4b}\u{6c5f}\u{8def}\u{62cd}\u{7167}', '\u{5206}\u{4eab}\u{4e86}\u{4e00}\u{6bb5}\u{65e5}\u{843d}\u{89c6}\u{9891}', '1 \u{5c0f}\u{65f6}\u{524d}', '\u{67e5}\u{770b}'),
    _PA('Luna', '\u{1f525}', '\u{5948}\u{4f55}\u{591c}\u{9a91}', '\u{7ec4}\u{961f}\u{4e2d}\u{2014}\u{2014}\u{4eca}\u{665a}20:00\u{51fa}\u{53d1}', '3 \u{5c0f}\u{65f6}\u{524d}', '\u{52a0}\u{5165}'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(
        backgroundColor: AppConfig.cardBg,
        title: const Text('\u{1f91d} \u{642d}\u{5b50}\u{52a8}\u{6001}', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppConfig.pageMargin),
        itemCount: _activities.length,
        itemBuilder: (_, i) => _buildCard(_activities[i], i),
      ),
    );
  }

  Widget _buildCard(_PA a, int index) {
    final isGroup = a.action == '\u{52a0}\u{5165}';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), boxShadow: AppConfig.cardShadow),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(radius: 20, backgroundColor: AppConfig.primary.withOpacity(0.15), child: Text(a.emoji, style: const TextStyle(fontSize: 18))),
        title: Row(children: [
          Text(a.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
          const Spacer(),
          Text(a.time, style: const TextStyle(fontSize: 10, color: AppConfig.textSecondary)),
        ]),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 4),
          Text('\u{1f4cd} ${a.route}', style: const TextStyle(fontSize: 11, color: AppConfig.textSecondary)),
          Text(a.desc, style: const TextStyle(fontSize: 12, color: AppConfig.textPrimary)),
        ]),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isGroup ? AppConfig.primary.withOpacity(0.1) : Colors.grey.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: isGroup ? Border.all(color: AppConfig.primary.withOpacity(0.3)) : null,
          ),
          child: Text(a.action, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isGroup ? AppConfig.primary : AppConfig.textSecondary)),
        ),
      ),
    );
  }
}

class _PA {
  final String name, emoji, route, desc, time, action;
  const _PA(this.name, this.emoji, this.route, this.desc, this.time, this.action);
}
"""


# ============================================================
# 5. favorite_routes_page.dart
# ============================================================
favorite_routes = """
/// V7.5 &#25910;&#34255;&#36335;&#32447;
class FavoriteRoutesPage extends StatelessWidget {
  const FavoriteRoutesPage({super.key});

  final _routes = const [
    _FR('\u{1f6b4}', '\u{897f}\u{6e56}\u{4e1c}\u{73af}\u{7ebf}', 42.6, 620, '\u{4e2d}\u{7b49}', '\u{676d}\u{5dde} \u00b7 \u{897f}\u{6e56}'),
    _FR('\u{1f3d4}', '\u{9f99}\u{4e95}\u{722c}\u{5761}\u{8def}\u{7ebf}', 18.5, 480, '\u{8f83}\u{96be}', '\u{676d}\u{5dde} \u00b7 \u{9f99}\u{4e95}'),
    _FR('\u{1f332}', '\u{5343}\u{5c9b}\u{6e56}\u{73af}\u{6e56}\u{7ebf}', 140.0, 2100, '\u{56f0}\u{96be}', '\u{676d}\u{5dde} \u00b7 \u{6df3}\u{5b89}'),
    _FR('\u{1f30a}', '\u{6cbf}\u{6c5f}\u{6ee8}\u{6c5f}\u{7ebf}', 26.8, 180, '\u{7b80}\u{5355}', '\u{676d}\u{5dde} \u00b7 \u{94b1}\u{5858}'),
    _FR('\u{1f31f}', '\u{6885}\u{5bb6}\u{575e}\u{8336}\u{56ed}\u{7ebf}', 35.2, 350, '\u{4e2d}\u{7b49}', '\u{676d}\u{5dde} \u00b7 \u{6885}\u{5bb6}\u{575e}'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(
        backgroundColor: AppConfig.cardBg,
        title: const Text('\u{2b50} \u{5e38}\u{7528}\u{8def}\u{7ebf}', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
      ),
      body: _routes.isEmpty
          ? const Center(child: Text('\u{8fd8}\u{6ca1}\u{6709}\u{6536}\u{85cf}\u{7684}\u{8def}\u{7ebf}', style: TextStyle(fontSize: 13, color: AppConfig.textSecondary)))
          : ListView.builder(
              padding: const EdgeInsets.all(AppConfig.pageMargin),
              itemCount: _routes.length,
              itemBuilder: (_, i) => _buildCard(_routes[i]),
            ),
    );
  }

  Widget _buildCard(_FR r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), boxShadow: AppConfig.cardShadow),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: AppConfig.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Center(child: Text(r.emoji, style: const TextStyle(fontSize: 22)))),
        title: Text(r.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
        subtitle: Text('\u{1f4cd} ${r.location}  \u{1f4cf} ${r.distance.toStringAsFixed(1)}km  \u{26f0} ${r.climb}m  \u{1f396} ${r.difficulty}', style: const TextStyle(fontSize: 11, color: AppConfig.textSecondary)),
        trailing: const Icon(Icons.chevron_right, color: AppConfig.textSecondary),
      ),
    );
  }
}

class _FR {
  final String emoji, name, difficulty, location;
  final double distance;
  final int climb;
  const _FR(this.emoji, this.name, this.distance, this.climb, this.difficulty, this.location);
}
"""


# ============================================================
# 6. cycling_video_page.dart
# ============================================================
cycling_video = """
/// V7.5 &#39569;&#34892;&#30701;&#29255; (stub)
class CyclingVideoPage extends StatefulWidget {
  const CyclingVideoPage({super.key});
  @override
  State<CyclingVideoPage> createState() => _CyclingVideoPageState();
}

class _CyclingVideoPageState extends State<CyclingVideoPage> {
  final _clips = [
    _Clip('\u{1f6b4} \u{73af}\u{897f}\u{6e56}\u{7eaa}\u{5f55}', '2026-05-08', '\u{65f6}\u{957f}: 2:34  \u{8ddd}\u{79bb}: 42.6km', true),
    _Clip('\u{1f31f} \u{591c}\u{9a91}\u{5948}\u{4f55}', '2026-05-05', '\u{65f6}\u{957f}: 1:48  \u{8ddd}\u{79bb}: 28.3km', true),
    _Clip('\u{1f332} \u{5343}\u{5c9b}\u{6e56}\u{63a2}\u{5e7d}', '2026-04-28', '\u{65f6}\u{957f}: 5:12  \u{8ddd}\u{79bb}: 140.0km', false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(
        backgroundColor: AppConfig.cardBg,
        title: const Text('\u{1f3ac} \u{9a91}\u{884c}\u{77ed}\u{7247}', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
        actions: [TextButton(onPressed: () {}, child: const Text('\u{5168}\u{90e8}', style: TextStyle(fontSize: 13, color: AppConfig.primary)))],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(AppConfig.pageMargin),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.85),
        itemCount: _clips.length,
        itemBuilder: (_, i) => _buildClip(_clips[i]),
      ),
    );
  }

  Widget _buildClip(_Clip c) {
    return GestureDetector(
      onTap: c.generated ? () { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('\u{64ad}\u{653e}: ${c.title}'))); } : null,
      child: Container(
        decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), boxShadow: AppConfig.cardShadow),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: c.generated ? AppConfig.primary.withOpacity(0.08) : Colors.grey.withOpacity(0.08),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Center(
                child: c.generated
                    ? const Icon(Icons.play_circle_fill, size: 40, color: AppConfig.primary)
                    : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.auto_awesome, size: 28, color: AppConfig.textSecondary),
                        SizedBox(height: 4),
                        Text('\u{70b9}\u{51fb}\u{751f}\u{6210}', style: TextStyle(fontSize: 10, color: AppConfig.textSecondary)),
                      ]),
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
            const SizedBox(height: 4),
            Text(c.meta, style: const TextStyle(fontSize: 9, color: AppConfig.textSecondary)),
          ])),
        ]),
      ),
    );
  }
}

class _Clip {
  final String title, date, meta;
  final bool generated;
  const _Clip(this.title, this.date, this.meta, this.generated);
}
"""


# ============================================================
# 7. cycling_accounting_page.dart
# ============================================================
cycling_accounting = """
/// V7.5 &#39569;&#34892;&#35760;&#36134;
class CyclingAccountingPage extends StatefulWidget {
  const CyclingAccountingPage({super.key});
  @override
  State<CyclingAccountingPage> createState() => _CyclingAccountingPageState();
}

class _CyclingAccountingPageState extends State<CyclingAccountingPage> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  final _expenses = [
    _Expense('\u{1f6b2} \u{65b0}\u{8f66}', 4999, '\u{88c5}\u{5907}', '2026-04-15', '\u{8d2d}\u{4e70} Specialized Allez'),
    _Expense('\u{26f0} \u{5343}\u{5c9b}\u{6e56}\u{65c5}\u{884c}', 1280, '\u{51fa}\u{884c}', '2026-04-28', '\u{4f4f}\u{5bbf}+\u{996e}\u{98df}+\u{95e8}\u{7968}'),
    _Expense('\u{1f50c} \u{94fe}\u{6761}\u{6e05}\u{6d01}', 88, '\u{4fdd}\u{517b}', '2026-05-02', '\u{94fe}\u{6761}\u{6d17}\u{62a4}\u{5957}\u{88c5}'),
    _Expense('\u{1f9e2} \u{9a91}\u{884c}\u{88e4}', 299, '\u{88c5}\u{5907}', '2026-05-05', '\u{590f}\u{5b63}\u{9a91}\u{884c}\u{88e4}'),
    _Expense('\u{1f3d4} \u{83ab}\u{5e72}\u{5c71}\u{8def}\u{9910}', 320, '\u{51fa}\u{884c}', '2026-05-10', '\u{4e2d}\u{9014}\u{8865}\u{7ed9}+\u{5348}\u{9910}'),
    _Expense('\u{1f6f4} \u{8f6e}\u{80ce}\u{66f4}\u{6362}', 356, '\u{4fdd}\u{517b}', '2026-05-08', '\u{524d}\u{540e}\u{8f6e}\u{80ce}\u{66f4}\u{6362}'),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  double get _total => _expenses.fold(0, (s, e) => s + e.amount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(
        backgroundColor: AppConfig.cardBg,
        title: const Text('\u{1f4b0} \u{9a91}\u{884c}\u{8bb0}\u{8d26}', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: TabBar(
            controller: _tabCtrl,
            labelColor: AppConfig.textPrimary,
            unselectedLabelColor: AppConfig.textSecondary,
            indicatorColor: AppConfig.primary,
            tabs: const [Tab(text: '\u{5168}\u{90e8}'), Tab(text: '\u{88c5}\u{5907}'), Tab(text: '\u{4fdd}\u{517b}')],
          ),
        ),
        actions: [IconButton(icon: const Icon(Icons.add_circle_outline, color: AppConfig.primary), onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('\u{8bb0}\u{8d26}\u{529f}\u{80fd}\u{5f00}\u{53d1}\u{4e2d}'))); })],
      ),
      body: Column(children: [
        _buildTotalHeader(),
        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: [
              _buildList(null),
              _buildList('\u{88c5}\u{5907}'),
              _buildList('\u{4fdd}\u{517b}'),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildTotalHeader() {
    return Container(
      width: double.infinity, margin: const EdgeInsets.all(AppConfig.pageMargin),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), boxShadow: AppConfig.cardShadow),
      child: Row(children: [
        const Text('\u{672c}\u{6708}\u{603b}\u{652f}\u{51fa}', style: TextStyle(fontSize: 13, color: AppConfig.textSecondary)),
        const Spacer(),
        Text('\u{00a5}${_total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppConfig.primary)),
      ]),
    );
  }

  Widget _buildList(String? category) {
    final items = category == null ? _expenses : _expenses.where((e) => e.category == category).toList();
    if (items.isEmpty) return const Center(child: Text('\u{6682}\u{65e0}\u{8bb0}\u{5f55}', style: TextStyle(fontSize: 13, color: AppConfig.textSecondary)));
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
      itemCount: items.length,
      itemBuilder: (_, i) => _buildItem(items[i]),
    );
  }

  Widget _buildItem(_Expense e) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), boxShadow: AppConfig.cardShadow),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(width: 38, height: 38, decoration: BoxDecoration(color: AppConfig.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Center(child: Text(e.emoji.split(' ').last, style: const TextStyle(fontSize: 16)))),
        title: Text(e.emoji.split(' ').first, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
        subtitle: Text('\u{1f4c5} ${e.date}  ${e.note}', style: const TextStyle(fontSize: 10, color: AppConfig.textSecondary)),
        trailing: Text('\u{00a5}${e.amount}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
      ),
    );
  }
}

class _Expense {
  final String emoji, category, date, note;
  final int amount;
  const _Expense(this.emoji, this.amount, this.category, this.date, this.note);
}
"""


# ============================================================
# 8. maintenance_reminder_page.dart
# ============================================================
maintenance_reminder = """
/// V7.5 &#20445;&#20859;&#25552;&#37266;
class MaintenanceReminderPage extends StatefulWidget {
  const MaintenanceReminderPage({super.key});
  @override
  State<MaintenanceReminderPage> createState() => _MaintenanceReminderPageState();
}

class _MaintenanceReminderPageState extends State<MaintenanceReminderPage> {

  final _reminders = [
    _Reminder('\u{1f517}', '\u{94fe}\u{6761}\u{4e0a}\u{6cb9}', '\u{6bcf}200-300km\u{4e0a}\u{6cb9}\u{4e00}\u{6b21}', '2 \u{5929}\u{540e}', true, 200, 185),
    _Reminder('\u{1f6f4}', '\u{8f6e}\u{80ce}\u{68c0}\u{67e5}', '\u{68c0}\u{67e5}\u{80ce}\u{538b}\u{3001}\u{78e8}\u{635f}\u{3001}\u{88c2}\u{7f1d}', '5 \u{5929}\u{540e}', true, 500, 420),
    _Reminder('\u{1f6bf}', '\u{5239}\u{8f66}\u{68c0}\u{67e5}', '\u{68c0}\u{67e5}\u{6765}\u{4ee4}\u{7247}\u{78e8}\u{635f}\u{3001}\u{5239}\u{8f66}\u{7ebf}\u{5f20}\u{529b}', '7 \u{5929}\u{540e}', false, 800, 780),
    _Reminder('\u{2699}', '\u{53d8}\u{901f}\u{8c03}\u{6821}', '\u{68c0}\u{67e5}\u{53d8}\u{901f}\u{7cbe}\u{51c6}\u{5ea6}\u{3001}\u{7ebf}\u{7ba1}\u{6da6}\u{6ed1}', '14 \u{5929}\u{540e}', false, 1000, 920),
    _Reminder('\u{1f4e6}', '\u{6574}\u{8f66}\u{68c0}\u{67e5}', '\u{5168}\u{8f66}\u{87ba}\u{4e1d}\u{62e7}\u{7d27}\u{3001}\u{8f74}\u{627f}\u{6da6}\u{6ed1}', '30 \u{5929}\u{540e}', false, 2000, 1850),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(
        backgroundColor: AppConfig.cardBg,
        title: const Text('\u{1f527} \u{4fdd}\u{517b}\u{63d0}\u{9192}', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
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
      decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), boxShadow: AppConfig.cardShadow),
      child: Row(children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFFE74C3C).withOpacity(0.1), borderRadius: BorderRadius.circular(24)), child: const Center(child: Icon(Icons.warning_amber_rounded, color: Color(0xFFE74C3C), size: 24))),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$urgent \u{9879}\u{5f85}\u{5904}\u{7406}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
          const Text('\u{5b9a}\u{671f}\u{4fdd}\u{517b}\u{786e}\u{4fdd}\u{9a91}\u{884c}\u{5b89}\u{5168}', style: TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
        ]),
      ]),
    );
  }

  Widget _buildCard(_Reminder r) {
    final pct = r.intervalKm > 0 ? r.currentKm / r.intervalKm : 0.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), boxShadow: AppConfig.cardShadow),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(r.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(child: Text(r.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConfig.textPrimary))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: r.urgent ? const Color(0xFFE74C3C).withOpacity(0.1) : Colors.grey.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
              child: Text(r.due, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: r.urgent ? const Color(0xFFE74C3C) : AppConfig.textSecondary)),
            ),
          ]),
          const SizedBox(height: 8),
          Text(r.desc, style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: pct.clamp(0.0, 1.0), backgroundColor: Colors.grey.withOpacity(0.1), color: r.urgent ? const Color(0xFFE74C3C) : AppConfig.primary, minHeight: 4),
          ),
          const SizedBox(height: 4),
          Text('\u{5df2}\u{9a91}\u{884c} ${r.currentKm} / ${r.intervalKm} km', style: const TextStyle(fontSize: 10, color: AppConfig.textSecondary)),
        ]),
      ),
    );
  }
}

class _Reminder {
  final String emoji, title, desc, due;
  final bool urgent;
  final int intervalKm, currentKm;
  const _Reminder(this.emoji, this.title, this.desc, this.due, this.urgent, this.intervalKm, this.currentKm);
}
"""


# ============================================================
# 9. golden_hour_page.dart
# ============================================================
golden_hour = """
/// V7.5 &#40644;&#37329;&#26102;&#21051; &#8212; &#26085;&#20986;&#26085;&#33853;&#12289;&#34013;&#35843;&#12289;&#37329;&#33394;&#26102;&#21051;
class GoldenHourPage extends StatelessWidget {
  const GoldenHourPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(
        backgroundColor: AppConfig.cardBg,
        title: const Text('\u{1f305} \u{9ec4}\u{91d1}\u{65f6}\u{523b}', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConfig.pageMargin),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildTodayCard(),
          const SizedBox(height: 20),
          const Text('\u{672c}\u{5468}\u{9884}\u{62a5}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
          const SizedBox(height: 10),
          ...List.generate(7, (i) => _buildDayRow(i)),
          const SizedBox(height: 100),
        ]),
      ),
    );
  }

  Widget _buildTodayCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFF6B35), Color(0xFFF7C948), Color(0xFF3498DB)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(AppConfig.cardRadiusLg),
      ),
      child: Column(children: [
        const Text('\u{4eca}\u{5929} 5\u{6708}10\u{65e5}', style: TextStyle(fontSize: 12, color: Colors.white70)),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _buildTimeBlock('\u{1f307}', '\u{65e5}\u{51fa}', '05:12', '\u{84dd}\u{8c03}\u{65f6}\u{523b}'),
          _buildTimeBlock('\u{2600}', '\u{91d1}\u{8272}\u{65f6}\u{523b}', '05:42-06:36', '\u{6700}\u{4f73}\u{62cd}\u{6444}'),
          _buildTimeBlock('\u{1f306}', '\u{65e5}\u{843d}', '18:46', '\u{91d1}\u{8272}\u{65f6}\u{523b}'),
        ]),
      ]),
    );
  }

  Widget _buildTimeBlock(String emoji, String label, String time, String sub) {
    return Column(children: [
      Text(emoji, style: const TextStyle(fontSize: 28)),
      const SizedBox(height: 6),
      Text(time, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
      Text(sub, style: const TextStyle(fontSize: 9, color: Colors.white54)),
    ]);
  }

  Widget _buildDayRow(int offset) {
    final now = DateTime.now();
    final d = now.add(Duration(days: offset));
    final days = ['\u{4eca}\u{5929}', '\u{660e}\u{5929}', '\u{5468}\u{4e8c}', '\u{5468}\u{4e09}', '\u{5468}\u{56db}', '\u{5468}\u{4e94}', '\u{5468}\u{516d}'];
    final sunrise = '${(5 + offset % 2).toString().padLeft(2, '0')}:${(12 + offset * 3 % 60).toString().padLeft(2, '0')}';
    final sunset = '${(18 + offset % 2).toString().padLeft(2, '0')}:${(46 - offset * 2 % 60).toString().padLeft(2, '0')}';
    final isToday = offset == 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isToday ? AppConfig.primary.withOpacity(0.05) : AppConfig.cardBg,
        borderRadius: BorderRadius.circular(AppConfig.cardRadius),
        boxShadow: isToday ? null : AppConfig.cardShadow,
        border: isToday ? Border.all(color: AppConfig.primary.withOpacity(0.2)) : null,
      ),
      child: Row(children: [
        Text('${d.month}/${d.day} ${days[offset]}', style: TextStyle(fontSize: 13, fontWeight: isToday ? FontWeight.w700 : FontWeight.w400, color: AppConfig.textPrimary)),
        const Spacer(),
        const Icon(Icons.wb_twilight, size: 16, color: Color(0xFFF39C12)),
        const SizedBox(width: 4),
        Text(sunrise, style: const TextStyle(fontSize: 13, color: AppConfig.textPrimary)),
        const SizedBox(width: 16),
        const Icon(Icons.wb_sunny, size: 16, color: Color(0xFFE74C3C)),
        const SizedBox(width: 4),
        Text(sunset, style: const TextStyle(fontSize: 13, color: AppConfig.textPrimary)),
      ]),
    );
  }
}
"""


# ============================================================
# 10. cycling_advice_page.dart
# ============================================================
cycling_advice = """
/// V7.5 &#39569;&#34892;&#24314;&#35758;
class CyclingAdvicePage extends StatelessWidget {
  const CyclingAdvicePage({super.key});

  final _tips = const [
    _Tip('\u{1f331}', '\u{6625}\u{5b63}\u{9a91}\u{884c}', '\u{6e29}\u{5dee}\u{5927}\u{65f6}\u{6ce8}\u{610f}\u{5206}\u{5c42}\u{7a7f}\u{7740}\u{3001}\u{9632}\u{6c34}\u{5939}\u{514b}\u{968f}\u{8eab}\u{643a}\u{5e26}\u{3001}\u{6ce8}\u{610f}\u{6c47}\u{805a}\u{67f3\u98de}\u{7d6e}\u{3001}\u{65b0}\u{624b}\u{9002}\u{5408}\u{77ed}\u{9014}\u{9002}\u{5e94}'),
    _Tip('\u{2600}', '\u{590f}\u{5b63}\u{9a91}\u{884c}', '\u{907f}\u{5f00}\u{6b63}\u{5348}\u{65f6}\u{6bb5}\u{3001}\u{591a}\u{8865}\u{6c34}\u{548c}\u{7535}\u{89e3}\u{8d28}\u{3001}\u{9632}\u{6652}\u{88c5}\u{5907}\u{5fc5}\u{4e0d}\u{53ef}\u{5c11}\u{3001}\u{6ce8}\u{610f}\u{4e2d}\u{6691}\u{75c7}\u{72b6}'),
    _Tip('\u{1f342}', '\u{79cb}\u{5b63}\u{9a91}\u{884c}', '\u{6700}\u{4f73}\u{9a91}\u{884c}\u{5b63}\u{8282}\u{3001}\u{8def}\u{9762}\u{843d}\u{53f6}\u{53ef}\u{80fd}\u{6e7f}\u{6ed1}\u{3001}\u{65e5}\u{7167}\u{7f29}\u{77ed}\u{6ce8}\u{610f}\u{7167}\u{660e}\u{3001}\u{5c42}\u{5c42}\u{53e0}\u{7a7f}\u{65b9}\u{4fbf}\u{8131}\u{7a7f}'),
    _Tip('\u{2744}', '\u{51ac}\u{5b63}\u{9a91}\u{884c}', '\u{4fdd}\u{6696}\u{4f18}\u{5148}\u{3001}\u{964d}\u{4f4e}\u{80ce}\u{538b}\u{589e}\u{52a0}\u{6293}\u{5730}\u{529b}\u{3001}\u{72ed}\u{80ce}\u{66f4}\u{5b89}\u{5168}\u{3001}\u{6ce8}\u{610f}\u{8def}\u{9762}\u{7ed3}\u{51b0}'),
    _Tip('\u{1f4cf}', '\u{957f}\u{9014}\u{9a91}\u{884c}', '\u{63d0}\u{524d}\u{89c4}\u{5212}\u{8def}\u{7ebf}\u{3001}\u{5907}\u{8db3}\u{8865}\u{7ed9}\u{3001}\u{6bcf}\u{5c0f}\u{65f6}\u{4f11}\u{606f}10\u{5206}\u{949f}\u{3001}\u{6440}\u{5f71}\u{5206}\u{4eab}\u{4f4d}\u{7f6e}'),
    _Tip('\u{1f9e0}', '\u{65b0}\u{624b}\u{5165}\u{95e8}', '\u{4ece}10km\u{5f00}\u{59cb}\u{9010}\u{6b65}\u{589e}\u{52a0}\u{3001}\u{6b63}\u{786e}\u{8c03}\u{6574}\u{5ea7}\u{9ad8}\u{3001}\u{5b66}\u{4e60}\u{57fa}\u{672c}\u{4fee}\u{8865}\u{3001}\u{52a0}\u{5165}\u{9a91}\u{884c}\u{793e}\u{7fa4}'),
    _Tip('\u{1f4aa}', '\u{4f53}\u{80fd}\u{63d0}\u{5347}', '\u{95f4}\u{6b47}\u{8bad}\u{7ec3}\u{63d0}\u{5347}\u{5feb}\u{3001}\u{6838}\u{5fc3}\u{8bad}\u{7ec3}\u{4f18}\u{5148}\u{3001}\u{8ba1}\u{5212}\u{4f11}\u{606f}\u{65e5}\u{3001}\u{8bb0}\u{5f55}\u{8bad}\u{7ec3}\u{6570}\u{636e}'),
    _Tip('\u{1f37d}', '\u{9a91}\u{884c}\u{996e}\u{98df}', '\u{9a91}\u{884c}\u{524d}1-2\u{5c0f}\u{65f6}\u{8fdb}\u{98df}\u{3001}\u{9014}\u{4e2d}\u{6bcf}30\u{5206}\u{949f}\u{8865}\u{5145}\u{78b3}\u{6c34}\u{3001}\u{9a91}\u{884c}\u{540e}\u{8865}\u{5145}\u{86cb}\u{767d}\u{8d28}'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(
        backgroundColor: AppConfig.cardBg,
        title: const Text('\u{1f4a1} \u{9a91}\u{884c}\u{5efa}\u{8bae}', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppConfig.pageMargin),
        itemCount: _tips.length,
        itemBuilder: (_, i) => _buildCard(_tips[i]),
      ),
    );
  }

  Widget _buildCard(_Tip t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), boxShadow: AppConfig.cardShadow),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: AppConfig.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Center(child: Text(t.emoji, style: const TextStyle(fontSize: 22)))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
            const SizedBox(height: 6),
            Text(t.content, style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary, height: 1.5)),
          ])),
        ]),
      ),
    );
  }
}

class _Tip {
  final String emoji, title, content;
  const _Tip(this.emoji, this.title, this.content);
}
"""


# ============================================================
# Write all files
# ============================================================
pages = [
    ('cycling_stats_page.dart', cycling_stats),
    ('my_achievements_page.dart', my_achievements),
    ('trip_plan_page.dart', trip_plan),
    ('partner_activity_page.dart', partner_activity),
    ('favorite_routes_page.dart', favorite_routes),
    ('cycling_video_page.dart', cycling_video),
    ('cycling_accounting_page.dart', cycling_accounting),
    ('maintenance_reminder_page.dart', maintenance_reminder),
    ('golden_hour_page.dart', golden_hour),
    ('cycling_advice_page.dart', cycling_advice),
]

for name, code in pages:
    write_dart(name, code)

print(f'\n{len(pages)} pages written successfully.')