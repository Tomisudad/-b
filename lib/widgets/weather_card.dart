import 'package:flutter/material.dart';
import '../config/theme.dart';

/// 天气卡片 — 严格对照 HTML renderHome() 天气卡片
/// 山脉背景图 + 半透明橄榄绿遮罩 + 温度/天气/湿度/UV/日落
class WeatherCard extends StatelessWidget {
  final VoidCallback? onTap;
  const WeatherCard({Key? key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.rCard24),
        child: Container(
          height: 208, // h-52 = 13rem = 208px
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(AppTheme.rCard24),
            boxShadow: AppTheme.cardShadowList,
          ),
          child: Stack(
            children: [
              // 山脉背景图
              Positioned.fill(
                child: Image.network(
                  'https://picsum.photos/id/1039/800/400',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFF7A8F55), // 备用渐变底色
                  ),
                ),
              ),
              // 橄榄绿半透明遮罩 bg-primary/70
              Positioned.fill(
                child: Container(
                  color: AppTheme.primary.withOpacity(0.7),
                ),
              ),
              // 文字内容
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 顶部：太阳图标 + "今日天气" + 收藏按钮
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.wb_sunny, color: Colors.white, size: 24),
                              const SizedBox(width: 8),
                              const Text(
                                '今日天气',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: AppTheme.wBold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.favorite_border,
                                color: Colors.white, size: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 温度/天气/湿度/UV/日落信息
                      Text(
                        '温度24℃ · 东南风2级 · 未来3小时无雨',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: AppTheme.fsBody,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // 大号"适合骑行"
                      const Text(
                        '适合骑行',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: AppTheme.wBold,
                          shadows: [
                            Shadow(
                              color: Color(0x4D000000),
                              offset: Offset(0, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // 标签行
                      Row(
                        children: [
                          _tag('湿度58%'),
                          const SizedBox(width: 8),
                          _tag('UV中等'),
                          const SizedBox(width: 8),
                          _tag('日落19:24'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tag(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
          ),
        ),
      );
}
