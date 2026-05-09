import 'package:flutter/material.dart';
import '../config/app_config.dart';

/// V5.2 社区页面 — 统一信息流（全部/关注），附件自动识别渲染
class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  bool _showFollowing = false;
  String _sortBy = 'hot';
  late List<_Post> _posts;

  @override
  void initState() {
    super.initState();
    _genMockPosts();
  }

  void _genMockPosts() {
    _posts = [
      _Post(postId: 'p1', user: _User('山野行者', 'Lv.12', 128), body: '终于骑完千岛湖绿道全程！68km、三座桥、两个隧道，最后十公里是意志力的对决。风景值回票价 😌', timeAgo: '刚刚', likes: 23, comments: 5, stars: 3, attachments: [
        _Attach.route('千岛湖绿道全程', '68km · 进阶 · 580m爬升'),
        _Attach.photo(4),
      ], tags: ['骑行', '千岛湖']),
      _Post(postId: 'p2', user: _User('追风骑士', 'Lv.18', 342), body: '皖南川藏线摩旅归来。弯道一个接一个，压弯压到怀疑人生。沿途的竹林和云海，让人忘了速度。推荐给所有摩友 🏍️', timeAgo: '15分钟前', likes: 56, comments: 12, stars: 8, attachments: [
        _Attach.route('皖南川藏线', '120km · 困难 · 2200m爬升'),
        _Attach.track('轨迹记录 · 4.2h'),
        _Attach.photo(6),
      ], tags: ['摩旅', '皖南']),
      _Post(postId: 'p3', user: _User('户外老炮', 'Lv.35', 1204), body: '青海大环线第六次走了。这次带新人，讲一下必经的坑：1) 茶卡盐湖下午去拍不到镜面，必须日出 2) 大柴旦翡翠湖别开车进去 3) 敦煌鸣沙山买鞋套不如光脚。详细路书在主页。', timeAgo: '1小时前', likes: 1893, comments: 127, stars: 352, attachments: [
        _Attach.route('青海甘肃大环线', '1800km · 资深 · 6500m爬升'),
        _Attach.gear('自驾露营装备清单', '11项装备'),
      ], tags: ['自驾', '西北', '攻略']),
      _Post(postId: 'p4', user: _User('骑行小白', 'Lv.5', 18), body: '第一次骑长途，龙井爬坡记录。老哥们帮我看看这速度正常吗？感觉坡上去腿已经不是自己的了 😂', timeAgo: '2小时前', likes: 12, comments: 28, stars: 1, attachments: [
        _Attach.track('8.4km · 310m爬升 · 0.9h'),
      ], tags: ['骑行', '新手', '杭州']),
      _Post(postId: 'p5', user: _User('路书达人', 'Lv.22', 560), body: '【太行天路详解】全长95km，翻越三个山口，难度不高但风景绝了。附：最佳季节、补给点、住宿推荐。', timeAgo: '3小时前', likes: 782, comments: 53, stars: 135, attachments: [
        _Attach.route('太行天路', '95km · 进阶 · 1800m爬升'),
      ], tags: ['摩旅', '太行山', '路书']),
      _Post(postId: 'p6', user: _User('露营日记', 'Lv.10', 89), body: '德清莫干山下的新露营地，有水电有厕所，晚上能看到银河。🌌', timeAgo: '昨天', likes: 45, comments: 8, stars: 12, attachments: [
        _Attach.photo(3),
        _Attach.gear('自驾露营装备', '11项装备'),
      ], tags: ['露营', '自驾', '浙江']),
    // V6.1: 替换为骑摄天下 (1205/42/98)
      _Post(postId: 'p7', user: _User('骑摄天下', 'Lv.28', 680), body: '太湖日落，美到窒息。环湖骑一圈，东山半岛的光影绝了。相机根本停不下来 📸', timeAgo: '昨天', likes: 1205, comments: 42, stars: 98, attachments: [
        _Attach.route('太湖东山半岛', '28km · 新手 · 150m爬升'),
        _Attach.photo(9),
      ], tags: ['骑行', '太湖', '摄影']),
      _Post(postId: 'p8', user: _User('装备党', 'Lv.20', 340), body: '新入手了一套骑行装备，用了一周来反馈：头盔够用但透气性一般；手套强烈推荐，长时间握把不酸。', timeAgo: '前天', likes: 456, comments: 89, stars: 203, attachments: [
        _Attach.gear('骑行基础装备', '12项装备'),
      ], tags: ['装备', '骑行', '评测']),
    ];
  }

  List<_Post> get _sortedPosts {
    var list = _posts.toList();
    if (_sortBy == 'hot') {
      list.sort((a, b) => b._hotScore.compareTo(a._hotScore));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final posts = _sortedPosts;
    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      appBar: AppBar(
        title: const Text('社区', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        actions: [
          TextButton(
            onPressed: () => setState(() => _sortBy = _sortBy == 'hot' ? 'new' : 'hot'),
            child: Text(_sortBy == 'hot' ? '热度' : '最新', style: const TextStyle(fontSize: 13, color: AppConfig.textSecondary)),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabs(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
              itemCount: posts.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppConfig.cardGap),
              itemBuilder: (_, i) => _buildPostCard(posts[i]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => _showPublishSheet(context),
        backgroundColor: AppConfig.goldStart,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppConfig.pageMargin, 0, AppConfig.pageMargin, 10),
      child: Row(children: [
        _tabBtn('全部', !_showFollowing, () => setState(() => _showFollowing = false)),
        const SizedBox(width: 8),
        _tabBtn('关注', _showFollowing, () => setState(() => _showFollowing = true)),
      ]),
    );
  }

  Widget _tabBtn(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppConfig.goldStart.withOpacity(0.1) : AppConfig.cardBg,
          borderRadius: BorderRadius.circular(AppConfig.tagRadius),
          border: Border.all(color: active ? AppConfig.goldStart : AppConfig.divider, width: active ? 1.2 : 0.8),
        ),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: active ? FontWeight.w600 : FontWeight.w400, color: active ? AppConfig.goldStart : AppConfig.textSecondary)),
      ),
    );
  }

  Widget _buildPostCard(_Post post) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.circular(AppConfig.cardRadius), boxShadow: AppConfig.cardShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFF0C040), Color(0xFFE67E22)]), borderRadius: BorderRadius.circular(18)), child: Center(child: Text(post.user.name[0], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Text(post.user.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)), const SizedBox(width: 6), Text(post.user.level, style: const TextStyle(fontSize: 11, color: AppConfig.textSecondary))]),
            Text(post.timeAgo, style: const TextStyle(fontSize: 11, color: AppConfig.textSecondary)),
          ])),
        ]),
        const SizedBox(height: 10),
        Text(post.body, style: const TextStyle(fontSize: 14, color: AppConfig.textPrimary, height: 1.6)),
        if (post.tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(spacing: 4, runSpacing: 4, children: post.tags.map((t) => Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppConfig.goldStart.withOpacity(0.06), borderRadius: BorderRadius.circular(4)), child: Text('#$t', style: const TextStyle(fontSize: 11, color: AppConfig.goldStart)))).toList()),
        ],
        if (post.attachments.isNotEmpty) ...[
          const SizedBox(height: 10),
          ...post.attachments.map((att) => _buildAttachment(att)),
        ],
        const SizedBox(height: 10),
        Row(children: [
          _actionBtn(Icons.favorite_border, '${post.likes}', () => setState(() => post.likes++)),
          const SizedBox(width: 20),
          _actionBtn(Icons.chat_bubble_outline, '${post.comments}', () => _showComments(context, post)),
          const Spacer(),
          _actionBtn(Icons.star_border, '${post.stars}', () {}),
        ]),
      ]),
    );
  }

  Widget _buildAttachment(_Attach att) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: AppConfig.bgMain, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppConfig.divider)),
      child: Row(children: [
        Icon(att.icon, size: 18, color: att.color),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(att.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
          if (att.sub != null) Text(att.sub!, style: const TextStyle(fontSize: 11, color: AppConfig.textSecondary)),
        ])),
        const Icon(Icons.chevron_right, size: 16, color: AppConfig.textSecondary),
      ]),
    );
  }

  Widget _actionBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 18, color: AppConfig.textSecondary), const SizedBox(width: 3), Text(label, style: const TextStyle(fontSize: 13, color: AppConfig.textSecondary))]));
  }

  // V6.5 Fix 8: 评论半屏 — 底部可拖拽面板
  void _showComments(BuildContext context, _Post post) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5, minChildSize: 0.3, maxChildSize: 0.8,
        builder: (_, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: AppConfig.cardBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppConfig.dialogRadius)),
          ),
          child: Stack(children: [
            ListView(controller: scrollCtrl, padding: const EdgeInsets.only(bottom: 80), children: [
              Center(child: Container(margin: const EdgeInsets.only(top: 10, bottom: 4), width: 32, height: 4, decoration: BoxDecoration(color: AppConfig.divider, borderRadius: BorderRadius.circular(2)))),
              const Padding(padding: EdgeInsets.fromLTRB(14, 6, 14, 10), child: Text('评论', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConfig.textPrimary))),
              const Divider(height: 1, color: AppConfig.divider),
              _cItem('骑友小明', '太厉害了！这条线我也想去', '5分钟前'),
              _cItem('户外达人', '照片拍得好看 📸', '1小时前'),
              _cItem('新手在路上', '学习了学习了 🙏 下次求带', '2小时前'),
            ]),
            // 底部评论输入条
            Positioned(bottom: 0, left: 0, right: 0, child: Container(
              padding: EdgeInsets.fromLTRB(14, 8, 14, MediaQuery.of(context).padding.bottom + 8),
              decoration: const BoxDecoration(color: AppConfig.cardBg, border: Border(top: BorderSide(color: AppConfig.divider))),
              child: Row(children: [
                Expanded(child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: AppConfig.bgMain, borderRadius: BorderRadius.circular(20)),
                  child: const TextField(decoration: InputDecoration(hintText: '写下你的评论...', hintStyle: TextStyle(fontSize: 13, color: AppConfig.textSecondary), border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 8)), style: TextStyle(fontSize: 13)),
                )),
                const SizedBox(width: 8),
                GestureDetector(onTap: () { setState(() => post.comments++); Navigator.pop(ctx); }, child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppConfig.goldStart, AppConfig.goldEnd]), borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.send, size: 16, color: Colors.white))),
              ]),
            )),
          ]),
        ),
      ),
    );
  }

  Widget _cItem(String n, String t, String time) => Padding(
    padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 32, height: 32, decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppConfig.goldStart, AppConfig.goldEnd]), borderRadius: BorderRadius.circular(16)), child: Center(child: Text(n[0], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)))),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Text(n, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)), const SizedBox(width: 8), Text(time, style: const TextStyle(fontSize: 11, color: AppConfig.textSecondary))]),
        const SizedBox(height: 3), Text(t, style: const TextStyle(fontSize: 13, color: AppConfig.textPrimary, height: 1.4)),
      ])),
    ]),
  );

  void _showPublishSheet(BuildContext context) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(color: AppConfig.cardBg, borderRadius: BorderRadius.vertical(top: Radius.circular(AppConfig.dialogRadius))),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SafeArea(child: Padding(
          padding: const EdgeInsets.all(AppConfig.pageMargin),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 32, height: 4, decoration: BoxDecoration(color: AppConfig.divider, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 12),
            const Text('发布动态', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
            const SizedBox(height: 12),
            TextField(controller: controller, maxLines: 4, maxLength: 500, decoration: InputDecoration(hintText: '分享你的户外故事...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConfig.cardRadius), borderSide: const BorderSide(color: AppConfig.divider)), contentPadding: const EdgeInsets.all(12))),
            const SizedBox(height: 8),
            Row(children: [_pubBtn('关联路线', Icons.route_outlined), const SizedBox(width: 8), _pubBtn('照片', Icons.photo_outlined), const SizedBox(width: 8), _pubBtn('装备', Icons.checklist_outlined)]),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () { if (controller.text.trim().isNotEmpty) { setState(() { _posts.insert(0, _Post(postId: 'p${DateTime.now().millisecondsSinceEpoch}', user: _User('我', 'Lv.12', 128), body: controller.text.trim(), timeAgo: '刚刚', tags: [])); }); Navigator.pop(context); } }, style: ElevatedButton.styleFrom(backgroundColor: AppConfig.goldStart, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.buttonRadius)), padding: const EdgeInsets.symmetric(vertical: 14)), child: const Text('发布', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)))),
          ]),
        )),
      ),
    );
  }

  Widget _pubBtn(String label, IconData icon) {
    return OutlinedButton.icon(onPressed: () {}, icon: Icon(icon, size: 14), label: Text(label, style: const TextStyle(fontSize: 11)), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.tagRadius)), side: const BorderSide(color: AppConfig.divider), foregroundColor: AppConfig.textSecondary));
  }
}

class _User {
  final String name;
  final String level;
  final int posts;
  const _User(this.name, this.level, this.posts);
}

enum _AttachType { route, gear, track, photo, medal }

class _Attach {
  final _AttachType type;
  final String title;
  final String? sub;
  const _Attach._(this.type, this.title, this.sub);
  factory _Attach.route(String t, String s) => _Attach._(_AttachType.route, t, s);
  factory _Attach.gear(String t, String s) => _Attach._(_AttachType.gear, t, s);
  factory _Attach.track(String s) => _Attach._(_AttachType.track, '轨迹记录', s);
  factory _Attach.photo(int n) => _Attach._(_AttachType.photo, '$n张照片', null);
  factory _Attach.medal(String n, String d) => _Attach._(_AttachType.medal, n, d);

  IconData get icon => switch (type) { _AttachType.route => Icons.route_outlined, _AttachType.gear => Icons.checklist_outlined, _AttachType.track => Icons.timeline_outlined, _AttachType.photo => Icons.photo_outlined, _AttachType.medal => Icons.emoji_events_outlined };
  Color get color => switch (type) { _AttachType.route => AppConfig.cyclePrimary, _AttachType.gear => AppConfig.drivePrimary, _AttachType.track => AppConfig.motoPrimary, _AttachType.photo => AppConfig.textSecondary, _AttachType.medal => AppConfig.goldStart };
}

class _Post {
  final String postId;
  final _User user;
  final String body;
  final String timeAgo;
  int likes;
  int comments;
  int stars;
  final List<_Attach> attachments;
  final List<String> tags;

  _Post({required this.postId, required this.user, required this.body, required this.timeAgo, this.likes = 0, this.comments = 0, this.stars = 0, this.attachments = const [], this.tags = const [], this.postComments = const []});
  int get _hotScore => likes + comments * 3 + stars * 5;

  /// V6.5 Fix 8: 关联评论数据（不参与排序/序列化）
  final List<_Comment> postComments;
}

/// V6.5 Fix 8: 评论数据模型
class _Comment {
  final String user;
  final String text;
  final String timeAgo;
  const _Comment({required this.user, required this.text, required this.timeAgo});
}
