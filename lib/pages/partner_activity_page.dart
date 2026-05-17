import 'package:flutter/material.dart';
import '../config/app_config.dart';

/// V7.5 搭子动态
class PartnerActivityPage extends StatefulWidget {
  const PartnerActivityPage({super.key});
  @override
  State<PartnerActivityPage> createState() => _PartnerActivityPageState();
}

class _PartnerActivityPageState extends State<PartnerActivityPage> {
  final _activities = [
    _PA('Kevin', '🚴', '环西湖骑行', '完成了 42.6km 骑行', '2 小时前', '✔ 完成'),
    _PA('小明', '🏔️', '龙井爬坡', '即将出发——还缺2人', '30 分钟前', '加入'),
    _PA('阿维', '📸', '之江路拍照', '分享了一段日落视频', '1 小时前', '查看'),
    _PA('Luna', '🔥', '奈何夜骑', '组队中——今晚20:00出发', '3 小时前', '加入'),
  ];

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(
        backgroundColor: AppConfig.cardBg,
        title: const Text('🤝 搭子动态', style: TextStyle(
            fontSize: 17, fontWeight: FontWeight.w700,
            color: AppConfig.textPrimary)),
      ),
      body: Column(children: [
        // V7.7: 发布组队招募按钮
        Padding(padding: const EdgeInsets.fromLTRB(14, 12, 14, 8), child: SizedBox(
          width: double.infinity, height: 48,
          child: OutlinedButton.icon(
            onPressed: () => _showRecruitSheet(ctx),
            icon: const Icon(Icons.add, size: 20),
            label: const Text('发布组队招募', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppConfig.cyclePrimary,
              side: const BorderSide(color: AppConfig.cyclePrimary, width: 1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: Colors.white,
            ),
          ),
        )),
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
          cacheExtent: 500,
          itemCount: _activities.length,
          itemBuilder: (_, i) => _buildCard(_activities[i]),
        )),
      ]),
    );
  }

  Widget _buildCard(_PA a) {
    final isGroup = a.action == '加入';
    // V7.7: card press feedback
    return GestureDetector(
      onTap: () {},
      child: AnimatedScale(
        scale: 1.0, duration: const Duration(milliseconds: 150),
        child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppConfig.cardBg,
          borderRadius: BorderRadius.circular(AppConfig.cardRadius),
          boxShadow: AppConfig.cardShadow,
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: CircleAvatar(
            radius: 20,
            backgroundColor: AppConfig.primary.withOpacity(0.15),
            child: Text(a.emoji, style: const TextStyle(fontSize: 18)),
          ),
          title: Row(children: [
            Text(a.name, style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: AppConfig.textPrimary)),
            const Spacer(),
            Text(a.time, style: const TextStyle(
                fontSize: 10, color: AppConfig.textSecondary)),
          ]),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text('📍 ${a.route}', style: const TextStyle(
                  fontSize: 11, color: AppConfig.textSecondary)),
              Text(a.desc, style: const TextStyle(
                  fontSize: 12, color: AppConfig.textPrimary)),
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isGroup
                  ? AppConfig.primary.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: isGroup
                  ? Border.all(color: AppConfig.primary.withOpacity(0.3))
                  : null,
            ),
            child: Text(a.action, style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600,
                color: isGroup ? AppConfig.primary : AppConfig.textSecondary)),
          ),
        ),
      ),
    ));
  }

  void _showRecruitSheet(BuildContext ctx) {
    final routeCtrl = TextEditingController();
    final paceCtrl = TextEditingController();
    String targetLabel = '休闲骑';
    showModalBottomSheet(
      context: ctx, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 12),
        child: SafeArea(child: Padding(
          padding: const EdgeInsets.all(AppConfig.pageMargin),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 32, height: 4, decoration: BoxDecoration(color: AppConfig.divider, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 12),
            const Text('发布组队招募', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
            const SizedBox(height: 14),
            TextField(controller: routeCtrl, decoration: InputDecoration(labelText: '骑行路线', hintText: '如：龙井爬坡', border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConfig.cardRadius), borderSide: const BorderSide(color: AppConfig.divider)), contentPadding: const EdgeInsets.all(12))),
            const SizedBox(height: 10),
            TextField(controller: paceCtrl, decoration: InputDecoration(labelText: '目标配速 (km/h)', hintText: '如：20-25', border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConfig.cardRadius), borderSide: const BorderSide(color: AppConfig.divider)), contentPadding: const EdgeInsets.all(12)), keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            const Text('骑行目标', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
            const SizedBox(height: 6),
            StatefulBuilder(builder: (_, sbSetState) => Wrap(spacing: 6, children: ['休闲骑', '有氧骑', '拉练', '长距离', '爬坡'].map((t) => ChoiceChip(
              label: Text(t, style: TextStyle(fontSize: 12, color: targetLabel == t ? Colors.white : AppConfig.textPrimary)),
              selected: targetLabel == t, selectedColor: AppConfig.cyclePrimary,
              backgroundColor: AppConfig.bgMain, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              onSelected: (_) { sbSetState(() => targetLabel = t); },
            )).toList())),
            const SizedBox(height: 14),
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: () {
                if (routeCtrl.text.trim().isNotEmpty) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('组队招募已发布', style: TextStyle(color: Colors.white)), backgroundColor: AppConfig.cyclePrimary, duration: Duration(seconds: 2)));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppConfig.goldStart, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
              child: const Text('发布招募', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
            )),
          ]),
        )),
      ),
    );
  }
}

class _PA {
  final String name, emoji, route, desc, time, action;
  const _PA(this.name, this.emoji, this.route, this.desc, this.time, this.action);
}