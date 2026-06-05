import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../providers/app_state.dart';
import 'package:provider/provider.dart';

/// 出发准备卡片 — 严格对照 HTML renderHome() 装备卡片
/// 橄榄绿背景 + 左侧"出发装备"标题和状态描述 + 右侧户外装备图片
class EquipmentCard extends StatelessWidget {
  final VoidCallback? onTap;
  const EquipmentCard({Key? key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final equipment = context.watch<AppState>().equipment;
    final issues = equipment.where((e) => e.status != 'ok').length;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.rCard),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(AppTheme.rCard),
            boxShadow: AppTheme.cardShadowList,
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Row(
              children: [
                // 左侧文字
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '出发准备',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: AppTheme.wBold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (equipment.isEmpty)
                        const Text(
                          '轻装简行，装备够用就好\n提前规划，享受运动时光',
                          style: TextStyle(
                            color: Color(0xB3FFFFFF),
                            fontSize: 15,
                            height: 1.6,
                          ),
                        )
                      else if (issues > 0)
                        Text(
                          '$issues项待处理，点击查看\n提前规划，享受运动时光',
                          style: const TextStyle(
                            color: Color(0xB3FFFFFF),
                            fontSize: 15,
                            height: 1.6,
                          ),
                        )
                      else
                        const Text(
                          '全部就绪 ✅\n提前规划，享受运动时光',
                          style: TextStyle(
                            color: Color(0xB3FFFFFF),
                            fontSize: 15,
                            height: 1.6,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // 右侧户外装备图片
                Flexible(
                  flex: 0,
                  child: _buildEquipmentImage(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEquipmentImage() => SizedBox(
        height: 192,
        child: Image.network(
          'https://p3-flow-imagex-sign.byteimg.com/ocean-cloud-tos/36e05908070e400899008070e4008990~tplv-a9rns2rl98-image.png?rk3s=1e24567e&x-expires=2054275200&x-signature=abc123def456ghi789jkl012mn',
          height: 192,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Text(
            '\u{1F392}',
            style: TextStyle(fontSize: 80),
          ),
        ),
      );
}
