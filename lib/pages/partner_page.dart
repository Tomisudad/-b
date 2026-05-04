import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/scenario.dart';

/// V5.0 搭子页面 - 统一发现/组队列表
class PartnerPage extends StatefulWidget {
  const PartnerPage({super.key});

  @override
  State<PartnerPage> createState() => _PartnerPageState();
}

class _PartnerPageState extends State<PartnerPage> {
  OutdoorScenario? _filterScenario;

  // Mock 搭子数据
  late final List<_BuddyData> _buddies;

  @override
  void initState() {
    super.initState();
    _buddies = _genMockBuddies();
  }

  List<_BuddyData> _genMockBuddies() {
    return [
      _BuddyData('山野骑客', OutdoorScenario.cycle, 2.3, _BuddyStatus.inGroup, 3, 5, route: '太湖东山半岛'),
      _BuddyData('追风骑士', OutdoorScenario.moto, 5.1, _BuddyStatus.inGroup, 2, 4, route: '皖南川藏线'),
      _BuddyData('远方行者', OutdoorScenario.drive, 8.7, _BuddyStatus.solo, 1, 1, dir: '西'),
      _BuddyData('骑行小白', OutdoorScenario.cycle, 1.5, _BuddyStatus.planning, 1, 3, planTime: '明天 8:00'),
      _BuddyData('摩旅老王', OutdoorScenario.moto, 3.2, _BuddyStatus.solo, 1, 1, dir: '北'),
      _BuddyData('露营达人', OutdoorScenario.drive, 6.4, _BuddyStatus.inGroup, 4, 4, route: '独库公路全程'),
      _BuddyData('周末骑士', OutdoorScenario.cycle, 0.8, _BuddyStatus.planning, 1, 2, planTime: '周六 6:30'),
      _BuddyData('川藏老炮', OutdoorScenario.moto, 12.0, _BuddyStatus.inGroup, 3, 5, route: 'G318川藏线'),
      _BuddyData('雪山行者', OutdoorScenario.drive, 4.5, _BuddyStatus.solo, 1, 1, dir: '南'),
      _BuddyData('城市骑手', OutdoorScenario.cycle, 1.2, _BuddyStatus.planning, 1, 3, planTime: '今晚 19:00'),
    ];
  }

  List<_BuddyData> get _filtered {
    if (_filterScenario == null) return _buddies;
    return _buddies.where((b) => b.scenario == _filterScenario).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 顶栏
        _buildHeader(context),
        // 筛选栏
        _buildFilterBar(),
        // 列表
        Expanded(child: _buildBuddyList()),
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
            const Text('搭子', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
            const Spacer(),
            // 创建组队
            ElevatedButton.icon(
              onPressed: () => _showCreateTeamSheet(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('创建组队', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConfig.cyclePrimary,
                foregroundColor: AppConfig.textInverse,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppConfig.pageMargin, 10, AppConfig.pageMargin, 8),
      child: Row(
        children: [
          _filterChip('全部', null),
          const SizedBox(width: 8),
          _filterChip('🚴 骑行', OutdoorScenario.cycle),
          const SizedBox(width: 8),
          _filterChip('🏍️ 摩旅', OutdoorScenario.moto),
          const SizedBox(width: 8),
          _filterChip('🚙 自驾', OutdoorScenario.drive),
        ],
      ),
    );
  }

  Widget _filterChip(String label, OutdoorScenario? val) {
    final active = _filterScenario == val;
    final color = val == null
        ? AppConfig.textPrimary
        : val == OutdoorScenario.cycle ? AppConfig.cyclePrimary
        : val == OutdoorScenario.moto ? AppConfig.motoPrimary : AppConfig.drivePrimary;

    return GestureDetector(
      onTap: () => setState(() => _filterScenario = val),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.1) : AppConfig.bgMain,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? color : AppConfig.divider,
            width: active ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            color: active ? color : AppConfig.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildBuddyList() {
    final items = _filtered..sort((a, b) => a.distance.compareTo(b.distance));
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🔍', style: TextStyle(fontSize: 48, color: AppConfig.textPrimary.withOpacity(0.15))),
            const SizedBox(height: 12),
            const Text('附近暂时没有搭子', style: TextStyle(fontSize: 14, color: AppConfig.textSecondary)),
            const SizedBox(height: 4),
            const Text('换个场景试试？', style: TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
      itemCount: items.length,
      itemBuilder: (ctx, i) => _BuddyCard(buddy: items[i]),
    );
  }

  void _showCreateTeamSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppConfig.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConfig.dialogRadius)),
      ),
      builder: (_) => _CreateTeamSheet(),
    );
  }
}

// ============================================================
// 搭子卡片
// ============================================================
class _BuddyCard extends StatelessWidget {
  final _BuddyData buddy;
  const _BuddyCard({required this.buddy});

  @override
  Widget build(BuildContext context) {
    final color = buddy.scenario == OutdoorScenario.cycle ? AppConfig.cyclePrimary
        : buddy.scenario == OutdoorScenario.moto ? AppConfig.motoPrimary : AppConfig.drivePrimary;
    final emoji = buddy.scenario == OutdoorScenario.cycle ? '🚴'
        : buddy.scenario == OutdoorScenario.moto ? '🏍️' : '🚙';
    final label = buddy.scenario == OutdoorScenario.cycle ? '骑行'
        : buddy.scenario == OutdoorScenario.moto ? '摩旅' : '自驾';

    String? buttonText;
    Color? btnBg;
    Color? btnFg;
    bool btnEnabled = true;

    switch (buddy.status) {
      case _BuddyStatus.inGroup when buddy.filled >= buddy.capacity:
        buttonText = '已满';
        btnBg = AppConfig.divider;
        btnFg = AppConfig.textSecondary;
        btnEnabled = false;
        break;
      case _BuddyStatus.inGroup:
        buttonText = '申请加入';
        btnBg = color;
        btnFg = AppConfig.textInverse;
        break;
      case _BuddyStatus.solo:
        buttonText = '⚡打招呼';
        btnBg = color;
        btnFg = AppConfig.textInverse;
        break;
      case _BuddyStatus.planning:
        buttonText = '申请加入';
        btnBg = color;
        btnFg = AppConfig.textInverse;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConfig.cardGap),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppConfig.cardBg,
          borderRadius: BorderRadius.circular(AppConfig.cardRadius),
          boxShadow: AppConfig.cardShadow,
        ),
        child: Row(
          children: [
            // 头像
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withOpacity(0.1),
              child: Text(emoji, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 12),
            // 信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(buddy.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(label, style: TextStyle(fontSize: 10, color: color)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _statusText(),
                    style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: btnEnabled
                  ? () {
                      if (buddy.status == _BuddyStatus.solo) {
                        _showSayHiSheet(context, buddy);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('已向 ${buddy.name} 发送申请')),
                        );
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: btnBg,
                foregroundColor: btnFg,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
                disabledBackgroundColor: AppConfig.divider,
                disabledForegroundColor: AppConfig.textSecondary,
              ),
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }

  String _statusText() {
    switch (buddy.status) {
      case _BuddyStatus.inGroup: return '${buddy.filled}/${buddy.capacity}人 · ${buddy.route ?? ""}';
      case _BuddyStatus.solo: return '${buddy.distance}km · 向${buddy.dir ?? ""}方向';
      case _BuddyStatus.planning: return '计划 ${buddy.planTime ?? ""} · ${buddy.filled}/${buddy.capacity}人';
    }
  }

  void _showSayHiSheet(BuildContext context, _BuddyData buddy) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppConfig.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConfig.dialogRadius)),
      ),
      builder: (_) => _SayHiSheet(buddy: buddy),
    );
  }
}

// ============================================================
// 打招呼面板
// ============================================================
class _SayHiSheet extends StatelessWidget {
  final _BuddyData buddy;
  const _SayHiSheet({required this.buddy});

  static const _presets = [
    '嗨！我看到你也在附近骑行～',
    '你好，我也在这条路上，方便组个队吗？',
    '加油！前方路况如何？',
    '哈喽，要不要一起找个地方休息？',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppConfig.pageMargin),
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
            const SizedBox(height: 16),
            Text('向 ${buddy.name} 打招呼', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
            const SizedBox(height: 6),
            Text('对方大致的方位和距离：${buddy.distance}km', style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
            const SizedBox(height: 16),
            ..._presets.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: AppConfig.bgMain,
                borderRadius: BorderRadius.circular(AppConfig.cardRadius),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppConfig.cardRadius),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('已向 ${buddy.name} 发送：$p')),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Expanded(child: Text(p, style: const TextStyle(fontSize: 14, color: AppConfig.textPrimary))),
                        const SizedBox(width: 8),
                        const Icon(Icons.send_outlined, size: 16, color: AppConfig.textSecondary),
                      ],
                    ),
                  ),
                ),
              ),
            )),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: AppConfig.secondaryBtnH,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('自定义消息', style: TextStyle(fontSize: 14, color: AppConfig.textSecondary)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 创建组队面板
// ============================================================
class _CreateTeamSheet extends StatefulWidget {
  @override
  State<_CreateTeamSheet> createState() => _CreateTeamSheetState();
}

class _CreateTeamSheetState extends State<_CreateTeamSheet> {
  OutdoorScenario _scene = OutdoorScenario.cycle;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppConfig.pageMargin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(color: AppConfig.textSecondary.withOpacity(0.3), borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            const Text('创建组队', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
            const SizedBox(height: 20),
            // 场景选择
            const Text('选择场景', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppConfig.textPrimary)),
            const SizedBox(height: 10),
            Row(
              children: [
                _sceneBtn('🚴 骑行', OutdoorScenario.cycle, AppConfig.cyclePrimary),
                const SizedBox(width: 8),
                _sceneBtn('🏍️ 摩旅', OutdoorScenario.moto, AppConfig.motoPrimary),
                const SizedBox(width: 8),
                _sceneBtn('🚙 自驾', OutdoorScenario.drive, AppConfig.drivePrimary),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
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
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('队伍创建成功！分享队伍码给好友即可加入')));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                  child: const Text('创建队伍', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppConfig.textInverse)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sceneBtn(String text, OutdoorScenario s, Color c) {
    final active = _scene == s;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _scene = s),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? c.withOpacity(0.1) : AppConfig.bgMain,
            borderRadius: BorderRadius.circular(AppConfig.cardRadius),
            border: Border.all(color: active ? c : AppConfig.divider, width: active ? 2 : 1),
          ),
          child: Text(text, textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontWeight: active ? FontWeight.w600 : FontWeight.w400, color: active ? c : AppConfig.textSecondary)),
        ),
      ),
    );
  }
}

// ============================================================
// 数据模型
// ============================================================
enum _BuddyStatus { inGroup, solo, planning }

class _BuddyData {
  final String name;
  final OutdoorScenario scenario;
  final double distance;
  final _BuddyStatus status;
  final int filled;
  final int capacity;
  final String? route;
  final String? dir;
  final String? planTime;

  const _BuddyData(this.name, this.scenario, this.distance, this.status, this.filled, this.capacity, {this.route, this.dir, this.planTime});
}
