import 'package:flutter/material.dart';
import '../config/theme.dart';

/// 维修手册卡片 — 严格对照 HTML renderHome() 维修手册部分
/// 白底 + 扳手图标 + "维修手册" + "补胎·换胎·链条·刹车·安全应急 · 离线可用"
class RepairCard extends StatelessWidget {
  final VoidCallback? onTap;
  const RepairCard({Key? key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(AppTheme.rCard24),
          boxShadow: AppTheme.cardShadowList,
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.build,
                      color: AppTheme.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '维修手册',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: AppTheme.wBold,
                        color: AppTheme.dark,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '补胎·换胎·链条·刹车·安全应急 · 离线可用',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Icon(Icons.chevron_right,
                color: Color(0xFFD1D5DB), size: 20),
          ],
        ),
      ),
    );
  }
}
