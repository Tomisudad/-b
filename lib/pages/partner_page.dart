import 'package:flutter/material.dart';
import 'dart:ui';

import '../config/app_config.dart';

/// 搭子页面 — 寻找同行伙伴
class PartnerPage extends StatefulWidget {
  const PartnerPage({super.key});

  @override
  State<PartnerPage> createState() => _PartnerPageState();
}

class _PartnerPageState extends State<PartnerPage> {
  int _tabIndex = 0; // 0=附近队伍, 1=临时搭子, 2=我的队伍

  static const _tabs = ['附近队伍', '临时搭子', '我的队伍'];

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
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppConfig.pageMargin, vertical: 12),
                    child: Row(
                      children: [
                        Text('搭子', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
                        Spacer(),
                      ],
                    ),
                  ),
                  // Tab 切换
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppConfig.pageMargin, 0, AppConfig.pageMargin, 8),
                    child: Row(
                      children: List.generate(3, (i) {
                        final isActive = _tabIndex == i;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _tabIndex = i),
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
                              child: Text(
                                _tabs[i],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                                  color: isActive ? AppConfig.cyclePrimary : AppConfig.textSecondary,
                                ),
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
        // 内容区
        Expanded(
          child: IndexedStack(
            index: _tabIndex,
            children: [
              _NearbyTeamsTab(),
              _TemporaryPartnerTab(),
              _MyTeamsTab(),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// 附近队伍
// ============================================================
class _NearbyTeamsTab extends StatelessWidget {
  final List<_TeamData> _teams = const [
    _TeamData('山野行者', '川西小环线', '3/5', '招募中', '2h后出发'),
    _TeamData('追风骑士', '皖南川藏线', '4/6', '招募中', '明天 7:00'),
    _TeamData('自由之翼', '太湖东山', '2/4', '进行中', '正在进行'),
    _TeamData('独行侠', '太行天路', '5/8', '招募中', '后天 6:30'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConfig.pageMargin),
      itemCount: _teams.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppConfig.cardGap),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    label: const Text('创建队伍'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppConfig.cyclePrimary,
                      side: const BorderSide(color: AppConfig.cyclePrimary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.explore_outlined, size: 18),
                    label: const Text('发现搭子'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppConfig.textSecondary,
                      side: const BorderSide(color: AppConfig.divider),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        final team = _teams[index - 1];
        return _TeamCard(team: team);
      },
    );
  }
}

class _TeamCard extends StatelessWidget {
  final _TeamData team;
  const _TeamCard({required this.team});

  @override
  Widget build(BuildContext context) {
    final isRecruiting = team.status == '招募中';
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
            // 头像
            CircleAvatar(
              radius: 22,
              backgroundColor: AppConfig.cyclePrimary.withOpacity(0.1),
              child: Text(team.leader.substring(0, 1), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppConfig.cyclePrimary)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(team.leader, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
                  const SizedBox(height: 4),
                  Text(team.route, style: const TextStyle(fontSize: 13, color: AppConfig.textSecondary)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.group, size: 13, color: AppConfig.textSecondary.withOpacity(0.6)),
                      const SizedBox(width: 4),
                      Text(team.members, style: TextStyle(fontSize: 12, color: AppConfig.textSecondary.withOpacity(0.7))),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time, size: 13, color: AppConfig.textSecondary.withOpacity(0.6)),
                      const SizedBox(width: 4),
                      Text(team.time, style: TextStyle(fontSize: 12, color: AppConfig.textSecondary.withOpacity(0.7))),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isRecruiting ? AppConfig.cyclePrimary.withOpacity(0.1) : AppConfig.textSecondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                team.status,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isRecruiting ? AppConfig.cyclePrimary : AppConfig.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamData {
  final String leader;
  final String route;
  final String members;
  final String status;
  final String time;
  const _TeamData(this.leader, this.route, this.members, this.status, this.time);
}

// ============================================================
// 临时搭子
// ============================================================
class _TemporaryPartnerTab extends StatelessWidget {
  final List<_TempPartnerData> _partners = const [
    _TempPartnerData('骑行之鹰', '环太湖路线', 1.2, '同向'),
    _TempPartnerData('山路行者', '莫干山爬坡', 2.8, '同向'),
    _TempPartnerData('追风少年', '千岛湖绿道', 0.5, '反向'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(AppConfig.pageMargin),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppConfig.cyclePrimary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(AppConfig.cardRadius),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: AppConfig.cyclePrimary),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  '开启位置共享并处于行程中时，可发现附近同向出行者',
                  style: TextStyle(fontSize: 12, color: AppConfig.textSecondary),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
            itemCount: _partners.length,
            itemBuilder: (context, index) {
              final p = _partners[index];
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
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppConfig.motoPrimary.withOpacity(0.1),
                        child: Text(p.name.substring(0, 1), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConfig.motoPrimary)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConfig.textPrimary)),
                            const SizedBox(height: 2),
                            Text('${p.route} · ${p.distanceKm}km · ${p.direction}',
                              style: const TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          foregroundColor: AppConfig.cyclePrimary,
                          side: const BorderSide(color: AppConfig.cyclePrimary),
                        ),
                        child: const Text('打招呼', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TempPartnerData {
  final String name;
  final String route;
  final double distanceKm;
  final String direction;
  const _TempPartnerData(this.name, this.route, this.distanceKm, this.direction);
}

// ============================================================
// 我的队伍
// ============================================================
class _MyTeamsTab extends StatelessWidget {
  final List<_MyTeamData> _myTeams = const [
    _MyTeamData('周末骑行小队', '4人', '太湖东山', '明天 8:00'),
  ];

  @override
  Widget build(BuildContext context) {
    if (_myTeams.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.group_outlined, size: 48, color: AppConfig.textSecondary.withOpacity(0.3)),
            const SizedBox(height: 12),
            const Text('还没有加入队伍', style: TextStyle(fontSize: 14, color: AppConfig.textSecondary)),
            const SizedBox(height: 4),
            const Text('去发现搭子或创建队伍吧', style: TextStyle(fontSize: 12, color: AppConfig.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConfig.pageMargin),
      itemCount: _myTeams.length,
      itemBuilder: (context, index) {
        final team = _myTeams[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppConfig.cardGap),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppConfig.cardBg,
              borderRadius: BorderRadius.circular(AppConfig.cardRadius),
              boxShadow: AppConfig.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(team.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppConfig.textPrimary)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppConfig.cyclePrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('待出发', style: TextStyle(fontSize: 11, color: AppConfig.cyclePrimary, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.group, size: 14, color: AppConfig.textSecondary),
                    const SizedBox(width: 4),
                    Text(team.members, style: const TextStyle(fontSize: 13, color: AppConfig.textSecondary)),
                    const SizedBox(width: 16),
                    Icon(Icons.route_outlined, size: 14, color: AppConfig.textSecondary.withOpacity(0.6)),
                    const SizedBox(width: 4),
                    Text(team.route, style: TextStyle(fontSize: 13, color: AppConfig.textSecondary.withOpacity(0.7))),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: AppConfig.textSecondary.withOpacity(0.5)),
                    const SizedBox(width: 4),
                    Text(team.time, style: TextStyle(fontSize: 13, color: AppConfig.textSecondary.withOpacity(0.6))),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppConfig.divider),
                          foregroundColor: AppConfig.textPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Text('位置共享', style: TextStyle(fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppConfig.divider),
                          foregroundColor: AppConfig.textPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Text('队内聊天', style: TextStyle(fontSize: 13)),
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
}

class _MyTeamData {
  final String name;
  final String members;
  final String route;
  final String time;
  const _MyTeamData(this.name, this.members, this.route, this.time);
}
