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
      body: ListView.builder(
        padding: const EdgeInsets.all(AppConfig.pageMargin),
        itemCount: _activities.length,
        itemBuilder: (_, i) => _buildCard(_activities[i]),
      ),
    );
  }

  Widget _buildCard(_PA a) {
    final isGroup = a.action == '加入';
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
    );
  }
}

class _PA {
  final String name, emoji, route, desc, time, action;
  const _PA(this.name, this.emoji, this.route, this.desc, this.time, this.action);
}