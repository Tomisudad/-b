import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/scenario_provider.dart';
import '../config/scenario_config.dart';
import '../config/app_config.dart';
import '../theme/app_theme.dart';
import '../models/partner_model.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _postCtrl = TextEditingController();

  // Mock data
  final _posts = _mockPosts();
  final _partners = _mockPartners();
  final _bonfireMessages = _mockBonfire();
  int _showCommentPostIndex = -1;
  final _commentCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _postCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  bool get _showBonfire {
    final h = DateTime.now().hour;
    return h >= AppConfig.bonfireStartHour || h < AppConfig.bonfireEndHour || h < 1;
  }

  // ===== 动态瀑布流 =====
  Widget _buildFeedTab(OutdoorScenario scenario, Color sceneColor) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final p = _posts[i];
                    // 交替高度
                    final isTall = i % 3 == 0;
                    return GestureDetector(
                      onTap: () => setState(() => _showCommentPostIndex = i),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.divider, width: 0.5),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 图片区
                            Container(
                              height: isTall ? 180 : 120,
                              color: Color(0xFFDCE8D0 + i * 10),
                              child: Center(
                                child: Icon(Icons.landscape_outlined, size: 32, color: Color(0xFF2E7D32).withOpacity(0.2)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.content, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary)),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      CircleAvatar(radius: 10, backgroundColor: AppTheme.secondaryBg, child: const Icon(Icons.person, size: 12, color: AppTheme.textAux)),
                                      const SizedBox(width: 6),
                                      Text(p.authorName, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                                      const Spacer(),
                                      const Icon(Icons.favorite_border, size: 14, color: AppTheme.textAux),
                                      const SizedBox(width: 2),
                                      Text('${p.likeCount}', style: const TextStyle(fontSize: 11, color: AppTheme.textAux)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: _posts.length,
                ),
              ),
            ),
          ],
        ),

        // 发布按钮
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: _showPostDialog,
            backgroundColor: sceneColor,
            mini: false,
            elevation: 2,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),

        // 评论弹窗
        if (_showCommentPostIndex >= 0) _buildCommentOverlay(_showCommentPostIndex, sceneColor),
      ],
    );
  }

  void _showPostDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 16, right: 16, top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('分享你的路上见闻', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            TextField(
              controller: _postCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: '写点什么...',
                hintStyle: TextStyle(color: AppTheme.textAux),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _postCtrl.clear();
                },
                child: const Text('发布'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentOverlay(int index, Color sceneColor) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _showCommentPostIndex = -1),
        child: Container(color: Colors.black26),
      ),
    );
  }

  // ===== 找搭子 Tab =====
  Widget _buildPartnerTab(Color sceneColor) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _partners.length,
      itemBuilder: (_, i) {
        final p = _partners[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(radius: 20, backgroundColor: AppTheme.secondaryBg,
                      child: Text(p.nickname[0], style: const TextStyle(color: AppTheme.textPrimary))),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(p.nickname, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                              if (p.verified) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.verified, size: 16, color: Color(0xFF2196F3)),
                              ],
                            ],
                          ),
                          Text(p.formatDate, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: ScenarioConfig.of(p.scenario).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(ScenarioConfig.of(p.scenario).label,
                        style: TextStyle(fontSize: 11, color: ScenarioConfig.of(p.scenario).primaryColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(p.destination, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                if (p.description != null) ...[
                  const SizedBox(height: 4),
                  Text(p.description!, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                ],
                if (p.tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: p.tags.map((t) => Chip(
                      label: Text(t, style: const TextStyle(fontSize: 11)),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      backgroundColor: AppTheme.secondaryBg,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    )).toList(),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.people_outline, size: 16, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text('${p.joined}/${p.capacity}人', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                    const Spacer(),
                    SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: p.isFull ? null : () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: p.isFull ? AppTheme.secondaryBg : sceneColor,
                          foregroundColor: p.isFull ? AppTheme.textAux : Colors.white,
                          elevation: 0,
                          minimumSize: const Size(72, 36),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          textStyle: const TextStyle(fontSize: 13),
                        ),
                        child: Text(p.isFull ? '已满' : '申请加入'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===== 篝火 Tab =====
  Widget _buildBonfireTab(Color sceneColor) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          const Text('🔥 篝火', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFFFF8A65))),
          const Text('匿名 · 夜晚 · 心情', style: TextStyle(fontSize: 12, color: Color(0xFF999999))),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _bonfireMessages.length,
              itemBuilder: (_, i) {
                final m = _bonfireMessages[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF252550),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.content, style: const TextStyle(fontSize: 14, color: Color(0xFFD0D0E0))),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (m.moodTag != null) Text(m.moodTag!, style: const TextStyle(fontSize: 11, color: Color(0xFF7777AA))),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {},
                            child: Row(
                              children: [
                                const Icon(Icons.favorite, size: 14, color: Color(0xFFFF8A65)),
                                const SizedBox(width: 2),
                                Text('${m.warmthCount}', style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(m.timeAgo, style: const TextStyle(fontSize: 11, color: Color(0xFF666666))),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // 篝火输入
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A2E),
              border: Border(top: BorderSide(color: Color(0xFF333366), width: 0.5)),
            ),
            child: Row(
              children: [
                const Text('🎭', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '在这里说你想说的...',
                      hintStyle: TextStyle(color: Color(0xFF666666), fontSize: 14),
                      border: InputBorder.none,
                      filled: false,
                    ),
                    style: TextStyle(color: Color(0xFFD0D0E0), fontSize: 14),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8A65),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text('发送', style: TextStyle(fontSize: 13, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scenario = context.watch<ScenarioProvider>().scenario;
    final sceneColor = ScenarioConfig.of(scenario).primaryColor;

    return Scaffold(
      backgroundColor: AppTheme.secondaryBg,
      appBar: AppBar(
        title: const Text('社区'),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: sceneColor,
          labelColor: sceneColor,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: [
            const Tab(text: '动态'),
            const Tab(text: '找搭子'),
            if (_showBonfire) const Tab(text: '篝火'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildFeedTab(scenario, sceneColor),
          _buildPartnerTab(sceneColor),
          if (_showBonfire) _buildBonfireTab(sceneColor),
        ],
      ),
    );
  }
}

// ===== Mock Data =====
List<PostModel> _mockPosts() => List.generate(12, (i) => PostModel(
  id: 'p$i',
  authorId: 'u$i',
  authorName: ['老张', '小丽的旅行', '远方', '骑着摩托的狗', '山野笔记', '自由的风'][i % 6],
  content: _postContents[i % _postContents.length],
  imageUrls: const [],
  scenario: OutdoorScenario.values[i % 3],
  likeCount: 10 + i * 7,
  commentCount: 2 + i,
  createdAt: DateTime.now().subtract(Duration(hours: i * 3)),
  moodTag: ['#路上的风景', '#日落时分', '#山野', '#痛快'][i % 4],
  locationName: '杭州·西湖',
));

const _postContents = [
  '今天的日落太美了，骑行80公里，一切都值得。',
  '318国道上的第三次停留，每一次都不一样。',
  '在服务区遇到的摩旅大哥，已经骑了8个月了。',
  '带着帐篷出发，天为被地为床。',
  '雨天骑行Tips：防水是第一位。',
  '终南山隧道，自驾穿越真刺激。',
];

List<PartnerModel> _mockPartners() => [
  PartnerModel(
    id: 'bp1', nickname: '老王在路上', scenario: OutdoorScenario.drive,
    destination: '杭州 → 川西环线，10天',
    departTime: DateTime.now().add(const Duration(days: 3)),
    capacity: 4, joined: 2, verified: true,
    description: '计划沿318国道走，有驮包经验的朋友优先',
    tags: const ['318国道', '自驾', '找副驾'],
  ),
  PartnerModel(
    id: 'bp2', nickname: '骑行小分队', scenario: OutdoorScenario.cycle,
    destination: '环太湖骑行，2天',
    departTime: DateTime.now().add(const Duration(days: 1)),
    capacity: 6, joined: 4, verified: false,
    description: '休闲骑，配速25左右',
    tags: const ['环太湖', '休闲', '找队友'],
  ),
  PartnerModel(
    id: 'bp3', nickname: '摩旅人生', scenario: OutdoorScenario.moto,
    destination: '皖南川藏线，3天',
    departTime: DateTime.now().add(const Duration(days: 2)),
    capacity: 6, joined: 6, verified: true,
    description: '已经满员啦~',
    tags: const ['皖南', '摩旅', '已满'],
  ),
  PartnerModel(
    id: 'bp4', nickname: '滇藏线找车友', scenario: OutdoorScenario.drive,
    destination: '大理 → 拉萨，15天',
    departTime: DateTime.now().add(const Duration(days: 7)),
    capacity: 3, joined: 1, verified: true,
    tags: const ['滇藏线', '越野', '找伴'],
  ),
];

List<BonfireMessage> _mockBonfire() => [
  BonfireMessage(id: 'bf1', content: '一个人骑了300公里，路上遇到的所有人都很好。', moodTag: '#感动', createdAt: DateTime.now().subtract(const Duration(minutes: 15)), warmthCount: 23),
  BonfireMessage(id: 'bf2', content: '今天摩托坏了三次，但奇怪的是，我并不觉得倒霉。修车路上遇到了一个老师傅，聊了半小时人生。', moodTag: '#因果', createdAt: DateTime.now().subtract(const Duration(minutes: 42)), warmthCount: 51),
  BonfireMessage(id: 'bf3', content: '辞职两个月了，朋友们都问我什么时候回去。其实我也不知道。', moodTag: '#迷茫', createdAt: DateTime.now().subtract(const Duration(hours: 1)), warmthCount: 78),
  BonfireMessage(id: 'bf4', content: '路上捡了一只小狗，给它取名叫"导航"。因为它老往错的方向跑。', moodTag: '#快乐', createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)), warmthCount: 112),
  BonfireMessage(id: 'bf5', content: '出发前觉得非走不可的东西，走到半路全寄回家了。', moodTag: '#感悟', createdAt: DateTime.now().subtract(const Duration(hours: 2)), warmthCount: 67),
];
