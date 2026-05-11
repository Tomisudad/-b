import 'package:flutter/material.dart';
import '../config/app_config.dart';

/// V7.5 骑行短片 (stub)
class CyclingVideoPage extends StatelessWidget {
  const CyclingVideoPage({super.key});

  static const _clips = [
    _Clip('🚴 环西湖纪录', '2026-05-08', '时长: 2:34  距离: 42.6km', true),
    _Clip('🌟 夜骑奈れ何', '2026-05-05', '时长: 1:48  距离: 28.3km', true),
    _Clip('🌲 千岛湖探幽', '2026-04-28', '时长: 5:12  距离: 140.0km', false),
  ];

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(
        backgroundColor: AppConfig.cardBg,
        title: const Text('🎬 骑行短片', style: TextStyle(
            fontSize: 17, fontWeight: FontWeight.w700,
            color: AppConfig.textPrimary)),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('全部',
                style: TextStyle(fontSize: 13, color: AppConfig.primary)),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(AppConfig.pageMargin),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, mainAxisSpacing: 12,
          crossAxisSpacing: 12, childAspectRatio: 0.85,
        ),
        itemCount: _clips.length,
        itemBuilder: (_, i) => _buildClip(ctx, _clips[i]),
      ),
    );
  }

  Widget _buildClip(BuildContext ctx, _Clip c) {
    return GestureDetector(
      onTap: c.generated
          ? () => ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(content: Text('播放: ${c.title}')))
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: AppConfig.cardBg,
          borderRadius: BorderRadius.circular(AppConfig.cardRadius),
          boxShadow: AppConfig.cardShadow,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: c.generated
                    ? AppConfig.primary.withOpacity(0.08)
                    : Colors.grey.withOpacity(0.08),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12)),
              ),
              child: Center(
                child: c.generated
                    ? const Icon(Icons.play_circle_fill,
                        size: 40, color: AppConfig.primary)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.auto_awesome,
                              size: 28, color: AppConfig.textSecondary),
                          const SizedBox(height: 4),
                          Text('点击生成',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AppConfig.textSecondary)),
                        ],
                      ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppConfig.textPrimary)),
                const SizedBox(height: 4),
                Text(c.meta, style: const TextStyle(
                    fontSize: 9, color: AppConfig.textSecondary)),
              ],
            ),
          ),
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