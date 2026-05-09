import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../config/scenario_config.dart';

/// V5.5 搭子页面 — 基于出行目标的精准匹配
/// 目标分类: 挑战/风景/社交/长途/探索

enum _TravelGoal { challenge, scenery, social, longHaul, explore }

extension _TravelGoalX on _TravelGoal {
  String get label => switch (this) {
    _TravelGoal.challenge => '🏆 挑战',
    _TravelGoal.scenery => '🏞️ 风景',
    _TravelGoal.social => '🎉 社交',
    _TravelGoal.longHaul => '🗺️ 长途',
    _TravelGoal.explore => '🧭 探索',
  };
  String get shortLabel => switch (this) {
    _TravelGoal.challenge => '挑战极限',
    _TravelGoal.scenery => '欣赏风景',
    _TravelGoal.social => '旅行社交',
    _TravelGoal.longHaul => '纯长途赶路',
    _TravelGoal.explore => '探索新地方',
  };
  // V6.1: 挑战铜色 / 风景蓝绿 / 社交暖橙 / 长途深蓝 / 探索紫色
  Color get color => switch (this) {
    _TravelGoal.challenge => const Color(0xFFB87333),
    _TravelGoal.scenery => const Color(0xFF0D9488),
    _TravelGoal.social => const Color(0xFFF97316),
    _TravelGoal.longHaul => const Color(0xFF1E3A5F),
    _TravelGoal.explore => const Color(0xFF7C3AED),
  };
  IconData get icon => switch (this) {
    _TravelGoal.challenge => Icons.emoji_events_outlined,
    _TravelGoal.scenery => Icons.landscape_outlined,
    _TravelGoal.social => Icons.group_outlined,
    _TravelGoal.longHaul => Icons.flight_takeoff,
    _TravelGoal.explore => Icons.explore_outlined,
  };
}

class PartnerPage extends StatefulWidget {
  const PartnerPage({super.key});
  @override
  State<PartnerPage> createState() => _PartnerPageState();
}

class _PartnerPageState extends State<PartnerPage> {
  OutdoorScenario? _filterScene;
  _TravelGoal? _filterGoal;
  bool _mapView = false;

  // V6.1 mock: 5 条精确数据（含时间、成员信息、目标宣言）
  static final List<_Buddy> _buddies = [
    _Buddy('周末骑士', OutdoorScenario.cycle, 0.8, _Status.planning, null, '每周六环西湖，固定活动。来了就能跟上。', ['入门车', '头盔'], _TravelGoal.social, time: '周六 7:00', memberInfo: '已有3人'),
    _Buddy('骑行小白', OutdoorScenario.cycle, 1.5, _Status.planning, null, '新手求带！周末西湖周边随便骑骑。', ['新手', '求带'], _TravelGoal.social, time: '周六 8:30', memberInfo: '独行'),
    _Buddy('山野骑客', OutdoorScenario.cycle, 2.3, _Status.inGroup, '环太湖', '周末环湖，不求速度求风景。已有2人，缺1人。', ['装备齐全', '对讲机'], _TravelGoal.scenery, time: '周日 6:30', memberInfo: '2/4人'),
    _Buddy('长途骑士', OutdoorScenario.cycle, 5.0, _Status.planning, '川藏线', '计划下月川藏线，找有经验队友。一起走不孤单。', ['长途', '经验丰富'], _TravelGoal.longHaul, time: '待定', memberInfo: '独行'),
    _Buddy('爬坡达人', OutdoorScenario.cycle, 3.1, _Status.planning, '龙井北坡', '龙井北坡5趟连爬，找配速相当搭子。心率不过165的勿扰。', ['公路车', '功率计'], _TravelGoal.challenge, time: '周六 5:30', memberInfo: '独行'),
  ];

  // V5.5: Sort by goal match > scene match > distance
  List<_Buddy> get _filtered {
    var list = _buddies.toList();
    if (_filterScene != null) list = list.where((b) => b.scene == _filterScene).toList();
    if (_filterGoal != null) list = list.where((b) => b.goal == _filterGoal).toList();
    // Distance-based sort as default tiebreaker
    list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final buddies = _filtered;
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          const Text('搭子', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(color: AppConfig.goldStart.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
            child: Text('${buddies.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppConfig.goldStart)),
          ),
        ]),
        actions: [
          IconButton(icon: Icon(_mapView ? Icons.list : Icons.map_outlined, color: AppConfig.textSecondary), onPressed: () => setState(() => _mapView = !_mapView)),
          IconButton(icon: const Icon(Icons.group_add_outlined, size: 20, color: AppConfig.cyclePrimary), onPressed: _showCreateTeam),
        ],
      ),
      body: Column(children: [
        _buildSceneFilter(),
        _buildGoalFilter(),
        Expanded(
          child: buddies.isEmpty
              ? _emptyState()
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
                  itemCount: buddies.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppConfig.cardGap),
                  itemBuilder: (_, i) => _buildBuddyCard(buddies[i]),
                ),
        ),
      ]),
    );
  }

  // -- 场景筛选 --
  Widget _buildSceneFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppConfig.pageMargin, 0, AppConfig.pageMargin, 6),
      child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
        _filterChip('全部', _filterScene == null, () => setState(() => _filterScene = null)),
        const SizedBox(width: 6),
        _filterChip('🚴 骑行', _filterScene == OutdoorScenario.cycle, () => setState(() => _filterScene = OutdoorScenario.cycle)),
        const SizedBox(width: 6),
        _filterChip('🏍️ 摩旅', _filterScene == OutdoorScenario.moto, () => setState(() => _filterScene = OutdoorScenario.moto)),
        const SizedBox(width: 6),
        _filterChip('🚗 自驾', _filterScene == OutdoorScenario.drive, () => setState(() => _filterScene = OutdoorScenario.drive)),
      ])),
    );
  }

  // -- 目标筛选 --
  Widget _buildGoalFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppConfig.pageMargin, 0, AppConfig.pageMargin, 10),
      child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
        _goalChip(null),
        const SizedBox(width: 6),
        ..._TravelGoal.values.map((g) => Padding(padding: const EdgeInsets.only(right: 6), child: _goalChip(g))),
      ])),
    );
  }

  Widget _filterChip(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppConfig.goldStart.withOpacity(0.1) : AppConfig.cardBg,
          borderRadius: BorderRadius.circular(AppConfig.tagRadius),
          border: Border.all(color: active ? AppConfig.goldStart : AppConfig.divider, width: active ? 1.2 : 0.8),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: active ? FontWeight.w600 : FontWeight.w400, color: active ? AppConfig.goldStart : AppConfig.textSecondary)),
      ),
    );
  }

  Widget _goalChip(_TravelGoal? goal) {
    final active = _filterGoal == goal;
    final color = goal?.color ?? AppConfig.textSecondary;
    final label = goal?.label ?? '全部目标';
    return GestureDetector(
      onTap: () => setState(() => _filterGoal = goal),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.08) : AppConfig.cardBg,
          borderRadius: BorderRadius.circular(AppConfig.tagRadius),
          border: Border.all(color: active ? color : AppConfig.divider, width: active ? 1.2 : 0.8),
        ),
        child: Text(label, style: TextStyle(fontSize: 11, fontWeight: active ? FontWeight.w600 : FontWeight.w400, color: active ? color : AppConfig.textSecondary)),
      ),
    );
  }

  // -- 搭子卡片 --
  Widget _buildBuddyCard(_Buddy buddy) {
    final color = buddy.scene.primaryColor;
    final goalColor = buddy.goal.color;
    return GestureDetector(
      onTap: () => _showBuddyDetail(buddy),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), boxShadow: AppConfig.cardShadow),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            // 头像
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(21),
                gradient: const LinearGradient(colors: [Color(0xFFF0C040), Color(0xFFE67E22)]),
              ),
              child: Center(child: Text(buddy.name[0], style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white))),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(buddy.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
                const SizedBox(width: 6),
                Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(3)), child: Text(buddy.scene.label, style: TextStyle(fontSize: 10, color: color))),
                const SizedBox(width: 6),
                buddy.status.widget,
              ]),
              const SizedBox(height: 3),
              Row(children: [
                Icon(Icons.location_on_outlined, size: 12, color: AppConfig.textSecondary.withOpacity(0.6)),
                const SizedBox(width: 3),
                Text('${buddy.distanceKm.toStringAsFixed(1)}km', style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
                // V6.1: time + member info
                if (buddy.time.isNotEmpty) ...[
                  const SizedBox(width: 10),
                  const Icon(Icons.access_time, size: 12, color: AppConfig.textSecondary),
                  const SizedBox(width: 3),
                  Text(buddy.time, style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
                ],
                const SizedBox(width: 10),
                Text(buddy.memberInfo, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: buddy.memberInfo == '独行' ? AppConfig.textSecondary : AppConfig.goldEnd)),
              ]),
            ])),
            const Icon(Icons.chevron_right, size: 18, color: AppConfig.textSecondary),
          ]),
          const SizedBox(height: 8),
          // V6.1: 目标标签（渐变背景 hint）
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [goalColor.withOpacity(0.12), goalColor.withOpacity(0.04)]),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: goalColor.withOpacity(0.15)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(buddy.goal.icon, size: 14, color: goalColor),
              const SizedBox(width: 4),
              Text(buddy.goal.shortLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: goalColor)),
            ]),
          ),
          const SizedBox(height: 6),
          Text(buddy.desc, style: const TextStyle(fontSize: 13, color: AppConfig.textPrimary, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Row(children: [
            ...buddy.tags.take(2).map((t) => Padding(padding: const EdgeInsets.only(right: 6), child: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppConfig.bgMain, borderRadius: BorderRadius.circular(4)), child: Text(t, style: const TextStyle(fontSize: 10, color: AppConfig.textSecondary))))),
            const Spacer(),
            if (buddy.route != null) ...[
              Icon(Icons.route_outlined, size: 12, color: color),
              const SizedBox(width: 3),
              Text(buddy.route!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
            ],
          ]),
          const SizedBox(height: 10),
          // V6.1: 合并"打招呼"和"组队"为"申请加入"
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showBuddyDetail(buddy),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.buttonRadius)),
                backgroundColor: AppConfig.goldStart,
                foregroundColor: Colors.white,
              ),
              child: const Text('申请加入', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _emptyState() => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 80, height: 80, decoration: BoxDecoration(color: AppConfig.goldStart.withOpacity(0.08), shape: BoxShape.circle), child: const Icon(Icons.group_outlined, size: 36, color: AppConfig.goldStart)),
    const SizedBox(height: 16),
    const Text('暂无匹配的搭子', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
    const SizedBox(height: 6),
    const Text('点击右上角 + 发起组队', style: TextStyle(fontSize: 13, color: AppConfig.textSecondary)),
  ]));

  // -- 搭子详情 --
  void _showBuddyDetail(_Buddy buddy) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.72, maxChildSize: 0.92, minChildSize: 0.5,
        builder: (_, scrollCtrl) => Container(
          decoration: const BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.vertical(top: Radius.circular(AppConfig.dialogRadius))),
          child: ListView(controller: scrollCtrl, padding: const EdgeInsets.all(AppConfig.pageMargin), children: [
            Center(child: Container(width: 32, height: 4, decoration: BoxDecoration(color: AppConfig.divider, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            // Header
            Row(children: [
              Container(width: 52, height: 52, decoration: BoxDecoration(borderRadius: BorderRadius.circular(26), gradient: const LinearGradient(colors: [Color(0xFFF0C040), Color(0xFFE67E22)])), child: Center(child: Text(buddy.name[0], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Text(buddy.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)), const SizedBox(width: 8), buddy.status.widget]),
                Text('${buddy.scene.emoji} ${buddy.scene.label} · ${buddy.distanceKm.toStringAsFixed(1)}km', style: const TextStyle(fontSize: 13, color: AppConfig.textSecondary)),
              ])),
            ]),
            const SizedBox(height: 14),
            // Goal
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: buddy.goal.color.withOpacity(0.06), borderRadius: BorderRadius.circular(AppConfig.cardRadius), border: Border.all(color: buddy.goal.color.withOpacity(0.15))),
              child: Row(children: [
                Icon(buddy.goal.icon, size: 22, color: buddy.goal.color),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('出行目标：${buddy.goal.shortLabel}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: buddy.goal.color)),
                  const SizedBox(height: 2),
                  Text(_goalManifesto(buddy.goal), style: TextStyle(fontSize: 12, color: buddy.goal.color.withOpacity(0.7))),
                ])),
              ]),
            ),
            const SizedBox(height: 14),
            // Body
            Text(buddy.desc, style: const TextStyle(fontSize: 14, color: AppConfig.textPrimary, height: 1.6)),
            const SizedBox(height: 14),
            // Route
            if (buddy.route != null) ...[
              const Text('计划路线', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppConfig.textSecondary)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: buddy.scene.primaryColor.withOpacity(0.05), borderRadius: BorderRadius.circular(AppConfig.cardRadius), border: Border.all(color: buddy.scene.primaryColor.withOpacity(0.15))),
                child: Row(children: [Icon(Icons.route_outlined, size: 18, color: buddy.scene.primaryColor), const SizedBox(width: 8), Text(buddy.route!, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: buddy.scene.primaryColor))]),
              ),
              const SizedBox(height: 12),
            ],
            // Tags
            const Text('装备与标签', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppConfig.textSecondary)),
            const SizedBox(height: 6),
            Wrap(spacing: 6, runSpacing: 6, children: buddy.tags.map((t) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppConfig.bgMain, borderRadius: BorderRadius.circular(AppConfig.tagRadius)), child: Text(t, style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary)))).toList()),
            const SizedBox(height: 20),
            // Actions
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConfig.goldStart,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.buttonRadius)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('申请组队', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  String _goalManifesto(_TravelGoal goal) => switch (goal) {
    _TravelGoal.challenge => '不设上限，只问极限',
    _TravelGoal.scenery => '风景在路上，不在终点',
    _TravelGoal.social => '有趣的灵魂在路上相遇',
    _TravelGoal.longHaul => '路遥知马力，日久见人心',
    _TravelGoal.explore => '未知的才是最迷人的',
  };

  // -- 发起组队 --
  void _showCreateTeam() {
    _TravelGoal? selectedGoal;
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => Container(
          decoration: const BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.vertical(top: Radius.circular(AppConfig.dialogRadius))),
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SafeArea(child: Padding(
            padding: const EdgeInsets.all(AppConfig.pageMargin),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 4),
              Center(child: Container(width: 32, height: 4, decoration: BoxDecoration(color: AppConfig.divider, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              const Text('发起组队', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
              const SizedBox(height: 6),
              const Text('选择出行目标，系统自动生成宣言并匹配搭子', style: TextStyle(fontSize: 13, color: AppConfig.textSecondary)),
              const SizedBox(height: 16),
              // Goal selection
              Wrap(spacing: 8, runSpacing: 8, children: _TravelGoal.values.map((g) {
                final sel = selectedGoal == g;
                return GestureDetector(
                  onTap: () => setSt(() => selectedGoal = sel ? null : g),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: sel ? g.color.withOpacity(0.1) : AppConfig.cardBg,
                      borderRadius: BorderRadius.circular(AppConfig.cardRadius),
                      border: Border.all(color: sel ? g.color : AppConfig.divider, width: sel ? 1.5 : 1),
                    ),
                    child: Column(children: [
                      Icon(g.icon, size: 28, color: sel ? g.color : AppConfig.textSecondary),
                      const SizedBox(height: 4),
                      Text(g.label, style: TextStyle(fontSize: 13, fontWeight: sel ? FontWeight.w600 : FontWeight.w400, color: sel ? g.color : AppConfig.textPrimary)),
                      Text(g.shortLabel, style: TextStyle(fontSize: 11, color: sel ? g.color.withOpacity(0.7) : AppConfig.textSecondary)),
                    ]),
                  ),
                );
              }).toList()),
              if (selectedGoal != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: selectedGoal!.color.withOpacity(0.06), borderRadius: BorderRadius.circular(AppConfig.cardRadius)),
                  child: Row(children: [
                    Icon(Icons.auto_awesome, size: 16, color: selectedGoal!.color),
                    const SizedBox(width: 8),
                    Expanded(child: Text('宣言：${_goalManifesto(selectedGoal!)}', style: TextStyle(fontSize: 13, color: selectedGoal!.color, fontWeight: FontWeight.w500))),
                  ]),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: ctrl,
                  maxLines: 3,
                  maxLength: 200,
                  decoration: InputDecoration(
                    hintText: '补充你的出行计划、时间、要求...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConfig.cardRadius), borderSide: const BorderSide(color: AppConfig.divider)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedGoal != null ? () { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('组队已发布！'), backgroundColor: AppConfig.cyclePrimary)); } : null,
                  style: ElevatedButton.styleFrom(backgroundColor: AppConfig.goldStart, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.buttonRadius)), padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: const Text('发布组队', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ]),
          )),
        ),
      ),
    );
  }
}

// -- 搭子数据 --
enum _Status { solo, inGroup, planning }

extension _StatusX on _Status {
  Widget get widget => switch (this) {
    _Status.solo => Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1), decoration: BoxDecoration(color: AppConfig.cyclePrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(3)), child: const Text('独行', style: TextStyle(fontSize: 10, color: AppConfig.cyclePrimary))),
    _Status.inGroup => Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1), decoration: BoxDecoration(color: AppConfig.goldStart.withOpacity(0.15), borderRadius: BorderRadius.circular(3)), child: const Text('组队中', style: TextStyle(fontSize: 10, color: AppConfig.goldStart))),
    _Status.planning => Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1), decoration: BoxDecoration(color: AppConfig.textSecondary.withOpacity(0.1), borderRadius: BorderRadius.circular(3)), child: const Text('计划中', style: TextStyle(fontSize: 10, color: AppConfig.textSecondary))),
  };
}

class _Buddy {
  final String name;
  final OutdoorScenario scene;
  final double distanceKm;
  final _Status status;
  final String? route;
  final String desc;
  final List<String> tags;
  final _TravelGoal goal;
  final String time;       // V6.1: 出行时间
  final String memberInfo;  // V6.1: "独行" / "已有3人" / "2/4人"
  const _Buddy(this.name, this.scene, this.distanceKm, this.status, this.route, this.desc, this.tags, this.goal, {this.time = '', this.memberInfo = '独行'});
}
