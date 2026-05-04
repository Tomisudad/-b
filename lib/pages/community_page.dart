import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/scenario.dart';

/// V5.0 社区页面 - 统一信息流（「全部」/「关注」）
class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  bool _showFollowing = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 顶栏
        _buildHeader(context),
        // 全部/关注切换
        _buildTabBar(),
        // 内容流
        Expanded(child: _buildFeed()),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: const BoxDecoration(
        color: AppConfig.glassBg,
        border: Border(bottom: BorderSide(color: AppConfig.divider, width: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin, vertical: 10),
        child: Row(
          children: [
            const Text('社区', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
            const Spacer(),
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
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppConfig.pageMargin, 8, AppConfig.pageMargin, 4),
      child: Row(
        children: [
          _tabBtn('全部', !_showFollowing),
          const SizedBox(width: 16),
          _tabBtn('关注', _showFollowing),
        ],
      ),
    );
  }

  Widget _tabBtn(String label, bool active) {
    return GestureDetector(
      onTap: () => setState(() => _showFollowing = label == '关注'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              color: active ? AppConfig.textPrimary : AppConfig.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 20, height: 2,
            color: active ? AppConfig.cyclePrimary : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildFeed() {
    final posts = _mockPosts;

    return ListView.builder(
      padding: const EdgeInsets.all(AppConfig.pageMargin),
      itemCount: posts.length,
      itemBuilder: (ctx, i) => _PostCard(post: posts[i]),
    );
  }

  void _showPublishSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _PublishSheetV5(),
    );
  }
}

// ============================================================
// 帖子卡片
// ============================================================
class _PostCard extends StatefulWidget {
  final _PostV5 post;
  const _PostCard({required this.post});

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  bool _liked = false;
  int _likeCount = 0;
  bool _collected = false;
  int _collectCount = 0;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post.likes;
    _collectCount = widget.post.collects;
    _collected = widget.post.isCollected;
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
            // 用户行
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppConfig.cyclePrimary.withOpacity(0.1),
                  child: Text(post.author[0], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppConfig.cyclePrimary)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(post.author, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
                          if (post.scenario != null) ...[
                            const SizedBox(width: 6),
                            _scenarioTag(post.scenario!),
                          ],
                        ],
                      ),
                      Text(post.timeAgo, style: const TextStyle(fontSize: 11, color: AppConfig.textSecondary)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _collected = !_collected),
                  child: Icon(
                    _collected ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 18, color: _collected ? AppConfig.goldEnd : AppConfig.textSecondary,
                  ),
                ),
              ],
            ),
            // 正文
            if (post.text.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(post.text, style: const TextStyle(fontSize: 14, color: AppConfig.textPrimary, height: 1.6), maxLines: 6, overflow: TextOverflow.ellipsis),
            ],
            // 附件渲染
            if (post.attachments.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...post.attachments.map((a) => _renderAttachment(a)),
            ],
            const SizedBox(height: 12),
            // 互动栏
            Row(
              children: [
                _actionBtn(Icons.thumb_up_outlined, Icons.thumb_up, _likeCount, _liked, AppConfig.cyclePrimary, () {
                  setState(() { _liked = !_liked; _likeCount += _liked ? 1 : -1; });
                }),
                const Spacer(),
                _actionBtn(Icons.chat_bubble_outline, Icons.chat_bubble, post.comments, false, AppConfig.textSecondary, () {}),
                const Spacer(),
                _actionBtn(Icons.star_outline_rounded, Icons.star_rounded, _collectCount, _collected, AppConfig.goldEnd, () {
                  setState(() { _collected = !_collected; _collectCount += _collected ? 1 : -1; });
                }),
                const Spacer(),
                GestureDetector(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已复制分享链接'))),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.share_outlined, size: 16, color: AppConfig.textSecondary),
                      SizedBox(width: 4),
                      Text('转发', style: TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _scenarioTag(OutdoorScenario s) {
    final c = s == OutdoorScenario.cycle ? AppConfig.cyclePrimary
        : s == OutdoorScenario.moto ? AppConfig.motoPrimary : AppConfig.drivePrimary;
    final l = s == OutdoorScenario.cycle ? '骑行' : s == OutdoorScenario.moto ? '摩旅' : '自驾';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: c.withOpacity(0.08), borderRadius: BorderRadius.circular(4)),
      child: Text(l, style: TextStyle(fontSize: 9, color: c)),
    );
  }

  Widget _renderAttachment(_Attachment a) {
    switch (a.type) {
      case _AttachType.route:
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppConfig.bgMain, borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              const Icon(Icons.route_outlined, size: 18, color: AppConfig.cyclePrimary),
              const SizedBox(width: 8),
              Expanded(child: Text(a.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppConfig.cyclePrimary))),
              Text(a.subtitle ?? '', style: const TextStyle(fontSize: 11, color: AppConfig.textSecondary)),
            ],
          ),
        );
      case _AttachType.gear:
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppConfig.bgMain, borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              const Icon(Icons.backpack_outlined, size: 18, color: AppConfig.motoPrimary),
              const SizedBox(width: 8),
              Expanded(child: Text(a.title, style: const TextStyle(fontSize: 13, color: AppConfig.motoPrimary))),
              Text('查看清单 >', style: TextStyle(fontSize: 11, color: AppConfig.textSecondary.withOpacity(0.6))),
            ],
          ),
        );
      case _AttachType.track:
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppConfig.bgMain, borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              const Icon(Icons.timeline_outlined, size: 18, color: AppConfig.drivePrimary),
              const SizedBox(width: 8),
              Expanded(child: Text(a.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppConfig.textPrimary))),
              if (a.subtitle != null)
                Text(a.subtitle!, style: const TextStyle(fontSize: 11, color: AppConfig.textSecondary)),
            ],
          ),
        );
      case _AttachType.photo:
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 160,
            color: AppConfig.bgMain,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.image_outlined, size: 40, color: AppConfig.textSecondary),
                  const SizedBox(height: 8),
                  Text(a.title, style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
                  if (a.subtitle != null)
                    Text(a.subtitle!, style: const TextStyle(fontSize: 11, color: AppConfig.textSecondary)),
                ],
              ),
            ),
          ),
        );
      case _AttachType.medal:
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppConfig.goldStart.withOpacity(0.15), AppConfig.goldEnd.withOpacity(0.05)]),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Text('🏅', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(child: Text(a.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppConfig.goldEnd))),
              if (a.subtitle != null) Text(a.subtitle!, style: const TextStyle(fontSize: 11, color: AppConfig.textSecondary)),
            ],
          ),
        );
    }
  }

  Widget _actionBtn(IconData off, IconData on, int count, bool active, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(active ? on : off, size: 16, color: active ? color : AppConfig.textSecondary),
          const SizedBox(width: 4),
          Text('$count', style: TextStyle(fontSize: 12, color: active ? color : AppConfig.textSecondary)),
        ],
      ),
    );
  }
}

// ============================================================
// 发布面板 V5.0 (不选类型，附件自动渲染)
// ============================================================
class _PublishSheetV5 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: AppConfig.cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConfig.dialogRadius)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(color: AppConfig.textSecondary.withOpacity(0.3), borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            const Text('发布内容', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
            const SizedBox(height: 20),
            // 附件选择 — 不选类型，选附件
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _attBtn('🖼️', '照片'),
                  _attBtn('🗺️', '路线'),
                  _attBtn('🛠️', '装备'),
                  _attBtn('📝', '轨迹'),
                  _attBtn('🏅', '勋章'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // 发布
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
              child: SizedBox(
                width: double.infinity,
                height: AppConfig.primaryBtnH,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: goldGradient,
                    borderRadius: BorderRadius.all(Radius.circular(AppConfig.buttonRadius)),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('发布成功！')));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                    child: const Text('发布', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppConfig.textInverse)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _attBtn(String emoji, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: AppConfig.bgMain,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: AppConfig.textSecondary)),
      ],
    );
  }
}

// ============================================================
// Mock 数据
// ============================================================
final _mockPosts = [
  _PostV5('山野行者', '川西大环线详细路书分享，沿途补给点、住宿推荐和注意事项一应俱全。全程风景绝美！',
    likes: 128, collects: 54, comments: 23, scenario: OutdoorScenario.moto,
    attachments: [_Attachment.route('川西大环线', '320km · 5天')]),
  _PostV5('骑行达人', '',
    likes: 96, collects: 32, comments: 15, scenario: OutdoorScenario.cycle,
    attachments: [_Attachment.track('环青海湖', '360km · 4天'), _Attachment.photo('沿途美景合集', '12张')]),
  _PostV5('装备控', '长途骑行装备清单分享：从车辆到急救包，这些年踩过的坑都在这里。',
    likes: 56, collects: 78, comments: 9,
    attachments: [_Attachment.gear('长途骑行装备清单', '32项')]),
  _PostV5('远方来信', '第一次完成百公里骑行，虽然累但特别有成就感。路上遇到的骑友都很友善，这种体验是城市里感受不到的。',
    likes: 203, collects: 88, comments: 34, scenario: OutdoorScenario.cycle),
  _PostV5('越野老王', '独库公路自驾路书v2.0，新增北段详细标注和营地推荐。',
    likes: 87, collects: 41, comments: 12, scenario: OutdoorScenario.drive,
    attachments: [_Attachment.route('独库公路全程', '561km · 3天')]),
  _PostV5('摩旅人生', '周末小跑，发现一条超美的山路，弯道多但路况好！',
    likes: 58, collects: 15, comments: 7, scenario: OutdoorScenario.moto,
    attachments: [_Attachment.photo('山路弯道', '1张')]),
  _PostV5('行者无疆', '',
    likes: 167, collects: 63, comments: 21, scenario: OutdoorScenario.drive,
    attachments: [_Attachment.medal('行者无疆', '累计500km'), _Attachment.track('新疆自驾一月', '1800km · 8天')]),
  _PostV5('露营达人', '摩旅露营装备推荐，轻量化是关键。帐篷选三季帐，睡袋温标要根据季节调整。',
    likes: 73, collects: 45, comments: 11, scenario: OutdoorScenario.moto,
    attachments: [_Attachment.gear('摩旅露营装备', '18项')]),
  _PostV5('川藏老炮', 'G318川藏线摩旅路书10.0版，沿途加油站、维修点、住宿全标注。',
    likes: 215, collects: 102, comments: 38, scenario: OutdoorScenario.moto,
    attachments: [_Attachment.route('G318川藏线', '2100km · 12天')]),
  _PostV5('追风少年', '今天天气真好，骑了三十公里，风吹在脸上的感觉太棒了！☀️',
    likes: 42, collects: 8, comments: 5, scenario: OutdoorScenario.cycle),
];

class _PostV5 {
  final String author;
  final String text;
  final int likes;
  final int collects;
  final int comments;
  final OutdoorScenario? scenario;
  final List<_Attachment> attachments;
  final bool isCollected;
  final String timeAgo;

  _PostV5(this.author, this.text, {
    required this.likes,
    this.collects = 0,
    this.comments = 0,
    this.scenario,
    this.attachments = const [],
    this.isCollected = false,
  }) : timeAgo = _randomTimeAgo(author.hashCode + likes);

  static String _randomTimeAgo(int seed) {
    const opts = ['刚刚', '5分钟前', '15分钟前', '30分钟前', '1小时前', '2小时前', '3小时前', '昨天', '前天', '3天前'];
    return opts[seed.abs() % opts.length];
  }
}

enum _AttachType { route, gear, track, photo, medal }

class _Attachment {
  final _AttachType type;
  final String title;
  final String? subtitle;

  const _Attachment(this.type, this.title, [this.subtitle]);

  const _Attachment.route(String title, [String? sub]) : this(_AttachType.route, title, sub);
  const _Attachment.gear(String title, [String? sub]) : this(_AttachType.gear, title, sub);
  const _Attachment.track(String title, [String? sub]) : this(_AttachType.track, title, sub);
  const _Attachment.photo(String title, [String? sub]) : this(_AttachType.photo, title, sub);
  const _Attachment.medal(String title, [String? sub]) : this(_AttachType.medal, title, sub);
}
