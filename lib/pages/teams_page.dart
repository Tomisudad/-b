import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../config/scenario_config.dart';
import '../providers/scenario_provider.dart';

// ============================================================
// 组队 Tab — 队伍列表 + 创建/加入 + 聊天 + 位置共享
// ============================================================
class TeamsListPage extends StatefulWidget {
  const TeamsListPage({super.key});

  @override
  State<TeamsListPage> createState() => _TeamsListPageState();
}

class _TeamsListPageState extends State<TeamsListPage> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scenario = context.watch<ScenarioProvider>().scenario;
    final cfg = ScenarioConfig.of(scenario);

    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      body: SafeArea(
        child: Column(
          children: [
            // ---- Header ----
            Container(
              padding: const EdgeInsets.fromLTRB(AppConfig.pageMargin, 8, AppConfig.pageMargin, 0),
              decoration: const BoxDecoration(
                color: AppConfig.glassBg,
                border: Border(bottom: BorderSide(color: AppConfig.divider, width: 0.5)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text('组队', style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w700, color: AppConfig.textPrimary,
                      )),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _showCreateTeamSheet(cfg),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: cfg.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.add, size: 22, color: cfg.primaryColor),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => _showJoinTeamSheet(cfg),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: AppConfig.motoPrimary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.search, size: 22, color: AppConfig.motoPrimary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TabBar(
                    controller: _tabCtrl,
                    indicatorColor: cfg.primaryColor,
                    labelColor: AppConfig.textPrimary,
                    unselectedLabelColor: AppConfig.textSecondary,
                    labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: const [
                      Tab(text: '我的队伍'),
                      Tab(text: '找搭子'),
                    ],
                  ),
                ],
              ),
            ),

            // ---- Body ----
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  _buildMyTeams(cfg),
                  _buildFindPartners(cfg),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 我的队伍 ====================
  Widget _buildMyTeams(ScenarioConfig cfg) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConfig.pageMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 进行中的队伍
          const Text('进行中', style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600, color: AppConfig.textSecondary,
          )),
          const SizedBox(height: AppConfig.cardGap),
          _teamCard(
            name: '环太湖摩旅小队',
            route: '环太湖线 168km',
            members: '3/5人',
            time: '明天 06:30 出发',
            color: cfg.primaryColor,
            active: true,
          ),
          const SizedBox(height: AppConfig.sectionGap),
          const Text('活动推荐', style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600, color: AppConfig.textSecondary,
          )),
          const SizedBox(height: AppConfig.cardGap),

          // 空状态
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(Icons.group_outlined, size: 56, color: AppConfig.textSecondary.withOpacity(0.3)),
                  const SizedBox(height: 12),
                  const Text('还没有加入队伍', style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w500, color: AppConfig.textSecondary,
                  )),
                  const SizedBox(height: 4),
                  const Text('创建一个队伍或搜索加入吧', style: TextStyle(
                    fontSize: 13, color: AppConfig.textSecondary,
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _teamCard({
    required String name,
    required String route,
    required String members,
    required String time,
    required Color color,
    bool active = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConfig.cardBg,
        borderRadius: BorderRadius.circular(AppConfig.cardRadius),
        boxShadow: AppConfig.cardShadow,
        border: active ? Border.all(color: color.withOpacity(0.3), width: 1) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.group_work_outlined, size: 24, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600, color: AppConfig.textPrimary,
                )),
                const SizedBox(height: 4),
                Text(route, style: const TextStyle(
                  fontSize: 13, color: AppConfig.textSecondary,
                )),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.people_outline, size: 14, color: AppConfig.textSecondary),
                    const SizedBox(width: 4),
                    Text(members, style: const TextStyle(
                      fontSize: 12, color: AppConfig.textSecondary,
                    )),
                    const SizedBox(width: 12),
                    const Icon(Icons.access_time, size: 14, color: AppConfig.textSecondary),
                    const SizedBox(width: 4),
                    Text(time, style: const TextStyle(
                      fontSize: 12, color: AppConfig.textSecondary,
                    )),
                  ],
                ),
              ],
            ),
          ),
          if (active)
            Icon(Icons.arrow_forward, size: 20, color: color.withOpacity(0.5)),
        ],
      ),
    );
  }

  // ==================== 找搭子 ====================
  Widget _buildFindPartners(ScenarioConfig cfg) {
    final partners = [
      _PartnerBrief('🚙 川藏线搭车', '自驾 · 318国道 · 成都→拉萨', '2/4人', cfg.primaryColor),
      _PartnerBrief('🏍️ 寻找摩旅伙伴', '摩旅 · 川西环线 · 5天', '1/3人', AppConfig.motoPrimary),
      _PartnerBrief('🚴 北京骑行搭子', '骑行 · 京郊 · 周末', '3/6人', AppConfig.cyclePrimary),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(AppConfig.pageMargin),
      itemCount: partners.length,
      itemBuilder: (ctx, i) {
        final p = partners[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppConfig.cardGap),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppConfig.cardBg,
              borderRadius: BorderRadius.circular(AppConfig.cardRadius),
              boxShadow: AppConfig.cardShadow,
            ),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: p.color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.person_search_outlined, size: 24, color: p.color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.title, style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600, color: AppConfig.textPrimary,
                      )),
                      const SizedBox(height: 3),
                      Text(p.desc, style: const TextStyle(
                        fontSize: 13, color: AppConfig.textSecondary,
                      )),
                      const SizedBox(height: 3),
                      Text(p.count, style: TextStyle(
                        fontSize: 12, color: p.color, fontWeight: FontWeight.w500,
                      )),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, size: 20, color: AppConfig.textSecondary.withOpacity(0.5)),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==================== 创建队伍弹窗 ====================
  void _showCreateTeamSheet(ScenarioConfig cfg) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppConfig.cardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppConfig.dialogRadius)),
        ),
        padding: const EdgeInsets.all(AppConfig.pageMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: AppConfig.divider, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('创建队伍', style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700, color: AppConfig.textPrimary,
            )),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: '队伍名称', hintText: '如：环太湖骑友小队'),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(labelText: '关联路线', hintText: '选择一条路线'),
              readOnly: true,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: '人数上限'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: '出发时间'),
                    readOnly: true,
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: AppConfig.primaryBtnH,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: goldGradient,
                  borderRadius: BorderRadius.all(Radius.circular(AppConfig.buttonRadius)),
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.buttonRadius)),
                  ),
                  child: const Text('创建队伍', style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600, color: AppConfig.textInverse,
                  )),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showJoinTeamSheet(ScenarioConfig cfg) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(AppConfig.pageMargin),
        decoration: const BoxDecoration(
          color: AppConfig.cardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppConfig.dialogRadius)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('加入队伍', style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700, color: AppConfig.textPrimary,
            )),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: '队伍ID',
                hintText: '输入6位队伍ID或扫码',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: AppConfig.primaryBtnH,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: goldGradient,
                  borderRadius: BorderRadius.all(Radius.circular(AppConfig.buttonRadius)),
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.buttonRadius)),
                  ),
                  child: const Text('加入', style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600, color: AppConfig.textInverse,
                  )),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _PartnerBrief {
  final String title, desc, count;
  final Color color;
  const _PartnerBrief(this.title, this.desc, this.count, this.color);
}
