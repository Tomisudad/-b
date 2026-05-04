import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../config/scenario_config.dart';
import '../providers/scenario_provider.dart';
import '../providers/trip_provider.dart';
import '../models/trip_model.dart';
import 'offline_maps_page.dart';
import 'privacy_page.dart';
import 'user_agreement_page.dart';
import 'navigation_page.dart';

// ============================================================
// 我的个人中心（底部"我的"Tab）
// ============================================================
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final tripProv = context.watch<TripProvider>();
    final scenario = context.watch<ScenarioProvider>().scenario;
    final cfg = ScenarioConfig.of(scenario);

    final activeTrip = tripProv.activeTrip;
    final completed = tripProv.completedTrips;
    final totalKm = completed.fold<double>(0, (s, t) => s + t.totalDistanceKm);

    return Scaffold(
      backgroundColor: AppConfig.bgMain,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== 头像卡片 =====
              _buildAvatarCard(cfg),

              // ===== 数据面板 =====
              _buildStatPanel(totalKm, 0, completed.length),

              const SizedBox(height: AppConfig.sectionGap),

              // ===== 进行中行程 =====
              if (activeTrip != null)
                _buildActiveTrip(activeTrip, cfg),

              // ===== 功能列表 =====
              _buildFuncList(context),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== 头像卡片 ====================
  Widget _buildAvatarCard(ScenarioConfig cfg) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppConfig.pageMargin, 24, AppConfig.pageMargin, 24),
      decoration: const BoxDecoration(
        color: AppConfig.glassBg,
        border: Border(bottom: BorderSide(color: AppConfig.divider, width: 0.5)),
      ),
      child: Row(
        children: [
          // 头像
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cfg.primaryColor, cfg.primaryColor.withOpacity(0.6)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: cfg.primaryColor.withOpacity(0.25),
                  blurRadius: 12, offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text('🌍', style: TextStyle(fontSize: 28)),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('探险家 · 去野', style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700, color: AppConfig.textPrimary,
                )),
                const SizedBox(height: 4),
                const Text('用脚步丈量世界', style: TextStyle(
                  fontSize: 13, color: AppConfig.textSecondary,
                )),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: cfg.primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('Lv.5 行者', style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600, color: cfg.primaryColor,
                      )),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Icon(Icons.chevron_right, size: 24, color: AppConfig.textSecondary),
        ],
      ),
    );
  }

  // ==================== 数据面板 ====================
  Widget _buildStatPanel(double km, int climb, int routes) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin, vertical: AppConfig.cardGap),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppConfig.cardBg,
        borderRadius: BorderRadius.circular(AppConfig.cardRadius),
        boxShadow: AppConfig.cardShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statItem('累计里程', '${km.toStringAsFixed(0)} km'),
          _statItem('累计爬升', '$climb m'),
          _statItem('路线完成', '$routes 条'),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.w700, color: AppConfig.textPrimary,
        )),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(
          fontSize: 12, color: AppConfig.textSecondary,
        )),
      ],
    );
  }

  // ==================== 进行中行程 ====================
  Widget _buildActiveTrip(TripModel trip, ScenarioConfig cfg) {
    final scenario = context.read<ScenarioProvider>().scenario;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => NavigationPage(scenario: scenario),
          ));
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppConfig.cardBg,
            borderRadius: BorderRadius.circular(AppConfig.cardRadius),
            boxShadow: AppConfig.cardShadow,
            border: Border.all(color: AppConfig.goldStart.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.directions_bike, size: 24, color: AppConfig.goldEnd),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('进行中的行程', style: TextStyle(
                      fontSize: 12, color: AppConfig.textSecondary,
                    )),
                    Text('${trip.totalDistanceKm.toStringAsFixed(1)} km · 继续追踪', style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600, color: AppConfig.textPrimary,
                    )),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppConfig.goldStart.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('继续', style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: AppConfig.goldEnd,
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== 功能列表 ====================
  Widget _buildFuncList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConfig.pageMargin),
      child: Column(
        children: [
          const SizedBox(height: AppConfig.cardGap),

          _funcGroup('我的档案', [
            _FuncItem(Icons.route_outlined,  '我的轨迹',   AppConfig.cyclePrimary, () {}),
            _FuncItem(Icons.star_outlined,  '我的收藏',   AppConfig.goldStart, () {}),
            _FuncItem(Icons.emoji_events_outlined, '我的勋章', AppConfig.motoPrimary, () {}),
          ]),

          const SizedBox(height: AppConfig.cardGap),
          _funcGroup('探索', [
            _FuncItem(Icons.public_outlined, '我的地图',  AppConfig.drivePrimary, () {}),
            _FuncItem(Icons.auto_graph_outlined, '年度报告', AppConfig.cyclePrimary, () {}),
          ]),

          const SizedBox(height: AppConfig.cardGap),
          _funcGroup('工具', [
            _FuncItem(Icons.cloud_download_outlined, '离线地图', AppConfig.cyclePrimary, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const OfflineMapsPage()));
            }),
          ]),

          const SizedBox(height: AppConfig.cardGap),
          _funcGroup('设置', [
            _FuncItem(Icons.lock_outlined,        '隐私',      AppConfig.textSecondary, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPage()));
            }),
            _FuncItem(Icons.description_outlined, '用户协议',  AppConfig.textSecondary, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const UserAgreementPage()));
            }),
            _FuncItem(Icons.delete_outline_outlined, '缓存清理', AppConfig.textSecondary, () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('缓存已清理')),
              );
            }),
            _FuncItem(Icons.info_outline, '关于去野', AppConfig.textSecondary, () {
              showAboutDialog(
                context: context,
                applicationName: AppConfig.appName,
                applicationVersion: '1.1.0',
                children: [
                  const Text('去野 · 去探索\n户外移动指挥官'),
                ],
              );
            }),
          ]),
        ],
      ),
    );
  }

  Widget _funcGroup(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppConfig.cardBg,
        borderRadius: BorderRadius.circular(AppConfig.cardRadius),
        boxShadow: AppConfig.cardShadow,
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

// ===== 功能项 =====
class _FuncItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  const _FuncItem(this.icon, this.title, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w500, color: AppConfig.textPrimary,
              )),
            ),
            const Icon(Icons.chevron_right, size: 20, color: AppConfig.textSecondary),
          ],
        ),
      ),
    );
  }
}
