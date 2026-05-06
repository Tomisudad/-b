import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../config/scenario_config.dart';

/// V5.2 搭子页面 — 找人组队
class PartnerPage extends StatefulWidget {
  const PartnerPage({super.key});

  @override
  State<PartnerPage> createState() => _PartnerPageState();
}

class _PartnerPageState extends State<PartnerPage> {
  OutdoorScenario? _filter;
  bool _mapView = false;

  static final List<_Buddy> _buddies = [
    _Buddy('山野骑客', OutdoorScenario.cycle, 2.3, _Status.inGroup, '太湖东山半岛', '明天 7:30出发，已有2人', ['骑行', '休闲']),
    _Buddy('追风骑士', OutdoorScenario.moto, 5.1, _Status.solo, '皖南川藏线', '周末两天，摩旅老手带路', ['摩旅', '周末']),
    _Buddy('远方行者', OutdoorScenario.drive, 8.7, _Status.solo, '青海大环线', '7月底出发，14天，捡1人', ['自驾', '长途']),
    _Buddy('骑行小白', OutdoorScenario.cycle, 1.5, _Status.planning, '未知', '新手求带！周末西湖周边随便骑', ['新手', '骑行']),
    _Buddy('露营达人', OutdoorScenario.drive, 3.2, _Status.inGroup, '德清莫干山', '周六露营，缺个司机', ['露营', '自驾']),
    _Buddy('摩旅老炮', OutdoorScenario.moto, 12.0, _Status.solo, '318川藏线', '6月中旬出发，全程摩旅，找搭档', ['摩旅', '长途', '西藏']),
    _Buddy('周末骑士', OutdoorScenario.cycle, 0.8, _Status.planning, '未知', '每周六环西湖，欢迎加入', ['骑行', '休闲', '固定活动']),
    _Buddy('西北老司机', OutdoorScenario.drive, 15.3, _Status.solo, '独库公路', '老司机捡人，全程AA，限两人', ['自驾', '新疆']),
    _Buddy('越野爱好者', OutdoorScenario.cycle, 4.5, _Status.inGroup, '午潮山越野', '明天下午，XC路线', ['越野', '骑行']),
  ];

  List<_Buddy> get _filtered {
    var list = _buddies.toList();
    if (_filter != null) list = list.where((b) => b.scene == _filter).toList();
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
          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1), decoration: BoxDecoration(color: AppConfig.cyclePrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text('${buddies.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppConfig.cyclePrimary))),
        ]),
        actions: [IconButton(icon: Icon(_mapView ? Icons.list : Icons.map_outlined, color: AppConfig.textSecondary), onPressed: () => setState(() => _mapView = !_mapView))],
      ),
      body: Column(children: [
        _buildSceneFilter(),
        Expanded(child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin), itemCount: buddies.length, separatorBuilder: (_, __) => const SizedBox(height: AppConfig.cardGap), itemBuilder: (_, i) => _buildBuddyCard(buddies[i]))),
      ]),
    );
  }

  Widget _buildSceneFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppConfig.pageMargin, 0, AppConfig.pageMargin, 10),
      child: Row(children: [
        _filterChip('全部', _filter == null, () => setState(() => _filter = null)),
        const SizedBox(width: 6),
        _filterChip('🚴 骑行', _filter == OutdoorScenario.cycle, () => setState(() => _filter = OutdoorScenario.cycle)),
        const SizedBox(width: 6),
        _filterChip('🏍️ 摩旅', _filter == OutdoorScenario.moto, () => setState(() => _filter = OutdoorScenario.moto)),
        const SizedBox(width: 6),
        _filterChip('🚗 自驾', _filter == OutdoorScenario.drive, () => setState(() => _filter = OutdoorScenario.drive)),
      ]),
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

  Widget _buildBuddyCard(_Buddy buddy) {
    final color = buddy.scene.primaryColor;
    return GestureDetector(
      onTap: () => _showBuddyDetail(buddy),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), boxShadow: AppConfig.cardShadow),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: const LinearGradient(colors: [Color(0xFFF0C040), Color(0xFFE67E22)])), child: Center(child: Text(buddy.name[0], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)))),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(buddy.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
                const SizedBox(width: 6),
                Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(3)), child: Text(buddy.scene.label, style: TextStyle(fontSize: 10, color: color))),
              ]),
              const SizedBox(height: 3),
              Row(children: [
                Icon(Icons.location_on_outlined, size: 12, color: AppConfig.textSecondary.withOpacity(0.6)),
                const SizedBox(width: 3),
                Text('${buddy.distanceKm.toStringAsFixed(1)}km', style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
                const SizedBox(width: 8),
                buddy.status.widget,
              ]),
            ])),
            const Icon(Icons.chevron_right, size: 18, color: AppConfig.textSecondary),
          ]),
          const SizedBox(height: 8),
          Text(buddy.desc, style: const TextStyle(fontSize: 13, color: AppConfig.textPrimary, height: 1.4)),
          const SizedBox(height: 8),
          Row(children: [
            ...buddy.tags.map((t) => Padding(padding: const EdgeInsets.only(right: 6), child: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppConfig.bgMain, borderRadius: BorderRadius.circular(4)), child: Text(t, style: const TextStyle(fontSize: 10, color: AppConfig.textSecondary))))),
            const Spacer(),
            if (buddy.route != null) Text(buddy.route!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.buttonRadius)), side: const BorderSide(color: AppConfig.divider), foregroundColor: AppConfig.textPrimary), child: const Text('打招呼', style: TextStyle(fontSize: 13)))),
            const SizedBox(width: 8),
            Expanded(child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.buttonRadius)), backgroundColor: AppConfig.goldStart, foregroundColor: Colors.white), child: const Text('组队', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)))),
          ]),
        ]),
      ),
    );
  }

  void _showBuddyDetail(_Buddy buddy) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7, maxChildSize: 0.92, minChildSize: 0.5,
        builder: (_, scrollCtrl) => Container(
          decoration: const BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.vertical(top: Radius.circular(AppConfig.dialogRadius))),
          child: ListView(controller: scrollCtrl, padding: const EdgeInsets.all(AppConfig.pageMargin), children: [
            Center(child: Container(width: 32, height: 4, decoration: BoxDecoration(color: AppConfig.divider, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Row(children: [Container(width: 48, height: 48, decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFFF0C040), Color(0xFFE67E22)])), child: Center(child: Text(buddy.name[0], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)))), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(buddy.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)), Text('${buddy.scene.label} · ${buddy.distanceKm.toStringAsFixed(1)}km', style: const TextStyle(fontSize: 13, color: AppConfig.textSecondary))]))]),
            const SizedBox(height: 16),
            Text(buddy.desc, style: const TextStyle(fontSize: 14, color: AppConfig.textPrimary, height: 1.5)),
            const SizedBox(height: 16),
            if (buddy.route != null) ...[
              const Text('计划路线', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppConfig.textSecondary)),
              const SizedBox(height: 6),
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: buddy.scene.primaryColor.withOpacity(0.05), borderRadius: BorderRadius.circular(AppConfig.cardRadius), border: Border.all(color: buddy.scene.primaryColor.withOpacity(0.15))), child: Row(children: [Icon(Icons.route_outlined, size: 18, color: buddy.scene.primaryColor), const SizedBox(width: 8), Text(buddy.route!, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: buddy.scene.primaryColor))])),
              const SizedBox(height: 12),
            ],
            const Text('装备情况', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppConfig.textSecondary)),
            const SizedBox(height: 6),
            Wrap(spacing: 6, runSpacing: 6, children: buddy.tags.map((t) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppConfig.bgMain, borderRadius: BorderRadius.circular(AppConfig.tagRadius)), child: Text(t, style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary)))).toList()),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: AppConfig.goldStart, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.buttonRadius)), padding: const EdgeInsets.symmetric(vertical: 14)), child: const Text('申请组队', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)))),
          ]),
        ),
      ),
    );
  }
}

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
  const _Buddy(this.name, this.scene, this.distanceKm, this.status, this.route, this.desc, this.tags);
}
