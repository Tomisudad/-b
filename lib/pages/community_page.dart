import 'dart:ui';
import 'package:flutter/material.dart';
import '../config/app_config.dart';

/// V5.2 社区页面 — 统一信息流（全部/关注），附件自动识别渲染
class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> with TickerProviderStateMixin {
  bool _showFollowing = false;
  String _sortBy = 'hot';
  final Set<String> _likedPosts = {};
  final Set<String> _starredPosts = {};
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
      _Post(postId: 'p2', user: _User('追风骑士', 'Lv.18', 342), body: '皖南川藏线骑行归来。发卡弯一个接一个，爬坡爬到怀疑人生。沿途的竹林和云海是最大的奖励。推荐给所有骑友 🚴', timeAgo: '15分钟前', likes: 56, comments: 12, stars: 8, attachments: [
        _Attach.route('皖南川藏线', '120km · 挑战 · 2200m爬升'),
        _Attach.track('轨迹记录 · 4.2h'),
        _Attach.photo(6),
      ], tags: ['骑行', '皖南']),
      _Post(postId: 'p3', user: _User('户外老炮', 'Lv.35', 1204), body: '青海大环线第六次走了。这次带新人，讲一下必经的坑：1) 茶卡盐湖下午去拍不到镜面，必须日出 2) 大柴旦翡翠湖别开车进去 3) 敦煌鸣沙山买鞋套不如光脚。详细路书在主页。', timeAgo: '1小时前', likes: 1893, comments: 210, stars: 127, attachments: [
        _Attach.route('青海甘肃大环线', '1800km · 资深 · 6500m爬升'),
        _Attach.gear('骑行露营装备清单', '11项装备'),
      ], tags: ['骑行', '西北', '攻略']),
      _Post(postId: 'p4', user: _User('骑行小白', 'Lv.5', 18), body: '第一次骑长途，龙井爬坡记录。老哥们帮我看看这速度正常吗？感觉坡上去腿已经不是自己的了 😂', timeAgo: '2小时前', likes: 12, comments: 8, stars: 1, attachments: [
        _Attach.track('8.4km · 310m爬升 · 0.9h'),
      ], tags: ['骑行', '新手', '杭州']),
      _Post(postId: 'p5', user: _User('路书达人', 'Lv.22', 560), body: '【太行天路详解】全长95km，翻越三个山口，难度不高但风景绝了。附：最佳季节、补给点、住宿推荐。', timeAgo: '3小时前', likes: 782, comments: 178, stars: 53, attachments: [
        _Attach.route('太行天路', '95km · 进阶 · 1800m爬升'),
      ], tags: ['骑行', '太行山', '路书']),
      _Post(postId: 'p6', user: _User('露营日记', 'Lv.10', 89), body: '德清莫干山下的新露营地，有水电有厕所，晚上能看到银河。🌌', timeAgo: '昨天', likes: 45, comments: 18, stars: 8, attachments: [
        _Attach.photo(3),
        _Attach.gear('骑行露营装备', '11项装备'),
      ], tags: ['露营', '骑行', '浙江']),
    // V6.1: 替换为骑摄天下 (1205/42/98)
      _Post(postId: 'p7', user: _User('骑摄天下', 'Lv.28', 680), body: '太湖日落，美到窒息。环湖骑一圈，东山半岛的光影绝了。相机根本停不下来 📸', timeAgo: '昨天', likes: 1205, comments: 152, stars: 42, attachments: [
        _Attach.route('太湖东山半岛', '28km · 新手 · 150m爬升'),
        _Attach.photo(9),
      ], tags: ['骑行', '太湖', '摄影']),
      _Post(postId: 'p8', user: _User('装备党', 'Lv.20', 340), body: '新入手了一套骑行装备，用了一周来反馈：头盔够用但透气性一般；手套强烈推荐，长时间握把不酸。', timeAgo: '前天', likes: 456, comments: 178, stars: 89, attachments: [
        _Attach.gear('骑行基础装备', '12项装备'),
      ], tags: ['装备', '骑行', '评测']),
    ];
  }

  List<_Post> get _sortedPosts {
    var list = _posts.toList();
    if (_showFollowing) list = list.where((p) => p.isFollowing).toList();
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
      floatingActionButton: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppConfig.cyclePrimary, width: 2),
              boxShadow: [BoxShadow(color: AppConfig.cyclePrimary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
            ),
          ),
          FloatingActionButton(
            onPressed: () => _showPublishSheet(context),
            backgroundColor: Colors.white,
            elevation: 0,
            shape: const CircleBorder(),
            child: const Icon(Icons.edit_outlined, color: AppConfig.cyclePrimary, size: 24),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
        Text(post.body, style: const TextStyle(fontSize: 14, color: AppConfig.textBody, height: 1.5)),
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
          _AnimatedActionBtn(
            isActive: _likedPosts.contains(post.postId),
            activeIcon: Icons.favorite,
            inactiveIcon: Icons.favorite_border,
            activeColor: AppConfig.sosRed,
            label: '${post.likes}',
            onTap: () => setState(() {
              if (_likedPosts.contains(post.postId)) {
                _likedPosts.remove(post.postId);
                post.likes--;
              } else {
                _likedPosts.add(post.postId);
                post.likes++;
              }
            }),
          ),
          const SizedBox(width: 20),
          _actionBtn(Icons.chat_bubble_outline, '${post.comments}', () => _showComments(context, post)),
          const Spacer(),
          _AnimatedActionBtn(
            isActive: _starredPosts.contains(post.postId),
            activeIcon: Icons.star,
            inactiveIcon: Icons.star_border,
            activeColor: AppConfig.goldStart,
            label: '${post.stars}',
            onTap: () => setState(() {
              if (_starredPosts.contains(post.postId)) {
                _starredPosts.remove(post.postId);
                post.stars--;
              } else {
                _starredPosts.add(post.postId);
                post.stars++;
              }
            }),
          ),
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

  // V7.6: 评论半屏 — 接入 postComments 数据
  void _showComments(BuildContext context, _Post post) {
    final commentCtrl = TextEditingController();
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5, minChildSize: 0.3, maxChildSize: 0.8,
        builder: (_, scrollCtrl) => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                color: AppConfig.cardBg.withOpacity(0.95),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Stack(children: [
                ListView(controller: scrollCtrl, padding: const EdgeInsets.only(bottom: 80), children: [
                  Center(child: Container(margin: const EdgeInsets.only(top: 10, bottom: 4), width: 32, height: 4, decoration: BoxDecoration(color: AppConfig.divider, borderRadius: BorderRadius.circular(2)))),
                  Padding(padding: const EdgeInsets.fromLTRB(14, 6, 14, 10), child: Text('评论 (${post.postComments.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConfig.textPrimary))),
                  const Divider(height: 1, color: AppConfig.divider),
                  if (post.postComments.isEmpty)
                    const Padding(padding: EdgeInsets.all(32), child: Center(child: Text('暂无评论，来抢沙发吧 😊', style: TextStyle(color: AppConfig.textSecondary, fontSize: 13)))),
                  ...post.postComments.map((c) => _cItem(c.user, c.text, c.timeAgo)),
                ]),
                // 底部评论输入条
                Positioned(bottom: 0, left: 0, right: 0, child: Container(
                  padding: EdgeInsets.fromLTRB(14, 8, 14, MediaQuery.of(context).padding.bottom + 8),
                  decoration: const BoxDecoration(color: AppConfig.cardBg, border: Border(top: BorderSide(color: AppConfig.divider))),
                  child: Row(children: [
                    // V7.7: @ 提及按钮
                    GestureDetector(
                      onTap: () => _showMentionSheet(ctx, commentCtrl),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.alternate_email, size: 16, color: AppConfig.cyclePrimary),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: AppConfig.bgMain, borderRadius: BorderRadius.circular(20)),
                      child: TextField(controller: commentCtrl, decoration: const InputDecoration(hintText: '写下你的评论...', hintStyle: TextStyle(fontSize: 13, color: AppConfig.textSecondary), border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 8)), style: const TextStyle(fontSize: 13)),
                    )),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        final text = commentCtrl.text.trim();
                        if (text.isNotEmpty) {
                          setState(() {
                            post.postComments = [...post.postComments, _Comment(user: '我', text: text, timeAgo: '刚刚')];
                            post.comments++;
                          });
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('评论成功')));
                        }
                      },
                      child: Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppConfig.goldStart, AppConfig.goldEnd]), borderRadius: BorderRadius.all(Radius.circular(20))), child: const Icon(Icons.send, size: 16, color: Colors.white)),
                    ),
                  ]),
                )),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  // V7.7: @ 提及用户列表
  void _showMentionSheet(BuildContext parentCtx, TextEditingController ctrl) {
    const users = [
      _MentionUser('Kevin', 'Lv.15', '杭州'), _MentionUser('小明', 'Lv.8', '上海'),
      _MentionUser('阿维', 'Lv.12', '北京'), _MentionUser('Luna', 'Lv.10', '成都'),
      _MentionUser('山野行者', 'Lv.20', '拉萨'), _MentionUser('骑行少女', 'Lv.7', '厦门'),
    ];
    showModalBottomSheet(
      context: parentCtx, backgroundColor: AppConfig.cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(child: Padding(padding: const EdgeInsets.all(14), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('提及用户', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
        const SizedBox(height: 8),
        ...users.map((u) => ListTile(
          dense: true, contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(radius: 16, backgroundColor: AppConfig.cyclePrimary.withOpacity(0.15), child: Text(u.name[0], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppConfig.cyclePrimary))),
          title: Row(children: [Text(u.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)), const SizedBox(width: 6), Text(u.level, style: const TextStyle(fontSize: 10, color: AppConfig.textSecondary)), const Spacer(), Text(u.city, style: const TextStyle(fontSize: 10, color: AppConfig.textSecondary))]),
          onTap: () {
            ctrl.text += '@${u.name} ';
            ctrl.selection = TextSelection.collapsed(offset: ctrl.text.length);
            Navigator.pop(parentCtx);
          },
        )),
      ]))),
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
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () { if (controller.text.trim().isNotEmpty) { setState(() { _posts.insert(0, _Post(postId: 'p${DateTime.now().millisecondsSinceEpoch}', user: _User('我', 'Lv.12', 128), body: controller.text.trim(), timeAgo: '刚刚', tags: [])); }); Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('发布成功'), backgroundColor: AppConfig.cyclePrimary, duration: Duration(seconds: 2))); } }, style: ElevatedButton.styleFrom(backgroundColor: AppConfig.goldStart, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.buttonRadius)), padding: const EdgeInsets.symmetric(vertical: 14)), child: const Text('发布', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)))),
          ]),
        )),
      ),
    );
  }

  Widget _pubBtn(String label, IconData icon) {
    return OutlinedButton.icon(
      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label 功能开发中...'), duration: const Duration(seconds: 1))),
      icon: Icon(icon, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 11)),
      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.tagRadius)), side: const BorderSide(color: AppConfig.divider), foregroundColor: AppConfig.textSecondary));
  }
}

// V7.6: 带弹性动画的互动按钮
class _AnimatedActionBtn extends StatefulWidget {
  final bool isActive;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final Color activeColor;
  final String label;
  final VoidCallback onTap;

  const _AnimatedActionBtn({
    super.key,
    required this.isActive,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.activeColor,
    required this.label,
    required this.onTap,
  });

  @override
  State<_AnimatedActionBtn> createState() => _AnimatedActionBtnState();
}

class _AnimatedActionBtnState extends State<_AnimatedActionBtn> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    _ctrl.forward(from: 0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isActive;
    final icon = isActive ? widget.activeIcon : widget.inactiveIcon;
    final color = isActive ? widget.activeColor : AppConfig.textSecondary;
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(
          scale: _scale.value,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 3),
            Text(widget.label, style: TextStyle(fontSize: 13, color: color)),
          ]),
        ),
      ),
    );
  }
}

class _MentionUser { final String name; final String level; final String city; const _MentionUser(this.name, this.level, this.city); }

class _User {
  final String name;
  final String level;
  final int posts;
  const _User(this.name, this.level, this.posts);
}

enum _AttachType { route, gear, track, photo }

class _Attach {
  final _AttachType type;
  final String title;
  final String? sub;
  const _Attach._(this.type, this.title, this.sub);
  factory _Attach.route(String t, String s) => _Attach._(_AttachType.route, t, s);
  factory _Attach.gear(String t, String s) => _Attach._(_AttachType.gear, t, s);
  factory _Attach.track(String s) => _Attach._(_AttachType.track, '轨迹记录', s);
  factory _Attach.photo(int n) => _Attach._(_AttachType.photo, '$n张照片', null);

  IconData get icon => switch (type) { _AttachType.route => Icons.route_outlined, _AttachType.gear => Icons.checklist_outlined, _AttachType.track => Icons.timeline_outlined, _AttachType.photo => Icons.photo_outlined };
  Color get color => switch (type) { _AttachType.route => AppConfig.cyclePrimary, _AttachType.gear => AppConfig.accentBlue, _AttachType.track => AppConfig.accentOrange, _AttachType.photo => AppConfig.textSecondary };
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
  bool isFollowing = false;

  _Post({required this.postId, required this.user, required this.body, required this.timeAgo, this.likes = 0, this.comments = 0, this.stars = 0, this.attachments = const [], this.tags = const []});
  int get _hotScore => likes + comments * 3 + stars * 5;

  /// V6.5 Fix 8: 关联评论数据
  List<_Comment> postComments = const [];
}

/// V6.5 Fix 8: 评论数据模型
class _Comment {
  final String user;
  final String text;
  final String timeAgo;
  const _Comment({required this.user, required this.text, required this.timeAgo});
}
