import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/scenario_provider.dart';
import '../providers/auth_provider.dart';
import '../config/scenario_config.dart';
import '../theme/app_theme.dart';
import '../models/user_model.dart';
import '../models/route_model.dart';
import 'offline_maps_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _trips = _mockTrips();

  @override
  Widget build(BuildContext context) {
    final scenario = context.watch<ScenarioProvider>().scenario;
    final sceneColor = ScenarioConfig.of(scenario).primaryColor;
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppTheme.secondaryBg,
      body: CustomScrollView(
        slivers: [
          // ===== 个人信息卡片 =====
          SliverToBoxAdapter(child: _buildProfileCard(user, sceneColor)),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // ===== 车库 / 装备墙 / 勋章墙 =====
          SliverToBoxAdapter(child: _buildCollectionsRow(auth)),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // ===== 历史行程 =====
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text('历史行程', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
            ),
          ),
          if (_trips.isEmpty)
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(32),
                child: const Text('还没有行程记录。去出发吧。', textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _buildTripCard(_trips[i], sceneColor),
                childCount: _trips.length,
              ),
            ),

          // 设置入口
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListTile(
                leading: const Icon(Icons.settings_outlined, color: AppTheme.textSecondary),
                title: const Text('设置', style: TextStyle(fontSize: 15)),
                trailing: const Icon(Icons.chevron_right),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                tileColor: Colors.white,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => _SettingsPage(sceneColor: sceneColor, user: user)),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildProfileCard(UserModel user, Color sceneColor) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 56, 16, 24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppTheme.secondaryBg,
            child: Text(user.nickname.isNotEmpty ? user.nickname[0] : '?',
              style: const TextStyle(fontSize: 24, color: AppTheme.textSecondary)),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(user.nickname.isNotEmpty ? user.nickname : '去野探索者',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              if (user.verified) ...[const SizedBox(width: 4), const Icon(Icons.verified, size: 18, color: Color(0xFF2196F3))],
            ],
          ),
          const SizedBox(height: 4),
          if (user.bio != null && user.bio!.isNotEmpty)
            Text(user.bio!, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          const SizedBox(height: 16),
          // 统计数据
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statItem('${user.tripCount}', '行程'),
              _statItem('${user.totalDistanceKm}', '公里'),
              _statItem('${user.badges.length}', '勋章'),
              _statItem(DateTime.now().difference(user.joinDate).inDays.toString(), '天'),
            ],
          ),
          const SizedBox(height: 16),
          // 编辑资料
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: sceneColor),
              foregroundColor: sceneColor,
              minimumSize: const Size(100, 36),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('编辑资料', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _buildCollectionsRow(AuthProvider auth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _collectionCard('🚗', '车库', '${auth.user.vehicleIds.length}辆')),
          const SizedBox(width: 12),
          Expanded(child: _collectionCard('🎒', '装备墙', '查看')),
          const SizedBox(width: 12),
          Expanded(child: _collectionCard('🏅', '勋章墙', '${auth.user.badges.length}枚')),
        ],
      ),
    );
  }

  Widget _collectionCard(String emoji, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.divider, width: 0.5),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textAux)),
        ],
      ),
    );
  }

  Widget _buildTripCard(RouteModel trip, Color sceneColor) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(trip.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: ScenarioConfig.of(trip.scenario).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(ScenarioConfig.of(trip.scenario).label,
                    style: TextStyle(fontSize: 11, color: ScenarioConfig.of(trip.scenario).primaryColor)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('${trip.formatDate} · ${trip.formatDistance} · ${trip.formatDuration}',
              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            if (trip.moodTag != null) ...[
              const SizedBox(height: 4),
              Text(trip.moodTag!, style: TextStyle(fontSize: 12, color: sceneColor)),
            ],
          ],
        ),
      ),
    );
  }
}

// ===== 设置页 =====
class _SettingsPage extends StatelessWidget {
  final Color sceneColor;
  final UserModel user;
  const _SettingsPage({required this.sceneColor, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryBg,
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('通知', [
            _switchItem('新消息推送', true),
            _switchItem('SOS 提醒', true),
          ]),
          _section('GPS 与记录', [
            _optionItem('轨迹记录间隔', '3秒'),
            _switchItem('后台保活追踪', true),
          ]),
          _section('数据', [
            _optionItem('清理缓存', '128MB'),
            _optionItem('导出轨迹数据', 'GPX'),
          ]),
          _section('隐私', [
            _switchItem('允许抓取位置', true),
            _switchItem('数据共享给队友', false),
          ]),
          _section('工具', [
            ListTile(
              title: const Text('离线地图', style: TextStyle(fontSize: 14)),
              leading: const Icon(Icons.map_outlined, size: 20, color: AppTheme.textSecondary),
              trailing: const Icon(Icons.chevron_right, size: 18, color: AppTheme.textAux),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const OfflineMapsPage()));
              },
              shape: const RoundedRectangleBorder(),
            ),
          ]),
          _section('关于', [
            _optionItem('版本', '2.0.0-beta'),
            _optionItem('用户协议', ''),
            _optionItem('隐私政策', ''),
            _optionItem('意见反馈', ''),
            _optionItem('开源许可', ''),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            height: 44,
            child: OutlinedButton(
              onPressed: () {
                context.read<AuthProvider>().logout();
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.warning),
                foregroundColor: AppTheme.warning,
              ),
              child: const Text('退出登录'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 0, 8),
          child: Text(title, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        ),
        Card(
          child: Column(children: items.map((w) => w).toList()),
        ),
      ],
    );
  }

  Widget _switchItem(String title, bool value) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: Switch(value: value, onChanged: (_) {}, activeColor: sceneColor),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _optionItem(String title, String subtitle) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(subtitle, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          if (subtitle.isEmpty) const SizedBox(width: 0) else const SizedBox(width: 4),
          if (subtitle.isEmpty) const SizedBox.shrink() else const Icon(Icons.chevron_right, size: 18, color: AppTheme.textAux),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      onTap: () {},
      shape: const RoundedRectangleBorder(),
    );
  }
}

List<RouteModel> _mockTrips() => [
  RouteModel(
    id: 't1', name: '周末环西湖骑行', scenario: OutdoorScenario.cycle,
    difficulty: 2, distanceKm: 45.3, durationMinutes: 180,
    startTime: DateTime.now().subtract(const Duration(days: 7)),
    endTime: DateTime.now().subtract(const Duration(days: 7, hours: 3)),
    tags: const ['休闲', '城市'], moodTag: '#心情不错',
  ),
  RouteModel(
    id: 't2', name: '徽杭古道摩旅', scenario: OutdoorScenario.moto,
    difficulty: 3, distanceKm: 280, durationMinutes: 480,
    startTime: DateTime.now().subtract(const Duration(days: 14)),
    tags: const ['古道', '长途'],
    associatedMusic: 'Take Me Home, Country Roads',
  ),
];
