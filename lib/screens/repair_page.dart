import 'package:flutter/material.dart';
import '../config/theme.dart';

/// 维修手册页 — 严格对照 HTML renderSub() repair + toggleRepair()
class RepairPage extends StatefulWidget {
  const RepairPage({super.key});

  @override
  State<RepairPage> createState() => _RepairPageState();
}

class _RepairPageState extends State<RepairPage> {
  final List<Map<String, String>> _repairs = const [
    {
      'title': '补胎教程',
      'detail': '1.找到漏气点 2.打磨内胎 3.涂胶水 4.贴补片 5.按压3分钟',
    },
    {
      'title': '换内胎',
      'detail': '1.拆卸车轮 2.取出破损内胎 3.检查外胎内侧 4.装入新内胎 5.充气',
    },
    {
      'title': '链条上油',
      'detail': '1.清洁链条 2.逐节滴润滑油 3.转动曲柄 4.擦去多余油',
    },
    {
      'title': '刹车调整',
      'detail': '1.检查来令片磨损 2.调节刹车线松紧 3.测试刹车力度',
    },
  ];

  final Set<int> _expanded = {};

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(AppTheme.rCard24),
            boxShadow: AppTheme.cardShadowList,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('维修手册',
                  style: TextStyle(fontSize: 18, fontWeight: AppTheme.wBold)),
              const SizedBox(height: 4),
              for (int i = 0; i < _repairs.length; i++)
                _RepairTile(
                  title: _repairs[i]['title']!,
                  detail: _repairs[i]['detail']!,
                  isExpanded: _expanded.contains(i),
                  isLast: i == _repairs.length - 1,
                  onTap: () {
                    setState(() {
                      if (_expanded.contains(i)) {
                        _expanded.remove(i);
                      } else {
                        _expanded.add(i);
                      }
                    });
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}

class _RepairTile extends StatelessWidget {
  final String title;
  final String detail;
  final bool isExpanded;
  final bool isLast;
  final VoidCallback onTap;

  const _RepairTile({
    required this.title,
    required this.detail,
    required this.isExpanded,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0x1A5A6F45),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.build, color: AppTheme.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                  if (isExpanded) ...[
                    const SizedBox(height: 4),
                    Text(detail,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                  ],
                ],
              ),
            ),
            Text(isExpanded ? '▲' : '▼',
                style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
