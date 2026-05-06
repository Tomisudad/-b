import 'package:flutter/material.dart';
import '../config/app_config.dart';

/// V5.2 个人中心 — 两列网格入口 + 足迹地图 + 设置
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _statsVisible = false;
  bool _gridVisible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () { if (mounted) setState(() => _statsVisible = true); });
    Future.delayed(const Duration(milliseconds: 500), () { if (mounted) setState(() => _gridVisible = true); });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(title: const Text('我的', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)), actions: [IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {})]),
      body: ListView(padding: const EdgeInsets.fromLTRB(AppConfig.pageMargin, 8, AppConfig.pageMargin, AppConfig.pageMargin), children: [
        _buildProfileCard(),
        const SizedBox(height: AppConfig.cardGap),
        _buildStats(),
        const SizedBox(height: AppConfig.cardGap),
        _buildMenuGrid(),
        const SizedBox(height: AppConfig.cardGap),
        _buildFootprintMap(),
        const SizedBox(height: AppConfig.cardGap),
        _buildProgressCard(),
        const SizedBox(height: AppConfig.cardGap),
        _buildSettings(),
      ]),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFF0C040), Color(0xFFE67E22)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(AppConfig.cardRadius), boxShadow: AppConfig.cardShadow),
      child: Row(children: [
        Container(width: 56, height: 56, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)), child: const CircleAvatar(backgroundColor: Colors.white, child: Text('山', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFFE67E22))))),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('山野行者', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 4),
          const Text('读万卷书，行万里路', style: TextStyle(fontSize: 13, color: Colors.white70)),
          const SizedBox(height: 6),
          Row(children: [_tag('Lv.12'), const SizedBox(width: 8), _tag('骑行达人'), const SizedBox(width: 8), _tag('128篇')]),
        ])),
        const Icon(Icons.chevron_right, color: Colors.white70),
      ]),
    );
  }

  Widget _tag(String text) => Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(4)), child: Text(text, style: const TextStyle(fontSize: 10, color: Colors.white)));

  Widget _buildStats() {
    return AnimatedOpacity(opacity: _statsVisible ? 1 : 0, duration: const Duration(milliseconds: 400), child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), boxShadow: AppConfig.cardShadow),
      child: Row(children: [
        _stat(Icons.route_outlined, '42', '路线', AppConfig.cyclePrimary),
        _stat(Icons.timeline_outlined, '156', '轨迹', AppConfig.motoPrimary),
        _stat(Icons.emoji_events_outlined, '8', '勋章', AppConfig.goldStart),
        _stat(Icons.explore_outlined, '23', '点亮区县', AppConfig.drivePrimary),
      ]),
    ));
  }

  Widget _stat(IconData icon, String v, String l, Color c) => Expanded(child: Column(children: [Icon(icon, size: 20, color: c), const SizedBox(height: 4), Text(v, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: c)), Text(l, style: const TextStyle(fontSize: 11, color: AppConfig.textSecondary))]));

  Widget _buildMenuGrid() {
    final items = [
      _MI(Icons.route_outlined, '路线规划', AppConfig.cyclePrimary, () {}, '42'),
      _MI(Icons.timeline_outlined, '我的轨迹', AppConfig.motoPrimary, () {}, '156'),
      _MI(Icons.star_outlined, '我的收藏', AppConfig.goldStart, () {}, '35'),
      _MI(Icons.emoji_events_outlined, '勋章', AppConfig.goldStart, () {}, '8'),
      _MI(Icons.public_outlined, '足迹地图', AppConfig.drivePrimary, () {}, '23'),
      _MI(Icons.auto_awesome_outlined, '年度报告', const Color(0xFF9C27B0), () {}),
      _MI(Icons.edit_note_outlined, '我的创作', AppConfig.textSecondary, () {}, '12'),
      _MI(Icons.leaderboard_outlined, '排行榜', AppConfig.cyclePrimary, () {}),
    ];
    return AnimatedOpacity(opacity: _gridVisible ? 1 : 0, duration: const Duration(milliseconds: 500), child: GridView.builder(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.85),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        return GestureDetector(
          onTap: item.onTap,
          child: Container(decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), boxShadow: AppConfig.cardShadow), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: item.color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(item.icon, size: 18, color: item.color)),
            const SizedBox(height: 6),
            Text(item.label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppConfig.textPrimary)),
            if (item.count.isNotEmpty) Text(item.count, style: TextStyle(fontSize: 10, color: item.color)),
          ])),
        );
      },
    ));
  }

  Widget _buildFootprintMap() {
    return Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), boxShadow: AppConfig.cardShadow), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [Text('足迹地图', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)), SizedBox(width: 6), Text('23个区县', style: TextStyle(fontSize: 12, color: AppConfig.textSecondary))]),
      const SizedBox(height: 10),
      Container(height: 140, decoration: BoxDecoration(color: AppConfig.drivePrimary.withOpacity(0.04), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppConfig.drivePrimary.withOpacity(0.1))), child: Center(child: Text('中国地图 · 23区县已点亮', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppConfig.drivePrimary.withOpacity(0.6))))),
      const SizedBox(height: 8),
      Wrap(spacing: 4, runSpacing: 4, children: [('杭州·西湖'), ('杭州·临安'), ('湖州·德清'), ('黄山·歙县'), ('宣城·绩溪'), ('苏州·吴中'), ('湖州·安吉'), ('南京·江宁')].map((n) => Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), decoration: BoxDecoration(color: AppConfig.drivePrimary.withOpacity(0.06), borderRadius: BorderRadius.circular(4), border: Border.all(color: AppConfig.drivePrimary.withOpacity(0.1))), child: Text(n, style: const TextStyle(fontSize: 10, color: AppConfig.drivePrimary)))).toList()),
    ]));
  }

  Widget _buildProgressCard() {
    return Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), boxShadow: AppConfig.cardShadow), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('经典路线进度', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
      const SizedBox(height: 10),
      _prog('G318川藏线', 0.12, AppConfig.drivePrimary),
      _prog('青海湖环湖', 0.65, AppConfig.cyclePrimary),
      _prog('独库公路', 0.00, AppConfig.motoPrimary),
      _prog('千岛湖绿道', 1.00, AppConfig.cyclePrimary),
    ]));
  }

  Widget _prog(String name, double pct, Color color) {
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
      SizedBox(width: 80, child: Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppConfig.textPrimary))),
      Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(value: pct, backgroundColor: AppConfig.bgMain, valueColor: AlwaysStoppedAnimation(color), minHeight: 5))),
      const SizedBox(width: 8),
      Text('${(pct * 100).round()}%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: pct >= 1 ? AppConfig.cyclePrimary : AppConfig.textSecondary)),
    ]));
  }

  Widget _buildSettings() {
    return Column(children: [
      _setting(Icons.security_outlined, '账号安全', () {}),
      _setting(Icons.map_outlined, '离线地图管理', () {}),
      _setting(Icons.tune, '默认出行场景', () {}, right: '骑行'),
      _setting(Icons.notifications_outlined, '通知设置', () {}),
      _setting(Icons.privacy_tip_outlined, '隐私设置', () {}),
      _setting(Icons.storage_outlined, '缓存管理', () {}, right: '32MB'),
      _setting(Icons.info_outlined, '关于去野', () {}, right: 'v5.2.0'),
    ]);
  }

  Widget _setting(IconData icon, String label, VoidCallback onTap, {String right = ''}) {
    return Container(margin: const EdgeInsets.only(bottom: 1), child: ListTile(
      dense: true, leading: Icon(icon, size: 18, color: AppConfig.textSecondary),
      title: Text(label, style: const TextStyle(fontSize: 14, color: AppConfig.textPrimary)),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [if (right.isNotEmpty) Padding(padding: const EdgeInsets.only(right: 8), child: Text(right, style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary))), const Icon(Icons.chevron_right, size: 16, color: AppConfig.textSecondary)]),
      onTap: onTap,
    ));
  }
}

class _MI {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final String count;
  const _MI(this.icon, this.label, this.color, this.onTap, [this.count = '']);
}
