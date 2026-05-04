import 'package:flutter/material.dart';
import 'dart:ui';

import '../config/app_config.dart';
import '../models/scenario.dart';

/// V4.0 社区页面 — 路书/装备/心得/心情 四分类
class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  int _categoryIndex = 0;
  bool _sortByLikes = false;

  static const _categories = ['路书', '装备', '心得', '心情'];
  static const _categoryIcons = [Icons.map_outlined, Icons.backpack_outlined, Icons.menu_book_outlined, Icons.mood_outlined];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 毛玻璃顶栏
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: AppConfig.glassBlur, sigmaY: AppConfig.glassBlur),
            child: Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              decoration: const BoxDecoration(
                color: AppConfig.glassBg,
                border: Border(bottom: BorderSide(color: AppConfig.divider, width: 0.5)),
              ),
              child: Column(
                children: [
                  // 标题行
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin, vertical: 10),
                    child: Row(
                      children: [
                        const Text('社区', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
                        const Spacer(),
                        // 排序切换
                        GestureDetector(
                          onTap: () => setState(() => _sortByLikes = !_sortByLikes),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: _sortByLikes ? AppConfig.cyclePrimary.withOpacity(0.1) : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _sortByLikes ? Icons.thumb_up : Icons.access_time,
                                  size: 14,
                                  color: _sortByLikes ? AppConfig.cyclePrimary : AppConfig.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _sortByLikes ? '热度' : '最新',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _sortByLikes ? AppConfig.cyclePrimary : AppConfig.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // 发布按钮
                        GestureDetector(
                          onTap: () => _showPublishSheet(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: goldGradient,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add, size: 16, color: AppConfig.textInverse),
                                SizedBox(width: 2),
                                Text('发布', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppConfig.textInverse)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 分类标签
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppConfig.pageMargin, 0, AppConfig.pageMargin, 8),
                    child: Row(
                      children: List.generate(4, (i) {
                        final isActive = _categoryIndex == i;
                        final color = isActive ? AppConfig.cyclePrimary : AppConfig.textSecondary;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _categoryIndex = i),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: isActive ? AppConfig.cyclePrimary : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(_categoryIcons[i], size: 15, color: color),
                                  const SizedBox(width: 4),
                                  Text(
                                    _categories[i],
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                                      color: color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // 内容流
        Expanded(
          child: _buildContentFeed(),
        ),
      ],
    );
  }

  Widget _buildContentFeed() {
    final posts = _mockPosts(_categoryIndex, _sortByLikes);

    return ListView.builder(
      padding: const EdgeInsets.all(AppConfig.pageMargin),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return _PostCard(post: post);
      },
    );
  }

  void _showPublishSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PublishSheet(),
    );
  }
}

// ============================================================
// 帖子卡片
// ============================================================
class _PostCard extends StatefulWidget {
  final _PostData post;
  const _PostCard({required this.post});

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  bool _liked = false;
  int _likeCount = 0;
  late bool _collected;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post.likes;
    _collected = widget.post.collected;
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConfig.cardGap),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppConfig.cardBg,
          borderRadius: BorderRadius.circular(AppConfig.cardRadius),
          boxShadow: AppConfig.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户信息行
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppConfig.cyclePrimary.withOpacity(0.1),
                  child: Text(post.author.substring(0, 1),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppConfig.cyclePrimary)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.author, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
                      Text(post.timeAgo, style: const TextStyle(fontSize: 11, color: AppConfig.textSecondary)),
                    ],
                  ),
                ),
                // 场景标签
                if (post.scenario != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _scenarioColor(post.scenario!).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _scenarioLabel(post.scenario!),
                      style: TextStyle(fontSize: 10, color: _scenarioColor(post.scenario!)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // 正文
            Text(post.content, style: const TextStyle(fontSize: 14, color: AppConfig.textPrimary, height: 1.6)),
            // 关联路线（路书类）
            if (post.routeName != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppConfig.bgMain,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.route_outlined, size: 16, color: AppConfig.cyclePrimary),
                    const SizedBox(width: 8),
                    Text(post.routeName!, style: const TextStyle(fontSize: 13, color: AppConfig.cyclePrimary, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
            // 点赞 + 评论 + 收藏
            Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() {
                    _liked = !_liked;
                    _likeCount += _liked ? 1 : -1;
                  }),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _liked ? Icons.thumb_up : Icons.thumb_up_outlined,
                        size: 16,
                        color: _liked ? AppConfig.cyclePrimary : AppConfig.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text('$_likeCount', style: TextStyle(fontSize: 12, color: _liked ? AppConfig.cyclePrimary : AppConfig.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () {},
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 16, color: AppConfig.textSecondary),
                      SizedBox(width: 4),
                      Text('评论', style: TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
                    ],
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() => _collected = !_collected),
                  child: Icon(
                    _collected ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 18,
                    color: _collected ? AppConfig.goldEnd : AppConfig.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _scenarioColor(OutdoorScenario s) {
    switch (s) {
      case OutdoorScenario.cycle: return AppConfig.cyclePrimary;
      case OutdoorScenario.moto: return AppConfig.motoPrimary;
      case OutdoorScenario.drive: return AppConfig.drivePrimary;
    }
  }

  String _scenarioLabel(OutdoorScenario s) {
    switch (s) {
      case OutdoorScenario.cycle: return '骑行';
      case OutdoorScenario.moto: return '摩旅';
      case OutdoorScenario.drive: return '自驾';
    }
  }
}

// ============================================================
// Mock 数据
// ============================================================
List<_PostData> _mockPosts(int category, bool sortByLikes) {
  final all = <_PostData>[
    // 路书
    _PostData('山野行者', '川西大环线详细路书分享，包括沿途补给点、住宿推荐和注意事项。全程风景绝美，值得一去！',
      likes: 128, scenario: OutdoorScenario.moto, routeName: '川西大环线', category: 0),
    _PostData('骑行达人', '环青海湖骑行路书，逆时针方向，四天三晚。沿途补给充足，适合新手挑战。',
      likes: 96, scenario: OutdoorScenario.cycle, routeName: '青海湖环湖', category: 0),
    _PostData('越野老王', '独库公路自驾路书 v2.0，新增北段详细标注和营地推荐。',
      likes: 87, scenario: OutdoorScenario.drive, routeName: '独库公路全程', category: 0),
    _PostData('摩旅日记', 'G318川藏线摩旅路书，详细标注加油站和高反注意事项。',
      likes: 215, scenario: OutdoorScenario.moto, routeName: 'G318川藏线', category: 0),
    // 装备
    _PostData('装备控', '长途骑行装备清单分享：从车辆到急救包，一应俱全。这些年踩过的坑都总结在这里了。',
      likes: 56, scenario: OutdoorScenario.cycle, category: 1),
    _PostData('露营达人', '摩旅露营装备推荐，轻量化是关键。帐篷选三季帐，睡袋温标要根据季节调整。',
      likes: 73, scenario: OutdoorScenario.moto, category: 1),
    // 心得
    _PostData('远方来信', '第一次完成百公里骑行，虽然累但特别有成就感。路上遇到的骑友都很友善，这种体验是城市里感受不到的。',
      likes: 203, scenario: OutdoorScenario.cycle, category: 2),
    _PostData('行者无疆', '自驾新疆一月，最美的风景在路上。推荐喀纳斯到禾木这一段，秋天去简直就是童话世界。',
      likes: 167, scenario: OutdoorScenario.drive, category: 2),
    // 心情
    _PostData('追风少年', '今天天气真好，骑了三十公里，风吹在脸上的感觉太棒了！',
      likes: 42, scenario: OutdoorScenario.cycle, category: 3),
    _PostData('摩旅人生', '周末小跑，发现一条超美的山路，弯道多但路况好，强烈推荐！',
      likes: 58, scenario: OutdoorScenario.moto, category: 3),
  ];

  var filtered = all.where((p) => p.category == category).toList();
  if (sortByLikes) {
    filtered.sort((a, b) => b.likes.compareTo(a.likes));
  } else {
    filtered = filtered.reversed.toList();
  }
  return filtered;
}

class _PostData {
  final String author;
  final String content;
  final int likes;
  final OutdoorScenario? scenario;
  final String? routeName;
  final int category;
  final bool collected;
  final String timeAgo;

  _PostData(this.author, this.content, {
    required this.likes,
    this.scenario,
    this.routeName,
    this.category = 0,
    this.collected = false,
  }) : timeAgo = _randomTimeAgo(likes);

  static String _randomTimeAgo(int seed) {
    final options = ['刚刚', '5分钟前', '30分钟前', '1小时前', '2小时前', '昨天', '前天'];
    return options[seed % options.length];
  }
}

// ============================================================
// 发布面板
// ============================================================
class _PublishSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConfig.pageMargin),
      decoration: const BoxDecoration(
        color: AppConfig.cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConfig.dialogRadius)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: AppConfig.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text('发布内容', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
            const SizedBox(height: 20),
            _pubOption(context, Icons.map_outlined, '路书', '关联公开路线，附文字说明', AppConfig.cyclePrimary),
            const SizedBox(height: 12),
            _pubOption(context, Icons.backpack_outlined, '装备', '发布装备清单，可勾选公开项', AppConfig.motoPrimary),
            const SizedBox(height: 12),
            _pubOption(context, Icons.menu_book_outlined, '心得', '长篇游记，支持轨迹+照片+文字', AppConfig.drivePrimary),
            const SizedBox(height: 12),
            _pubOption(context, Icons.mood_outlined, '心情', '短文本+照片，记录此刻感受', AppConfig.goldEnd),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _pubOption(BuildContext context, IconData icon, String title, String desc, Color color) {
    return Material(
      color: AppConfig.bgMain,
      borderRadius: BorderRadius.circular(AppConfig.cardRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConfig.cardRadius),
        onTap: () => Navigator.pop(context),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
                    const SizedBox(height: 2),
                    Text(desc, style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 18, color: AppConfig.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
